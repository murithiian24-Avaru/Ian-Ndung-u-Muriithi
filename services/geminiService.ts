import { GoogleGenAI } from "@google/genai";
import { TransactionCategory } from "../types";

const apiKey = process.env.API_KEY || '';
const ai = new GoogleGenAI({ apiKey });
const MODEL_ID = "gemini-2.5-flash";

async function callGemini<T>(
  contents: string | { parts: Array<{ text?: string; inlineData?: { mimeType: string; data: string } }> },
  fallback: T
): Promise<T> {
  if (!apiKey) return fallback;

  try {
    const response = await ai.models.generateContent({
      model: MODEL_ID,
      contents,
      config: { responseMimeType: "application/json" },
    });
    return JSON.parse(response.text || "{}");
  } catch (error) {
    console.error("Gemini API call failed", error);
    return fallback;
  }
}

export const analyzeRequest = async (
  text: string,
  imageUrl?: string
): Promise<{ recommendation: string; category: TransactionCategory; confidence: number; summary: string }> => {
  const prompt = `
    You are a financial trust assistant for 'The Haven', an app for the Kenyan diaspora.
    Analyze this funding request from a family member in Kenya.
    
    Request Text: "${text}"
    ${imageUrl ? "An image (receipt/invoice) is attached." : "No image attached."}

    Determine:
    1. The most likely category (Rent, School Fees, Shopping, Utilities, Healthcare, Personal Allowance, Emergency Release).
    2. A confidence score (0-100).
    3. A recommendation (Approve/Reject/Verify More) based on tone and clarity.
    4. A brief summary of what the money is for.

    Return JSON.
  `;

  const fallback = {
    recommendation: apiKey ? "Manual Review Needed" : "API Key missing. Cannot analyze.",
    category: TransactionCategory.GENERAL,
    confidence: 0,
    summary: apiKey ? "Could not analyze request automatically." : "Simulated analysis: Looks like a valid request.",
  };

  const raw = await callGemini<Record<string, unknown>>(prompt, fallback as unknown as Record<string, unknown>);
  if (raw === (fallback as unknown)) return fallback;

  return {
    recommendation: (raw.recommendation as string) || "Verify",
    category: (raw.category as TransactionCategory) || TransactionCategory.GENERAL,
    confidence: (raw.confidence as number) || 50,
    summary: (raw.summary as string) || "Request analyzed.",
  };
};

export const verifyDocument = async (
  base64Image: string
): Promise<{ isValid: boolean; extractedAmount: number; merchant: string }> => {
  const fallback = { isValid: apiKey ? false : true, extractedAmount: 0, merchant: apiKey ? "Error" : "Unknown" };

  const contents = {
    parts: [
      { inlineData: { mimeType: "image/jpeg", data: base64Image } },
      { text: "Extract the total amount and merchant name from this receipt/invoice. Determine if it looks authentic. Return JSON: { isValid: boolean, amount: number, merchant: string }" },
    ],
  };

  const raw = await callGemini<Record<string, unknown>>(contents, fallback as unknown as Record<string, unknown>);
  if (raw === (fallback as unknown)) return fallback;

  return {
    isValid: (raw.isValid as boolean) ?? false,
    extractedAmount: (raw.amount as number) ?? 0,
    merchant: (raw.merchant as string) ?? "Unknown",
  };
};

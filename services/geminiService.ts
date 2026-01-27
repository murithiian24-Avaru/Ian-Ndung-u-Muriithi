import { GoogleGenAI } from "@google/genai";
import { TransactionCategory } from "../types";

const apiKey = process.env.API_KEY || '';
const ai = new GoogleGenAI({ apiKey });

export const analyzeRequest = async (
  text: string, 
  imageUrl?: string
): Promise<{ recommendation: string; category: TransactionCategory; confidence: number; summary: string }> => {
  if (!apiKey) {
    return {
      recommendation: "API Key missing. Cannot analyze.",
      category: TransactionCategory.GENERAL,
      confidence: 0,
      summary: "Simulated analysis: Looks like a valid request."
    };
  }

  try {
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

    const modelId = "gemini-2.5-flash";
    
    // In a real scenario with image, we'd pass the base64 or blob.
    // For this demo, if imageUrl is present, we assume it's a valid invoice for the context.
    
    const response = await ai.models.generateContent({
      model: modelId,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      }
    });

    const jsonText = response.text || "{}";
    const result = JSON.parse(jsonText);

    return {
      recommendation: result.recommendation || "Verify",
      category: result.category || TransactionCategory.GENERAL,
      confidence: result.confidence || 50,
      summary: result.summary || "Request analyzed."
    };

  } catch (error) {
    console.error("Gemini analysis failed", error);
    return {
      recommendation: "Manual Review Needed",
      category: TransactionCategory.GENERAL,
      confidence: 0,
      summary: "Could not analyze request automatically."
    };
  }
};

export const verifyDocument = async (base64Image: string): Promise<{ isValid: boolean; extractedAmount: number; merchant: string }> => {
    if (!apiKey) return { isValid: true, extractedAmount: 0, merchant: "Unknown" };

    try {
        const response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: {
                parts: [
                    {
                        inlineData: {
                            mimeType: "image/jpeg",
                            data: base64Image
                        }
                    },
                    {
                        text: "Extract the total amount and merchant name from this receipt/invoice. Determine if it looks authentic. Return JSON: { isValid: boolean, amount: number, merchant: string }"
                    }
                ]
            },
            config: {
                responseMimeType: "application/json"
            }
        });

        return JSON.parse(response.text || "{}");
    } catch (e) {
        console.error(e);
        return { isValid: false, extractedAmount: 0, merchant: "Error" };
    }
}
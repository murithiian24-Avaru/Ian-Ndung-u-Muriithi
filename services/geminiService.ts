import { GoogleGenAI } from "@google/genai";
import { TransactionCategory } from "../types";

const apiKey = process.env.API_KEY || '';
const ai = new GoogleGenAI({ apiKey });

export interface AnalysisResult {
  recommendation: string;
  category: TransactionCategory;
  confidence: number;
  summary: string;
  error?: string;
}

export const analyzeRequest = async (
  text: string, 
  imageUrl?: string
): Promise<AnalysisResult> => {
  if (!apiKey) {
    return {
      recommendation: "Manual Review Needed",
      category: TransactionCategory.GENERAL,
      confidence: 0,
      summary: "Automatic analysis unavailable.",
      error: "API key is not configured. Please set the GEMINI_API_KEY environment variable."
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
    
    const response = await ai.models.generateContent({
      model: modelId,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
      }
    });

    const jsonText = response.text;
    if (!jsonText) {
      return {
        recommendation: "Manual Review Needed",
        category: TransactionCategory.GENERAL,
        confidence: 0,
        summary: "Analysis returned an empty response.",
        error: "The AI model returned an empty response. Please try again."
      };
    }

    let result: Record<string, unknown>;
    try {
      result = JSON.parse(jsonText);
    } catch (parseError) {
      return {
        recommendation: "Manual Review Needed",
        category: TransactionCategory.GENERAL,
        confidence: 0,
        summary: "Analysis returned an unparseable response.",
        error: "Failed to parse AI response. Please try again."
      };
    }

    return {
      recommendation: (result.recommendation as string) || "Verify",
      category: (result.category as TransactionCategory) || TransactionCategory.GENERAL,
      confidence: (result.confidence as number) || 50,
      summary: (result.summary as string) || "Request analyzed."
    };

  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    console.error("Gemini analysis failed:", message);
    return {
      recommendation: "Manual Review Needed",
      category: TransactionCategory.GENERAL,
      confidence: 0,
      summary: "Could not analyze request automatically.",
      error: `Analysis failed: ${message}`
    };
  }
};

export interface VerifyDocumentResult {
  isValid: boolean;
  extractedAmount: number;
  merchant: string;
  error?: string;
}

export const verifyDocument = async (base64Image: string): Promise<VerifyDocumentResult> => {
    if (!apiKey) {
        return {
            isValid: false,
            extractedAmount: 0,
            merchant: "Unknown",
            error: "API key is not configured. Document could not be verified."
        };
    }

    if (!base64Image) {
        return {
            isValid: false,
            extractedAmount: 0,
            merchant: "Unknown",
            error: "No image data provided for verification."
        };
    }

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

        const jsonText = response.text;
        if (!jsonText) {
            return {
                isValid: false,
                extractedAmount: 0,
                merchant: "Unknown",
                error: "Document verification returned an empty response."
            };
        }

        let result: Record<string, unknown>;
        try {
            result = JSON.parse(jsonText);
        } catch (parseError) {
            return {
                isValid: false,
                extractedAmount: 0,
                merchant: "Unknown",
                error: "Failed to parse verification response."
            };
        }

        return {
            isValid: Boolean(result.isValid),
            extractedAmount: Number(result.amount) || 0,
            merchant: (result.merchant as string) || "Unknown"
        };
    } catch (e) {
        const message = e instanceof Error ? e.message : "Unknown error";
        console.error("Document verification failed:", message);
        return {
            isValid: false,
            extractedAmount: 0,
            merchant: "Unknown",
            error: `Document verification failed: ${message}`
        };
    }
}
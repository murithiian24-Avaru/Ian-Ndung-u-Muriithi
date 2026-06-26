import { describe, it, expect, vi } from 'vitest';
import { TransactionCategory } from '../types';

vi.mock('@google/genai', () => {
  return {
    GoogleGenAI: vi.fn().mockImplementation(function () {
      return {
        models: {
          generateContent: vi.fn(),
        },
      };
    }),
  };
});

// Import after the mock is set up
import { analyzeRequest, verifyDocument } from './geminiService';

describe('geminiService', () => {
  describe('analyzeRequest', () => {
    it('returns fallback result when API key is missing', async () => {
      const result = await analyzeRequest('Need money for groceries');

      expect(result).toHaveProperty('recommendation');
      expect(result).toHaveProperty('category');
      expect(result).toHaveProperty('confidence');
      expect(result).toHaveProperty('summary');
      expect(typeof result.recommendation).toBe('string');
      expect(typeof result.confidence).toBe('number');
    });

    it('returns fallback result with correct structure when image URL is provided', async () => {
      const result = await analyzeRequest('School fees payment', 'https://example.com/receipt.jpg');

      expect(result).toHaveProperty('recommendation');
      expect(result).toHaveProperty('category');
      expect(result).toHaveProperty('confidence');
      expect(result).toHaveProperty('summary');
    });

    it('returns a result object with valid category', async () => {
      const result = await analyzeRequest('Emergency medical bill');

      expect(Object.values(TransactionCategory)).toContain(result.category);
    });

    it('handles empty input text', async () => {
      const result = await analyzeRequest('');

      expect(typeof result.recommendation).toBe('string');
      expect(typeof result.confidence).toBe('number');
      expect(typeof result.summary).toBe('string');
    });
  });

  describe('verifyDocument', () => {
    it('returns a result with correct structure', async () => {
      const result = await verifyDocument('base64encodedimage');

      expect(result).toHaveProperty('isValid');
      expect(result).toHaveProperty('extractedAmount');
      expect(result).toHaveProperty('merchant');
    });

    it('returns valid types for all fields', async () => {
      const result = await verifyDocument('');

      expect(typeof result.isValid).toBe('boolean');
      expect(typeof result.extractedAmount).toBe('number');
      expect(typeof result.merchant).toBe('string');
    });
  });
});

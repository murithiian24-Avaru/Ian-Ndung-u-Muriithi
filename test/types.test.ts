import { describe, it, expect } from 'vitest';
import {
  TransactionCategory,
  RecipientStatus,
  RequestStatus,
} from '../types';

describe('TransactionCategory enum', () => {
  it('has all expected category values', () => {
    expect(TransactionCategory.RENT).toBe('Rent');
    expect(TransactionCategory.SCHOOL_FEES).toBe('School Fees');
    expect(TransactionCategory.SHOPPING).toBe('Shopping');
    expect(TransactionCategory.UTILITIES).toBe('Utilities');
    expect(TransactionCategory.HEALTHCARE).toBe('Healthcare');
    expect(TransactionCategory.ALLOWANCE).toBe('Personal Allowance');
    expect(TransactionCategory.EMERGENCY).toBe('Emergency Release');
    expect(TransactionCategory.GENERAL).toBe('General');
  });

  it('contains exactly 8 categories', () => {
    const values = Object.values(TransactionCategory);
    expect(values).toHaveLength(8);
  });
});

describe('RecipientStatus enum', () => {
  it('has all expected status values', () => {
    expect(RecipientStatus.VERIFIED).toBe('Verified');
    expect(RecipientStatus.PENDING).toBe('Pending Verification');
    expect(RecipientStatus.REJECTED).toBe('Rejected');
  });

  it('contains exactly 3 statuses', () => {
    const values = Object.values(RecipientStatus);
    expect(values).toHaveLength(3);
  });
});

describe('RequestStatus enum', () => {
  it('has all expected status values', () => {
    expect(RequestStatus.PENDING).toBe('Pending');
    expect(RequestStatus.APPROVED).toBe('Approved');
    expect(RequestStatus.REJECTED).toBe('Rejected');
    expect(RequestStatus.PAID).toBe('Paid');
  });

  it('contains exactly 4 statuses', () => {
    const values = Object.values(RequestStatus);
    expect(values).toHaveLength(4);
  });
});

export enum TransactionCategory {
  RENT = 'Rent',
  SCHOOL_FEES = 'School Fees',
  SHOPPING = 'Shopping',
  UTILITIES = 'Utilities',
  HEALTHCARE = 'Healthcare',
  ALLOWANCE = 'Personal Allowance',
  EMERGENCY = 'Emergency Release',
  GENERAL = 'General'
}

export enum RecipientStatus {
  VERIFIED = 'Verified',
  PENDING = 'Pending Verification',
  REJECTED = 'Rejected'
}

export enum RequestStatus {
  PENDING = 'Pending',
  APPROVED = 'Approved',
  REJECTED = 'Rejected',
  PAID = 'Paid'
}

export interface Recipient {
  id: string;
  name: string;
  relation: string; // e.g., "Mother", "Landlord", "School Bursar"
  type: 'Family' | 'Service Provider' | 'Institution';
  phone: string; // M-Pesa
  status: RecipientStatus;
  trustScore: number; // 0-100
  documents?: string[]; // URLs to ID proofs
}

export interface Transaction {
  id: string;
  date: string;
  amount: number;
  recipientId: string;
  recipientName: string;
  category: TransactionCategory;
  proofUrl?: string; // Receipt image
  verified: boolean;
  description: string;
}

export interface FundRequest {
  id: string;
  requesterId: string;
  requesterName: string;
  amount: number;
  category: TransactionCategory;
  reason: string;
  status: RequestStatus;
  attachmentUrl?: string; // Bill or Invoice
  date: string;
  aiAnalysis?: string; // Gemini analysis of the request/attachment
}

export interface Wallet {
  balance: number;
  currency: string;
  allocated: Record<TransactionCategory, number>;
}
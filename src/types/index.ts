export type SplitMode = 'native';

export interface PaymentSlice {
  id: string;
  sliceNumber: number;
  totalSlices: number;
  amount: number;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  upiUri: string;
  appSpecificUris: {
    gpay: string;
    phonepe: string;
    paytm: string;
    bhim: string;
    cred: string;
  };
  txnRef: string;
  utr?: string;
  rrn?: string;
  timestamp?: number;
  latencyMs?: number;
  failureReason?: string;
}

export interface BankAccount {
  id: string;
  bankName: string;
  bankCode: 'HDFC' | 'SBI' | 'ICICI' | 'AXIS';
  accountNumberMasked: string;
  accountType: 'Savings' | 'Current';
  balance: number;
  vpa: string;
  isDefault: boolean;
  color: string;
  accentColor: string;
  mpinLength: 4 | 6;
}

export interface UpiEngineLog {
  id: string;
  timestamp: string;
  step: 'AUTH' | 'SWITCH' | 'DEBIT' | 'CREDIT' | 'SETTLED' | 'ERROR';
  message: string;
  sliceNumber?: number;
  utr?: string;
  latencyMs?: number;
}

export interface SplitPlan {
  totalAmount: number;
  vpa: string;
  payeeName: string;
  note: string;
  thresholdLimit: number;
  slices: PaymentSlice[];
  mode: SplitMode;
  estimatedFeeSavings: number;
  createdAt: number;
  selectedAccountId?: string;
  debitAccountMasked?: string;
}
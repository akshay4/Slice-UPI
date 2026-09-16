export type SplitMode = 'intent' | 'escrow';

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
  timestamp?: number;
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
}

export interface EscrowMandate {
  mandateId: string;
  totalAmount: number;
  authorized: boolean;
  status: 'initiated' | 'authorized' | 'dispersing' | 'completed';
  scheduledPayouts: {
    payoutId: string;
    amount: number;
    delaySeconds: number;
    status: 'scheduled' | 'sent' | 'settled';
    dispatchedAt?: string;
  }[];
}
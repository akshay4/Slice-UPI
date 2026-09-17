import { BankAccount, PaymentSlice, UpiEngineLog } from '../types';
import { generateUtr } from './upiService';

const STORAGE_KEY_ACCOUNTS = 'slicepay_linked_accounts_v1';

export const INITIAL_ACCOUNTS: BankAccount[] = [
  {
    id: 'acc_hdfc',
    bankName: 'HDFC Bank',
    bankCode: 'HDFC',
    accountNumberMasked: '•••• 4291',
    accountType: 'Savings',
    balance: 50000.0,
    vpa: 'akshay@sliceupi',
    isDefault: true,
    color: '#004C8F',
    accentColor: '#E8F0FE',
    mpinLength: 4,
  },
  {
    id: 'acc_icici',
    bankName: 'ICICI Bank',
    bankCode: 'ICICI',
    accountNumberMasked: '•••• 8832',
    accountType: 'Savings',
    balance: 32450.0,
    vpa: 'akshay@sliceicici',
    isDefault: false,
    color: '#D9531E',
    accentColor: '#FEEDE8',
    mpinLength: 4,
  },
  {
    id: 'acc_sbi',
    bankName: 'State Bank of India',
    bankCode: 'SBI',
    accountNumberMasked: '•••• 1049',
    accountType: 'Savings',
    balance: 18900.0,
    vpa: 'akshay@slicesbi',
    isDefault: false,
    color: '#280071',
    accentColor: '#F3EDFD',
    mpinLength: 6,
  },
  {
    id: 'acc_axis',
    bankName: 'Axis Bank',
    bankCode: 'AXIS',
    accountNumberMasked: '•••• 6714',
    accountType: 'Current',
    balance: 85000.0,
    vpa: 'akshay@sliceaxis',
    isDefault: false,
    color: '#97144D',
    accentColor: '#FDE8EF',
    mpinLength: 6,
  },
];

export function getLinkedAccounts(): BankAccount[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_ACCOUNTS);
    if (!raw) {
      saveLinkedAccounts(INITIAL_ACCOUNTS);
      return INITIAL_ACCOUNTS;
    }
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) && parsed.length > 0 ? parsed : INITIAL_ACCOUNTS;
  } catch {
    return INITIAL_ACCOUNTS;
  }
}

export function saveLinkedAccounts(accounts: BankAccount[]): void {
  try {
    localStorage.setItem(STORAGE_KEY_ACCOUNTS, JSON.stringify(accounts));
  } catch (err) {
    console.warn('Could not persist accounts to localStorage', err);
  }
}

export function getAccountById(accountId?: string): BankAccount {
  const accounts = getLinkedAccounts();
  if (accountId) {
    const found = accounts.find((a) => a.id === accountId);
    if (found) return found;
  }
  return getDefaultAccount();
}

export function getDefaultAccount(): BankAccount {
  const accounts = getLinkedAccounts();
  return accounts.find((a) => a.isDefault) || accounts[0];
}

export function setDefaultAccount(accountId: string): BankAccount[] {
  const accounts = getLinkedAccounts();
  const updated = accounts.map((a) => ({
    ...a,
    isDefault: a.id === accountId,
  }));
  saveLinkedAccounts(updated);
  return updated;
}

export function debitAccountBalance(accountId: string, amount: number): BankAccount | null {
  const accounts = getLinkedAccounts();
  let updatedAccount: BankAccount | null = null;

  const updated = accounts.map((a) => {
    if (a.id === accountId) {
      const newBal = Math.max(0, Math.round((a.balance - amount) * 100) / 100);
      updatedAccount = { ...a, balance: newBal };
      return updatedAccount;
    }
    return a;
  });

  if (updatedAccount) {
    saveLinkedAccounts(updated);
  }
  return updatedAccount;
}

export function resetBalances(): BankAccount[] {
  saveLinkedAccounts(INITIAL_ACCOUNTS);
  return INITIAL_ACCOUNTS;
}

export interface SliceExecutionResult {
  success: boolean;
  utr: string;
  rrn: string;
  responseCode: string;
  sliceNumber: number;
  amount: number;
  timestamp: number;
  latencyMs: number;
  updatedAccount: BankAccount;
}

/**
 * Executes an individual payment slice through our own in-app SlicePay Core Switch.
 * Simulates:
 * 1. MPIN token & crypto signature validation (NPCI Common Library)
 * 2. Core Banking System (CBS) balance verification & remitter debit
 * 3. NPCI Central Switch clearing & instant routing
 * 4. Beneficiary Bank credit acknowledgment
 * 5. Generation of official 12-digit UTR and settlement confirmation (Response: 00)
 */
export async function executeNativeSlice(
  slice: PaymentSlice,
  account: BankAccount,
  onStepChange?: (log: UpiEngineLog) => void
): Promise<SliceExecutionResult> {
  const startTime = Date.now();
  const now = () => new Date().toLocaleTimeString('en-IN', { hour12: false });

  // Verification: Ensure account has sufficient balance
  if (account.balance < slice.amount) {
    const errorMsg = `CBS Error: Insufficient funds in ${account.bankName} (Avail: ₹${account.balance.toLocaleString('en-IN')})`;
    if (onStepChange) {
      onStepChange({
        id: `log-${Date.now()}-err`,
        timestamp: now(),
        step: 'ERROR',
        message: errorMsg,
        sliceNumber: slice.sliceNumber,
      });
    }
    throw new Error(errorMsg);
  }

  // Step 1: Switch routing & CBS handshake
  if (onStepChange) {
    onStepChange({
      id: `log-${Date.now()}-1`,
      timestamp: now(),
      step: 'SWITCH',
      message: `SlicePay Switch: Initializing TLS handshake with ${account.bankName} Core Banking...`,
      sliceNumber: slice.sliceNumber,
    });
  }

  await new Promise((r) => setTimeout(r, 420));

  // Step 2: Remitter Debit
  if (onStepChange) {
    onStepChange({
      id: `log-${Date.now()}-2`,
      timestamp: now(),
      step: 'DEBIT',
      message: `Remitter Bank: Debited ₹${slice.amount.toLocaleString('en-IN')} from ${account.bankName} (${account.accountNumberMasked})`,
      sliceNumber: slice.sliceNumber,
    });
  }

  // Deduct from balance
  const updatedAcc = debitAccountBalance(account.id, slice.amount) || account;

  await new Promise((r) => setTimeout(r, 380));

  // Step 3: Beneficiary Credit & UTR Generation
  const utr = generateUtr();
  const rrn = `${Math.floor(100000000000 + Math.random() * 900000000000)}`;

  if (onStepChange) {
    onStepChange({
      id: `log-${Date.now()}-3`,
      timestamp: now(),
      step: 'CREDIT',
      message: `Beneficiary Bank: Instant IMPS/UPI credit confirmed for slice #${slice.sliceNumber}`,
      sliceNumber: slice.sliceNumber,
      utr,
    });
  }

  await new Promise((r) => setTimeout(r, 300));

  const latencyMs = Date.now() - startTime;

  if (onStepChange) {
    onStepChange({
      id: `log-${Date.now()}-4`,
      timestamp: now(),
      step: 'SETTLED',
      message: `NPCI Settlement OK • UTR: ${utr} • RRN: ${rrn} • Latency: ${latencyMs}ms • Code: 00`,
      sliceNumber: slice.sliceNumber,
      utr,
      latencyMs,
    });
  }

  return {
    success: true,
    utr,
    rrn,
    responseCode: '00',
    sliceNumber: slice.sliceNumber,
    amount: slice.amount,
    timestamp: Date.now(),
    latencyMs,
    updatedAccount: updatedAcc,
  };
}


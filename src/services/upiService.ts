import { PaymentSlice, SplitPlan } from '../types';

export interface ParsedUpiData {
  vpa: string;
  payeeName?: string;
  amount?: number;
  note?: string;
}

export function generateTxnRef(prefix = 'TXN'): string {
  const rand = Math.random().toString(36).substring(2, 8).toUpperCase();
  const time = Date.now().toString().slice(-6);
  return `${prefix}${time}${rand}`;
}

export function generateUtr(): string {
  // NPCI standard 12-digit UTR: [Last Digit of Year][3-digit Day of Year][8 random digits]
  const now = new Date();
  const yearDigit = now.getFullYear().toString().slice(-1);
  const startOfYear = new Date(now.getFullYear(), 0, 0);
  const diff = now.getTime() - startOfYear.getTime();
  const oneDay = 1000 * 60 * 60 * 24;
  const dayOfYear = Math.floor(diff / oneDay).toString().padStart(3, '0');
  const rand8 = Math.floor(10000000 + Math.random() * 90000000).toString();
  return `${yearDigit}${dayOfYear}${rand8}`;
}

export function buildUpiUri(params: {
  pa: string;
  pn: string;
  am: number;
  tn?: string;
  tr: string;
}): string {
  const encodedPa = encodeURIComponent(params.pa.trim());
  const encodedPn = encodeURIComponent(params.pn.trim() || 'Beneficiary');
  const amountStr = params.am.toFixed(2);
  const encodedTn = encodeURIComponent(params.tn || 'Smart Split Payment');
  const encodedTr = encodeURIComponent(params.tr);

  return `upi://pay?pa=${encodedPa}&pn=${encodedPn}&am=${amountStr}&cu=INR&tn=${encodedTn}&tr=${encodedTr}`;
}

export function buildAppSpecificUris(baseUri: string) {
  const query = baseUri.replace('upi://pay?', '');
  return {
    gpay: `tez://upi/pay?${query}`,
    phonepe: `phonepe://upi/pay?${query}`,
    paytm: `paytmmp://upi/pay?${query}`,
    bhim: `bhim://pay?${query}`,
    cred: `cred://upi/pay?${query}`,
  };
}

export function parseUpiUri(raw: string): ParsedUpiData | null {
  if (!raw) return null;
  const trimmed = raw.trim();

  // Handle standard upi://pay?...
  if (trimmed.toLowerCase().startsWith('upi://pay')) {
    try {
      const qIndex = trimmed.indexOf('?');
      if (qIndex === -1) return null;
      const searchParams = new URLSearchParams(trimmed.slice(qIndex + 1));
      const pa = searchParams.get('pa');
      if (!pa) return null;

      const pn = searchParams.get('pn');
      const am = searchParams.get('am');
      const tn = searchParams.get('tn');

      return {
        vpa: decodeURIComponent(pa),
        payeeName: pn ? decodeURIComponent(pn) : undefined,
        amount: am && !isNaN(parseFloat(am)) ? parseFloat(am) : undefined,
        note: tn ? decodeURIComponent(tn) : undefined,
      };
    } catch {
      return null;
    }
  }

  // Handle direct VPA like name@bank
  if (trimmed.includes('@') && !trimmed.includes(' ')) {
    return {
      vpa: trimmed,
    };
  }

  // Handle 10-digit mobile number
  const cleanDigits = trimmed.replace(/\D/g, '');
  if (cleanDigits.length === 10) {
    return {
      vpa: `${cleanDigits}@upi`,
      payeeName: `Contact (${cleanDigits})`,
    };
  }

  return null;
}

export function formatMobileToVpa(mobile: string, handle = 'upi'): string {
  const digits = mobile.replace(/\D/g, '');
  if (digits.length >= 10) {
    const last10 = digits.slice(-10);
    return `${last10}@${handle}`;
  }
  return mobile;
}

/**
 * Calculates payment slices strictly enforcing:
 * - If amount >= 2000, it splits into sub-₹2,000 tranches to eliminate surcharge and bank cooling caps
 * - If amount < 2000, it processes as a single direct tranche unless custom threshold is configured below 2000
 */
export function calculateSlices(
  totalAmount: number,
  vpa: string,
  payeeName: string,
  note: string,
  threshold = 1990,
  randomizeJitter = false
): PaymentSlice[] {
  if (totalAmount <= 0) return [];

  // Effective ceiling limit: strictly below ₹2,000 when totalAmount >= 2000
  const effectiveThreshold = totalAmount >= 2000 ? Math.min(threshold, 1990) : threshold;

  const rawSlices: number[] = [];

  // If amount is strictly less than 2,000 rupees: 1 single direct slice (no surcharge applies)
  if (totalAmount < 2000) {
    rawSlices.push(Math.round(totalAmount * 100) / 100);
  } else {
    // Amount is >= 2,000 rupees: split into sub-₹2,000 tranches
    let remaining = totalAmount;

    while (remaining > 0) {
      if (remaining <= effectiveThreshold) {
        rawSlices.push(Math.round(remaining * 100) / 100);
        break;
      }

      let sliceAmount = effectiveThreshold;
      if (randomizeJitter) {
        const jitter = Math.floor(Math.random() * 30) - 15;
        sliceAmount = Math.max(500, Math.min(effectiveThreshold, effectiveThreshold + jitter));
      }

      // Smooth out the remainder so the last slice isn't a micro-fragment (e.g., < ₹100)
      if (remaining - sliceAmount < 100 && remaining > sliceAmount) {
        sliceAmount = Math.floor(remaining / 2);
      }

      sliceAmount = Math.round(sliceAmount * 100) / 100;
      rawSlices.push(sliceAmount);
      remaining = Math.round((remaining - sliceAmount) * 100) / 100;
    }
  }

  const totalSlices = rawSlices.length;

  return rawSlices.map((amount, idx) => {
    const sliceNumber = idx + 1;
    const txnRef = generateTxnRef(`SP${sliceNumber}`);
    const sliceNote = totalSlices > 1
      ? `${note ? note + ' ' : ''}[Part ${sliceNumber}/${totalSlices}]`
      : (note || 'SliceUPI Direct Transfer');
    const upiUri = buildUpiUri({
      pa: vpa,
      pn: payeeName,
      am: amount,
      tn: sliceNote,
      tr: txnRef,
    });

    return {
      id: `slice-${Date.now()}-${sliceNumber}`,
      sliceNumber,
      totalSlices,
      amount,
      status: 'pending' as const,
      upiUri,
      appSpecificUris: buildAppSpecificUris(upiUri),
      txnRef,
      utr: undefined,
    };
  });
}

export function createPlan(
  totalAmount: number,
  vpa: string,
  payeeName: string,
  note: string,
  threshold = 1990,
  randomizeJitter = false,
  selectedAccountId?: string,
  debitAccountMasked?: string
): SplitPlan {
  const slices = calculateSlices(totalAmount, vpa, payeeName, note, threshold, randomizeJitter);
  const estimatedFeeSavings = totalAmount >= 2000 ? Math.round(totalAmount * 0.011) : 0;

  return {
    totalAmount,
    vpa,
    payeeName,
    note,
    thresholdLimit: threshold,
    slices,
    mode: 'native',
    estimatedFeeSavings,
    createdAt: Date.now(),
    selectedAccountId,
    debitAccountMasked,
  };
}
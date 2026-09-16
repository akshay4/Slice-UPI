import { PaymentSlice, SplitPlan, SplitMode } from '../types';

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

export function calculateSlices(
  totalAmount: number,
  vpa: string,
  payeeName: string,
  note: string,
  threshold = 1990,
  randomizeJitter = false
): PaymentSlice[] {
  if (totalAmount <= 0) return [];

  const rawSlices: number[] = [];
  let remaining = totalAmount;

  while (remaining > 0) {
    if (remaining <= threshold) {
      rawSlices.push(Math.round(remaining * 100) / 100);
      break;
    }

    let sliceAmount = threshold;
    if (randomizeJitter) {
      const jitter = Math.floor(Math.random() * 30) - 15;
      sliceAmount = Math.max(500, Math.min(threshold, threshold + jitter));
    }

    if (remaining - sliceAmount < 100 && remaining > sliceAmount) {
      sliceAmount = Math.floor(remaining / 2);
    }

    sliceAmount = Math.round(sliceAmount * 100) / 100;
    rawSlices.push(sliceAmount);
    remaining = Math.round((remaining - sliceAmount) * 100) / 100;
  }

  const totalSlices = rawSlices.length;

  return rawSlices.map((amount, idx) => {
    const sliceNumber = idx + 1;
    const txnRef = generateTxnRef(`SP${sliceNumber}`);
    const sliceNote = `${note ? note + ' ' : ''}[Part ${sliceNumber}/${totalSlices}]`;
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
    };
  });
}

export function createPlan(
  totalAmount: number,
  vpa: string,
  payeeName: string,
  note: string,
  mode: SplitMode,
  threshold = 1990,
  randomizeJitter = false
): SplitPlan {
  const slices = calculateSlices(totalAmount, vpa, payeeName, note, threshold, randomizeJitter);
  const estimatedFeeSavings = totalAmount > 2000 ? Math.round(totalAmount * 0.011) : 0;

  return {
    totalAmount,
    vpa,
    payeeName,
    note,
    thresholdLimit: threshold,
    slices,
    mode,
    estimatedFeeSavings,
    createdAt: Date.now(),
  };
}
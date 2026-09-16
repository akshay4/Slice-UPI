import React, { useState } from 'react';
import { QrCode, ArrowRight, CheckCircle2, ChevronDown, ChevronUp, Sparkles, Shield, Smartphone, AtSign } from 'lucide-react';
import { ModeSelector } from './ModeSelector';
import { QrScannerModal } from './QrScannerModal';
import { SplitMode, SplitPlan } from '../types';
import { createPlan, ParsedUpiData, formatMobileToVpa } from '../services/upiService';

interface Props {
  onPlanCreated: (plan: SplitPlan) => void;
  onOpenCompliance: () => void;
}

type PayeeInputType = 'vpa' | 'phone';

export const SplitCalculator: React.FC<Props> = ({ onPlanCreated, onOpenCompliance }) => {
  const [amount, setAmount] = useState<string>('3500');
  const [payeeType, setPayeeType] = useState<PayeeInputType>('vpa');
  const [vpa, setVpa] = useState<string>('merchantstore@oksbi');
  const [phoneNumber, setPhoneNumber] = useState<string>('9876543210');
  const [phoneHandle, setPhoneHandle] = useState<string>('upi');
  const [payeeName, setPayeeName] = useState<string>('Suresh Electronics');
  const [note, setNote] = useState<string>('Hardware accessories');
  const [mode, setMode] = useState<SplitMode>('intent');
  const [threshold, setThreshold] = useState<number>(1990);
  const [antiAmlJitter, setAntiAmlJitter] = useState<boolean>(true);
  const [showAdvanced, setShowAdvanced] = useState<boolean>(false);
  const [isQrScannerOpen, setIsQrScannerOpen] = useState<boolean>(false);
  const [scanNotice, setScanNotice] = useState<string | null>(null);

  const numAmount = parseFloat(amount) || 0;
  const numSlices = numAmount > 0 ? Math.ceil(numAmount / threshold) : 0;
  const estimatedSavings = numAmount > 2000 ? Math.round(numAmount * 0.011) : 0;

  // Active resolved VPA
  const activeVpa = payeeType === 'phone' ? formatMobileToVpa(phoneNumber, phoneHandle) : vpa.trim();

  const handleGeneratePlan = (e: React.FormEvent) => {
    e.preventDefault();

    if (numAmount <= 0) {
      alert('Please enter a valid amount greater than ₹0');
      return;
    }

    if (payeeType === 'phone') {
      const cleanDigits = phoneNumber.replace(/\D/g, '');
      if (cleanDigits.length < 10) {
        alert('Please enter a valid 10-digit mobile number');
        return;
      }
    } else {
      if (!vpa.includes('@')) {
        alert('Please enter a valid UPI ID (e.g. name@bank)');
        return;
      }
    }

    const plan = createPlan(
      numAmount,
      activeVpa,
      payeeName,
      note,
      mode,
      threshold,
      antiAmlJitter
    );
    onPlanCreated(plan);
  };

  const handlePresetAmount = (val: number) => {
    setAmount(val.toString());
  };

  const handleScanSuccess = (data: ParsedUpiData) => {
    setVpa(data.vpa);
    setPayeeType('vpa');

    if (data.payeeName) {
      setPayeeName(data.payeeName);
    }
    if (data.amount && data.amount > 0) {
      setAmount(data.amount.toString());
    }
    if (data.note) {
      setNote(data.note);
    }

    setScanNotice(`QR Code Verified: ${data.payeeName || data.vpa}`);
    setTimeout(() => setScanNotice(null), 4000);
  };

  return (
    <form onSubmit={handleGeneratePlan} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Google Pay Recipient Header Card */}
      <div
        className="gpay-card"
        style={{
          padding: '16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          {/* Avatar Circle with initials */}
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '50%',
              background: 'linear-gradient(135deg, #1A73E8, #002970)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 700,
              fontSize: '1.1rem',
              boxShadow: '0 2px 6px rgba(26, 115, 232, 0.25)',
              flexShrink: 0,
            }}
          >
            {payeeName ? payeeName.slice(0, 2).toUpperCase() : 'UP'}
          </div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <span style={{ fontWeight: 700, fontSize: '0.95rem', color: '#1F2937' }}>
                {payeeName || 'Recipient'}
              </span>
              <CheckCircle2 size={16} color="#0F9D58" />
            </div>
            <div style={{ fontSize: '0.78rem', color: '#5F6368', marginTop: '1px' }}>
              {activeVpa}
            </div>
          </div>
        </div>

        {/* Scan QR Code Button */}
        <button
          type="button"
          onClick={() => setIsQrScannerOpen(true)}
          className="btn-secondary-gpay"
          style={{ padding: '8px 14px', fontSize: '0.8rem' }}
        >
          <QrCode size={16} />
          <span>Scan QR</span>
        </button>
      </div>

      {/* QR Scan Success Feedback Alert */}
      {scanNotice && (
        <div
          style={{
            background: '#E6F4EA',
            border: '1px solid #CEEAD6',
            borderRadius: 'var(--radius-md)',
            padding: '10px 14px',
            fontSize: '0.82rem',
            color: '#137333',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <CheckCircle2 size={16} color="#0F9D58" />
          <span>{scanNotice}</span>
        </div>
      )}

      {/* Payee Selection Tabs (UPI ID vs Mobile Number) */}
      <div className="gpay-card" style={{ padding: '16px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
          <label style={{ fontSize: '0.78rem', color: '#5F6368', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
            PAYEE DETAILS
          </label>

          {/* Type Toggle Pills */}
          <div style={{ display: 'flex', background: '#F1F3F4', borderRadius: 'var(--radius-pill)', padding: '2px', gap: '2px' }}>
            <button
              type="button"
              onClick={() => setPayeeType('vpa')}
              style={{
                background: payeeType === 'vpa' ? '#FFFFFF' : 'transparent',
                border: 'none',
                borderRadius: 'var(--radius-pill)',
                padding: '4px 10px',
                fontSize: '0.75rem',
                fontWeight: payeeType === 'vpa' ? 700 : 500,
                color: payeeType === 'vpa' ? '#1A73E8' : '#5F6368',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                boxShadow: payeeType === 'vpa' ? '0 1px 2px rgba(0,0,0,0.1)' : 'none',
              }}
            >
              <AtSign size={13} />
              <span>UPI ID</span>
            </button>

            <button
              type="button"
              onClick={() => setPayeeType('phone')}
              style={{
                background: payeeType === 'phone' ? '#FFFFFF' : 'transparent',
                border: 'none',
                borderRadius: 'var(--radius-pill)',
                padding: '4px 10px',
                fontSize: '0.75rem',
                fontWeight: payeeType === 'phone' ? 700 : 500,
                color: payeeType === 'phone' ? '#1A73E8' : '#5F6368',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                boxShadow: payeeType === 'phone' ? '0 1px 2px rgba(0,0,0,0.1)' : 'none',
              }}
            >
              <Smartphone size={13} />
              <span>Mobile No</span>
            </button>
          </div>
        </div>

        {/* Option 1: Direct UPI ID Input */}
        {payeeType === 'vpa' ? (
          <div>
            <input
              type="text"
              value={vpa}
              onChange={(e) => {
                const val = e.target.value;
                // Auto-switch to phone if 10 consecutive digits
                const digits = val.replace(/\D/g, '');
                if (digits.length === 10 && !val.includes('@')) {
                  setPhoneNumber(digits);
                  setPayeeType('phone');
                } else {
                  setVpa(val);
                }
              }}
              placeholder="e.g. merchant@oksbi or mobile@paytm"
              required
              className="gpay-input"
            />
            <div style={{ fontSize: '0.72rem', color: '#80868B', marginTop: '4px' }}>
              Enter any valid Virtual Payment Address (e.g. username@okhdfcbank)
            </div>
          </div>
        ) : (
          /* Option 2: 10-digit Mobile Number Input */
          <div>
            <div style={{ display: 'flex', gap: '6px' }}>
              <div
                style={{
                  background: '#F1F3F4',
                  border: '1px solid #DADCE0',
                  borderRadius: 'var(--radius-md)',
                  padding: '12px',
                  fontSize: '0.95rem',
                  fontWeight: 600,
                  color: '#3C4043',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                }}
              >
                <span>🇮🇳</span>
                <span>+91</span>
              </div>
              <input
                type="tel"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value.replace(/\D/g, '').slice(0, 10))}
                placeholder="10-digit mobile number"
                maxLength={10}
                required
                className="gpay-input"
                style={{ flex: 1, letterSpacing: '0.05em' }}
              />
            </div>

            {/* Quick UPI Handle Selector */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '8px', flexWrap: 'wrap' }}>
              <span style={{ fontSize: '0.72rem', color: '#5F6368', fontWeight: 600 }}>Handle:</span>
              {['upi', 'paytm', 'okhdfcbank', 'okaxis', 'oksbi'].map((h) => (
                <button
                  key={h}
                  type="button"
                  onClick={() => setPhoneHandle(h)}
                  className={`chip-pill ${phoneHandle === h ? 'active' : ''}`}
                  style={{ padding: '2px 8px', fontSize: '0.72rem' }}
                >
                  @{h}
                </button>
              ))}
            </div>
            <div style={{ fontSize: '0.72rem', color: '#0F9D58', marginTop: '4px', fontWeight: 600 }}>
              ✓ Resolving to: {formatMobileToVpa(phoneNumber, phoneHandle)}
            </div>
          </div>
        )}

        {/* Recipient Display Name */}
        <div style={{ marginTop: '12px' }}>
          <label style={{ fontSize: '0.75rem', color: '#5F6368', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
            Payee Name
          </label>
          <input
            type="text"
            value={payeeName}
            onChange={(e) => setPayeeName(e.target.value)}
            placeholder="Recipient / Merchant Name"
            className="gpay-input"
            style={{ fontSize: '0.88rem', padding: '10px 12px' }}
          />
        </div>
      </div>

      {/* Mode Selector (Direct UPI vs AutoPay Mandate) */}
      <ModeSelector mode={mode} onSelectMode={setMode} />

      {/* Main Payment Amount Card (Google Pay signature centered input) */}
      <div className="gpay-card" style={{ padding: '24px 20px', textAlign: 'center' }}>
        <div style={{ fontSize: '0.8rem', color: '#5F6368', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
          ENTER TOTAL AMOUNT
        </div>

        {/* Big Google Pay Amount Input */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '12px 0 16px 0',
          }}
        >
          <span style={{ fontSize: '2.4rem', fontWeight: 800, color: '#1F2937', marginRight: '4px' }}>
            ₹
          </span>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0"
            required
            style={{
              width: '180px',
              fontSize: '2.6rem',
              fontWeight: 800,
              color: '#1F2937',
              border: 'none',
              outline: 'none',
              background: 'transparent',
              textAlign: 'left',
              fontFamily: 'inherit',
            }}
          />
        </div>

        {/* Quick Amount Chips */}
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'center', flexWrap: 'wrap', marginBottom: '16px' }}>
          {[2000, 3500, 5000, 7500].map((val) => (
            <button
              key={val}
              type="button"
              onClick={() => handlePresetAmount(val)}
              className={`chip-pill ${numAmount === val ? 'active' : ''}`}
            >
              ₹{val.toLocaleString('en-IN')}
            </button>
          ))}
        </div>

        {/* Purpose / Note input */}
        <div style={{ borderTop: '1px solid #ECEFF1', paddingTop: '14px', textAlign: 'left' }}>
          <label style={{ fontSize: '0.78rem', color: '#5F6368', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
            Add a note (optional)
          </label>
          <input
            type="text"
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="e.g. Hardware accessories or Invoice #104"
            className="gpay-input"
            style={{ fontSize: '0.88rem', padding: '10px 12px' }}
          />
        </div>
      </div>

      {/* Smart Split Breakdown & Savings Banner (Paytm style cashback/offer card) */}
      {numAmount > 2000 ? (
        <div
          style={{
            background: '#E6F4EA',
            border: '1px solid #CEEAD6',
            borderRadius: 'var(--radius-lg)',
            padding: '14px 16px',
            display: 'flex',
            alignItems: 'flex-start',
            gap: '12px',
          }}
        >
          <div
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              background: '#0F9D58',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
              marginTop: '2px',
            }}
          >
            <Sparkles size={16} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 700, fontSize: '0.9rem', color: '#137333' }}>
              Splits into {numSlices} tranches &bull; Saves ~₹{estimatedSavings} in fees
            </div>
            <div style={{ fontSize: '0.78rem', color: '#1E4620', marginTop: '3px', lineHeight: 1.4 }}>
              Keeps each transfer below ₹2,000 to avoid the 1.1% PPI wallet interchange fee and daily cooling limits.
            </div>
          </div>
        </div>
      ) : (
        <div
          style={{
            background: '#F1F3F4',
            borderRadius: 'var(--radius-lg)',
            padding: '12px 16px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            fontSize: '0.8rem',
            color: '#5F6368',
          }}
        >
          <Shield size={16} color="#1A73E8" />
          <span>Standard amount under ₹2,000 transfers in 1 single transaction.</span>
        </div>
      )}

      {/* Advanced Rules Engine Collapsible (Simple & Clean) */}
      <div className="gpay-card" style={{ padding: '12px 16px' }}>
        <button
          type="button"
          onClick={() => setShowAdvanced(!showAdvanced)}
          style={{
            width: '100%',
            background: 'transparent',
            border: 'none',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            cursor: 'pointer',
            color: '#1F2937',
            fontWeight: 600,
            fontSize: '0.85rem',
          }}
        >
          <span>Advanced Split & Security Rules</span>
          {showAdvanced ? <ChevronUp size={18} color="#5F6368" /> : <ChevronDown size={18} color="#5F6368" />}
        </button>

        {showAdvanced && (
          <div style={{ marginTop: '12px', borderTop: '1px solid #ECEFF1', paddingTop: '12px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.78rem', color: '#5F6368', fontWeight: 600, marginBottom: '4px' }}>
                Per-Slice Ceiling Limit
              </label>
              <select
                value={threshold}
                onChange={(e) => setThreshold(Number(e.target.value))}
                className="gpay-input"
                style={{ fontSize: '0.85rem', padding: '8px 12px' }}
              >
                <option value={1990}>₹1,990 (Recommended for 0% surcharge)</option>
                <option value={1950}>₹1,950 (Extra buffer for strict banks)</option>
                <option value={1800}>₹1,800 (Conservative split)</option>
              </select>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div>
                <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#1F2937' }}>
                  Anti-Velocity Jitter
                </div>
                <div style={{ fontSize: '0.75rem', color: '#5F6368' }}>
                  Randomizes tranche amounts slightly to prevent bank fraud false-positives
                </div>
              </div>
              <input
                type="checkbox"
                checked={antiAmlJitter}
                onChange={(e) => setAntiAmlJitter(e.target.checked)}
                style={{ width: '18px', height: '18px', accentColor: '#1A73E8', cursor: 'pointer' }}
              />
            </div>

            <button
              type="button"
              onClick={onOpenCompliance}
              style={{
                background: 'transparent',
                border: 'none',
                color: '#1A73E8',
                fontSize: '0.78rem',
                fontWeight: 600,
                textAlign: 'left',
                cursor: 'pointer',
                padding: '4px 0',
              }}
            >
              Learn more about NPCI & RBI rules &rarr;
            </button>
          </div>
        )}
      </div>

      {/* Primary Bottom Action Button (Google Pay / Paytm Signature Pill) */}
      <button
        type="submit"
        className="btn-gpay"
        style={{ width: '100%', marginTop: '8px' }}
      >
        <span>Proceed to Pay ₹{numAmount.toLocaleString('en-IN')}</span>
        <ArrowRight size={18} />
      </button>

      {/* Simple Security Badge */}
      <div style={{ textAlign: 'center', fontSize: '0.75rem', color: '#5F6368', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
        <Shield size={14} color="#0F9D58" />
        <span>100% Secure &bull; Protected by NPCI UPI Common Library</span>
      </div>

      {/* QR Scanner Modal */}
      <QrScannerModal
        isOpen={isQrScannerOpen}
        onClose={() => setIsQrScannerOpen(false)}
        onScanSuccess={handleScanSuccess}
      />
    </form>
  );
};
import React, { useState, useMemo } from 'react';
import { QrCode, ArrowRight, CheckCircle2, ChevronDown, ChevronUp, Sparkles, Shield, Smartphone, AtSign, Zap, ChevronRight } from 'lucide-react';
import { QrScannerModal } from './QrScannerModal';
import { BankAccountDrawer } from './BankAccountDrawer';
import { SplitPlan, BankAccount } from '../types';
import { createPlan, calculateSlices, ParsedUpiData, formatMobileToVpa } from '../services/upiService';
import { getDefaultAccount } from '../services/nativeEngineService';

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
  const [threshold, setThreshold] = useState<number>(1990);
  const [antiAmlJitter, setAntiAmlJitter] = useState<boolean>(true);
  const [showAdvanced, setShowAdvanced] = useState<boolean>(false);
  const [isQrScannerOpen, setIsQrScannerOpen] = useState<boolean>(false);
  const [isAccountDrawerOpen, setIsAccountDrawerOpen] = useState<boolean>(false);
  const [scanNotice, setScanNotice] = useState<string | null>(null);
  const [selectedAccount, setSelectedAccount] = useState<BankAccount>(getDefaultAccount());


  const numAmount = parseFloat(amount) || 0;
  const effectiveThreshold = numAmount >= 2000 ? Math.min(threshold, 1990) : threshold;
  const numSlices = numAmount >= 2000 ? Math.ceil(numAmount / effectiveThreshold) : (numAmount > 0 ? 1 : 0);
  const estimatedSavings = numAmount >= 2000 ? Math.round(numAmount * 0.011) : 0;

  // Active resolved VPA
  const activeVpa = payeeType === 'phone' ? formatMobileToVpa(phoneNumber, phoneHandle) : vpa.trim();

  // Live computed slice preview showcasing Slicing Engine + Anti-Velocity Jitter
  const previewSlices = useMemo(() => {
    if (numAmount <= 0) return [];
    return calculateSlices(numAmount, activeVpa, payeeName, note, threshold, antiAmlJitter);
  }, [numAmount, activeVpa, payeeName, note, threshold, antiAmlJitter]);

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
      threshold,
      antiAmlJitter,
      selectedAccount.id,
      `${selectedAccount.bankName} ${selectedAccount.accountNumberMasked}`
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
      {/* Material 3 Recipient Header Card */}
      <div
        className="m3-card-outlined"
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
              borderRadius: 'var(--md-shape-corner-full)',
              background: 'var(--md-sys-color-primary-container)',
              color: 'var(--md-sys-color-on-primary-container)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 700,
              fontSize: '1.1rem',
              flexShrink: 0,
            }}
          >
            {payeeName ? payeeName.slice(0, 2).toUpperCase() : 'UP'}
          </div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span style={{ fontWeight: 700, fontSize: '0.95rem', color: 'var(--md-sys-color-on-surface)' }}>
                {payeeName || 'Recipient'}
              </span>
              <CheckCircle2 size={16} color="var(--md-sys-color-tertiary)" />
            </div>
            <div style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '2px' }}>
              {activeVpa}
            </div>
          </div>
        </div>

        {/* Scan QR Code Button (M3 Tonal Button) */}
        <button
          type="button"
          onClick={() => setIsQrScannerOpen(true)}
          className="m3-btn-tonal"
          style={{ height: '36px', padding: '0 12px', fontSize: '0.78rem' }}
        >
          <QrCode size={15} />
          <span>Scan QR</span>
        </button>
      </div>

      {/* QR Scan Success Feedback Alert */}
      {scanNotice && (
        <div
          style={{
            background: 'var(--md-sys-color-tertiary-container)',
            borderRadius: 'var(--md-shape-corner-md)',
            padding: '10px 14px',
            fontSize: '0.82rem',
            color: 'var(--md-sys-color-on-tertiary-container)',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <CheckCircle2 size={16} color="var(--md-sys-color-tertiary)" />
          <span>{scanNotice}</span>
        </div>
      )}

      {/* Material 3 Payee Selection Card */}
      <div className="m3-card-outlined" style={{ padding: '16px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
          <label style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
            PAYEE DETAILS
          </label>

          {/* Type Toggle Pills (M3 Filter Chips) */}
          <div style={{ display: 'flex', background: 'var(--md-sys-color-surface-container-high)', borderRadius: 'var(--md-shape-corner-full)', padding: '2px', gap: '2px' }}>
            <button
              type="button"
              onClick={() => setPayeeType('vpa')}
              style={{
                background: payeeType === 'vpa' ? 'var(--md-sys-color-surface-container-lowest)' : 'transparent',
                border: 'none',
                borderRadius: 'var(--md-shape-corner-full)',
                padding: '4px 10px',
                fontSize: '0.75rem',
                fontWeight: payeeType === 'vpa' ? 700 : 500,
                color: payeeType === 'vpa' ? 'var(--md-sys-color-primary)' : 'var(--md-sys-color-on-surface-variant)',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                boxShadow: payeeType === 'vpa' ? '0 1px 2px rgba(0,0,0,0.08)' : 'none',
                transition: 'all 0.15s ease',
              }}
            >
              <AtSign size={13} />
              <span>UPI ID</span>
            </button>

            <button
              type="button"
              onClick={() => setPayeeType('phone')}
              style={{
                background: payeeType === 'phone' ? 'var(--md-sys-color-surface-container-lowest)' : 'transparent',
                border: 'none',
                borderRadius: 'var(--md-shape-corner-full)',
                padding: '4px 10px',
                fontSize: '0.75rem',
                fontWeight: payeeType === 'phone' ? 700 : 500,
                color: payeeType === 'phone' ? 'var(--md-sys-color-primary)' : 'var(--md-sys-color-on-surface-variant)',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                boxShadow: payeeType === 'phone' ? '0 1px 2px rgba(0,0,0,0.08)' : 'none',
                transition: 'all 0.15s ease',
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
              className="m3-input"
            />
            <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '4px' }}>
              Virtual Payment Address (VPA)
            </div>
          </div>
        ) : (
          /* Option 2: 10-digit Mobile Number Input */
          <div>
            <div style={{ display: 'flex', gap: '6px' }}>
              <div
                style={{
                  background: 'var(--md-sys-color-surface-container-high)',
                  border: '1px solid var(--md-sys-color-outline-variant)',
                  borderRadius: 'var(--md-shape-corner-sm)',
                  padding: '12px',
                  fontSize: '0.95rem',
                  fontWeight: 600,
                  color: 'var(--md-sys-color-on-surface-variant)',
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
                className="m3-input"
                style={{ flex: 1, letterSpacing: '0.05em' }}
              />
            </div>

            {/* Quick UPI Handle Selector Chips */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '8px', flexWrap: 'wrap' }}>
              <span style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 600 }}>Handle:</span>
              {['upi', 'paytm', 'okhdfcbank', 'okaxis', 'oksbi'].map((h) => (
                <button
                  key={h}
                  type="button"
                  onClick={() => setPhoneHandle(h)}
                  className={`m3-chip ${phoneHandle === h ? 'active' : ''}`}
                  style={{ padding: '3px 8px', fontSize: '0.72rem' }}
                >
                  @{h}
                </button>
              ))}
            </div>
            <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-tertiary)', marginTop: '4px', fontWeight: 600 }}>
              ✓ Resolving to: {formatMobileToVpa(phoneNumber, phoneHandle)}
            </div>
          </div>
        )}

        {/* Recipient Display Name */}
        <div style={{ marginTop: '12px' }}>
          <label style={{ fontSize: '0.75rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
            Payee Name
          </label>
          <input
            type="text"
            value={payeeName}
            onChange={(e) => setPayeeName(e.target.value)}
            placeholder="Recipient / Merchant Name"
            className="m3-input"
            style={{ fontSize: '0.88rem', padding: '10px 12px' }}
          />
        </div>
      </div>

      {/* Unified SlicePay Payment Engine & Linked Debit Bank Account Card */}
      <div
        className="m3-card-outlined"
        style={{
          padding: '14px 16px',
          background: 'var(--md-sys-color-surface-container-low)',
          display: 'flex',
          flexDirection: 'column',
          gap: '10px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                width: '22px',
                height: '22px',
                borderRadius: 'var(--md-shape-corner-xs)',
                background: 'var(--md-sys-color-primary)',
                color: '#FFF',
              }}
            >
              <Zap size={13} />
            </span>
            <span style={{ fontSize: '0.78rem', fontWeight: 800, color: 'var(--md-sys-color-on-surface)', letterSpacing: '0.02em' }}>
              SLICEPAY UPI ENGINE
            </span>
          </div>
          <span
            style={{
              fontSize: '0.68rem',
              fontWeight: 700,
              background: 'var(--md-sys-color-tertiary-container)',
              color: 'var(--md-sys-color-on-tertiary-container)',
              padding: '2px 8px',
              borderRadius: 'var(--md-shape-corner-full)',
            }}
          >
            0% MDR &bull; Direct Bank-to-Bank
          </span>
        </div>

        {/* Linked Bank Account Selector */}
        <div
          style={{
            background: 'var(--md-sys-color-surface-container-lowest)',
            border: '1px solid var(--md-sys-color-outline-variant)',
            borderRadius: 'var(--md-shape-corner-md)',
            padding: '10px 12px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <span
              style={{
                width: '34px',
                height: '34px',
                borderRadius: 'var(--md-shape-corner-xs)',
                background: selectedAccount.color,
                color: '#FFFFFF',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 800,
                fontSize: '0.78rem',
              }}
            >
              {selectedAccount.bankCode}
            </span>
            <div>
              <div style={{ fontWeight: 700, fontSize: '0.86rem', color: 'var(--md-sys-color-on-surface)' }}>
                {selectedAccount.bankName} ({selectedAccount.accountNumberMasked})
              </div>
              <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-tertiary)', fontWeight: 600 }}>
                Avail: ₹{selectedAccount.balance.toLocaleString('en-IN', { minimumFractionDigits: 2 })} &bull; {selectedAccount.vpa}
              </div>
            </div>
          </div>

          <button
            type="button"
            onClick={() => setIsAccountDrawerOpen(true)}
            className="m3-btn-tonal"
            style={{ height: '32px', padding: '0 10px', fontSize: '0.74rem' }}
          >
            <span>Change</span>
            <ChevronRight size={13} />
          </button>
        </div>

        <div style={{ fontSize: '0.7rem', color: 'var(--md-sys-color-on-surface-variant)', lineHeight: 1.35 }}>
          Autonomous In-App Switch debits directly via NPCI Common Library MPIN. No third-party apps needed.
        </div>
      </div>

      {/* Main Payment Amount Card (Material 3 Outlined Card) */}
      <div className="m3-card-outlined" style={{ padding: '24px 20px', textAlign: 'center' }}>
        <div style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
          ENTER TOTAL AMOUNT
        </div>

        {/* Big M3 Currency Input */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '12px 0 16px 0',
          }}
        >
          <span style={{ fontSize: '2.6rem', fontWeight: 800, color: 'var(--md-sys-color-on-surface)', marginRight: '4px' }}>
            ₹
          </span>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0"
            required
            style={{
              width: '200px',
              fontSize: '2.8rem',
              fontWeight: 800,
              color: 'var(--md-sys-color-on-surface)',
              border: 'none',
              outline: 'none',
              background: 'transparent',
              textAlign: 'left',
              fontFamily: 'inherit',
            }}
          />
        </div>

        {/* Quick Amount Filter Chips */}
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'center', flexWrap: 'wrap', marginBottom: '16px' }}>
          {[2000, 3500, 5000, 7500].map((val) => (
            <button
              key={val}
              type="button"
              onClick={() => handlePresetAmount(val)}
              className={`m3-chip ${numAmount === val ? 'active' : ''}`}
            >
              ₹{val.toLocaleString('en-IN')}
            </button>
          ))}
        </div>

        {/* Purpose / Note input */}
        <div style={{ borderTop: '1px solid var(--md-sys-color-outline-variant)', paddingTop: '14px', textAlign: 'left' }}>
          <label style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 600, display: 'block', marginBottom: '4px' }}>
            Add a note (optional)
          </label>
          <input
            type="text"
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="e.g. Hardware accessories or Invoice #104"
            className="m3-input"
            style={{ fontSize: '0.88rem', padding: '10px 12px' }}
          />
        </div>
      </div>

      {/* Smart Split Breakdown & Savings Banner */}
      {numAmount >= 2000 ? (
        <div
          style={{
            background: 'var(--md-sys-color-tertiary-container)',
            borderRadius: 'var(--md-shape-corner-lg)',
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
              borderRadius: 'var(--md-shape-corner-full)',
              background: 'var(--md-sys-color-tertiary)',
              color: 'var(--md-sys-color-on-tertiary)',
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
            <div style={{ fontWeight: 700, fontSize: '0.9rem', color: 'var(--md-sys-color-on-tertiary-container)' }}>
              Splits into {numSlices} tranches &bull; Saves ~₹{estimatedSavings} in fees
            </div>
            <div style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-tertiary-container)', opacity: 0.9, marginTop: '3px', lineHeight: 1.4 }}>
              Keeps each transfer strictly below ₹2,000 to eliminate the 1.1% PPI surcharge and daily cooling caps.
            </div>
          </div>
        </div>
      ) : (
        <div
          style={{
            background: 'var(--md-sys-color-surface-container-high)',
            borderRadius: 'var(--md-shape-corner-lg)',
            padding: '12px 16px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            fontSize: '0.8rem',
            color: 'var(--md-sys-color-on-surface-variant)',
          }}
        >
          <Shield size={16} color="var(--md-sys-color-primary)" />
          <span>Standard amount under ₹2,000 transfers in 1 single direct transaction.</span>
        </div>
      )}

      {/* Live Slicing Engine & Anti-Velocity Jitter Breakdown Preview */}
      {numAmount >= 2000 && previewSlices.length > 1 && (
        <div
          className="m3-card-outlined"
          style={{
            padding: '14px 16px',
            background: 'var(--md-sys-color-surface-container-lowest)',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Zap size={14} color="var(--md-sys-color-primary)" />
              <span style={{ fontSize: '0.78rem', fontWeight: 800, color: 'var(--md-sys-color-on-surface)', letterSpacing: '0.03em' }}>
                LIVE SLICING & JITTER PREVIEW
              </span>
            </div>
            <span
              style={{
                fontSize: '0.68rem',
                color: antiAmlJitter ? 'var(--md-sys-color-tertiary)' : 'var(--md-sys-color-on-surface-variant)',
                fontWeight: 700,
                background: antiAmlJitter ? 'var(--md-sys-color-tertiary-container)' : 'var(--md-sys-color-surface-container-high)',
                padding: '2px 8px',
                borderRadius: 'var(--md-shape-corner-full)',
              }}
            >
              {antiAmlJitter ? '⚡ Anti-Velocity Jitter ON' : 'Uniform Split'}
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {previewSlices.map((s) => (
              <div
                key={s.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '8px 12px',
                  borderRadius: 'var(--md-shape-corner-sm)',
                  background: 'var(--md-sys-color-surface-container-low)',
                  border: '1px solid var(--md-sys-color-outline-variant)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span
                    style={{
                      width: '24px',
                      height: '24px',
                      borderRadius: 'var(--md-shape-corner-full)',
                      background: 'var(--md-sys-color-primary-container)',
                      color: 'var(--md-sys-color-primary)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '0.74rem',
                      fontWeight: 700,
                    }}
                  >
                    {s.sliceNumber}
                  </span>
                  <span style={{ fontSize: '0.8rem', fontWeight: 600, color: 'var(--md-sys-color-on-surface)' }}>
                    Tranche #{s.sliceNumber}
                  </span>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '0.88rem', fontWeight: 800, color: 'var(--md-sys-color-on-surface)' }}>
                    ₹{s.amount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                  </span>
                  <span
                    style={{
                      fontSize: '0.66rem',
                      color: 'var(--md-sys-color-tertiary)',
                      background: 'var(--md-sys-color-tertiary-container)',
                      padding: '2px 6px',
                      borderRadius: '4px',
                      fontWeight: 700,
                    }}
                  >
                    &lt; ₹2,000 (0%)
                  </span>
                </div>
              </div>
            ))}
          </div>

          <div style={{ marginTop: '8px', fontSize: '0.68rem', color: 'var(--md-sys-color-on-surface-variant)', lineHeight: 1.35 }}>
            {antiAmlJitter
              ? 'Anti-Velocity Jitter dynamically offsets slice amounts (±₹15) to prevent AML structuring pattern detection in core banking systems.'
              : 'Tranches capped below ₹2,000 to qualify for 0% PPI MDR.'}
          </div>
        </div>
      )}

      {/* Advanced Rules Engine Collapsible */}
      <div className="m3-card-outlined" style={{ padding: '12px 16px' }}>
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
            color: 'var(--md-sys-color-on-surface)',
            fontWeight: 600,
            fontSize: '0.85rem',
          }}
        >
          <span>Advanced Split & Security Rules</span>
          {showAdvanced ? (
            <ChevronUp size={18} color="var(--md-sys-color-on-surface-variant)" />
          ) : (
            <ChevronDown size={18} color="var(--md-sys-color-on-surface-variant)" />
          )}
        </button>

        {showAdvanced && (
          <div style={{ marginTop: '12px', borderTop: '1px solid var(--md-sys-color-outline-variant)', paddingTop: '12px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 600, marginBottom: '4px' }}>
                Per-Slice Ceiling Limit
              </label>
              <select
                value={threshold}
                onChange={(e) => setThreshold(Number(e.target.value))}
                className="m3-input"
                style={{ fontSize: '0.85rem', padding: '8px 12px' }}
              >
                <option value={1990}>₹1,990 (Recommended for 0% surcharge)</option>
                <option value={1950}>₹1,950 (Extra buffer for strict banks)</option>
                <option value={1800}>₹1,800 (Conservative split)</option>
              </select>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div>
                <div style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--md-sys-color-on-surface)' }}>
                  Anti-Velocity Jitter
                </div>
                <div style={{ fontSize: '0.75rem', color: 'var(--md-sys-color-on-surface-variant)' }}>
                  Randomizes tranche amounts slightly to prevent bank fraud false-positives
                </div>
              </div>
              <input
                type="checkbox"
                checked={antiAmlJitter}
                onChange={(e) => setAntiAmlJitter(e.target.checked)}
                style={{ width: '18px', height: '18px', accentColor: 'var(--md-sys-color-primary)', cursor: 'pointer' }}
              />
            </div>

            <button
              type="button"
              onClick={onOpenCompliance}
              style={{
                background: 'transparent',
                border: 'none',
                color: 'var(--md-sys-color-primary)',
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

      {/* Primary Material 3 Filled Button (48px pill) */}
      <button
        type="submit"
        className="m3-btn-filled"
        style={{ width: '100%', marginTop: '4px', height: '52px' }}
      >
        <span>Proceed to Pay ₹{numAmount.toLocaleString('en-IN')}</span>
        <ArrowRight size={18} />
      </button>

      {/* M3 Security Badge */}
      <div style={{ textAlign: 'center', fontSize: '0.74rem', color: 'var(--md-sys-color-on-surface-variant)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
        <Shield size={14} color="var(--md-sys-color-tertiary)" />
        <span>Protected by NPCI UPI Common Library Architecture</span>
      </div>

      {/* QR Scanner Modal */}
      <QrScannerModal
        isOpen={isQrScannerOpen}
        onClose={() => setIsQrScannerOpen(false)}
        onScanSuccess={handleScanSuccess}
      />

      {/* Linked Bank Account Switcher Drawer */}
      <BankAccountDrawer
        isOpen={isAccountDrawerOpen}
        onClose={() => setIsAccountDrawerOpen(false)}
        selectedAccountId={selectedAccount.id}
        onSelectAccount={(acc) => {
          setSelectedAccount(acc);
          setIsAccountDrawerOpen(false);
        }}
      />
    </form>
  );
};
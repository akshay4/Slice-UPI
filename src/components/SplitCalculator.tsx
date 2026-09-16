import React, { useState } from 'react';
import { QrCode, ArrowRight, Sparkles, ShieldCheck } from 'lucide-react';
import { ModeSelector } from './ModeSelector';
import { SplitMode, SplitPlan } from '../types';
import { createPlan } from '../services/upiService';

interface Props {
  onPlanCreated: (plan: SplitPlan) => void;
  onOpenCompliance: () => void;
}

export const SplitCalculator: React.FC<Props> = ({ onPlanCreated, onOpenCompliance }) => {
  const [amount, setAmount] = useState<string>('3500');
  const [vpa, setVpa] = useState<string>('merchantstore@oksbi');
  const [payeeName, setPayeeName] = useState<string>('Suresh Electronics & Mart');
  const [note, setNote] = useState<string>('Hardware accessories purchase');
  const [mode, setMode] = useState<SplitMode>('intent');
  const [threshold, setThreshold] = useState<number>(1990);
  const [antiAmlJitter, setAntiAmlJitter] = useState<boolean>(true);

  const numAmount = parseFloat(amount) || 0;
  const numSlices = numAmount > 0 ? Math.ceil(numAmount / threshold) : 0;
  const savesFee = numAmount > 2000 ? Math.round(numAmount * 0.011) : 0;

  const handleGeneratePlan = (e: React.FormEvent) => {
    e.preventDefault();
    if (numAmount <= 0 || !vpa.includes('@')) {
      alert('Please enter a valid amount and UPI ID (e.g. name@bank)');
      return;
    }

    const plan = createPlan(
      numAmount,
      vpa,
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

  return (
    <form onSubmit={handleGeneratePlan} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
      {/* Mode Selector */}
      <ModeSelector mode={mode} onSelectMode={setMode} />

      {/* Main Input Card */}
      <div className="glass-card" style={{ padding: '20px' }}>
        {/* Total Amount Input */}
        <div style={{ marginBottom: '18px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
            <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600 }}>
              TOTAL TRANSACTION AMOUNT
            </label>
            {numAmount > 2000 && (
              <span style={{ fontSize: '0.75rem', color: '#34D399', display: 'flex', alignItems: 'center', gap: '4px' }}>
                <Sparkles size={12} /> Splitting into {numSlices} tranches
              </span>
            )}
          </div>

          <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
            <span style={{ position: 'absolute', left: '16px', fontSize: '1.6rem', fontWeight: 700, color: 'var(--text-primary)' }}>
              ₹
            </span>
            <input
              type="number"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="0.00"
              style={{
                width: '100%',
                background: 'rgba(255, 255, 255, 0.04)',
                border: '1px solid rgba(255, 255, 255, 0.12)',
                borderRadius: 'var(--radius-md)',
                padding: '14px 16px 14px 44px',
                fontSize: '1.6rem',
                fontWeight: 700,
                color: '#FFFFFF',
                outline: 'none',
              }}
            />
          </div>

          {/* Quick presets */}
          <div style={{ display: 'flex', gap: '8px', marginTop: '10px' }}>
            {[2400, 3500, 4999, 7500].map((val) => (
              <button
                key={val}
                type="button"
                onClick={() => handlePresetAmount(val)}
                style={{
                  background: 'rgba(255, 255, 255, 0.05)',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                  borderRadius: 'var(--radius-sm)',
                  padding: '5px 10px',
                  color: 'var(--text-secondary)',
                  fontSize: '0.8rem',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                ₹{val.toLocaleString('en-IN')}
              </button>
            ))}
          </div>
        </div>

        {/* Recipient UPI ID / VPA */}
        <div style={{ marginBottom: '18px' }}>
          <label style={{ display: 'block', fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600, marginBottom: '6px' }}>
            BENEFICIARY UPI ID (VPA)
          </label>
          <div style={{ display: 'flex', gap: '8px' }}>
            <input
              type="text"
              value={vpa}
              onChange={(e) => setVpa(e.target.value)}
              placeholder="merchant@upi or mobile@okhdfcbank"
              required
              style={{
                flex: 1,
                background: 'rgba(255, 255, 255, 0.04)',
                border: '1px solid rgba(255, 255, 255, 0.12)',
                borderRadius: 'var(--radius-md)',
                padding: '12px 14px',
                fontSize: '0.95rem',
                color: '#FFFFFF',
                outline: 'none',
              }}
            />
            <button
              type="button"
              title="Scan QR Code (Mock)"
              onClick={() => {
                setVpa('freshmart.pay@icici');
                setPayeeName('Fresh Mart Supermarket');
              }}
              style={{
                background: 'rgba(99, 102, 241, 0.15)',
                border: '1px solid rgba(99, 102, 241, 0.3)',
                borderRadius: 'var(--radius-md)',
                padding: '0 14px',
                color: '#818CF8',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                fontWeight: 600,
                fontSize: '0.85rem',
              }}
            >
              <QrCode size={18} /> Sample QR
            </button>
          </div>
        </div>

        {/* Beneficiary Name & Note */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginBottom: '10px' }}>
          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: 600, marginBottom: '4px' }}>
              Payee Name (Optional)
            </label>
            <input
              type="text"
              value={payeeName}
              onChange={(e) => setPayeeName(e.target.value)}
              style={{
                width: '100%',
                background: 'rgba(255, 255, 255, 0.04)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                borderRadius: 'var(--radius-sm)',
                padding: '10px',
                fontSize: '0.85rem',
                color: '#FFFFFF',
                outline: 'none',
              }}
            />
          </div>
          <div>
            <label style={{ display: 'block', fontSize: '0.75rem', color: 'var(--text-muted)', fontWeight: 600, marginBottom: '4px' }}>
              Purpose Note
            </label>
            <input
              type="text"
              value={note}
              onChange={(e) => setNote(e.target.value)}
              style={{
                width: '100%',
                background: 'rgba(255, 255, 255, 0.04)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                borderRadius: 'var(--radius-sm)',
                padding: '10px',
                fontSize: '0.85rem',
                color: '#FFFFFF',
                outline: 'none',
              }}
            />
          </div>
        </div>
      </div>

      {/* Advanced Rules & Safety */}
      <div className="glass-card" style={{ padding: '16px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldCheck size={16} color="#10B981" />
            <span style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-secondary)' }}>
              NPCI & Bank Rules Engine
            </span>
          </div>
          <button
            type="button"
            onClick={onOpenCompliance}
            style={{
              background: 'transparent',
              border: 'none',
              color: '#818CF8',
              fontSize: '0.75rem',
              fontWeight: 600,
              cursor: 'pointer',
              textDecoration: 'underline',
            }}
          >
            Legal Guidelines
          </button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: '0.85rem', fontWeight: 500, color: 'var(--text-primary)' }}>
                Per-Slice Ceiling Limit
              </div>
              <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)' }}>
                Keeps tranches below ₹2,000 threshold
              </div>
            </div>
            <select
              value={threshold}
              onChange={(e) => setThreshold(Number(e.target.value))}
              style={{
                background: 'rgba(255, 255, 255, 0.06)',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                borderRadius: 'var(--radius-sm)',
                color: '#FFFFFF',
                padding: '6px 10px',
                fontSize: '0.8rem',
                outline: 'none',
              }}
            >
              <option value={1990} style={{ background: '#111827' }}>₹1,990 (Recommended)</option>
              <option value={1800} style={{ background: '#111827' }}>₹1,800</option>
              <option value={1500} style={{ background: '#111827' }}>₹1,500</option>
              <option value={1000} style={{ background: '#111827' }}>₹1,000</option>
            </select>
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontSize: '0.85rem', fontWeight: 500, color: 'var(--text-primary)' }}>
                Anti-Velocity Jitter
              </div>
              <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)' }}>
                Randomizes amounts slightly to prevent bank fraud false-positives
              </div>
            </div>
            <input
              type="checkbox"
              checked={antiAmlJitter}
              onChange={(e) => setAntiAmlJitter(e.target.checked)}
              style={{ width: '18px', height: '18px', accentColor: 'var(--primary)', cursor: 'pointer' }}
            />
          </div>
        </div>
      </div>

      {/* Savings Insight Badge */}
      {numAmount > 2000 && (
        <div style={{
          background: 'rgba(16, 185, 129, 0.1)',
          border: '1px solid rgba(16, 185, 129, 0.25)',
          borderRadius: 'var(--radius-md)',
          padding: '12px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Sparkles size={18} color="#34D399" />
            <div>
              <div style={{ fontSize: '0.85rem', fontWeight: 600, color: '#6EE7B7' }}>
                Estimated Merchant / Wallet Savings: ~₹{savesFee}
              </div>
              <div style={{ fontSize: '0.72rem', color: 'rgba(255, 255, 255, 0.7)' }}>
                Bypasses the 1.1% PPI interchange fee applied above ₹2,000
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Action Button */}
      <button
        type="submit"
        className="btn-primary"
        style={{ marginTop: '6px' }}
      >
        <span>Initialize {mode === 'intent' ? 'Direct Orchestrator' : 'Automated Escrow'}</span>
        <ArrowRight size={18} />
      </button>
    </form>
  );
};
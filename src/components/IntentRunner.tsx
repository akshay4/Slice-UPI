import React, { useState } from 'react';
import { ArrowLeft, CheckCircle2, Circle, Smartphone, Copy, Check } from 'lucide-react';
import { SplitPlan, PaymentSlice } from '../types';

interface Props {
  plan: SplitPlan;
  onReset: () => void;
  onCompleteAll: () => void;
}

export const IntentRunner: React.FC<Props> = ({ plan, onReset, onCompleteAll }) => {
  const [slices, setSlices] = useState<PaymentSlice[]>(plan.slices);
  const [activeSliceIndex, setActiveSliceIndex] = useState<number>(0);
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const activeSlice = slices[activeSliceIndex];
  const completedCount = slices.filter((s) => s.status === 'completed').length;
  const isAllCompleted = completedCount === slices.length;

  const handleLaunchUpi = (slice: PaymentSlice, appUrl?: string) => {
    const targetUrl = appUrl || slice.upiUri;
    window.location.href = targetUrl;

    setSlices((prev) =>
      prev.map((s, idx) =>
        idx === activeSliceIndex ? { ...s, status: 'processing' } : s
      )
    );
  };

  const handleMarkSliceDone = (sliceIndex: number) => {
    const updated = slices.map((s, idx) =>
      idx === sliceIndex ? { ...s, status: 'completed' as const, timestamp: Date.now() } : s
    );
    setSlices(updated);

    if (sliceIndex + 1 < slices.length) {
      setActiveSliceIndex(sliceIndex + 1);
    } else {
      onCompleteAll();
    }
  };

  const handleCopyUri = (uri: string, id: string) => {
    navigator.clipboard.writeText(uri);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Navigation */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button
          onClick={onReset}
          style={{
            background: 'transparent',
            border: 'none',
            color: 'var(--text-secondary)',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '0.85rem',
            cursor: 'pointer',
            padding: '4px',
          }}
        >
          <ArrowLeft size={16} /> Change Amount
        </button>
        <span style={{ fontSize: '0.8rem', color: '#818CF8', fontWeight: 600, background: 'rgba(99, 102, 241, 0.15)', padding: '4px 10px', borderRadius: '20px' }}>
          Mode A: Direct Intent
        </span>
      </div>

      {/* Progress & Overview Card */}
      <div className="glass-card" style={{ padding: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
          <div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              Target Beneficiary
            </div>
            <div style={{ fontSize: '1.1rem', fontWeight: 700, color: 'var(--text-primary)', marginTop: '2px' }}>
              {plan.payeeName}
            </div>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
              {plan.vpa}
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>TOTAL TO SPLIT</div>
            <div style={{ fontSize: '1.4rem', fontWeight: 800, color: '#34D399' }}>
              ₹{plan.totalAmount.toLocaleString('en-IN')}
            </div>
          </div>
        </div>

        {/* Progress Bar */}
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.78rem', color: 'var(--text-muted)', marginBottom: '6px' }}>
            <span>Progress: {completedCount} of {slices.length} approved</span>
            <span>{Math.round((completedCount / slices.length) * 100)}%</span>
          </div>
          <div style={{ height: '8px', background: 'rgba(255, 255, 255, 0.08)', borderRadius: '4px', overflow: 'hidden' }}>
            <div
              style={{
                width: `${(completedCount / slices.length) * 100}%`,
                height: '100%',
                background: 'linear-gradient(90deg, #6366F1, #10B981)',
                transition: 'width 0.3s ease',
              }}
            />
          </div>
        </div>
      </div>

      {/* Active Slice Action Box */}
      {!isAllCompleted && activeSlice && (
        <div className="glass-card" style={{ padding: '20px', border: '1px solid rgba(99, 102, 241, 0.4)', background: 'linear-gradient(180deg, rgba(99, 102, 241, 0.1) 0%, rgba(18, 24, 38, 0.85) 100%)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <span style={{ fontSize: '0.8rem', color: '#A5B4FC', fontWeight: 700, textTransform: 'uppercase' }}>
              STEP {activeSlice.sliceNumber} OF {activeSlice.totalSlices}
            </span>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', fontFamily: 'monospace' }}>
              Ref: {activeSlice.txnRef}
            </span>
          </div>

          <div style={{ textAlign: 'center', margin: '14px 0' }}>
            <div style={{ fontSize: '2.2rem', fontWeight: 800, color: '#FFFFFF' }}>
              ₹{activeSlice.amount.toLocaleString('en-IN')}
            </div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
              Below ₹2,000 threshold (Zero surcharge)
            </div>
          </div>

          {/* Direct Launch Primary Button */}
          <button
            type="button"
            onClick={() => handleLaunchUpi(activeSlice)}
            className="btn-primary"
            style={{ width: '100%', marginBottom: '10px' }}
          >
            <Smartphone size={20} />
            <span>Launch UPI App Intent</span>
          </button>

          {/* Quick Specific App Choosers */}
          <div style={{ display: 'flex', gap: '8px', justifyContent: 'center', marginBottom: '14px' }}>
            {[
              { label: 'GPay', url: activeSlice.appSpecificUris.gpay, color: '#4285F4' },
              { label: 'PhonePe', url: activeSlice.appSpecificUris.phonepe, color: '#5F259F' },
              { label: 'Paytm', url: activeSlice.appSpecificUris.paytm, color: '#00BAF2' },
              { label: 'CRED', url: activeSlice.appSpecificUris.cred, color: '#E2E8F0' },
            ].map((app) => (
              <button
                key={app.label}
                type="button"
                onClick={() => handleLaunchUpi(activeSlice, app.url)}
                style={{
                  flex: 1,
                  background: 'rgba(255, 255, 255, 0.05)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  borderRadius: 'var(--radius-sm)',
                  padding: '8px 4px',
                  color: app.color,
                  fontSize: '0.78rem',
                  fontWeight: 700,
                  cursor: 'pointer',
                }}
              >
                {app.label}
              </button>
            ))}
          </div>

          {/* Confirmation checkbox */}
          <div style={{ borderTop: '1px solid rgba(255, 255, 255, 0.08)', paddingTop: '14px', display: 'flex', gap: '10px' }}>
            <button
              type="button"
              onClick={() => handleMarkSliceDone(activeSliceIndex)}
              style={{
                flex: 1,
                background: 'rgba(16, 185, 129, 0.15)',
                border: '1px solid rgba(16, 185, 129, 0.3)',
                borderRadius: 'var(--radius-md)',
                padding: '12px',
                color: '#34D399',
                fontSize: '0.9rem',
                fontWeight: 600,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
              }}
            >
              <CheckCircle2 size={18} />
              <span>Confirm Slice {activeSlice.sliceNumber} Paid</span>
            </button>

            <button
              type="button"
              title="Copy raw upi:// URI"
              onClick={() => handleCopyUri(activeSlice.upiUri, activeSlice.id)}
              style={{
                background: 'rgba(255, 255, 255, 0.05)',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                borderRadius: 'var(--radius-md)',
                padding: '0 14px',
                color: 'var(--text-secondary)',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {copiedId === activeSlice.id ? <Check size={18} color="#10B981" /> : <Copy size={18} />}
            </button>
          </div>
        </div>
      )}

      {/* Slices Checklist */}
      <div className="glass-card" style={{ padding: '16px' }}>
        <div style={{ fontSize: '0.85rem', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '12px' }}>
          TRANCHE LEDGER
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {slices.map((slice, idx) => {
            const isCompleted = slice.status === 'completed';
            const isActive = idx === activeSliceIndex && !isAllCompleted;

            return (
              <div
                key={slice.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 14px',
                  background: isActive ? 'rgba(99, 102, 241, 0.12)' : 'rgba(255, 255, 255, 0.02)',
                  border: isActive ? '1px solid var(--primary)' : '1px solid rgba(255, 255, 255, 0.05)',
                  borderRadius: 'var(--radius-md)',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  {isCompleted ? (
                    <CheckCircle2 size={20} color="#10B981" />
                  ) : isActive ? (
                    <div className="pulsing" style={{ width: '20px', height: '20px', borderRadius: '50%', border: '2px solid #818CF8', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#818CF8' }} />
                    </div>
                  ) : (
                    <Circle size={20} color="#475569" />
                  )}
                  <div>
                    <div style={{ fontWeight: 600, fontSize: '0.9rem', color: isCompleted ? '#94A3B8' : '#FFFFFF' }}>
                      Slice #{slice.sliceNumber}
                    </div>
                    <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                      {isCompleted ? 'Authorized & Confirmed' : isActive ? 'Action Required' : 'Queued'}
                    </div>
                  </div>
                </div>

                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontWeight: 700, fontSize: '1rem', color: isCompleted ? '#94A3B8' : '#F8FAFC' }}>
                    ₹{slice.amount.toLocaleString('en-IN')}
                  </div>
                  {isCompleted && (
                    <span style={{ fontSize: '0.68rem', color: '#10B981', fontWeight: 600 }}>SUCCESS</span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
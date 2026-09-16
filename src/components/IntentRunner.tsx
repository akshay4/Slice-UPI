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
  const [dispatchedInfo, setDispatchedInfo] = useState<string | null>(null);

  const activeSlice = slices[activeSliceIndex];
  const completedCount = slices.filter((s) => s.status === 'completed').length;
  const isAllCompleted = completedCount === slices.length;

  const handleLaunchUpi = (slice: PaymentSlice, appUrl?: string) => {
    const targetUrl = appUrl || slice.upiUri;

    // Dispatch via anchor to prevent WebView navigation error
    try {
      const a = document.createElement('a');
      a.href = targetUrl;
      a.style.display = 'none';
      document.body.appendChild(a);
      a.click();
      setTimeout(() => {
        if (document.body.contains(a)) document.body.removeChild(a);
      }, 500);
    } catch (e) {
      console.warn('Could not launch intent', e);
    }

    setDispatchedInfo(`Dispatched slice #${slice.sliceNumber} (₹${slice.amount.toLocaleString('en-IN')})`);
    setTimeout(() => setDispatchedInfo(null), 5000);

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
      {/* Top Back Navigation */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button
          type="button"
          onClick={onReset}
          style={{
            background: 'transparent',
            border: 'none',
            color: '#1A73E8',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '0.85rem',
            fontWeight: 600,
            cursor: 'pointer',
          }}
        >
          <ArrowLeft size={16} /> Change Amount
        </button>

        <span
          style={{
            background: '#E8F0FE',
            color: '#1A73E8',
            padding: '4px 10px',
            borderRadius: 'var(--radius-pill)',
            fontSize: '0.75rem',
            fontWeight: 700,
          }}
        >
          Direct UPI Mode
        </span>
      </div>

      {/* Google Pay Recipient & Progress Card */}
      <div className="gpay-card" style={{ padding: '18px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '50%',
                background: 'linear-gradient(135deg, #1A73E8, #002970)',
                color: '#FFFFFF',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700,
                fontSize: '1rem',
              }}
            >
              {plan.payeeName.slice(0, 2).toUpperCase()}
            </div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '0.95rem', color: '#1F2937' }}>
                {plan.payeeName}
              </div>
              <div style={{ fontSize: '0.78rem', color: '#5F6368' }}>
                {plan.vpa}
              </div>
            </div>
          </div>

          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '0.72rem', color: '#5F6368', fontWeight: 600 }}>TOTAL</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 800, color: '#1A73E8' }}>
              ₹{plan.totalAmount.toLocaleString('en-IN')}
            </div>
          </div>
        </div>

        {/* Clean Google Progress Bar */}
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.78rem', color: '#5F6368', marginBottom: '6px' }}>
            <span>Progress: {completedCount} of {slices.length} paid</span>
            <span style={{ fontWeight: 600 }}>{Math.round((completedCount / slices.length) * 100)}%</span>
          </div>
          <div style={{ height: '6px', background: '#E8EAED', borderRadius: '3px', overflow: 'hidden' }}>
            <div
              style={{
                width: `${(completedCount / slices.length) * 100}%`,
                height: '100%',
                background: '#0F9D58',
                transition: 'width 0.3s ease',
              }}
            />
          </div>
        </div>
      </div>

      {/* Active Slice Action Box (Google Pay Payment Card) */}
      {!isAllCompleted && activeSlice && (
        <div
          className="gpay-card"
          style={{
            padding: '20px',
            border: '2px solid #1A73E8',
            background: '#FFFFFF',
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
            <span
              style={{
                fontSize: '0.75rem',
                color: '#1A73E8',
                fontWeight: 700,
                background: '#E8F0FE',
                padding: '3px 8px',
                borderRadius: 'var(--radius-pill)',
              }}
            >
              SLICE {activeSlice.sliceNumber} OF {activeSlice.totalSlices}
            </span>
            <span style={{ fontSize: '0.72rem', color: '#80868B', fontFamily: 'monospace' }}>
              Ref: {activeSlice.txnRef}
            </span>
          </div>

          <div style={{ textAlign: 'center', margin: '12px 0 16px 0' }}>
            <div style={{ fontSize: '2.4rem', fontWeight: 800, color: '#1F2937' }}>
              ₹{activeSlice.amount.toLocaleString('en-IN')}
            </div>
            <div style={{ fontSize: '0.78rem', color: '#0F9D58', fontWeight: 600, marginTop: '2px' }}>
              ✓ Below ₹2,000 threshold (0% Surcharge)
            </div>
          </div>

          {/* Dispatched feedback notification */}
          {dispatchedInfo && (
            <div
              style={{
                background: '#E6F4EA',
                border: '1px solid #CEEAD6',
                borderRadius: 'var(--radius-md)',
                padding: '10px',
                marginBottom: '12px',
                fontSize: '0.8rem',
                color: '#137333',
                textAlign: 'center',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '6px',
              }}
            >
              <CheckCircle2 size={16} />
              <span>{dispatchedInfo} &bull; Confirm payment below</span>
            </div>
          )}

          {/* Primary Pay Pill Button */}
          <button
            type="button"
            onClick={() => handleLaunchUpi(activeSlice)}
            className="btn-gpay"
            style={{ width: '100%', marginBottom: '10px' }}
          >
            <Smartphone size={18} />
            <span>Pay ₹{activeSlice.amount.toLocaleString('en-IN')} with UPI App</span>
          </button>

          {/* Quick Specific App Choosers */}
          <div style={{ display: 'flex', gap: '8px', justifyContent: 'center', marginBottom: '14px' }}>
            {[
              { label: 'GPay', url: activeSlice.appSpecificUris.gpay, color: '#1A73E8' },
              { label: 'PhonePe', url: activeSlice.appSpecificUris.phonepe, color: '#5F259F' },
              { label: 'Paytm', url: activeSlice.appSpecificUris.paytm, color: '#00BAF2' },
              { label: 'CRED', url: activeSlice.appSpecificUris.cred, color: '#374151' },
            ].map((app) => (
              <button
                key={app.label}
                type="button"
                onClick={() => handleLaunchUpi(activeSlice, app.url)}
                style={{
                  flex: 1,
                  background: '#F8F9FA',
                  border: '1px solid #DADCE0',
                  borderRadius: 'var(--radius-pill)',
                  padding: '7px 4px',
                  color: app.color,
                  fontSize: '0.78rem',
                  fontWeight: 700,
                  cursor: 'pointer',
                  transition: 'background 0.15s ease',
                }}
              >
                {app.label}
              </button>
            ))}
          </div>

          {/* Confirmation button */}
          <div style={{ borderTop: '1px solid #ECEFF1', paddingTop: '14px', display: 'flex', gap: '8px' }}>
            <button
              type="button"
              onClick={() => handleMarkSliceDone(activeSliceIndex)}
              style={{
                flex: 1,
                background: '#0F9D58',
                color: '#FFFFFF',
                border: 'none',
                borderRadius: 'var(--radius-pill)',
                padding: '11px',
                fontWeight: 600,
                fontSize: '0.88rem',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '6px',
                boxShadow: '0 2px 6px rgba(15, 157, 88, 0.3)',
              }}
            >
              <CheckCircle2 size={16} />
              <span>Confirm Slice {activeSlice.sliceNumber} Paid</span>
            </button>

            <button
              type="button"
              title="Copy UPI Deep Link"
              onClick={() => handleCopyUri(activeSlice.upiUri, activeSlice.id)}
              style={{
                background: '#F1F3F4',
                border: '1px solid #DADCE0',
                borderRadius: 'var(--radius-pill)',
                padding: '0 14px',
                color: '#5F6368',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              {copiedId === activeSlice.id ? <Check size={16} color="#0F9D58" /> : <Copy size={16} />}
            </button>
          </div>
        </div>
      )}

      {/* Tranches Overview List (Paytm / Google Pay Bill breakdown style) */}
      <div className="gpay-card" style={{ padding: '16px' }}>
        <div style={{ fontSize: '0.78rem', color: '#5F6368', fontWeight: 700, textTransform: 'uppercase', marginBottom: '12px', letterSpacing: '0.04em' }}>
          TRANCHE LEDGER
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {slices.map((slice, idx) => {
            const isCurrent = idx === activeSliceIndex;
            const isDone = slice.status === 'completed';

            return (
              <div
                key={slice.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 14px',
                  borderRadius: 'var(--radius-md)',
                  background: isDone ? '#F1F8F5' : isCurrent ? '#E8F0FE' : '#F8F9FA',
                  border: isCurrent ? '1px solid #1A73E8' : '1px solid #ECEFF1',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  {isDone ? (
                    <CheckCircle2 size={18} color="#0F9D58" />
                  ) : isCurrent ? (
                    <div
                      style={{
                        width: '18px',
                        height: '18px',
                        borderRadius: '50%',
                        border: '2px solid #1A73E8',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#1A73E8' }} />
                    </div>
                  ) : (
                    <Circle size={18} color="#BDC1C6" />
                  )}

                  <div>
                    <div style={{ fontWeight: 600, fontSize: '0.88rem', color: '#1F2937' }}>
                      Slice #{slice.sliceNumber}
                    </div>
                    <div style={{ fontSize: '0.72rem', color: isDone ? '#0F9D58' : isCurrent ? '#1A73E8' : '#80868B' }}>
                      {isDone ? 'Paid Successfully' : isCurrent ? 'Action Required' : 'Queued'}
                    </div>
                  </div>
                </div>

                <div style={{ fontWeight: 700, fontSize: '0.95rem', color: isDone ? '#0F9D58' : '#1F2937' }}>
                  ₹{slice.amount.toLocaleString('en-IN')}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
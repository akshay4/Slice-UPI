import React, { useEffect } from 'react';
import { CheckCircle2, ArrowRight, Sparkles, ShieldCheck } from 'lucide-react';
import confetti from 'canvas-confetti';
import { SplitPlan } from '../types';

interface Props {
  plan: SplitPlan;
  onNewPayment: () => void;
}

export const SummaryReceipt: React.FC<Props> = ({ plan, onNewPayment }) => {
  useEffect(() => {
    // Google Pay celebration confetti
    confetti({
      particleCount: 80,
      spread: 60,
      origin: { y: 0.5 },
      colors: ['#1A73E8', '#0F9D58', '#F9AB00', '#EA4335'],
    });
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '18px', textAlign: 'center', padding: '10px 0' }}>
      {/* Iconic Google Pay Success Badge */}
      <div className="gpay-card" style={{ padding: '30px 20px', background: '#FFFFFF' }}>
        <div
          style={{
            width: '72px',
            height: '72px',
            borderRadius: '50%',
            background: '#0F9D58',
            color: '#FFFFFF',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px auto',
            boxShadow: '0 6px 20px rgba(15, 157, 88, 0.35)',
          }}
        >
          <CheckCircle2 size={44} />
        </div>

        <div style={{ fontSize: '0.95rem', fontWeight: 600, color: '#5F6368' }}>
          Paid successfully to
        </div>
        <h2 style={{ fontSize: '1.25rem', fontWeight: 800, color: '#1F2937', marginTop: '2px' }}>
          {plan.payeeName}
        </h2>
        <div style={{ fontSize: '0.8rem', color: '#80868B', marginTop: '2px' }}>
          {plan.vpa}
        </div>

        {/* Big Paid Amount */}
        <div style={{ fontSize: '2.6rem', fontWeight: 800, color: '#1F2937', margin: '14px 0 10px 0' }}>
          ₹{plan.totalAmount.toLocaleString('en-IN')}
        </div>

        {/* Savings Badge */}
        {plan.estimatedFeeSavings > 0 && (
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              background: '#E6F4EA',
              color: '#137333',
              borderRadius: 'var(--radius-pill)',
              padding: '6px 14px',
              fontSize: '0.82rem',
              fontWeight: 700,
            }}
          >
            <Sparkles size={14} />
            <span>Saved ~₹{plan.estimatedFeeSavings} in interchange fees</span>
          </div>
        )}
      </div>

      {/* Clean Paytm Bill / Tranche Receipt */}
      <div className="gpay-card" style={{ padding: '18px', textAlign: 'left' }}>
        <div style={{ fontSize: '0.78rem', color: '#5F6368', fontWeight: 700, textTransform: 'uppercase', marginBottom: '12px', letterSpacing: '0.04em' }}>
          TRANSACTION BREAKDOWN
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '10px' }}>
          <span style={{ color: '#5F6368' }}>Execution Mode</span>
          <span style={{ fontWeight: 600, color: '#1F2937' }}>
            {plan.mode === 'intent' ? 'Direct UPI Slices' : '1-Click AutoPay Mandate'}
          </span>
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '12px' }}>
          <span style={{ color: '#5F6368' }}>Total Tranches</span>
          <span style={{ fontWeight: 600, color: '#1F2937' }}>
            {plan.slices.length} Tranches (All Settled)
          </span>
        </div>

        <div style={{ borderTop: '1px solid #ECEFF1', paddingTop: '10px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {plan.slices.map((slice) => (
            <div key={slice.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.82rem' }}>
              <span style={{ color: '#5F6368' }}>
                Slice #{slice.sliceNumber} ({slice.txnRef})
              </span>
              <span style={{ fontWeight: 700, color: '#0F9D58', display: 'flex', alignItems: 'center', gap: '4px' }}>
                ₹{slice.amount.toLocaleString('en-IN')} <CheckCircle2 size={13} />
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Done Button */}
      <button
        type="button"
        onClick={onNewPayment}
        className="btn-gpay"
        style={{ width: '100%', marginTop: '4px' }}
      >
        <span>Done &bull; Start New Payment</span>
        <ArrowRight size={18} />
      </button>

      {/* Verified Footer */}
      <div style={{ fontSize: '0.72rem', color: '#80868B', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
        <ShieldCheck size={14} color="#0F9D58" />
        <span>Transaction settled securely under NPCI Unified Payments Interface</span>
      </div>
    </div>
  );
};
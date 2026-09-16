import React, { useEffect } from 'react';
import { CheckCircle, ArrowRight, Sparkles } from 'lucide-react';
import confetti from 'canvas-confetti';
import { SplitPlan } from '../types';

interface Props {
  plan: SplitPlan;
  onNewPayment: () => void;
}

export const SummaryReceipt: React.FC<Props> = ({ plan, onNewPayment }) => {
  useEffect(() => {
    confetti({
      particleCount: 80,
      spread: 70,
      origin: { y: 0.6 },
    });
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
      {/* Success Badge */}
      <div className="glass-card" style={{ padding: '28px 20px', textAlign: 'center', background: 'linear-gradient(180deg, rgba(16, 185, 129, 0.15) 0%, rgba(18, 24, 38, 0.9) 100%)' }}>
        <div style={{ width: '64px', height: '64px', borderRadius: '50%', background: 'rgba(16, 185, 129, 0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
          <CheckCircle size={36} color="#34D399" />
        </div>

        <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#FFFFFF', marginBottom: '4px' }}>
          Payment Completed
        </h2>
        <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
          All {plan.slices.length} tranches successfully settled
        </div>

        <div style={{ fontSize: '2.4rem', fontWeight: 800, color: '#FFFFFF', margin: '18px 0 6px' }}>
          ₹{plan.totalAmount.toLocaleString('en-IN')}
        </div>

        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', background: 'rgba(99, 102, 241, 0.15)', padding: '6px 14px', borderRadius: '20px', fontSize: '0.8rem', color: '#A5B4FC', fontWeight: 600 }}>
          <Sparkles size={14} /> Saved ~₹{plan.estimatedFeeSavings} in Interchange Fees
        </div>
      </div>

      {/* Details Box */}
      <div className="glass-card" style={{ padding: '20px' }}>
        <div style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--text-secondary)', marginBottom: '14px', textTransform: 'uppercase' }}>
          SETTLEMENT LEDGER
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
            <span style={{ color: 'var(--text-muted)' }}>Beneficiary VPA</span>
            <span style={{ color: '#FFFFFF', fontWeight: 600 }}>{plan.vpa}</span>
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem' }}>
            <span style={{ color: 'var(--text-muted)' }}>Execution Mode</span>
            <span style={{ color: '#818CF8', fontWeight: 600 }}>
              {plan.mode === 'intent' ? 'Direct Sequential Intent' : 'Automated Escrow Mandate'}
            </span>
          </div>

          <div style={{ borderTop: '1px solid rgba(255, 255, 255, 0.08)', margin: '6px 0' }} />

          {plan.slices.map((slice) => (
            <div key={slice.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.82rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>
                Part #{slice.sliceNumber} ({slice.txnRef})
              </span>
              <span style={{ color: '#34D399', fontWeight: 600 }}>
                ₹{slice.amount.toLocaleString('en-IN')} ✓
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom Action */}
      <button
        type="button"
        onClick={onNewPayment}
        className="btn-primary"
        style={{ width: '100%' }}
      >
        <span>Start New Split Payment</span>
        <ArrowRight size={18} />
      </button>
    </div>
  );
};
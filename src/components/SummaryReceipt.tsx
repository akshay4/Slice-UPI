import React, { useEffect } from 'react';
import { CheckCircle2, ArrowRight, Sparkles, ShieldCheck, Building2 } from 'lucide-react';
import confetti from 'canvas-confetti';
import { SplitPlan } from '../types';

interface Props {
  plan: SplitPlan;
  onNewPayment: () => void;
}

export const SummaryReceipt: React.FC<Props> = ({ plan, onNewPayment }) => {
  useEffect(() => {
    // Material 3 celebration confetti
    confetti({
      particleCount: 80,
      spread: 60,
      origin: { y: 0.5 },
      colors: ['#0B57D0', '#146C2E', '#F9AB00', '#BA1A1A'],
    });
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', textAlign: 'center', padding: '6px 0' }}>
      {/* Material 3 Success Hero Card */}
      <div className="m3-card-outlined" style={{ padding: '32px 20px', background: 'var(--md-sys-color-surface-container-lowest)' }}>
        <div
          style={{
            width: '76px',
            height: '76px',
            borderRadius: 'var(--md-shape-corner-full)',
            background: 'var(--md-sys-color-tertiary-container)',
            color: 'var(--md-sys-color-tertiary)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px auto',
            boxShadow: 'var(--md-sys-elevation-level2)',
          }}
        >
          <CheckCircle2 size={46} strokeWidth={2.5} />
        </div>

        <div style={{ fontSize: '0.92rem', fontWeight: 600, color: 'var(--md-sys-color-on-surface-variant)' }}>
          Paid successfully to
        </div>
        <h2 style={{ fontSize: '1.35rem', fontWeight: 800, color: 'var(--md-sys-color-on-surface)', marginTop: '2px' }}>
          {plan.payeeName}
        </h2>
        <div style={{ fontSize: '0.8rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '2px' }}>
          {plan.vpa}
        </div>

        {/* Big Paid Amount (M3 Display Style) */}
        <div style={{ fontSize: '2.8rem', fontWeight: 800, color: 'var(--md-sys-color-on-surface)', margin: '14px 0 10px 0', letterSpacing: '-0.02em' }}>
          ₹{plan.totalAmount.toLocaleString('en-IN')}
        </div>

        {/* Savings Badge */}
        {plan.estimatedFeeSavings > 0 && (
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              background: 'var(--md-sys-color-tertiary-container)',
              color: 'var(--md-sys-color-on-tertiary-container)',
              borderRadius: 'var(--md-shape-corner-full)',
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

      {/* Material 3 Tranche Breakdown Card */}
      <div className="m3-card-outlined" style={{ padding: '18px', textAlign: 'left' }}>
        <div style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 700, textTransform: 'uppercase', marginBottom: '12px', letterSpacing: '0.04em' }}>
          TRANSACTION BREAKDOWN
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '10px' }}>
          <span style={{ color: 'var(--md-sys-color-on-surface-variant)' }}>Execution Engine</span>
          <span style={{ fontWeight: 700, color: 'var(--md-sys-color-primary)' }}>
            SlicePay In-App UPI Switch (Direct Bank Debit)
          </span>
        </div>

        {plan.debitAccountMasked && (
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '10px' }}>
            <span style={{ color: 'var(--md-sys-color-on-surface-variant)' }}>Debited Account</span>
            <span style={{ fontWeight: 600, color: 'var(--md-sys-color-on-surface)', display: 'flex', alignItems: 'center', gap: '4px' }}>
              <Building2 size={13} color="var(--md-sys-color-on-surface-variant)" />
              {plan.debitAccountMasked}
            </span>
          </div>
        )}

        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', marginBottom: '12px' }}>
          <span style={{ color: 'var(--md-sys-color-on-surface-variant)' }}>Total Tranches</span>
          <span style={{ fontWeight: 600, color: 'var(--md-sys-color-on-surface)' }}>
            {plan.slices.length} Tranche{plan.slices.length > 1 ? 's' : ''} (All Settled)
          </span>
        </div>

        <div style={{ borderTop: '1px solid var(--md-sys-color-outline-variant)', paddingTop: '10px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {plan.slices.map((slice) => (
            <div key={slice.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', fontSize: '0.82rem' }}>
              <div>
                <div style={{ fontWeight: 600, color: 'var(--md-sys-color-on-surface)' }}>
                  Slice #{slice.sliceNumber} &bull; ₹{slice.amount.toLocaleString('en-IN')}
                </div>
                <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '2px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  {slice.utr ? (
                    <>
                      <span style={{ color: 'var(--md-sys-color-primary)', fontWeight: 600 }}>NPCI UTR: {slice.utr}</span>
                      {slice.latencyMs && (
                        <span style={{ color: 'var(--md-sys-color-tertiary)', fontWeight: 600 }}>&bull; {slice.latencyMs}ms</span>
                      )}
                    </>
                  ) : (
                    <span>Ref: {slice.txnRef}</span>
                  )}
                </div>
              </div>
              <span style={{ fontWeight: 700, color: 'var(--md-sys-color-tertiary)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                Settled <CheckCircle2 size={14} />
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Done Button (Material 3 Filled Button) */}
      <button
        type="button"
        onClick={onNewPayment}
        className="m3-btn-filled"
        style={{ width: '100%', height: '52px', marginTop: '4px' }}
      >
        <span>Done &bull; Start New Payment</span>
        <ArrowRight size={18} />
      </button>

      {/* Verified Footer */}
      <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px' }}>
        <ShieldCheck size={14} color="var(--md-sys-color-tertiary)" />
        <span>Transaction settled securely under NPCI Unified Payments Interface</span>
      </div>
    </div>
  );
};
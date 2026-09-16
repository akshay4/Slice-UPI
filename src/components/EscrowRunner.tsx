import React, { useState } from 'react';
import { ArrowLeft, ShieldCheck, CheckCircle2, Clock, Lock } from 'lucide-react';
import { SplitPlan, EscrowMandate } from '../types';

interface Props {
  plan: SplitPlan;
  onReset: () => void;
  onCompleteAll: () => void;
}

export const EscrowRunner: React.FC<Props> = ({ plan, onReset, onCompleteAll }) => {
  const [mandate, setMandate] = useState<EscrowMandate>(() => ({
    mandateId: `MANDATE-${Date.now().toString().slice(-6)}`,
    totalAmount: plan.totalAmount,
    authorized: false,
    status: 'initiated',
    scheduledPayouts: plan.slices.map((slice, idx) => ({
      payoutId: `PAYOUT-${idx + 1}-${slice.txnRef}`,
      amount: slice.amount,
      delaySeconds: (idx + 1) * 2,
      status: 'scheduled',
    })),
  }));

  const [isAuthorizing, setIsAuthorizing] = useState(false);

  const handleAuthorizeMandate = () => {
    setIsAuthorizing(true);
    setTimeout(() => {
      setMandate((prev) => ({
        ...prev,
        authorized: true,
        status: 'authorized',
      }));
      setIsAuthorizing(false);
      startAutomatedPayoutPipeline();
    }, 1500);
  };

  const startAutomatedPayoutPipeline = () => {
    setMandate((prev) => ({ ...prev, status: 'dispersing' }));

    plan.slices.forEach((_, idx) => {
      setTimeout(() => {
        setMandate((prev) => {
          const updatedPayouts = prev.scheduledPayouts.map((p, pIdx) =>
            pIdx === idx
              ? { ...p, status: 'settled' as const, dispatchedAt: new Date().toLocaleTimeString() }
              : p
          );
          const allSettled = updatedPayouts.every((p) => p.status === 'settled');
          if (allSettled) {
            setTimeout(onCompleteAll, 800);
          }
          return {
            ...prev,
            status: allSettled ? 'completed' : 'dispersing',
            scheduledPayouts: updatedPayouts,
          };
        });
      }, (idx + 1) * 2200);
    });
  };

  const settledCount = mandate.scheduledPayouts.filter((p) => p.status === 'settled').length;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header */}
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
        <span style={{ fontSize: '0.8rem', color: '#34D399', fontWeight: 600, background: 'rgba(16, 185, 129, 0.15)', padding: '4px 10px', borderRadius: '20px' }}>
          Mode B: Automated Escrow
        </span>
      </div>

      {/* Overview Card */}
      <div className="glass-card" style={{ padding: '20px', border: '1px solid rgba(16, 185, 129, 0.3)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '14px' }}>
          <div>
            <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>
              RECIPIENT BENEFICIARY
            </div>
            <div style={{ fontSize: '1.1rem', fontWeight: 700, color: 'var(--text-primary)' }}>
              {plan.payeeName}
            </div>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
              {plan.vpa}
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ fontSize: '0.78rem', color: 'var(--text-muted)' }}>SINGLE AUTHORIZATION</div>
            <div style={{ fontSize: '1.4rem', fontWeight: 800, color: '#34D399' }}>
              ₹{plan.totalAmount.toLocaleString('en-IN')}
            </div>
          </div>
        </div>

        {/* Regulatory Escrow Tag */}
        <div style={{ background: 'rgba(255, 255, 255, 0.03)', borderRadius: 'var(--radius-sm)', padding: '10px 12px', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.78rem', color: 'var(--text-secondary)' }}>
          <Lock size={14} color="#10B981" />
          <span>RBI Regulated Nodal/Escrow Pipeline &bull; Mandate Ref: {mandate.mandateId}</span>
        </div>
      </div>

      {/* Main Action Box */}
      {!mandate.authorized ? (
        <div className="glass-card" style={{ padding: '20px', textAlign: 'center' }}>
          <div style={{ width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(16, 185, 129, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 12px' }}>
            <ShieldCheck size={32} color="#34D399" />
          </div>
          <div style={{ fontSize: '1.2rem', fontWeight: 700, color: '#FFFFFF', marginBottom: '6px' }}>
            1-Click e-Mandate Authorization
          </div>
          <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '18px', lineHeight: 1.4 }}>
            Approve total amount once via UPI AutoPay. The backend escrow engine will automatically disburse {plan.slices.length} staggered tranches directly to {plan.vpa}.
          </div>

          <button
            type="button"
            onClick={handleAuthorizeMandate}
            disabled={isAuthorizing}
            className="btn-primary"
            style={{ width: '100%', background: 'linear-gradient(135deg, #10B981 0%, #059669 100%)', boxShadow: '0 10px 25px -5px rgba(16, 185, 129, 0.4)' }}
          >
            {isAuthorizing ? 'Authorizing with UPI AutoPay...' : `Authorize ₹${plan.totalAmount.toLocaleString('en-IN')}`}
          </button>
        </div>
      ) : (
        <div className="glass-card" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div className="pulsing" style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#34D399' }} />
              <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#34D399' }}>
                AUTOMATED DISBURSEMENT IN PROGRESS
              </span>
            </div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>
              {settledCount}/{mandate.scheduledPayouts.length} Settled
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {mandate.scheduledPayouts.map((payout, idx) => {
              const isSettled = payout.status === 'settled';
              return (
                <div
                  key={payout.payoutId}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '12px 14px',
                    background: isSettled ? 'rgba(16, 185, 129, 0.1)' : 'rgba(255, 255, 255, 0.03)',
                    border: isSettled ? '1px solid rgba(16, 185, 129, 0.3)' : '1px solid rgba(255, 255, 255, 0.05)',
                    borderRadius: 'var(--radius-md)',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    {isSettled ? (
                      <CheckCircle2 size={18} color="#34D399" />
                    ) : (
                      <Clock size={18} color="#F59E0B" className="pulsing" />
                    )}
                    <div>
                      <div style={{ fontSize: '0.88rem', fontWeight: 600, color: isSettled ? '#FFFFFF' : '#94A3B8' }}>
                        Tranche {idx + 1} ({payout.status === 'settled' ? 'Dispatched' : 'Queued'})
                      </div>
                      <div style={{ fontSize: '0.72rem', color: 'var(--text-muted)' }}>
                        {payout.dispatchedAt ? `Settled at ${payout.dispatchedAt}` : `Stagger window +${payout.delaySeconds}s`}
                      </div>
                    </div>
                  </div>

                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontWeight: 700, fontSize: '0.95rem', color: '#FFFFFF' }}>
                      ₹{payout.amount.toLocaleString('en-IN')}
                    </div>
                    <span style={{ fontSize: '0.68rem', color: isSettled ? '#34D399' : '#F59E0B', fontWeight: 600 }}>
                      {payout.status.toUpperCase()}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};
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
    }, 1200);
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
      }, (idx + 1) * 2000);
    });
  };

  const settledCount = mandate.scheduledPayouts.filter((p) => p.status === 'settled').length;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Back Button */}
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
            background: '#E6F4EA',
            color: '#0F9D58',
            padding: '4px 10px',
            borderRadius: 'var(--radius-pill)',
            fontSize: '0.75rem',
            fontWeight: 700,
          }}
        >
          1-Click AutoPay
        </span>
      </div>

      {/* Beneficiary Overview Card */}
      <div className="gpay-card" style={{ padding: '18px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '50%',
                background: 'linear-gradient(135deg, #0F9D58, #002970)',
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
            <div style={{ fontSize: '0.72rem', color: '#5F6368', fontWeight: 600 }}>TOTAL MANDATE</div>
            <div style={{ fontSize: '1.25rem', fontWeight: 800, color: '#0F9D58' }}>
              ₹{plan.totalAmount.toLocaleString('en-IN')}
            </div>
          </div>
        </div>

        <div
          style={{
            marginTop: '12px',
            background: '#F1F3F4',
            borderRadius: 'var(--radius-sm)',
            padding: '8px 10px',
            fontSize: '0.75rem',
            color: '#5F6368',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
          }}
        >
          <Lock size={12} color="#1A73E8" />
          <span>RBI Regulated Nodal Pipeline &bull; Mandate Ref: {mandate.mandateId}</span>
        </div>
      </div>

      {/* 1-Click Mandate Authorization Box */}
      {!mandate.authorized ? (
        <div className="gpay-card" style={{ padding: '24px 20px', textAlign: 'center' }}>
          <div
            style={{
              width: '54px',
              height: '54px',
              borderRadius: '50%',
              background: '#E6F4EA',
              color: '#0F9D58',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 14px auto',
            }}
          >
            <ShieldCheck size={30} />
          </div>

          <h2 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#1F2937', marginBottom: '8px' }}>
            1-Click e-Mandate Authorization
          </h2>
          <p style={{ fontSize: '0.85rem', color: '#5F6368', lineHeight: 1.4, marginBottom: '20px' }}>
            Approve the total amount once via UPI AutoPay. The backend escrow engine will automatically disburse {plan.slices.length} staggered tranches directly to {plan.payeeName}.
          </p>

          <button
            type="button"
            onClick={handleAuthorizeMandate}
            disabled={isAuthorizing}
            className="btn-gpay"
            style={{ width: '100%', background: '#0F9D58' }}
          >
            {isAuthorizing ? (
              <span>Authenticating Mandate...</span>
            ) : (
              <>
                <ShieldCheck size={18} />
                <span>Authorize ₹{plan.totalAmount.toLocaleString('en-IN')}</span>
              </>
            )}
          </button>
        </div>
      ) : (
        /* Live Automated Dispersal Pipeline */
        <div className="gpay-card" style={{ padding: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div
                style={{
                  width: '10px',
                  height: '10px',
                  borderRadius: '50%',
                  background: '#0F9D58',
                }}
                className="pulsing"
              />
              <span style={{ fontSize: '0.85rem', fontWeight: 700, color: '#1F2937' }}>
                Automated Payout in Progress
              </span>
            </div>
            <span style={{ fontSize: '0.78rem', color: '#5F6368' }}>
              {settledCount}/{mandate.scheduledPayouts.length} Settled
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
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
                    borderRadius: 'var(--radius-md)',
                    background: isSettled ? '#F1F8F5' : '#F8F9FA',
                    border: isSettled ? '1px solid #CEEAD6' : '1px solid #ECEFF1',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    {isSettled ? (
                      <CheckCircle2 size={18} color="#0F9D58" />
                    ) : (
                      <Clock size={18} color="#F9AB00" className="pulsing" />
                    )}
                    <div>
                      <div style={{ fontWeight: 600, fontSize: '0.88rem', color: '#1F2937' }}>
                        Tranche #{idx + 1}
                      </div>
                      <div style={{ fontSize: '0.72rem', color: isSettled ? '#0F9D58' : '#80868B' }}>
                        {isSettled ? `Dispatched at ${payout.dispatchedAt}` : `Stagger window +${payout.delaySeconds}s`}
                      </div>
                    </div>
                  </div>

                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontWeight: 700, fontSize: '0.95rem', color: isSettled ? '#0F9D58' : '#1F2937' }}>
                      ₹{payout.amount.toLocaleString('en-IN')}
                    </div>
                    <span
                      style={{
                        fontSize: '0.7rem',
                        fontWeight: 700,
                        color: isSettled ? '#0F9D58' : '#B06000',
                      }}
                    >
                      {isSettled ? 'SETTLED' : 'SCHEDULED'}
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
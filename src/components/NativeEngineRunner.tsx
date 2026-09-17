import React, { useState, useEffect, useRef } from 'react';
import {
  ArrowLeft,
  ShieldCheck,
  CheckCircle2,
  ChevronRight,
  Sparkles,
  Zap,
  Terminal,
  Building2,
  Check,
  AlertTriangle,
} from 'lucide-react';
import { SplitPlan, PaymentSlice, BankAccount, UpiEngineLog } from '../types';
import {
  getAccountById,
  executeNativeSlice,
} from '../services/nativeEngineService';
import { MpinModal } from './MpinModal';
import { BankAccountDrawer } from './BankAccountDrawer';

interface Props {
  plan: SplitPlan;
  onReset: () => void;
  onCompleteAll: (updatedPlan: SplitPlan) => void;
}

export const NativeEngineRunner: React.FC<Props> = ({
  plan,
  onReset,
  onCompleteAll,
}) => {
  const [slices, setSlices] = useState<PaymentSlice[]>(plan.slices);
  const [account, setAccount] = useState<BankAccount>(() =>
    getAccountById(plan.selectedAccountId)
  );
  const [isMpinOpen, setIsMpinOpen] = useState<boolean>(false);
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);
  const [isExecuting, setIsExecuting] = useState<boolean>(false);
  const [activeSliceIndex, setActiveSliceIndex] = useState<number>(0);
  const [logs, setLogs] = useState<UpiEngineLog[]>([]);
  const [showLogs, setShowLogs] = useState<boolean>(true);
  const [engineError, setEngineError] = useState<string | null>(null);

  const logsEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (showLogs && logsEndRef.current) {
      logsEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [logs, showLogs]);

  const completedCount = slices.filter((s) => s.status === 'completed').length;
  const isAllDone = completedCount === slices.length;

  const handleStartPayment = () => {
    setEngineError(null);
    setIsMpinOpen(true);
  };

  const handleMpinSuccess = async (_mpin: string) => {
    setIsMpinOpen(false);
    setIsExecuting(true);
    setEngineError(null);

    const updatedSlices = [...slices];

    // Add initial authentication log
    setLogs((prev) => [
      ...prev,
      {
        id: `log-auth-${Date.now()}`,
        timestamp: new Date().toLocaleTimeString('en-IN', { hour12: false }),
        step: 'AUTH',
        message: `NPCI Common Library: Authenticated via 256-bit MPIN. Initializing SlicePay Switch...`,
      },
    ]);

    // Sequentially process each slice natively
    for (let i = 0; i < updatedSlices.length; i++) {
      // Skip already completed slices on retry
      if (updatedSlices[i].status === 'completed') continue;

      setActiveSliceIndex(i);
      updatedSlices[i] = { ...updatedSlices[i], status: 'processing' };
      setSlices([...updatedSlices]);

      try {
        const result = await executeNativeSlice(
          updatedSlices[i],
          account,
          (newLog) => setLogs((prev) => [...prev, newLog])
        );

        updatedSlices[i] = {
          ...updatedSlices[i],
          status: 'completed',
          utr: result.utr,
          rrn: result.rrn,
          latencyMs: result.latencyMs,
          timestamp: result.timestamp,
        };
        setAccount(result.updatedAccount);
        setSlices([...updatedSlices]);
      } catch (err: any) {
        const errMsg = err?.message || 'Switch connection interrupted';
        updatedSlices[i] = {
          ...updatedSlices[i],
          status: 'failed',
          failureReason: errMsg,
        };
        setSlices([...updatedSlices]);
        setEngineError(errMsg);
        setIsExecuting(false);
        return;
      }
    }

    setIsExecuting(false);

    // Update parent plan with completed slices and debit account info
    const finalPlan: SplitPlan = {
      ...plan,
      slices: updatedSlices,
      selectedAccountId: account.id,
      debitAccountMasked: `${account.bankName} ${account.accountNumberMasked}`,
    };

    setTimeout(() => {
      onCompleteAll(finalPlan);
    }, 1000);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Top Navigation */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button
          type="button"
          onClick={onReset}
          disabled={isExecuting}
          style={{
            background: 'transparent',
            border: 'none',
            color: 'var(--md-sys-color-primary)',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '0.85rem',
            fontWeight: 600,
            cursor: isExecuting ? 'not-allowed' : 'pointer',
            opacity: isExecuting ? 0.5 : 1,
            padding: '4px 0',
          }}
        >
          <ArrowLeft size={16} /> Change Amount
        </button>

        {/* M3 Assist / Status Chip */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            background: 'var(--md-sys-color-tertiary-container)',
            color: 'var(--md-sys-color-on-tertiary-container)',
            padding: '5px 12px',
            borderRadius: 'var(--md-shape-corner-full)',
            fontSize: '0.74rem',
            fontWeight: 700,
          }}
        >
          <Zap size={14} />
          <span>In-App Switch Active</span>
        </div>
      </div>

      {/* Linked Bank Account Card (M3 Outlined Card) */}
      <div
        className="m3-card-outlined"
        style={{
          padding: '14px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div
            style={{
              width: '42px',
              height: '42px',
              borderRadius: 'var(--md-shape-corner-md)',
              background: account.color,
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 800,
              fontSize: '0.88rem',
            }}
          >
            {account.bankCode}
          </div>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span style={{ fontSize: '0.9rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)' }}>
                {account.bankName}
              </span>
              <span style={{ fontSize: '0.74rem', color: 'var(--md-sys-color-on-surface-variant)' }}>
                {account.accountNumberMasked}
              </span>
            </div>
            <div style={{ fontSize: '0.74rem', color: 'var(--md-sys-color-tertiary)', fontWeight: 600, marginTop: '2px' }}>
              Avail: ₹{account.balance.toLocaleString('en-IN', { minimumFractionDigits: 2 })} &bull; {account.vpa}
            </div>
          </div>
        </div>

        {/* M3 Tonal Button for Switch Account */}
        <button
          type="button"
          onClick={() => setIsDrawerOpen(true)}
          disabled={isExecuting}
          className="m3-btn-tonal"
          style={{ height: '34px', padding: '0 12px', fontSize: '0.75rem' }}
        >
          <span>Change</span>
          <ChevronRight size={14} />
        </button>
      </div>

      {/* Engine Error Alert Banner */}
      {engineError && (
        <div
          style={{
            background: 'var(--md-sys-color-error-container)',
            color: 'var(--md-sys-color-on-error-container)',
            borderRadius: 'var(--md-shape-corner-md)',
            padding: '12px 14px',
            fontSize: '0.8rem',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '10px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <AlertTriangle size={18} color="var(--md-sys-color-error)" />
            <span style={{ fontWeight: 600 }}>{engineError}</span>
          </div>
          <button
            type="button"
            onClick={() => setIsDrawerOpen(true)}
            className="m3-btn-tonal"
            style={{
              height: '30px',
              padding: '0 10px',
              fontSize: '0.72rem',
              background: '#FFFFFF',
              color: 'var(--md-sys-color-error)',
              fontWeight: 700,
            }}
          >
            Switch Bank
          </button>
        </div>
      )}

      {/* Payment Summary Header (M3 Elevated Hero Card) */}
      <div
        style={{
          background: 'linear-gradient(135deg, var(--md-sys-color-primary) 0%, #002970 100%)',
          borderRadius: 'var(--md-shape-corner-xl)',
          padding: '20px',
          color: '#FFFFFF',
          boxShadow: 'var(--md-sys-elevation-level2)',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <span style={{ fontSize: '0.76rem', color: '#D2E3FC', fontWeight: 500 }}>
              Paying Beneficiary
            </span>
            <h2 style={{ fontSize: '1.25rem', fontWeight: 700, margin: '2px 0 0', letterSpacing: '-0.01em' }}>
              {plan.payeeName}
            </h2>
            <div style={{ fontSize: '0.78rem', color: '#E8F0FE', marginTop: '2px' }}>
              {plan.vpa}
            </div>
          </div>

          <div style={{ textAlign: 'right' }}>
            <span style={{ fontSize: '0.72rem', color: '#D2E3FC' }}>Total Amount</span>
            <div style={{ fontSize: '1.6rem', fontWeight: 800, letterSpacing: '-0.02em' }}>
              ₹{plan.totalAmount.toLocaleString('en-IN')}
            </div>
          </div>
        </div>

        {/* Regulatory & Split Banner */}
        <div
          style={{
            marginTop: '14px',
            paddingTop: '12px',
            borderTop: '1px solid rgba(255, 255, 255, 0.18)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            fontSize: '0.75rem',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Sparkles size={14} color="#FDD663" />
            <span>
              {plan.totalAmount >= 2000
                ? `Split into ${slices.length} tranches (< ₹2,000) • 0% Surcharge`
                : 'Direct In-App Settlement (Sub-₹2,000)'}
            </span>
          </div>

          {plan.estimatedFeeSavings > 0 && (
            <span
              style={{
                background: 'rgba(255, 255, 255, 0.2)',
                padding: '2px 8px',
                borderRadius: '10px',
                fontWeight: 700,
                color: '#FFF',
              }}
            >
              Save ₹{plan.estimatedFeeSavings}
            </span>
          )}
        </div>
      </div>

      {/* Slices List */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 4px' }}>
          <span style={{ fontSize: '0.82rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)' }}>
            Payment Tranches ({completedCount}/{slices.length} Settled)
          </span>
          <span style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)' }}>
            SlicePay Switch
          </span>
        </div>

        {slices.map((slice, index) => {
          const isCurrent = isExecuting && index === activeSliceIndex;
          const isDone = slice.status === 'completed';

          return (
            <div
              key={slice.id}
              style={{
                background: isDone
                  ? 'var(--md-sys-color-surface-container-low)'
                  : isCurrent
                  ? 'var(--md-sys-color-surface-container-lowest)'
                  : 'var(--md-sys-color-surface-container-low)',
                border: isCurrent
                  ? '2px solid var(--md-sys-color-primary)'
                  : isDone
                  ? '1px solid var(--md-sys-color-outline-variant)'
                  : '1px solid var(--md-sys-color-outline-variant)',
                borderRadius: 'var(--md-shape-corner-md)',
                padding: '12px 14px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                transition: 'all 0.2s ease',
                boxShadow: isCurrent ? 'var(--md-sys-elevation-level2)' : 'none',
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div
                  style={{
                    width: '34px',
                    height: '34px',
                    borderRadius: 'var(--md-shape-corner-full)',
                    background: isDone
                      ? 'var(--md-sys-color-tertiary-container)'
                      : isCurrent
                      ? 'var(--md-sys-color-primary-container)'
                      : 'var(--md-sys-color-surface-container-high)',
                    color: isDone
                      ? 'var(--md-sys-color-on-tertiary-container)'
                      : isCurrent
                      ? 'var(--md-sys-color-primary)'
                      : 'var(--md-sys-color-on-surface-variant)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontWeight: 700,
                    fontSize: '0.8rem',
                  }}
                >
                  {isDone ? <Check size={16} strokeWidth={3} /> : slice.sliceNumber}
                </div>

                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <span style={{ fontSize: '0.92rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)' }}>
                      ₹{slice.amount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                    </span>
                    <span
                      style={{
                        fontSize: '0.68rem',
                        color: isDone ? 'var(--md-sys-color-tertiary)' : 'var(--md-sys-color-on-surface-variant)',
                        background: isDone ? 'var(--md-sys-color-tertiary-container)' : 'var(--md-sys-color-surface-container-high)',
                        padding: '2px 8px',
                        borderRadius: 'var(--md-shape-corner-full)',
                        fontWeight: 600,
                      }}
                    >
                      {isDone ? 'Settled' : isCurrent ? 'Debiting...' : 'Pending'}
                    </span>
                  </div>

                  <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '2px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                    {slice.utr ? (
                      <>
                        <span style={{ color: 'var(--md-sys-color-primary)', fontWeight: 600 }}>
                          UTR: {slice.utr}
                        </span>
                        {slice.latencyMs && (
                          <span style={{ color: 'var(--md-sys-color-tertiary)', fontSize: '0.68rem', fontWeight: 600 }}>
                            &bull; {slice.latencyMs}ms
                          </span>
                        )}
                      </>
                    ) : (
                      <span>Ref: {slice.txnRef}</span>
                    )}
                  </div>
                </div>
              </div>

              <div style={{ textAlign: 'right' }}>
                {isDone ? (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--md-sys-color-tertiary)', fontSize: '0.75rem', fontWeight: 600 }}>
                    <CheckCircle2 size={16} />
                    <span>0% Fee</span>
                  </div>
                ) : isCurrent ? (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--md-sys-color-primary)', fontSize: '0.75rem', fontWeight: 600 }}>
                    <div className="spinner-border" role="status" style={{ width: '14px', height: '14px' }} />
                    <span>Switching...</span>
                  </div>
                ) : (
                  <span style={{ fontSize: '0.74rem', color: 'var(--md-sys-color-outline)' }}>
                    Queued
                  </span>
                )}
              </div>
            </div>
          );
        })}
      </div>

      {/* Live Banking Switch Console / Logs (M3 Terminal Card) */}
      {logs.length > 0 && (
        <div
          style={{
            background: '#1E293B',
            borderRadius: 'var(--md-shape-corner-lg)',
            padding: '14px 16px',
            color: '#E2E8F0',
            fontSize: '0.72rem',
            fontFamily: 'monospace',
            boxShadow: 'var(--md-sys-elevation-level2)',
          }}
        >
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              borderBottom: '1px solid #334155',
              paddingBottom: '6px',
              marginBottom: '8px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#38BDF8', fontWeight: 700 }}>
              <Terminal size={14} />
              <span>SlicePay In-App Switch Stream</span>
            </div>
            <button
              type="button"
              onClick={() => setShowLogs(!showLogs)}
              style={{
                background: 'transparent',
                border: 'none',
                color: '#94A3B8',
                fontSize: '0.7rem',
                cursor: 'pointer',
              }}
            >
              {showLogs ? 'Hide' : 'Show'}
            </button>
          </div>

          {showLogs && (
            <div style={{ maxHeight: '120px', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '4px' }}>
              {logs.map((l) => (
                <div key={l.id} style={{ display: 'flex', gap: '8px' }}>
                  <span style={{ color: '#64748B' }}>[{l.timestamp}]</span>
                  <span
                    style={{
                      color:
                        l.step === 'SETTLED'
                          ? '#4ADE80'
                          : l.step === 'DEBIT'
                          ? '#FCD34D'
                          : l.step === 'CREDIT'
                          ? '#38BDF8'
                          : '#94A3B8',
                      fontWeight: 600,
                    }}
                  >
                    {l.step}:
                  </span>
                  <span>{l.message}</span>
                </div>
              ))}
              <div ref={logsEndRef} />
            </div>
          )}
        </div>
      )}

      {/* Primary Action Button (Material 3 Filled Button) */}
      {!isAllDone && (
        <button
          type="button"
          onClick={handleStartPayment}
          disabled={isExecuting}
          className="m3-btn-filled"
          style={{ width: '100%', height: '52px', fontSize: '0.96rem' }}
        >
          <ShieldCheck size={20} />
          <span>
            {isExecuting
              ? 'Processing In-App Switch...'
              : `Pay ₹${plan.totalAmount.toLocaleString('en-IN')} with SlicePay Engine`}
          </span>
        </button>
      )}

      {/* Trust Guarantee Footnote */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: '6px',
          fontSize: '0.72rem',
          color: 'var(--md-sys-color-on-surface-variant)',
        }}
      >
        <Building2 size={14} color="var(--md-sys-color-primary)" />
        <span>No external apps needed &bull; Direct Bank-to-Bank Settlement</span>
      </div>

      {/* In-App NPCI MPIN Modal */}
      <MpinModal
        isOpen={isMpinOpen}
        amount={plan.totalAmount}
        payeeName={plan.payeeName}
        payeeVpa={plan.vpa}
        account={account}
        sliceDescription={
          plan.totalAmount >= 2000
            ? `SlicePay Multi-Tranche (${slices.length} slices < ₹2,000)`
            : 'SlicePay Direct Bank Transfer'
        }
        onSuccess={handleMpinSuccess}
        onClose={() => setIsMpinOpen(false)}
      />

      {/* Bank Account Drawer */}
      <BankAccountDrawer
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
        selectedAccountId={account.id}
        onSelectAccount={(acc) => {
          setAccount(acc);
          setIsDrawerOpen(false);
        }}
      />
    </div>
  );
};

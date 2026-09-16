import React, { useState } from 'react';
import { SplitPlan } from './types';
import { SplitCalculator } from './components/SplitCalculator';
import { IntentRunner } from './components/IntentRunner';
import { EscrowRunner } from './components/EscrowRunner';
import { SummaryReceipt } from './components/SummaryReceipt';
import { ComplianceModal } from './components/ComplianceModal';
import { HelpCircle } from 'lucide-react';

export const App: React.FC = () => {
  const [currentPlan, setCurrentPlan] = useState<SplitPlan | null>(null);
  const [isCompleted, setIsCompleted] = useState<boolean>(false);
  const [isComplianceOpen, setIsComplianceOpen] = useState<boolean>(false);

  const handleReset = () => {
    setCurrentPlan(null);
    setIsCompleted(false);
  };

  return (
    <div
      style={{
        padding: '20px 16px',
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100vh',
        background: '#FFFFFF',
      }}
    >
      {/* Top Google Pay / Paytm App Header */}
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '20px',
          paddingBottom: '12px',
          borderBottom: '1px solid #ECEFF1',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          {/* GPay/Paytm Style App Icon */}
          <div
            style={{
              width: '38px',
              height: '38px',
              borderRadius: '12px',
              background: 'linear-gradient(135deg, #1A73E8 0%, #002970 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 2px 8px rgba(26, 115, 232, 0.3)',
            }}
          >
            <span style={{ fontWeight: 800, fontSize: '1.2rem', color: '#FFFFFF' }}>₹</span>
          </div>

          <div>
            <h1
              style={{
                fontSize: '1.25rem',
                fontWeight: 800,
                color: '#1F2937',
                letterSpacing: '-0.02em',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
              }}
            >
              Slice<span style={{ color: '#1A73E8' }}>UPI</span>
            </h1>
            <p style={{ fontSize: '0.72rem', color: '#5F6368', marginTop: '1px' }}>
              Zero-Fee Slicing &bull; AutoPay Mandates
            </p>
          </div>
        </div>

        {/* Legal & Info Button */}
        <button
          onClick={() => setIsComplianceOpen(true)}
          style={{
            background: '#F1F3F4',
            border: 'none',
            borderRadius: 'var(--radius-pill)',
            padding: '6px 12px',
            color: '#3C4043',
            fontSize: '0.78rem',
            fontWeight: 600,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
            transition: 'background 0.15s ease',
          }}
        >
          <HelpCircle size={15} color="#1A73E8" />
          <span>Rules Guide</span>
        </button>
      </header>

      {/* Main View Flow */}
      <main style={{ flex: 1 }}>
        {!currentPlan ? (
          <SplitCalculator
            onPlanCreated={(plan) => setCurrentPlan(plan)}
            onOpenCompliance={() => setIsComplianceOpen(true)}
          />
        ) : isCompleted ? (
          <SummaryReceipt
            plan={currentPlan}
            onNewPayment={handleReset}
          />
        ) : currentPlan.mode === 'intent' ? (
          <IntentRunner
            plan={currentPlan}
            onReset={handleReset}
            onCompleteAll={() => setIsCompleted(true)}
          />
        ) : (
          <EscrowRunner
            plan={currentPlan}
            onReset={handleReset}
            onCompleteAll={() => setIsCompleted(true)}
          />
        )}
      </main>

      {/* Google Pay / Paytm Trust Footer */}
      <footer
        style={{
          marginTop: '28px',
          textAlign: 'center',
          fontSize: '0.72rem',
          color: '#80868B',
          borderTop: '1px solid #ECEFF1',
          paddingTop: '14px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: '4px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 600, color: '#5F6368' }}>
          <span>NPCI Unified Payments Interface</span>
          <span>&bull;</span>
          <span>RBI AutoPay Compliant</span>
        </div>
        <div>
          SliceUPI &bull; Direct Bank-to-Bank 0% Surcharge Engine
        </div>
      </footer>

      {/* Compliance Modal */}
      <ComplianceModal
        isOpen={isComplianceOpen}
        onClose={() => setIsComplianceOpen(false)}
      />
    </div>
  );
};

export default App;
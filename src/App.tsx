import React, { useState } from 'react';
import { SplitPlan } from './types';
import { SplitCalculator } from './components/SplitCalculator';
import { NativeEngineRunner } from './components/NativeEngineRunner';
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
        padding: '16px 16px 24px',
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100vh',
        background: 'var(--md-sys-color-surface)',
      }}
    >
      {/* Material 3 Top App Bar */}
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '16px',
          paddingBottom: '12px',
          borderBottom: '1px solid var(--md-sys-color-outline-variant)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          {/* M3 Primary Icon Container */}
          <div
            style={{
              width: '40px',
              height: '40px',
              borderRadius: 'var(--md-shape-corner-md)',
              background: 'var(--md-sys-color-primary)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: 'var(--md-sys-elevation-level1)',
            }}
          >
            <span style={{ fontWeight: 800, fontSize: '1.25rem', color: 'var(--md-sys-color-on-primary)' }}>₹</span>
          </div>

          <div>
            <h1
              style={{
                fontSize: '1.3rem',
                fontWeight: 800,
                color: 'var(--md-sys-color-on-surface)',
                letterSpacing: '-0.02em',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                margin: 0,
              }}
            >
              Slice<span style={{ color: 'var(--md-sys-color-primary)' }}>UPI</span>
            </h1>
            <p style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '2px', margin: 0 }}>
              Autonomous In-App Switch &bull; Material 3 Design
            </p>
          </div>
        </div>

        {/* M3 Tonal Action Button */}
        <button
          onClick={() => setIsComplianceOpen(true)}
          className="m3-btn-tonal"
          style={{ height: '36px', padding: '0 12px', fontSize: '0.76rem' }}
        >
          <HelpCircle size={15} color="var(--md-sys-color-primary)" />
          <span>Rules Guide</span>
        </button>
      </header>

      {/* Main View Flow: Unified Native Engine */}
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
        ) : (
          <NativeEngineRunner
            plan={currentPlan}
            onReset={handleReset}
            onCompleteAll={(updatedPlan) => {
              setCurrentPlan(updatedPlan);
              setIsCompleted(true);
            }}
          />
        )}
      </main>

      {/* Material 3 Trust Footer */}
      <footer
        style={{
          marginTop: '28px',
          textAlign: 'center',
          fontSize: '0.72rem',
          color: 'var(--md-sys-color-on-surface-variant)',
          borderTop: '1px solid var(--md-sys-color-outline-variant)',
          paddingTop: '14px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: '4px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 600 }}>
          <span>NPCI Unified Payments Interface</span>
          <span>&bull;</span>
          <span>SlicePay In-App Switch</span>
        </div>
        <div style={{ color: 'var(--md-sys-color-outline)' }}>
          Material You Design System &bull; 0% MDR Surcharge Engine
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
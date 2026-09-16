import React, { useState } from 'react';
import { SplitPlan } from './types';
import { SplitCalculator } from './components/SplitCalculator';
import { IntentRunner } from './components/IntentRunner';
import { EscrowRunner } from './components/EscrowRunner';
import { SummaryReceipt } from './components/SummaryReceipt';
import { ComplianceModal } from './components/ComplianceModal';
import { Info } from 'lucide-react';

export const App: React.FC = () => {
  const [currentPlan, setCurrentPlan] = useState<SplitPlan | null>(null);
  const [isCompleted, setIsCompleted] = useState<boolean>(false);
  const [isComplianceOpen, setIsComplianceOpen] = useState<boolean>(false);

  const handleReset = () => {
    setCurrentPlan(null);
    setIsCompleted(false);
  };

  return (
    <div style={{ padding: '24px 20px', display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      {/* Top App Header */}
      <header style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '10px', background: 'linear-gradient(135deg, #6366F1, #10B981)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 12px rgba(99, 102, 241, 0.35)' }}>
              <span style={{ fontWeight: 800, fontSize: '1rem', color: '#FFF' }}>₹</span>
            </div>
            <div>
              <h1 style={{ fontSize: '1.3rem', fontWeight: 800, color: '#FFFFFF', letterSpacing: '-0.02em', display: 'flex', alignItems: 'center', gap: '4px' }}>
                Slice<span style={{ color: '#10B981' }}>UPI</span>
              </h1>
            </div>
          </div>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '2px' }}>
            Smart Multi-Tranche & Escrow Payment Engine
          </p>
        </div>

        <button
          onClick={() => setIsComplianceOpen(true)}
          style={{
            background: 'rgba(255, 255, 255, 0.05)',
            border: '1px solid rgba(255, 255, 255, 0.1)',
            borderRadius: 'var(--radius-sm)',
            padding: '6px 10px',
            color: 'var(--text-secondary)',
            fontSize: '0.75rem',
            fontWeight: 600,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '5px',
          }}
        >
          <Info size={14} /> Legal Guide
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

      {/* Footer */}
      <footer style={{ marginTop: '30px', textAlign: 'center', fontSize: '0.72rem', color: 'var(--text-muted)', borderTop: '1px solid rgba(255, 255, 255, 0.05)', paddingTop: '16px' }}>
        <span>SliceUPI &bull; NPCI & RBI Framework Compliant &bull; Android & iOS Unified Core</span>
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
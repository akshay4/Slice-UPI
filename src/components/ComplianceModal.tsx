import React from 'react';
import { X, ShieldAlert, Scale, CheckCircle } from 'lucide-react';

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

export const ComplianceModal: React.FC<Props> = ({ isOpen, onClose }) => {
  if (!isOpen) return null;

  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'rgba(0, 0, 0, 0.75)',
      backdropFilter: 'blur(8px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      zIndex: 100,
    }}>
      <div className="glass-card" style={{
        maxWidth: '440px',
        width: '100%',
        maxHeight: '85vh',
        overflowY: 'auto',
        padding: '24px',
        border: '1px solid rgba(255, 255, 255, 0.15)',
      }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Scale size={22} color="#818CF8" />
            <h3 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#FFFFFF' }}>
              Legal & NPCI Regulatory Guide
            </h3>
          </div>
          <button
            onClick={onClose}
            style={{ background: 'transparent', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}
          >
            <X size={20} />
          </button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.85rem', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
          <div style={{ background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.3)', borderRadius: 'var(--radius-sm)', padding: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#FCA5A5', fontWeight: 700, marginBottom: '4px' }}>
              <ShieldAlert size={16} /> PMLA & Anti-Structuring (Smurfing) Rules
            </div>
            <div>
              Artificially breaking large sums into smaller amounts to bypass regulatory tax reporting or merchant interchange rules is strictly monitored under the Prevention of Money Laundering Act (PMLA). Rapid identical transfers can trigger algorithmic bank velocity locks.
            </div>
          </div>

          <div>
            <h4 style={{ color: '#FFFFFF', fontWeight: 600, marginBottom: '4px' }}>Mode A: Why MPIN is needed for each slice</h4>
            NPCI's Common Library requires explicit two-factor authentication (MPIN) for every single UPI transaction. Third-party apps cannot execute silent background debits. Mode A organizes this as an authorized sequential intent chain.
          </div>

          <div>
            <h4 style={{ color: '#FFFFFF', fontWeight: 600, marginBottom: '4px' }}>Mode B: Escrow & Nodal Compliance</h4>
            To automate payouts with 1 consent, the platform must operate under RBI Payment Aggregator (PA) guidelines with a designated nodal escrow account (T+1 / T+2 settlement cycles).
          </div>

          <div style={{ background: 'rgba(16, 185, 129, 0.1)', border: '1px solid rgba(16, 185, 129, 0.2)', borderRadius: 'var(--radius-sm)', padding: '12px', color: '#6EE7B7' }}>
            <div style={{ fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '2px' }}>
              <CheckCircle size={15} /> Safe Usage Recommendation
            </div>
            Use the Anti-Velocity Jitter feature and stagger transfers across distinct intervals or multi-source payment accounts for genuine bill splitting.
          </div>
        </div>

        <button
          type="button"
          onClick={onClose}
          className="btn-primary"
          style={{ width: '100%', marginTop: '20px', padding: '10px' }}
        >
          Understood & Acknowledge
        </button>
      </div>
    </div>
  );
};
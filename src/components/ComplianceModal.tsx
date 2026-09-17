import React from 'react';
import { X, ShieldAlert, Scale, AlertTriangle, CheckCircle } from 'lucide-react';

interface Props {
  isOpen: boolean;
  onClose: () => void;
}

export const ComplianceModal: React.FC<Props> = ({ isOpen, onClose }) => {
  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(0, 0, 0, 0.6)',
        backdropFilter: 'blur(4px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
        zIndex: 9999,
      }}
      onClick={onClose}
    >
      <div
        className="m3-card-outlined"
        style={{
          width: '100%',
          maxWidth: '430px',
          maxHeight: '90vh',
          overflowY: 'auto',
          padding: '24px',
          background: 'var(--md-sys-color-surface-container-lowest)',
          borderRadius: 'var(--md-shape-corner-xl)',
          boxShadow: 'var(--md-sys-elevation-level3)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px', borderBottom: '1px solid var(--md-sys-color-outline-variant)', paddingBottom: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Scale size={20} color="var(--md-sys-color-primary)" />
            <h2 style={{ fontSize: '1.15rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)', margin: 0 }}>
              NPCI & RBI Guidelines
            </h2>
          </div>
          <button
            onClick={onClose}
            style={{
              background: 'var(--md-sys-color-surface-container-high)',
              border: 'none',
              borderRadius: 'var(--md-shape-corner-full)',
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: 'var(--md-sys-color-on-surface-variant)',
            }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Content list */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.85rem', color: 'var(--md-sys-color-on-surface-variant)', lineHeight: 1.5 }}>
          {/* Section 1 */}
          <div style={{ background: 'var(--md-sys-color-tertiary-container)', padding: '12px 14px', borderRadius: 'var(--md-shape-corner-md)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: 'var(--md-sys-color-on-tertiary-container)', marginBottom: '4px' }}>
              <CheckCircle size={16} color="var(--md-sys-color-tertiary)" />
              <span>1.1% PPI Interchange Fee Exemption</span>
            </div>
            <p style={{ color: 'var(--md-sys-color-on-tertiary-container)', fontSize: '0.8rem', opacity: 0.9 }}>
              NPCI levies up to 1.1% interchange on transactions over ₹2,000 made via prepaid instruments (wallets). Splitting payments into tranches below ₹2,000 keeps them eligible for 0% MDR direct bank transfers.
            </p>
          </div>

          {/* Section 2 */}
          <div style={{ background: 'var(--md-sys-color-secondary-container)', padding: '12px 14px', borderRadius: 'var(--md-shape-corner-md)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: 'var(--md-sys-color-on-secondary-container)', marginBottom: '4px' }}>
              <AlertTriangle size={16} color="var(--md-sys-color-secondary)" />
              <span>Cooling Periods & Velocity Limits</span>
            </div>
            <p style={{ color: 'var(--md-sys-color-on-secondary-container)', fontSize: '0.8rem', opacity: 0.9 }}>
              Banks enforce 24-hour transfer caps (₹2,000–₹5,000) for new unverified payees. Staggered sub-₹2,000 tranches prevent transfers from being blocked by velocity filters.
            </p>
          </div>

          {/* Section 3 */}
          <div style={{ background: 'var(--md-sys-color-surface-container-high)', padding: '12px 14px', borderRadius: 'var(--md-shape-corner-md)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: 'var(--md-sys-color-on-surface)', marginBottom: '4px' }}>
              <ShieldAlert size={16} color="var(--md-sys-color-primary)" />
              <span>Anti-Velocity Jitter & PMLA Rules</span>
            </div>
            <p style={{ color: 'var(--md-sys-color-on-surface-variant)', fontSize: '0.8rem' }}>
              To prevent bank fraud algorithms from flagging identical split amounts, SliceUPI introduces micro-jitter variations (e.g. ₹1,985 + ₹1,515 for ₹3,500 total).
            </p>
          </div>
        </div>

        <button
          onClick={onClose}
          className="m3-btn-filled"
          style={{ width: '100%', marginTop: '20px', height: '48px' }}
        >
          Understood &bull; Close Guide
        </button>
      </div>
    </div>
  );
};
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
        background: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
        zIndex: 9999,
      }}
      onClick={onClose}
    >
      <div
        className="gpay-card"
        style={{
          width: '100%',
          maxWidth: '430px',
          maxHeight: '90vh',
          overflowY: 'auto',
          padding: '24px',
          background: '#FFFFFF',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px', borderBottom: '1px solid #ECEFF1', paddingBottom: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Scale size={20} color="#1A73E8" />
            <h2 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#1F2937' }}>
              NPCI & RBI Guidelines
            </h2>
          </div>
          <button
            onClick={onClose}
            style={{
              background: '#F1F3F4',
              border: 'none',
              borderRadius: '50%',
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: '#5F6368',
            }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Content list */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.85rem', color: '#3C4043', lineHeight: 1.5 }}>
          {/* Section 1 */}
          <div style={{ background: '#E6F4EA', padding: '12px 14px', borderRadius: 'var(--radius-md)', border: '1px solid #CEEAD6' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: '#137333', marginBottom: '4px' }}>
              <CheckCircle size={16} />
              <span>1.1% PPI Interchange Fee Exemption</span>
            </div>
            <p style={{ color: '#1E4620', fontSize: '0.8rem' }}>
              NPCI levies up to 1.1% interchange on transactions over ₹2,000 made via prepaid instruments (wallets). Splitting payments into tranches below ₹2,000 keeps them eligible for 0% MDR direct bank transfers.
            </p>
          </div>

          {/* Section 2 */}
          <div style={{ background: '#FEF7E0', padding: '12px 14px', borderRadius: 'var(--radius-md)', border: '1px solid #FEEFC3' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: '#B06000', marginBottom: '4px' }}>
              <AlertTriangle size={16} />
              <span>Cooling Periods & Velocity Limits</span>
            </div>
            <p style={{ color: '#5C3800', fontSize: '0.8rem' }}>
              Banks enforce 24-hour transfer caps (₹2,000–₹5,000) for new unverified payees. Staggered sub-₹2,000 tranches prevent transfers from being blocked by velocity filters.
            </p>
          </div>

          {/* Section 3 */}
          <div style={{ background: '#F8F9FA', padding: '12px 14px', borderRadius: 'var(--radius-md)', border: '1px solid #ECEFF1' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 700, color: '#1F2937', marginBottom: '4px' }}>
              <ShieldAlert size={16} color="#1A73E8" />
              <span>Anti-Velocity Jitter & PMLA Rules</span>
            </div>
            <p style={{ color: '#5F6368', fontSize: '0.8rem' }}>
              To prevent bank fraud algorithms from flagging identical split amounts, SliceUPI introduces micro-jitter variations (e.g. ₹1,985 + ₹1,515 for ₹3,500 total).
            </p>
          </div>
        </div>

        <button
          onClick={onClose}
          className="btn-gpay"
          style={{ width: '100%', marginTop: '20px' }}
        >
          Understood &bull; Close Guide
        </button>
      </div>
    </div>
  );
};
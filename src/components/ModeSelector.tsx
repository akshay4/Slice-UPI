import React from 'react';
import { Zap, ShieldCheck } from 'lucide-react';
import { SplitMode } from '../types';

interface Props {
  mode: SplitMode;
  onSelectMode: (mode: SplitMode) => void;
}

export const ModeSelector: React.FC<Props> = ({ mode, onSelectMode }) => {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
      <label style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.05em' }}>
        Execution Architecture
      </label>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
        <button
          type="button"
          onClick={() => onSelectMode('intent')}
          style={{
            background: mode === 'intent' ? 'linear-gradient(135deg, rgba(99, 102, 241, 0.25) 0%, rgba(79, 70, 229, 0.15) 100%)' : 'rgba(255, 255, 255, 0.03)',
            border: mode === 'intent' ? '2px solid var(--primary)' : '1px solid var(--border-card)',
            borderRadius: 'var(--radius-md)',
            padding: '14px 12px',
            cursor: 'pointer',
            textAlign: 'left',
            display: 'flex',
            flexDirection: 'column',
            gap: '6px',
            transition: 'all 0.2s ease',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <Zap size={20} color={mode === 'intent' ? '#818CF8' : '#64748B'} />
            <span style={{ fontSize: '0.7rem', padding: '2px 6px', background: 'rgba(99, 102, 241, 0.2)', color: '#A5B4FC', borderRadius: '4px', fontWeight: 600 }}>
              Zero Fees
            </span>
          </div>
          <div>
            <div style={{ fontWeight: 700, fontSize: '0.95rem', color: mode === 'intent' ? '#FFFFFF' : '#94A3B8' }}>
              Direct Intent
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '2px', lineHeight: 1.3 }}>
              Sequential 1-Tap UPI app dispatch (GPay/PhonePe). No KYC.
            </div>
          </div>
        </button>

        <button
          type="button"
          onClick={() => onSelectMode('escrow')}
          style={{
            background: mode === 'escrow' ? 'linear-gradient(135deg, rgba(16, 185, 129, 0.2) 0%, rgba(5, 150, 105, 0.1) 100%)' : 'rgba(255, 255, 255, 0.03)',
            border: mode === 'escrow' ? '2px solid var(--secondary)' : '1px solid var(--border-card)',
            borderRadius: 'var(--radius-md)',
            padding: '14px 12px',
            cursor: 'pointer',
            textAlign: 'left',
            display: 'flex',
            flexDirection: 'column',
            gap: '6px',
            transition: 'all 0.2s ease',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <ShieldCheck size={20} color={mode === 'escrow' ? '#34D399' : '#64748B'} />
            <span style={{ fontSize: '0.7rem', padding: '2px 6px', background: 'rgba(16, 185, 129, 0.2)', color: '#6EE7B7', borderRadius: '4px', fontWeight: 600 }}>
              Auto 1-Consent
            </span>
          </div>
          <div>
            <div style={{ fontWeight: 700, fontSize: '0.95rem', color: mode === 'escrow' ? '#FFFFFF' : '#94A3B8' }}>
              Escrow / Mandate
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '2px', lineHeight: 1.3 }}>
              Single authorization e-Mandate with automated payout dispatcher.
            </div>
          </div>
        </button>
      </div>
    </div>
  );
};
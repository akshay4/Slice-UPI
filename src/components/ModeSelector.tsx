import React from 'react';
import { Zap, ShieldCheck } from 'lucide-react';
import { SplitMode } from '../types';

interface Props {
  mode: SplitMode;
  onSelectMode: (mode: SplitMode) => void;
}

export const ModeSelector: React.FC<Props> = ({ mode, onSelectMode }) => {
  return (
    <div style={{ marginBottom: '16px' }}>
      {/* Clean Segmented Tab Control */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          background: '#F1F3F4',
          borderRadius: 'var(--radius-pill)',
          padding: '4px',
          gap: '4px',
        }}
      >
        <button
          type="button"
          onClick={() => onSelectMode('intent')}
          style={{
            background: mode === 'intent' ? '#FFFFFF' : 'transparent',
            border: 'none',
            borderRadius: 'var(--radius-pill)',
            padding: '10px 12px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            boxShadow: mode === 'intent' ? '0 1px 3px rgba(0, 0, 0, 0.12)' : 'none',
            transition: 'all 0.2s ease',
          }}
        >
          <Zap size={16} color={mode === 'intent' ? '#1A73E8' : '#5F6368'} />
          <span
            style={{
              fontSize: '0.85rem',
              fontWeight: mode === 'intent' ? 700 : 500,
              color: mode === 'intent' ? '#1A73E8' : '#5F6368',
            }}
          >
            Direct UPI Apps
          </span>
        </button>

        <button
          type="button"
          onClick={() => onSelectMode('escrow')}
          style={{
            background: mode === 'escrow' ? '#FFFFFF' : 'transparent',
            border: 'none',
            borderRadius: 'var(--radius-pill)',
            padding: '10px 12px',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            boxShadow: mode === 'escrow' ? '0 1px 3px rgba(0, 0, 0, 0.12)' : 'none',
            transition: 'all 0.2s ease',
          }}
        >
          <ShieldCheck size={16} color={mode === 'escrow' ? '#0F9D58' : '#5F6368'} />
          <span
            style={{
              fontSize: '0.85rem',
              fontWeight: mode === 'escrow' ? 700 : 500,
              color: mode === 'escrow' ? '#0F9D58' : '#5F6368',
            }}
          >
            1-Click AutoPay
          </span>
        </button>
      </div>

      <p style={{ fontSize: '0.75rem', color: '#5F6368', textAlign: 'center', marginTop: '8px' }}>
        {mode === 'intent'
          ? 'Pay slices directly from Google Pay, PhonePe, or Paytm with 0% fee'
          : 'Authorize once via UPI AutoPay • Automated backend settlement'}
      </p>
    </div>
  );
};
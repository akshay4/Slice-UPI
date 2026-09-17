import React, { useState, useEffect } from 'react';
import { ShieldCheck, Delete, Check, Lock, Eye, EyeOff, X } from 'lucide-react';
import { BankAccount } from '../types';

interface Props {
  isOpen: boolean;
  amount: number;
  payeeName: string;
  payeeVpa: string;
  account: BankAccount;
  onSuccess: (mpin: string) => void;
  onClose: () => void;
  sliceDescription?: string;
}

export const MpinModal: React.FC<Props> = ({
  isOpen,
  amount,
  payeeName,
  payeeVpa,
  account,
  onSuccess,
  onClose,
  sliceDescription,
}) => {
  const pinLength = account.mpinLength || 4;
  const [pin, setPin] = useState<string>('');
  const [showPin, setShowPin] = useState<boolean>(false);
  const [errorShake, setErrorShake] = useState<boolean>(false);

  useEffect(() => {
    if (isOpen) {
      setPin('');
      setErrorShake(false);
    }
  }, [isOpen, account]);

  // Handle physical keyboard input
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key >= '0' && e.key <= '9') {
        if (pin.length < pinLength) {
          setPin((prev) => prev + e.key);
        }
      } else if (e.key === 'Backspace') {
        setPin((prev) => prev.slice(0, -1));
      } else if (e.key === 'Enter') {
        if (pin.length === pinLength) {
          onSuccess(pin);
        } else {
          triggerShake();
        }
      } else if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, pin, pinLength, onSuccess, onClose]);

  if (!isOpen) return null;

  const handleKeyPress = (num: string) => {
    if (pin.length < pinLength) {
      const nextPin = pin + num;
      setPin(nextPin);
      if (nextPin.length === pinLength) {
        // Auto submit on last digit with brief natural delay
        setTimeout(() => onSuccess(nextPin), 250);
      }
    }
  };

  const handleDelete = () => {
    setPin((prev) => prev.slice(0, -1));
  };

  const triggerShake = () => {
    setErrorShake(true);
    setTimeout(() => setErrorShake(false), 500);
  };

  const handleSubmit = () => {
    if (pin.length === pinLength) {
      onSuccess(pin);
    } else {
      triggerShake();
    }
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.65)',
        backdropFilter: 'blur(6px)',
        zIndex: 9999,
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-end',
      }}
    >
      <div
        className="m3-bottom-sheet"
        style={{
          padding: '16px 20px 24px',
          maxWidth: '480px',
          width: '100%',
          margin: '0 auto',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        {/* Material 3 Drag Handle */}
        <div className="m3-drag-handle" />

        {/* Header with Bank Badge & Close */}
        <div
          style={{
            width: '100%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginBottom: '16px',
            borderBottom: '1px solid var(--md-sys-color-outline-variant)',
            paddingBottom: '12px',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div
              style={{
                width: '36px',
                height: '36px',
                borderRadius: 'var(--md-shape-corner-sm)',
                background: account.color,
                color: '#FFF',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 800,
                fontSize: '0.85rem',
              }}
            >
              {account.bankCode}
            </div>
            <div>
              <div style={{ fontSize: '0.85rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)' }}>
                {account.bankName}
              </div>
              <div style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)' }}>
                {account.accountType} A/C {account.accountNumberMasked}
              </div>
            </div>
          </div>

          <button
            type="button"
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

        {/* Transaction Summary Info */}
        <div style={{ textAlign: 'center', marginBottom: '16px', width: '100%' }}>
          <div style={{ fontSize: '0.78rem', color: 'var(--md-sys-color-on-surface-variant)', fontWeight: 500 }}>
            Paying {payeeName} ({payeeVpa})
          </div>
          {sliceDescription && (
            <div
              style={{
                display: 'inline-block',
                marginTop: '4px',
                padding: '2px 10px',
                background: 'var(--md-sys-color-primary-container)',
                color: 'var(--md-sys-color-on-primary-container)',
                borderRadius: 'var(--md-shape-corner-full)',
                fontSize: '0.72rem',
                fontWeight: 600,
              }}
            >
              {sliceDescription}
            </div>
          )}
          <div
            style={{
              fontSize: '2.2rem',
              fontWeight: 800,
              color: 'var(--md-sys-color-on-surface)',
              letterSpacing: '-0.02em',
              marginTop: '4px',
            }}
          >
            ₹{amount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}
          </div>
        </div>

        {/* NPCI Common Library Prompt */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            color: 'var(--md-sys-color-primary)',
            fontSize: '0.82rem',
            fontWeight: 700,
            letterSpacing: '0.04em',
            marginBottom: '14px',
          }}
        >
          <Lock size={15} />
          <span>ENTER {pinLength}-DIGIT UPI PIN</span>
        </div>

        {/* PIN Dots Display */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '16px',
            marginBottom: '18px',
            transform: errorShake ? 'translateX(-8px)' : 'none',
            transition: 'transform 0.08s ease',
          }}
        >
          {Array.from({ length: pinLength }).map((_, i) => {
            const isFilled = i < pin.length;
            const digit = pin[i];
            return (
              <div
                key={i}
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: 'var(--md-shape-corner-md)',
                  border: isFilled
                    ? '2px solid var(--md-sys-color-primary)'
                    : '1.5px solid var(--md-sys-color-outline-variant)',
                  background: isFilled
                    ? 'var(--md-sys-color-primary-container)'
                    : 'var(--md-sys-color-surface-container-low)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '1.3rem',
                  fontWeight: 800,
                  color: 'var(--md-sys-color-primary)',
                  transition: 'all 0.15s ease',
                  boxShadow: isFilled ? '0 2px 8px rgba(11, 87, 208, 0.2)' : 'none',
                }}
              >
                {isFilled ? (showPin ? digit : '●') : ''}
              </div>
            );
          })}

          {/* Show / Hide Toggle */}
          <button
            type="button"
            onClick={() => setShowPin(!showPin)}
            style={{
              background: 'transparent',
              border: 'none',
              color: '#5F6368',
              cursor: 'pointer',
              marginLeft: '4px',
              padding: '4px',
            }}
          >
            {showPin ? <EyeOff size={18} /> : <Eye size={18} />}
          </button>
        </div>

        {/* Helper Test Note */}
        <div
          style={{
            fontSize: '0.72rem',
            color: 'var(--md-sys-color-on-surface-variant)',
            marginBottom: '16px',
            background: 'var(--md-sys-color-surface-container-high)',
            padding: '4px 12px',
            borderRadius: 'var(--md-shape-corner-full)',
          }}
        >
          Any {pinLength}-digit PIN works for demo (e.g. 1234)
        </div>

        {/* Numeric Touch Keypad (Material 3 Keypad) */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '12px',
            width: '100%',
            maxWidth: '340px',
            marginBottom: '16px',
          }}
        >
          {['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((num) => (
            <button
              key={num}
              type="button"
              onClick={() => handleKeyPress(num)}
              style={{
                height: '52px',
                background: 'var(--md-sys-color-surface-container-high)',
                border: '1px solid var(--md-sys-color-outline-variant)',
                borderRadius: 'var(--md-shape-corner-lg)',
                fontSize: '1.35rem',
                fontWeight: 600,
                color: 'var(--md-sys-color-on-surface)',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                transition: 'background 0.1s, transform 0.05s',
              }}
              onMouseDown={(e) => {
                e.currentTarget.style.transform = 'scale(0.96)';
                e.currentTarget.style.background = 'var(--md-sys-color-primary-container)';
              }}
              onMouseUp={(e) => {
                e.currentTarget.style.transform = 'scale(1)';
                e.currentTarget.style.background = 'var(--md-sys-color-surface-container-high)';
              }}
            >
              {num}
            </button>
          ))}

          {/* Delete Button */}
          <button
            type="button"
            onClick={handleDelete}
            style={{
              height: '52px',
              background: 'var(--md-sys-color-surface-container-high)',
              border: '1px solid var(--md-sys-color-outline-variant)',
              borderRadius: 'var(--md-shape-corner-lg)',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--md-sys-color-on-surface-variant)',
            }}
          >
            <Delete size={22} />
          </button>

          {/* Zero */}
          <button
            type="button"
            onClick={() => handleKeyPress('0')}
            style={{
              height: '52px',
              background: 'var(--md-sys-color-surface-container-high)',
              border: '1px solid var(--md-sys-color-outline-variant)',
              borderRadius: 'var(--md-shape-corner-lg)',
              fontSize: '1.35rem',
              fontWeight: 600,
              color: 'var(--md-sys-color-on-surface)',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            0
          </button>

          {/* Submit Checkmark (M3 Filled Primary Button) */}
          <button
            type="button"
            onClick={handleSubmit}
            disabled={pin.length !== pinLength}
            style={{
              height: '52px',
              background: pin.length === pinLength ? 'var(--md-sys-color-primary)' : 'var(--md-sys-color-surface-container-high)',
              border: 'none',
              borderRadius: 'var(--md-shape-corner-lg)',
              cursor: pin.length === pinLength ? 'pointer' : 'not-allowed',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: pin.length === pinLength ? 'var(--md-sys-color-on-primary)' : 'var(--md-sys-color-outline)',
              transition: 'background 0.2s ease',
              boxShadow: pin.length === pinLength ? 'var(--md-sys-elevation-level2)' : 'none',
            }}
          >
            <Check size={24} strokeWidth={2.5} />
          </button>
        </div>

        {/* NPCI Trust Footer */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '0.7rem',
            color: 'var(--md-sys-color-on-surface-variant)',
            fontWeight: 500,
          }}
        >
          <ShieldCheck size={14} color="var(--md-sys-color-tertiary)" />
          <span>NPCI Common Library &bull; 256-Bit Bank End-to-End Encryption</span>
        </div>
      </div>
    </div>
  );
};

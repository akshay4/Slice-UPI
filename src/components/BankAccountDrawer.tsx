import React, { useState } from 'react';
import { X, Check, CreditCard, RotateCcw, ShieldCheck, Eye, EyeOff } from 'lucide-react';
import { BankAccount } from '../types';
import {
  getLinkedAccounts,
  setDefaultAccount,
  resetBalances,
} from '../services/nativeEngineService';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  selectedAccountId: string;
  onSelectAccount: (account: BankAccount) => void;
}

export const BankAccountDrawer: React.FC<Props> = ({
  isOpen,
  onClose,
  selectedAccountId,
  onSelectAccount,
}) => {
  const [accounts, setAccounts] = useState<BankAccount[]>(getLinkedAccounts());
  const [revealedBalances, setRevealedBalances] = useState<{ [id: string]: boolean }>({});

  if (!isOpen) return null;

  const handleSelect = (account: BankAccount) => {
    setDefaultAccount(account.id);
    setAccounts(getLinkedAccounts());
    onSelectAccount(account);
  };

  const handleToggleBalance = (id: string) => {
    setRevealedBalances((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  const handleReset = () => {
    const fresh = resetBalances();
    setAccounts(fresh);
    const def = fresh.find((a) => a.id === selectedAccountId) || fresh[0];
    onSelectAccount(def);
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.65)',
        backdropFilter: 'blur(4px)',
        zIndex: 9998,
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
          maxHeight: '85vh',
          overflowY: 'auto',
        }}
      >
        {/* Material 3 Drag Handle */}
        <div className="m3-drag-handle" />

        <div
          style={{
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
                background: 'var(--md-sys-color-primary-container)',
                color: 'var(--md-sys-color-primary)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <CreditCard size={18} />
            </div>
            <div>
              <h3 style={{ fontSize: '1rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)', margin: 0 }}>
                Linked Bank Accounts
              </h3>
              <p style={{ fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)', margin: 0, marginTop: '2px' }}>
                SlicePay In-App Direct UPI Switch
              </p>
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

        {/* Account Cards */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '20px' }}>
          {accounts.map((acc) => {
            const isSelected = acc.id === selectedAccountId;
            const isRevealed = revealedBalances[acc.id];

            return (
              <div
                key={acc.id}
                onClick={() => handleSelect(acc)}
                style={{
                  border: isSelected
                    ? '2px solid var(--md-sys-color-primary)'
                    : '1px solid var(--md-sys-color-outline-variant)',
                  borderRadius: 'var(--md-shape-corner-lg)',
                  padding: '14px',
                  background: isSelected
                    ? 'var(--md-sys-color-surface-container-low)'
                    : 'var(--md-sys-color-surface-container-lowest)',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                  position: 'relative',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  boxShadow: isSelected ? 'var(--md-sys-elevation-level1)' : 'none',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div
                    style={{
                      width: '42px',
                      height: '42px',
                      borderRadius: 'var(--md-shape-corner-md)',
                      background: acc.color,
                      color: '#FFFFFF',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: 800,
                      fontSize: '0.9rem',
                    }}
                  >
                    {acc.bankCode}
                  </div>

                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span style={{ fontSize: '0.9rem', fontWeight: 700, color: 'var(--md-sys-color-on-surface)' }}>
                        {acc.bankName}
                      </span>
                      {acc.isDefault && (
                        <span
                          style={{
                            fontSize: '0.65rem',
                            background: 'var(--md-sys-color-primary-container)',
                            color: 'var(--md-sys-color-on-primary-container)',
                            padding: '2px 8px',
                            borderRadius: 'var(--md-shape-corner-full)',
                            fontWeight: 600,
                          }}
                        >
                          Default
                        </span>
                      )}
                    </div>
                    <div style={{ fontSize: '0.74rem', color: 'var(--md-sys-color-on-surface-variant)', marginTop: '2px' }}>
                      {acc.accountType} A/C {acc.accountNumberMasked} &bull; {acc.vpa}
                    </div>
                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px',
                        marginTop: '4px',
                        fontSize: '0.82rem',
                        fontWeight: 700,
                        color: 'var(--md-sys-color-tertiary)',
                      }}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleToggleBalance(acc.id);
                      }}
                    >
                      <span>
                        Balance: {isRevealed ? `₹${acc.balance.toLocaleString('en-IN')}` : '••••••'}
                      </span>
                      {isRevealed ? (
                        <EyeOff size={14} color="var(--md-sys-color-on-surface-variant)" />
                      ) : (
                        <Eye size={14} color="var(--md-sys-color-on-surface-variant)" />
                      )}
                    </div>
                  </div>
                </div>

                <div
                  style={{
                    width: '24px',
                    height: '24px',
                    borderRadius: 'var(--md-shape-corner-full)',
                    border: isSelected
                      ? '2px solid var(--md-sys-color-primary)'
                      : '2px solid var(--md-sys-color-outline-variant)',
                    background: isSelected ? 'var(--md-sys-color-primary)' : 'transparent',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  {isSelected && <Check size={14} color="var(--md-sys-color-on-primary)" strokeWidth={3} />}
                </div>
              </div>
            );
          })}
        </div>

        {/* Demo reset button (M3 Tonal Button) */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.72rem', color: 'var(--md-sys-color-on-surface-variant)' }}>
            <ShieldCheck size={14} color="var(--md-sys-color-tertiary)" />
            <span>NPCI Virtual Switch Verified</span>
          </div>

          <button
            type="button"
            onClick={handleReset}
            className="m3-btn-tonal"
            style={{ height: '32px', padding: '0 10px', fontSize: '0.74rem' }}
          >
            <RotateCcw size={12} />
            <span>Reset Demo Balances</span>
          </button>
        </div>
      </div>
    </div>
  );
};

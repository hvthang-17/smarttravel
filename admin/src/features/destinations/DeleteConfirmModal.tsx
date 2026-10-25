import React, { useEffect } from 'react';
import { AlertTriangleIcon } from '../../components/Icons';

interface Props {
  isOpen: boolean;
  destinationName: string;
  destinationId?: number;
  loading: boolean;
  onClose: () => void;
  onConfirm: () => Promise<void>;
}

export const DeleteConfirmModal: React.FC<Props> = ({
  isOpen,
  destinationName,
  loading,
  onClose,
  onConfirm,
}) => {
  // R-32: Keyboard accessibility - close modal with Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen && !loading) {
        onClose();
      }
    };
    if (isOpen) {
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, loading, onClose]);

  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(15, 23, 42, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1100,
        backdropFilter: 'blur(3px)',
      }}
      role="dialog"
      aria-modal="true"
      aria-labelledby="delete-confirm-title"
    >
      <div
        className="animate-fade-in"
        style={{
          background: '#ffffff',
          borderRadius: '12px',
          width: '420px',
          maxWidth: '90%',
          padding: '24px',
          boxShadow: '0 20px 40px rgba(0, 0, 0, 0.2)',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
          <div
            style={{
              width: '40px',
              height: '40px',
              borderRadius: '8px',
              backgroundColor: '#fee2e2',
              color: '#b91c1c',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <AlertTriangleIcon size={20} color="#b91c1c" />
          </div>
          <div>
            <h3 id="delete-confirm-title" style={{ margin: 0, fontSize: '18px', color: '#0f172a', fontWeight: 700 }}>
              Xác nhận xóa điểm đến
            </h3>
            <p style={{ margin: 0, fontSize: '13px', color: '#475569' }}>Hành động này không thể hoàn tác</p>
          </div>
        </div>

        <p style={{ fontSize: '14px', color: '#334155', lineHeight: '1.5', margin: '0 0 20px 0' }}>
          Bạn có chắc chắn muốn xóa điểm đến <strong>&ldquo;{destinationName}&rdquo;</strong> khỏi hệ thống SmartTravel?
        </p>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="btn-action-touch"
            style={{
              padding: '9px 18px',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              background: '#f8fafc',
              color: '#334155',
              fontWeight: 600,
              cursor: loading ? 'not-allowed' : 'pointer',
            }}
          >
            Hủy
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={loading}
            className="btn-action-touch"
            style={{
              padding: '9px 18px',
              borderRadius: '8px',
              border: 'none',
              background: '#dc2626',
              color: '#ffffff',
              fontWeight: 600,
              cursor: loading ? 'not-allowed' : 'pointer',
            }}
          >
            {loading ? 'Đang xóa...' : 'Xác nhận xóa'}
          </button>
        </div>
      </div>
    </div>
  );
};

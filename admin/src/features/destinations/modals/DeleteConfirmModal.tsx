import React, { useEffect } from 'react';
import { AlertTriangleIcon, TrashIcon, XIcon } from '../../../components/Icons';

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

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget && !loading) {
      onClose();
    }
  };

  return (
    <div
      className="destination-modal-backdrop"
      onClick={handleBackdropClick}
      role="dialog"
      aria-modal="true"
      aria-labelledby="delete-confirm-title"
    >
      <div
        className="destination-modal-panel animate-fade-in"
        style={{ width: '420px', maxWidth: '92%' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="destination-modal-header" style={{ borderBottom: 'none', paddingBottom: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
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
              <h3 id="delete-confirm-title" style={{ margin: 0, fontSize: '17px', color: '#0f172a', fontWeight: 700 }}>
                Xác nhận xóa điểm đến
              </h3>
              <p style={{ margin: '2px 0 0 0', fontSize: '12px', color: '#64748b' }}>Hành động này không thể hoàn tác</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="user-modal-close-btn"
            aria-label="Đóng hộp thoại xóa"
          >
            <XIcon size={18} />
          </button>
        </div>

        <div className="destination-modal-body" style={{ paddingTop: '16px' }}>
          <p style={{ fontSize: '13.5px', color: '#334155', lineHeight: '1.5', margin: 0 }}>
            Bạn có chắc chắn muốn xóa điểm đến <strong>&ldquo;{destinationName}&rdquo;</strong> khỏi hệ sinh thái du lịch Đà Nẵng không?
          </p>
        </div>

        <div className="destination-modal-footer">
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="destination-btn-cancel"
          >
            Hủy
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={loading}
            className={`btn-action-touch ${loading ? 'user-btn-submit-loading' : ''}`}
            style={{
              padding: '9px 18px',
              borderRadius: '8px',
              border: 'none',
              background: loading ? '#475569' : '#dc2626',
              color: '#ffffff',
              fontSize: '13px',
              fontWeight: 600,
              cursor: loading ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            <TrashIcon size={14} color="#ffffff" />
            <span>{loading ? 'Đang xóa...' : 'Xác nhận xóa'}</span>
          </button>
        </div>
      </div>
    </div>
  );
};

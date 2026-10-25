import React, { useEffect } from 'react';
import { AlertTriangleIcon, TrashIcon, XIcon } from '../../components/Icons';
import { ManagedUser } from '../../core/userApi';

interface DeleteUserModalProps {
  isOpen: boolean;
  user: ManagedUser | null;
  loading: boolean;
  onClose: () => void;
  onConfirm: () => Promise<void>;
}

export const DeleteUserModal: React.FC<DeleteUserModalProps> = ({
  isOpen,
  user,
  loading,
  onClose,
  onConfirm,
}) => {
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

  if (!isOpen || !user) return null;

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget && !loading) {
      onClose();
    }
  };

  return (
    <div
      className="user-modal-overlay"
      onClick={handleBackdropClick}
      role="dialog"
      aria-modal="true"
      aria-labelledby="delete-user-title"
    >
      <div className="user-modal-box animate-fade-in" style={{ maxWidth: '420px' }}>
        <div className="user-modal-header" style={{ borderBottom: 'none', paddingBottom: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '40px',
                height: '40px',
                borderRadius: '50%',
                backgroundColor: '#fee2e2',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              <AlertTriangleIcon size={20} color="#dc2626" />
            </div>
            <div>
              <h3 id="delete-user-title" style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: '#0f172a' }}>
                Xác nhận xóa tài khoản
              </h3>
              <p style={{ margin: '2px 0 0 0', fontSize: '12px', color: '#64748b' }}>
                Hành động này không thể hoàn tác
              </p>
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

        <div className="user-modal-body" style={{ paddingTop: '16px' }}>
          <p style={{ fontSize: '13.5px', color: '#334155', lineHeight: 1.5, margin: 0 }}>
            Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản <strong>{user.fullName}</strong> ({user.email}) khỏi hệ thống không? Dữ liệu các chuyến đi và phân quyền liên quan sẽ bị xóa hoàn toàn.
          </p>
        </div>

        <div className="user-modal-footer">
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="user-action-btn"
            style={{ width: 'auto', padding: '8px 16px', fontSize: '13px', fontWeight: 600 }}
          >
            Hủy bỏ
          </button>
          <button
            type="button"
            onClick={onConfirm}
            disabled={loading}
            className={`btn-action-touch ${loading ? 'user-btn-submit-loading' : ''}`}
            style={{
              padding: '8px 18px',
              borderRadius: '8px',
              border: 'none',
              backgroundColor: loading ? '#475569' : '#dc2626',
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
            <span>{loading ? 'Đang xóa...' : 'Xóa vĩnh viễn'}</span>
          </button>
        </div>
      </div>
    </div>
  );
};

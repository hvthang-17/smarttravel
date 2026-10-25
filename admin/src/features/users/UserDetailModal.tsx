import React, { useEffect } from 'react';
import {
  XIcon,
  MapIcon,
  ShieldCheckIcon,
  ShieldIcon,
  UserIcon,
  CheckCircleIcon,
  LockIcon,
} from '../../components/Icons';
import { ROLE_LABELS, ROLE_DESCRIPTIONS } from '../../types/auth';
import { ManagedUser } from '../../core/userApi';

interface UserDetailModalProps {
  isOpen: boolean;
  user: ManagedUser | null;
  isSelf: boolean;
  onClose: () => void;
  onEdit: () => void;
}

export const UserDetailModal: React.FC<UserDetailModalProps> = ({
  isOpen,
  user,
  isSelf,
  onClose,
  onEdit,
}) => {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    if (isOpen) {
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen || !user) return null;

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  const getInitials = (name: string) => {
    if (!name) return 'U';
    const parts = name.trim().split(' ');
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  };

  const formattedDate = user.createdAt
    ? new Date(user.createdAt).toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
      })
    : 'Chưa cập nhật';

  const renderRoleBadge = () => {
    switch (user.role) {
      case 'ROLE_ADMIN':
        return (
          <span className="user-badge role-admin">
            <ShieldCheckIcon size={13} color="#075985" />
            <span>Quản trị viên (Admin)</span>
          </span>
        );
      case 'ROLE_MODERATOR':
        return (
          <span className="user-badge role-moderator">
            <ShieldIcon size={13} color="#065f46" />
            <span>Điều phối viên (Moderator)</span>
          </span>
        );
      default:
        return (
          <span className="user-badge role-user">
            <UserIcon size={13} color="#334155" />
            <span>Khách du lịch (User)</span>
          </span>
        );
    }
  };

  return (
    <div
      className="user-modal-overlay"
      onClick={handleBackdropClick}
      role="dialog"
      aria-modal="true"
      aria-labelledby="user-detail-title"
    >
      <div className="user-modal-box animate-fade-in" style={{ maxWidth: '480px' }}>
        <div className="user-modal-header">
          <div>
            <h2 id="user-detail-title" style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: '#0f172a' }}>
              Hồ sơ tài khoản
            </h2>
            <p style={{ margin: '2px 0 0 0', fontSize: '12.5px', color: '#64748b' }}>
              Chi tiết thông tin định danh và phân quyền hệ thống
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="user-modal-close-btn"
            aria-label="Đóng hộp thoại chi tiết người dùng"
          >
            <XIcon size={18} />
          </button>
        </div>

        <div className="user-modal-body">
          {/* Header Card */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '14px',
              padding: '14px 16px',
              backgroundColor: '#f8fafc',
              borderRadius: '10px',
              border: '1px solid #e2e8f0',
              marginBottom: '18px',
            }}
          >
            <div
              style={{
                width: '50px',
                height: '50px',
                borderRadius: '50%',
                backgroundColor: '#e0f2fe',
                color: '#0369a1',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '17px',
                fontWeight: 700,
                flexShrink: 0,
                border: '1px solid #bae6fd',
              }}
            >
              {getInitials(user.fullName)}
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center' }}>
                <span style={{ fontSize: '16px', fontWeight: 700, color: '#0f172a' }}>
                  {user.fullName}
                </span>
                {isSelf && <span className="user-badge badge-self">Bạn</span>}
              </div>
              <div style={{ fontSize: '13px', color: '#64748b', marginTop: '2px' }}>
                {user.email}
              </div>
            </div>
          </div>

          {/* Details list */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '10px', borderBottom: '1px solid #f1f5f9' }}>
              <span style={{ fontSize: '13px', color: '#64748b' }}>Vai trò</span>
              {renderRoleBadge()}
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '10px', borderBottom: '1px solid #f1f5f9' }}>
              <span style={{ fontSize: '13px', color: '#64748b' }}>Trạng thái</span>
              {user.status === 'ACTIVE' ? (
                <span className="user-badge status-active">
                  <CheckCircleIcon size={13} color="#065f46" />
                  <span>Đang hoạt động</span>
                </span>
              ) : (
                <span className="user-badge status-locked">
                  <LockIcon size={13} color="#991b1b" />
                  <span>Tạm khóa tài khoản</span>
                </span>
              )}
            </div>

            {user.status === 'LOCKED' && (
              <div
                style={{
                  backgroundColor: '#fef2f2',
                  border: '1px solid #fecaca',
                  borderRadius: '8px',
                  padding: '10px 12px',
                  fontSize: '12.5px',
                  color: '#991b1b',
                  lineHeight: 1.4,
                }}
              >
                Tài khoản này hiện đang tạm dừng hoạt động và không thể đăng nhập vào ứng dụng hoặc hệ thống quản trị. Quản trị viên có thể kích hoạt lại bất kỳ lúc nào.
              </div>
            )}

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '10px', borderBottom: '1px solid #f1f5f9' }}>
              <span style={{ fontSize: '13px', color: '#64748b' }}>Ngày khởi tạo</span>
              <span style={{ fontSize: '13px', color: '#0f172a', fontWeight: 500 }}>{formattedDate}</span>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '10px', borderBottom: '1px solid #f1f5f9' }}>
              <span style={{ fontSize: '13px', color: '#64748b', display: 'flex', alignItems: 'center', gap: '6px' }}>
                <MapIcon size={14} color="#64748b" />
                <span>Lịch trình du lịch</span>
              </span>
              <span style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a' }}>
                {user.tripsCount || 0} chuyến đi
              </span>
            </div>

            <div
              style={{
                backgroundColor: '#f8fafc',
                padding: '10px 12px',
                borderRadius: '8px',
                border: '1px solid #e2e8f0',
                fontSize: '12px',
                color: '#475569',
                lineHeight: 1.5,
              }}
            >
              <strong>Quyền hạn:</strong> {ROLE_DESCRIPTIONS[user.role] || ROLE_LABELS[user.role]}
            </div>
          </div>
        </div>

        <div className="user-modal-footer">
          <button
            type="button"
            onClick={onClose}
            className="user-action-btn"
            style={{ width: 'auto', padding: '8px 16px', fontSize: '13px', fontWeight: 600 }}
          >
            Đóng
          </button>
          <button
            type="button"
            onClick={() => {
              onClose();
              onEdit();
            }}
            className="user-btn-add"
            style={{ fontSize: '13px', padding: '8px 16px' }}
          >
            Chỉnh sửa thông tin
          </button>
        </div>
      </div>
    </div>
  );
};

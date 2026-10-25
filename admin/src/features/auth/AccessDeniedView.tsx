import React from 'react';
import { LockIcon, LogOutIcon } from '../../components/Icons';
import { AuthUser, ROLE_LABELS, ROLE_BADGE_STYLES } from '../../types/auth';

interface AccessDeniedViewProps {
  currentUser: AuthUser;
  onLogout: () => void;
}

export const AccessDeniedView: React.FC<AccessDeniedViewProps> = ({
  currentUser,
  onLogout,
}) => {
  const roleStyle = ROLE_BADGE_STYLES[currentUser.role] || ROLE_BADGE_STYLES.ROLE_USER;

  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: '#f8fafc',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px 16px',
        boxSizing: 'border-box',
        fontFamily: 'inherit',
      }}
    >
      <div
        className="animate-fade-in"
        style={{
          width: '100%',
          maxWidth: '460px',
          backgroundColor: '#ffffff',
          borderRadius: '12px',
          border: '1px solid #e2e8f0',
          boxShadow: '0 10px 25px -5px rgba(15, 23, 42, 0.08)',
          padding: '40px 32px',
          textAlign: 'center',
          boxSizing: 'border-box',
        }}
      >
        <div
          style={{
            width: '56px',
            height: '56px',
            borderRadius: '12px',
            backgroundColor: '#fee2e2',
            color: '#dc2626',
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: '18px',
          }}
        >
          <LockIcon size={26} color="#dc2626" strokeWidth={2.2} />
        </div>

        <h2 style={{ margin: '0 0 10px 0', fontSize: '20px', fontWeight: 700, color: '#0f172a' }}>
          Yêu cầu quyền Quản trị viên
        </h2>

        <p style={{ margin: '0 0 20px 0', fontSize: '14px', color: '#475569', lineHeight: 1.5 }}>
          Tài khoản của bạn hiện có vai trò:
        </p>

        {/* Current user card */}
        <div
          style={{
            backgroundColor: '#f8fafc',
            border: '1px solid #e2e8f0',
            borderRadius: '8px',
            padding: '16px',
            marginBottom: '24px',
            textAlign: 'left',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
            <strong style={{ fontSize: '14px', color: '#0f172a' }}>{currentUser.fullName}</strong>
            <span
              style={{
                fontSize: '11px',
                fontWeight: 700,
                backgroundColor: roleStyle.bg,
                color: roleStyle.text,
                border: `1px solid ${roleStyle.border}`,
                padding: '2px 8px',
                borderRadius: '6px',
              }}
            >
              {ROLE_LABELS[currentUser.role]} ({currentUser.role})
            </span>
          </div>
          <div style={{ fontSize: '12.5px', color: '#64748b' }}>{currentUser.email}</div>
          <div style={{ marginTop: '10px', fontSize: '12px', color: '#b91c1c', lineHeight: 1.4 }}>
            * Tài khoản <strong>ROLE_USER</strong> không có thẩm quyền truy cập hệ thống quản trị dữ liệu. Vui lòng đăng nhập bằng tài khoản có vai trò <strong>ROLE_ADMIN</strong> hoặc <strong>ROLE_MODERATOR</strong>.
          </div>
        </div>

        {/* Actions */}
        <button
          type="button"
          onClick={onLogout}
          className="auth-btn-primary btn-action-touch"
        >
          <LogOutIcon size={16} color="#ffffff" />
          <span>Đăng xuất và Đăng nhập tài khoản khác</span>
        </button>
      </div>
    </div>
  );
};

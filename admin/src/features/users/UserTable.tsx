import React from 'react';
import {
  EyeIcon,
  PencilIcon,
  LockIcon,
  UnlockIcon,
  TrashIcon,
  ShieldCheckIcon,
  ShieldIcon,
  UserIcon,
  CheckCircleIcon,
} from '../../components/Icons';
import { ManagedUser } from '../../core/userApi';

interface UserTableProps {
  users: ManagedUser[];
  loading: boolean;
  currentUserEmail: string;
  actionPendingId: number | null;
  onViewDetail: (user: ManagedUser) => void;
  onEdit: (user: ManagedUser) => void;
  onToggleLock: (user: ManagedUser) => void;
  onDelete: (user: ManagedUser) => void;
  onClearFilters: () => void;
}

export const UserTable: React.FC<UserTableProps> = ({
  users,
  loading,
  currentUserEmail,
  actionPendingId,
  onViewDetail,
  onEdit,
  onToggleLock,
  onDelete,
  onClearFilters,
}) => {
  const getRoleBadge = (role: string) => {
    switch (role) {
      case 'ROLE_ADMIN':
        return (
          <span className="user-badge role-admin">
            <ShieldCheckIcon size={13} color="#075985" />
            <span>Quản trị viên</span>
          </span>
        );
      case 'ROLE_MODERATOR':
        return (
          <span className="user-badge role-moderator">
            <ShieldIcon size={13} color="#065f46" />
            <span>Điều phối viên</span>
          </span>
        );
      default:
        return (
          <span className="user-badge role-user">
            <UserIcon size={13} color="#334155" />
            <span>Khách du lịch</span>
          </span>
        );
    }
  };

  const getStatusBadge = (status: string) => {
    if (status === 'ACTIVE') {
      return (
        <span className="user-badge status-active">
          <CheckCircleIcon size={13} color="#065f46" />
          <span>Hoạt động</span>
        </span>
      );
    }
    return (
      <span className="user-badge status-locked">
        <LockIcon size={13} color="#991b1b" />
        <span>Tạm khóa</span>
      </span>
    );
  };

  const formatDate = (isoString: string) => {
    try {
      const d = new Date(isoString);
      return d.toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
      });
    } catch {
      return isoString || 'N/A';
    }
  };

  const getInitials = (name: string) => {
    if (!name) return 'U';
    const parts = name.trim().split(' ');
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  };

  // Loading skeleton state
  if (loading) {
    return (
      <div className="user-table-card">
        <div className="user-table-scroll">
          <table className="user-table">
            <thead>
              <tr>
                <th style={{ width: '32%' }}>Người dùng & Email</th>
                <th style={{ width: '18%' }}>Vai trò</th>
                <th style={{ width: '14%' }}>Ngày đăng ký</th>
                <th style={{ width: '12%', textAlign: 'center' }}>Lịch trình</th>
                <th style={{ width: '14%' }}>Trạng thái</th>
                <th style={{ width: '10%', textAlign: 'center' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {[1, 2, 3, 4, 5].map((row) => (
                <tr key={row}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div className="user-skeleton-avatar" />
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', width: '140px' }}>
                        <div className="user-skeleton-line" style={{ width: '90%' }} />
                        <div className="user-skeleton-line" style={{ width: '70%', height: '12px' }} />
                      </div>
                    </div>
                  </td>
                  <td><div className="user-skeleton-line" style={{ width: '100px' }} /></td>
                  <td><div className="user-skeleton-line" style={{ width: '80px' }} /></td>
                  <td><div className="user-skeleton-line" style={{ width: '40px', margin: '0 auto' }} /></td>
                  <td><div className="user-skeleton-line" style={{ width: '90px' }} /></td>
                  <td><div className="user-skeleton-line" style={{ width: '70px', margin: '0 auto' }} /></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  }

  // Empty state
  if (users.length === 0) {
    return (
      <div className="user-table-card" style={{ padding: '48px 24px', textAlign: 'center' }}>
        <div
          style={{
            width: '56px',
            height: '56px',
            borderRadius: '50%',
            backgroundColor: '#f1f5f9',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px auto',
          }}
        >
          <UserIcon size={28} color="#94a3b8" />
        </div>
        <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#0f172a', marginBottom: '6px' }}>
          Không tìm thấy tài khoản người dùng
        </h3>
        <p style={{ fontSize: '13.5px', color: '#64748b', maxWidth: '420px', margin: '0 auto 16px auto' }}>
          Không có kết quả nào phù hợp với bộ lọc hiện tại. Thử thay đổi từ khóa hoặc thiết lập lại bộ lọc.
        </p>
        <button
          type="button"
          onClick={onClearFilters}
          className="user-action-btn"
          style={{
            width: 'auto',
            padding: '8px 16px',
            fontSize: '13px',
            fontWeight: 600,
            color: '#0077b6',
            borderColor: '#bae6fd',
            backgroundColor: '#f0f9ff',
          }}
        >
          Xóa tất cả bộ lọc
        </button>
      </div>
    );
  }

  return (
    <div className="user-table-card">
      {/* Desktop Responsive Table Container (R-03) */}
      <div className="user-table-scroll">
        <table className="user-table">
          <thead>
            <tr>
              <th>Người dùng & Email</th>
              <th>Vai trò</th>
              <th>Ngày đăng ký</th>
              <th style={{ textAlign: 'center' }}>Lịch trình</th>
              <th>Trạng thái</th>
              <th style={{ textAlign: 'center' }}>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => {
              const isSelf = currentUserEmail && u.email.toLowerCase() === currentUserEmail.toLowerCase();
              const isPending = actionPendingId === u.id;

              return (
                <tr key={u.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div
                        style={{
                          width: '38px',
                          height: '38px',
                          borderRadius: '50%',
                          backgroundColor: '#e0f2fe',
                          color: '#0369a1',
                          fontWeight: 700,
                          fontSize: '13px',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          flexShrink: 0,
                          border: '1px solid #bae6fd',
                        }}
                      >
                        {getInitials(u.fullName)}
                      </div>
                      <div>
                        <div style={{ display: 'flex', alignItems: 'center' }}>
                          <span style={{ fontWeight: 600, color: '#0f172a' }}>{u.fullName}</span>
                          {isSelf && <span className="user-badge badge-self">Bạn</span>}
                        </div>
                        <div style={{ fontSize: '12.5px', color: '#64748b', marginTop: '1px' }}>
                          {u.email}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td>{getRoleBadge(u.role)}</td>
                  <td style={{ color: '#475569', fontSize: '13px' }}>{formatDate(u.createdAt)}</td>
                  <td style={{ textAlign: 'center' }}>
                    <span
                      style={{
                        padding: '2px 8px',
                        borderRadius: '12px',
                        backgroundColor: '#f1f5f9',
                        color: '#334155',
                        fontWeight: 600,
                        fontSize: '12px',
                      }}
                    >
                      {u.tripsCount || 0}
                    </span>
                  </td>
                  <td>{getStatusBadge(u.status)}</td>
                  <td>
                    <div className="user-action-group" style={{ justifyContent: 'center' }}>
                      <button
                        type="button"
                        onClick={() => onViewDetail(u)}
                        className="user-action-btn"
                        title="Xem chi tiết người dùng"
                        aria-label={`Xem chi tiết ${u.fullName}`}
                      >
                        <EyeIcon size={15} color="#475569" />
                      </button>
                      <button
                        type="button"
                        onClick={() => onEdit(u)}
                        className="user-action-btn"
                        title="Chỉnh sửa thông tin"
                        aria-label={`Chỉnh sửa ${u.fullName}`}
                      >
                        <PencilIcon size={14} color="#475569" />
                      </button>
                      <button
                        type="button"
                        onClick={() => onToggleLock(u)}
                        disabled={isPending || Boolean(isSelf)}
                        className="user-action-btn btn-lock"
                        title={
                          isSelf
                            ? 'Không thể tự khóa tài khoản của bạn'
                            : u.status === 'LOCKED'
                            ? 'Mở khóa tài khoản'
                            : 'Tạm khóa tài khoản'
                        }
                        aria-label={
                          u.status === 'LOCKED'
                            ? `Mở khóa tài khoản ${u.fullName}`
                            : `Tạm khóa tài khoản ${u.fullName}`
                        }
                      >
                        {u.status === 'LOCKED' ? (
                          <UnlockIcon size={15} color="#059669" />
                        ) : (
                          <LockIcon size={15} color="#d97706" />
                        )}
                      </button>
                      <button
                        type="button"
                        onClick={() => onDelete(u)}
                        disabled={isPending || Boolean(isSelf)}
                        className="user-action-btn btn-delete"
                        title={isSelf ? 'Không thể tự xóa tài khoản của bạn' : 'Xóa tài khoản'}
                        aria-label={`Xóa tài khoản ${u.fullName}`}
                      >
                        <TrashIcon size={14} color="#dc2626" />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Mobile Card List Reflow (< 768px) (R-03) */}
      <div className="user-mobile-list">
        {users.map((u) => {
          const isSelf = currentUserEmail && u.email.toLowerCase() === currentUserEmail.toLowerCase();
          const isPending = actionPendingId === u.id;

          return (
            <div key={`mob-${u.id}`} className="user-mobile-card">
              <div className="user-mobile-card-header">
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div
                    style={{
                      width: '36px',
                      height: '36px',
                      borderRadius: '50%',
                      backgroundColor: '#e0f2fe',
                      color: '#0369a1',
                      fontWeight: 700,
                      fontSize: '12.5px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    {getInitials(u.fullName)}
                  </div>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center' }}>
                      <span style={{ fontWeight: 600, color: '#0f172a', fontSize: '14px' }}>
                        {u.fullName}
                      </span>
                      {isSelf && <span className="user-badge badge-self">Bạn</span>}
                    </div>
                    <div style={{ fontSize: '12px', color: '#64748b' }}>{u.email}</div>
                  </div>
                </div>
                {getStatusBadge(u.status)}
              </div>

              <div className="user-mobile-card-row">
                <span>Vai trò:</span>
                {getRoleBadge(u.role)}
              </div>
              <div className="user-mobile-card-row">
                <span>Ngày tạo:</span>
                <span style={{ color: '#0f172a', fontWeight: 500 }}>{formatDate(u.createdAt)}</span>
              </div>
              <div className="user-mobile-card-row">
                <span>Lịch trình đã tạo:</span>
                <span style={{ color: '#0f172a', fontWeight: 600 }}>{u.tripsCount || 0}</span>
              </div>

              <div className="user-mobile-card-actions">
                <button
                  type="button"
                  onClick={() => onViewDetail(u)}
                  className="user-action-btn"
                  aria-label={`Xem chi tiết ${u.fullName}`}
                >
                  <EyeIcon size={16} color="#475569" />
                </button>
                <button
                  type="button"
                  onClick={() => onEdit(u)}
                  className="user-action-btn"
                  aria-label={`Chỉnh sửa ${u.fullName}`}
                >
                  <PencilIcon size={15} color="#475569" />
                </button>
                <button
                  type="button"
                  onClick={() => onToggleLock(u)}
                  disabled={isPending || Boolean(isSelf)}
                  className="user-action-btn btn-lock"
                  aria-label={
                    u.status === 'LOCKED'
                      ? `Mở khóa tài khoản ${u.fullName}`
                      : `Tạm khóa tài khoản ${u.fullName}`
                  }
                >
                  {u.status === 'LOCKED' ? (
                    <UnlockIcon size={16} color="#059669" />
                  ) : (
                    <LockIcon size={16} color="#d97706" />
                  )}
                </button>
                <button
                  type="button"
                  onClick={() => onDelete(u)}
                  disabled={isPending || Boolean(isSelf)}
                  className="user-action-btn btn-delete"
                  aria-label={`Xóa tài khoản ${u.fullName}`}
                >
                  <TrashIcon size={15} color="#dc2626" />
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

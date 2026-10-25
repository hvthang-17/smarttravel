import React, { useState, useEffect } from 'react';
import {
  XIcon,
  EyeIcon,
  EyeOffIcon,
  ShieldCheckIcon,
  ShieldIcon,
  UserIcon,
} from '../../components/Icons';
import { CreateUserData, ManagedUser, UpdateUserData } from '../../core/userApi';
import { RoleType } from '../../types/auth';

interface UserFormModalProps {
  isOpen: boolean;
  mode: 'create' | 'edit';
  user: ManagedUser | null;
  loading: boolean;
  onClose: () => void;
  onSubmitCreate?: (data: CreateUserData) => Promise<void>;
  onSubmitEdit?: (id: number, data: UpdateUserData) => Promise<void>;
}

export const UserFormModal: React.FC<UserFormModalProps> = ({
  isOpen,
  mode,
  user,
  loading,
  onClose,
  onSubmitCreate,
  onSubmitEdit,
}) => {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [role, setRole] = useState<RoleType>('ROLE_USER');
  const [status, setStatus] = useState<'ACTIVE' | 'LOCKED'>('ACTIVE');
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Reset or initialize form values
  useEffect(() => {
    if (isOpen) {
      if (mode === 'edit' && user) {
        setFullName(user.fullName || '');
        setEmail(user.email || '');
        setPassword('');
        setRole(user.role || 'ROLE_USER');
        setStatus(user.status === 'LOCKED' ? 'LOCKED' : 'ACTIVE');
      } else {
        setFullName('');
        setEmail('');
        setPassword('');
        setRole('ROLE_USER');
        setStatus('ACTIVE');
      }
      setShowPassword(false);
      setErrors({});
    }
  }, [isOpen, mode, user]);

  // Handle Escape key
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

  const validate = (): boolean => {
    const nextErrors: Record<string, string> = {};

    if (!fullName.trim()) {
      nextErrors.fullName = 'Họ và tên không được để trống';
    } else if (fullName.trim().length < 2) {
      nextErrors.fullName = 'Họ và tên phải có tối thiểu 2 ký tự';
    }

    if (mode === 'create') {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!email.trim()) {
        nextErrors.email = 'Email không được để trống';
      } else if (!emailRegex.test(email.trim())) {
        nextErrors.email = 'Địa chỉ email không đúng định dạng';
      }

      if (!password) {
        nextErrors.password = 'Mật khẩu khởi tạo không được để trống';
      } else if (password.length < 6) {
        nextErrors.password = 'Mật khẩu phải có tối thiểu 6 ký tự';
      }
    } else if (password && password.length < 6) {
      nextErrors.password = 'Mật khẩu mới phải có tối thiểu 6 ký tự';
    }

    setErrors(nextErrors);
    return Object.keys(nextErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate() || loading) return;

    if (mode === 'create' && onSubmitCreate) {
      await onSubmitCreate({
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        password,
        role,
        status,
      });
    } else if (mode === 'edit' && user && onSubmitEdit) {
      await onSubmitEdit(user.id, {
        fullName: fullName.trim(),
        role,
        status,
        ...(password.trim() ? { password: password.trim() } : {}),
      });
    }
  };

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget && !loading) {
      onClose();
    }
  };

  const rolesList: { key: RoleType; label: string; desc: string; icon: React.ReactNode }[] = [
    {
      key: 'ROLE_USER',
      label: 'Khách du lịch',
      desc: 'Quyền xem điểm đến, tạo và chia sẻ lịch trình du lịch cá nhân',
      icon: <UserIcon size={18} color="#0284c7" />,
    },
    {
      key: 'ROLE_MODERATOR',
      label: 'Điều phối viên',
      desc: 'Quản trị điểm đến, duyệt đánh giá và hỗ trợ nội dung điểm du lịch',
      icon: <ShieldIcon size={18} color="#059669" />,
    },
    {
      key: 'ROLE_ADMIN',
      label: 'Quản trị viên',
      desc: 'Toàn quyền cấu hình hệ thống, quản lý người dùng và phân quyền',
      icon: <ShieldCheckIcon size={18} color="#7c3aed" />,
    },
  ];

  return (
    <div
      className="user-modal-overlay"
      onClick={handleBackdropClick}
      role="dialog"
      aria-modal="true"
      aria-labelledby="user-form-modal-title"
    >
      <div className="user-modal-box animate-fade-in">
        {/* Modal Header */}
        <div className="user-modal-header">
          <div>
            <h3
              id="user-form-modal-title"
              style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: '#0f172a' }}
            >
              {mode === 'create' ? 'Tạo tài khoản người dùng mới' : 'Chỉnh sửa tài khoản người dùng'}
            </h3>
            <p style={{ margin: '2px 0 0 0', fontSize: '12.5px', color: '#64748b' }}>
              {mode === 'create'
                ? 'Thêm tài khoản vào cơ sở dữ liệu và cấp quyền truy cập'
                : `Cập nhật thông tin và vai trò cho ${user?.fullName || 'người dùng'}`}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="user-modal-close-btn"
            aria-label="Đóng hộp thoại"
          >
            <XIcon size={18} />
          </button>
        </div>

        {/* Modal Body Form */}
        <form onSubmit={handleSubmit} className="user-modal-form">
          <div className="user-modal-body">
            {/* Full Name */}
            <div className="user-form-group">
              <label htmlFor="user-fullname" className="user-form-label">
                Họ và tên <span style={{ color: '#dc2626' }}>*</span>
              </label>
              <input
                id="user-fullname"
                type="text"
                className="user-form-input"
                placeholder="Ví dụ: Nguyễn Văn An"
                value={fullName}
                onChange={(e) => {
                  setFullName(e.target.value);
                  if (errors.fullName) setErrors((prev) => ({ ...prev, fullName: '' }));
                }}
                disabled={loading}
              />
              {errors.fullName && <div className="user-form-error">{errors.fullName}</div>}
            </div>

            {/* Email */}
            <div className="user-form-group">
              <label htmlFor="user-email" className="user-form-label">
                Địa chỉ Email {mode === 'create' && <span style={{ color: '#dc2626' }}>*</span>}
              </label>
              <input
                id="user-email"
                type="email"
                className="user-form-input"
                placeholder="nguyenvanan@example.com"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  if (errors.email) setErrors((prev) => ({ ...prev, email: '' }));
                }}
                disabled={mode === 'edit' || loading}
              />
              {mode === 'edit' && (
                <div style={{ fontSize: '12px', color: '#64748b', marginTop: '4px' }}>
                  Email được dùng làm định danh đăng nhập nên không thể sửa đổi
                </div>
              )}
              {errors.email && <div className="user-form-error">{errors.email}</div>}
            </div>

            {/* Password */}
            <div className="user-form-group">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <label htmlFor="user-password" className="user-form-label">
                  {mode === 'create' ? 'Mật khẩu khởi tạo ' : 'Mật khẩu mới (Tùy chọn) '}
                  {mode === 'create' && <span style={{ color: '#dc2626' }}>*</span>}
                </label>
                {mode === 'edit' && (
                  <span style={{ fontSize: '11.5px', color: '#64748b' }}>
                    Để trống nếu giữ mật khẩu hiện tại
                  </span>
                )}
              </div>
              <div style={{ position: 'relative' }}>
                <input
                  id="user-password"
                  type={showPassword ? 'text' : 'password'}
                  className="user-form-input"
                  placeholder={mode === 'create' ? 'Tối thiểu 6 ký tự' : 'Nhập mật khẩu mới nếu muốn đổi'}
                  value={password}
                  onChange={(e) => {
                    setPassword(e.target.value);
                    if (errors.password) setErrors((prev) => ({ ...prev, password: '' }));
                  }}
                  disabled={loading}
                  style={{ paddingRight: '40px' }}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="user-action-btn"
                  style={{
                    position: 'absolute',
                    right: '6px',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    border: 'none',
                    background: 'transparent',
                    width: '30px',
                    height: '30px',
                  }}
                  aria-label={showPassword ? 'Ẩn mật khẩu' : 'Hiển thị mật khẩu'}
                >
                  {showPassword ? <EyeOffIcon size={16} color="#64748b" /> : <EyeIcon size={16} color="#64748b" />}
                </button>
              </div>
              {errors.password && <div className="user-form-error">{errors.password}</div>}
            </div>

            {/* Role Selection */}
            <div className="user-form-group">
              <label className="user-form-label">
                Phân quyền vai trò <span style={{ color: '#dc2626' }}>*</span>
              </label>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                {rolesList.map((r) => {
                  const isSelected = role === r.key;
                  return (
                    <label
                      key={r.key}
                      style={{
                        display: 'flex',
                        alignItems: 'flex-start',
                        gap: '10px',
                        padding: '8px 12px',
                        borderRadius: '8px',
                        border: isSelected ? '1.5px solid #0077b6' : '1px solid #e2e8f0',
                        backgroundColor: isSelected ? '#f0f9ff' : '#ffffff',
                        cursor: loading ? 'not-allowed' : 'pointer',
                        transition: 'all 0.15s ease',
                      }}
                    >
                      <input
                        type="radio"
                        name="user-role"
                        value={r.key}
                        checked={isSelected}
                        onChange={() => setRole(r.key)}
                        disabled={loading}
                        style={{ marginTop: '2px' }}
                      />
                      <div style={{ flex: 1 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          {r.icon}
                          <span style={{ fontWeight: 600, fontSize: '13px', color: '#0f172a' }}>
                            {r.label}
                          </span>
                          <span style={{ fontSize: '11px', color: '#64748b', fontFamily: 'monospace' }}>
                            ({r.key})
                          </span>
                        </div>
                        <div style={{ fontSize: '11.5px', color: '#64748b', marginTop: '1px', lineHeight: 1.35 }}>
                          {r.desc}
                        </div>
                      </div>
                    </label>
                  );
                })}
              </div>
            </div>

            {/* Status Selection */}
            <div className="user-form-group" style={{ marginBottom: 0 }}>
              <label className="user-form-label">Trạng thái tài khoản</label>
              <div style={{ display: 'flex', gap: '12px' }}>
                <label
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    padding: '8px 14px',
                    borderRadius: '8px',
                    border: status === 'ACTIVE' ? '1.5px solid #059669' : '1px solid #e2e8f0',
                    backgroundColor: status === 'ACTIVE' ? '#ecfdf5' : '#ffffff',
                    cursor: loading ? 'not-allowed' : 'pointer',
                    fontSize: '13px',
                    fontWeight: 500,
                    color: status === 'ACTIVE' ? '#065f46' : '#475569',
                    flex: 1,
                  }}
                >
                  <input
                    type="radio"
                    name="user-status"
                    value="ACTIVE"
                    checked={status === 'ACTIVE'}
                    onChange={() => setStatus('ACTIVE')}
                    disabled={loading}
                  />
                  <span>Đang hoạt động</span>
                </label>

                <label
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    padding: '8px 14px',
                    borderRadius: '8px',
                    border: status === 'LOCKED' ? '1.5px solid #dc2626' : '1px solid #e2e8f0',
                    backgroundColor: status === 'LOCKED' ? '#fef2f2' : '#ffffff',
                    cursor: loading ? 'not-allowed' : 'pointer',
                    fontSize: '13px',
                    fontWeight: 500,
                    color: status === 'LOCKED' ? '#991b1b' : '#475569',
                    flex: 1,
                  }}
                >
                  <input
                    type="radio"
                    name="user-status"
                    value="LOCKED"
                    checked={status === 'LOCKED'}
                    onChange={() => setStatus('LOCKED')}
                    disabled={loading}
                  />
                  <span>Tạm khóa tài khoản</span>
                </label>
              </div>
            </div>
          </div>

          {/* Modal Footer */}
          <div className="user-modal-footer">
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="user-action-btn"
              style={{
                width: 'auto',
                padding: '8px 16px',
                fontSize: '13px',
                fontWeight: 600,
                color: '#475569',
                borderColor: '#cbd5e1',
              }}
            >
              Hủy bỏ
            </button>
            <button
              type="submit"
              disabled={loading}
              className={`user-btn-add ${loading ? 'user-btn-submit-loading' : ''}`}
            >
              {loading
                ? mode === 'create'
                  ? 'Đang tạo...'
                  : 'Đang lưu...'
                : mode === 'create'
                ? 'Tạo tài khoản'
                : 'Lưu thay đổi'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

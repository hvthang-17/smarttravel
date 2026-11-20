import { t } from '../../core/language';
import React, { useState, useEffect } from 'react';
import { SearchIcon, RefreshCwIcon, XIcon } from '../../components/Icons';

interface UserFilterBarProps {
  search: string;
  onSearchChange: (val: string) => void;
  roleFilter: string;
  onRoleFilterChange: (val: string) => void;
  statusFilter: string;
  onStatusFilterChange: (val: string) => void;
  onRefresh: () => void;
  loading: boolean;
}

export const UserFilterBar: React.FC<UserFilterBarProps> = ({
  search,
  onSearchChange,
  roleFilter,
  onRoleFilterChange,
  statusFilter,
  onStatusFilterChange,
  onRefresh,
  loading,
}) => {
  const [localSearch, setLocalSearch] = useState(search);

  // Sync external search updates
  useEffect(() => {
    setLocalSearch(search);
  }, [search]);

  // Debounce search by 300ms
  useEffect(() => {
    const handler = setTimeout(() => {
      if (localSearch !== search) {
        onSearchChange(localSearch);
      }
    }, 300);

    return () => clearTimeout(handler);
  }, [localSearch, search, onSearchChange]);

  const handleClearSearch = () => {
    setLocalSearch('');
    onSearchChange('');
  };

  return (
    <div className="user-toolbar">
      <div className="user-toolbar-left">
        <div className="user-search-wrapper">
          <span
            className="user-search-icon"
            style={{
              position: 'absolute',
              left: '11px',
              top: '50%',
              transform: 'translateY(-50%)',
              display: 'flex',
              alignItems: 'center',
              pointerEvents: 'none',
              zIndex: 2,
            }}
          >
            <SearchIcon size={16} color="#94a3b8" />
          </span>
          <input
            type="text"
            className="user-search-input"
            placeholder={t("Tìm theo họ tên, email...")}
            value={localSearch}
            onChange={(e) => setLocalSearch(e.target.value)}
            aria-label={t("Tìm kiếm người dùng theo họ tên hoặc email")}
          />
          {localSearch && (
            <button
              type="button"
              onClick={handleClearSearch}
              className="user-action-btn"
              style={{
                position: 'absolute',
                right: '8px',
                top: '50%',
                transform: 'translateY(-50%)',
                width: '24px',
                height: '24px',
                border: 'none',
                background: 'transparent',
              }}
              aria-label={t("Xóa nội dung tìm kiếm")}
            >
              <XIcon size={14} color="#64748b" />
            </button>
          )}
        </div>

        <select
          className="user-filter-select"
          value={roleFilter}
          onChange={(e) => onRoleFilterChange(e.target.value)}
          aria-label={t("Lọc người dùng theo vai trò")}
        >
          <option value="ALL">{t("Tất cả vai trò")}</option>
          <option value="ROLE_ADMIN">{t("Quản trị viên (Admin)")}</option>
          <option value="ROLE_MODERATOR">{t("Điều phối viên (Moderator)")}</option>
          <option value="ROLE_USER">{t("Khách du lịch (User)")}</option>
        </select>

        <select
          className="user-filter-select"
          value={statusFilter}
          onChange={(e) => onStatusFilterChange(e.target.value)}
          aria-label={t("Lọc người dùng theo trạng thái")}
        >
          <option value="ALL">{t("Tất cả trạng thái")}</option>
          <option value="ACTIVE">{t("Đang hoạt động")}</option>
          <option value="LOCKED">{t("Tạm khóa")}</option>
        </select>

        <button
          type="button"
          onClick={onRefresh}
          disabled={loading}
          className="user-action-btn"
          style={{ width: '38px', height: '38px', borderRadius: '8px' }}
          title={t("Tải lại danh sách")}
          aria-label={t("Làm mới danh sách người dùng")}
        >
          <RefreshCwIcon size={16} color="#475569" className={loading ? 'animate-spin' : ''} />
        </button>
      </div>


    </div>
  );
};

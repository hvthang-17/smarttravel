import { t } from '../core/language';
import React, { useState, useEffect, useRef } from 'react';
import {
  SearchIcon,
  XIcon,
  PanelLeftCloseIcon,
  PanelLeftOpenIcon,
} from './Icons';
import { AuthUser, ROLE_LABELS } from '../types/auth';
import { LanguageSelect } from './LanguageSelect';

interface TopBarProps {
  currentTabName: string;
  isSidebarCollapsed?: boolean;
  onToggleSidebar?: () => void;
  onSearch?: (query: string) => void;
  currentUser?: AuthUser | null;
}

export const TopBar: React.FC<TopBarProps> = ({
  currentTabName,
  isSidebarCollapsed = false,
  onToggleSidebar,
  onSearch,
  currentUser,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const searchInputRef = useRef<HTMLInputElement>(null);

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const query = e.target.value;
    setSearchQuery(query);
    onSearch?.(query);
  };

  const handleClearSearch = () => {
    setSearchQuery('');
    onSearch?.('');
    searchInputRef.current?.focus();
  };

  // Ctrl+K keyboard shortcut to focus global search (R-32)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (searchInputRef.current && (e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        searchInputRef.current?.focus();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  return (
    <header className="admin-topbar">
      {/* Left: Sidebar Toggle & Breadcrumb (R-03, R-25, C-1) */}
      <div className="admin-topbar-context">
        {onToggleSidebar && (
          <button
            type="button"
            onClick={onToggleSidebar}
            className="btn-action-touch"
            style={{
              width: '36px',
              height: '36px',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              backgroundColor: isSidebarCollapsed ? '#e0f2fe' : '#ffffff',
              color: isSidebarCollapsed ? '#0077b6' : '#334155',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              padding: 0,
              transition: 'all 0.15s ease',
            }}
            title={isSidebarCollapsed ? 'Mở rộng thanh điều hướng (Sidebar)' : t('Thu gọn thanh điều hướng (Sidebar)')}
            aria-label={isSidebarCollapsed ? 'Mở rộng thanh điều hướng' : t('Thu gọn thanh điều hướng')}
          >
            {isSidebarCollapsed ? (
              <PanelLeftOpenIcon size={18} color="#0077b6" />
            ) : (
              <PanelLeftCloseIcon size={18} color="#334155" />
            )}
          </button>
        )}

        <div className="admin-breadcrumb">
          <span style={{ color: '#64748b', fontWeight: 500 }}>{t("Đà Nẵng")}</span>
          {/* Contrast compliant separator #64748b is 4.76:1 PASS WCAG AA */}
          <span style={{ color: '#64748b', fontWeight: 600 }}>›</span>
          <span style={{ color: '#0f172a', fontWeight: 600 }}>{currentTabName}</span>
        </div>
      </div>

      {/* Center: Global Search (R-26, C-2: Functional input linked with search callback) */}
      {onSearch && <div className="admin-global-search">
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            backgroundColor: '#f8fafc',
            border: '1px solid #cbd5e1',
            borderRadius: '8px',
            padding: '7px 12px',
            gap: '8px',
          }}
        >
          <SearchIcon size={15} color="#475569" />
          <input
            ref={searchInputRef}
            type="text"
            value={searchQuery}
            onChange={handleSearchChange}
            placeholder={t("Tìm địa điểm (Ctrl + K)")}
            aria-label={t("Tìm kiếm nhanh trong bảng điều khiển")}
            style={{
              border: 'none',
              background: 'transparent',
              outline: 'none',
              fontSize: '13px',
              color: '#0f172a',
              width: '100%',
            }}
          />
          {searchQuery && (
            <button
              type="button"
              onClick={handleClearSearch}
              style={{
                background: 'none',
                border: 'none',
                padding: '2px',
                cursor: 'pointer',
                color: '#475569',
                display: 'flex',
                alignItems: 'center',
              }}
              title={t("Xóa tìm kiếm")}
            >
              <XIcon size={14} color="#475569" />
            </button>
          )}
        </div>
      </div>}

      {/* Right: Status & User Info */}
      <div className="admin-topbar-tools">
        <LanguageSelect user={currentUser} />

        {/* User Info (R-23, C-1: Real authenticated user details) */}
        {(() => {
          const userInitials = currentUser?.fullName
            ? currentUser.fullName
                .trim()
                .split(/\s+/)
                .map((w) => w[0])
                .slice(-2)
                .join('')
                .toUpperCase()
            : 'AD';

          return (
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', paddingLeft: '8px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '8px',
                  backgroundColor: '#e0f2fe',
                  color: '#0369a1',
                  fontWeight: 700,
                  fontSize: '13px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  border: '1px solid #bae6fd',
                  flexShrink: 0,
                }}
              >
                {userInitials}
              </div>
              <div className="admin-topbar-account">
                <span style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a', lineHeight: 1.2 }}>
                  {currentUser?.fullName || t('Tài khoản quản trị')}
                </span>
                <span style={{ fontSize: '11px', color: '#475569' }}>
                  {currentUser ? ROLE_LABELS[currentUser.role] : t('Quản trị viên')}
                </span>
              </div>
            </div>
          );
        })()}
      </div>
    </header>
  );
};

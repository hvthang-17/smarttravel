import React, { useState, useEffect, useRef } from 'react';
import {
  SearchIcon,
  BellIcon,
  CheckCircleIcon,
  AlertTriangleIcon,
  InfoIcon,
  XIcon,
  PanelLeftCloseIcon,
  PanelLeftOpenIcon,
  CheckIcon,
} from './Icons';
import { AuthUser, ROLE_LABELS } from '../types/auth';

interface TopBarProps {
  currentTabName: string;
  isSidebarCollapsed?: boolean;
  onToggleSidebar?: () => void;
  onSearch?: (query: string) => void;
  currentUser?: AuthUser | null;
}

interface NotificationItem {
  id: number;
  title: string;
  meta: string;
  type: 'warning' | 'success' | 'info';
  read: boolean;
}

export const TopBar: React.FC<TopBarProps> = ({
  currentTabName,
  isSidebarCollapsed = false,
  onToggleSidebar,
  onSearch,
  currentUser,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [showNotifications, setShowNotifications] = useState(false);
  const [notifications, setNotifications] = useState<NotificationItem[]>([
    {
      id: 1,
      title: 'Cần xác minh giờ Chùa Linh Ứng',
      meta: '2 phản hồi từ du khách • 2 giờ trước',
      type: 'warning',
      read: false,
    },
    {
      id: 2,
      title: 'Bà Nà Hills đã cập nhật giờ mở cửa',
      meta: 'Bởi Admin Lan Nguyễn • 15 phút trước',
      type: 'success',
      read: false,
    },
    {
      id: 3,
      title: 'Hạn mức Maps API ở mức an toàn (34%)',
      meta: 'Đồng bộ hàng ngày lúc 06:00',
      type: 'info',
      read: false,
    },
  ]);

  const searchInputRef = useRef<HTMLInputElement>(null);
  const notifRef = useRef<HTMLDivElement>(null);

  const unreadCount = notifications.filter((n) => !n.read).length;

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

  const handleMarkAllAsRead = () => {
    setNotifications((prev) => prev.map((item) => ({ ...item, read: true })));
  };

  const handleDismissNotification = (id: number) => {
    setNotifications((prev) => prev.filter((item) => item.id !== id));
  };

  // Ctrl+K keyboard shortcut to focus global search (R-32)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        searchInputRef.current?.focus();
      }
      if (e.key === 'Escape') {
        setShowNotifications(false);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Click outside to close notifications
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setShowNotifications(false);
      }
    };
    if (showNotifications) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [showNotifications]);

  return (
    <header
      style={{
        height: '64px',
        backgroundColor: '#ffffff',
        borderBottom: '1px solid #e5e7eb',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '0 24px',
        position: 'sticky',
        top: 0,
        zIndex: 50,
        flexShrink: 0,
        boxSizing: 'border-box',
      }}
    >
      {/* Left: Sidebar Toggle & Breadcrumb (R-03, R-25, C-1) */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
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
            title={isSidebarCollapsed ? 'Mở rộng thanh điều hướng (Sidebar)' : 'Thu gọn thanh điều hướng (Sidebar)'}
            aria-label={isSidebarCollapsed ? 'Mở rộng thanh điều hướng' : 'Thu gọn thanh điều hướng'}
          >
            {isSidebarCollapsed ? (
              <PanelLeftOpenIcon size={18} color="#0077b6" />
            ) : (
              <PanelLeftCloseIcon size={18} color="#334155" />
            )}
          </button>
        )}

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13.5px', color: '#475569' }}>
          <span style={{ color: '#64748b', fontWeight: 500 }}>Đà Nẵng</span>
          {/* Contrast compliant separator #64748b is 4.76:1 PASS WCAG AA */}
          <span style={{ color: '#64748b', fontWeight: 600 }}>›</span>
          <span style={{ color: '#0f172a', fontWeight: 600 }}>{currentTabName}</span>
        </div>
      </div>

      {/* Center: Global Search (R-26, C-2: Functional input linked with search callback) */}
      <div style={{ flex: 1, maxWidth: '420px', margin: '0 24px' }}>
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
            placeholder="Tìm kiếm địa điểm, audit log... (Ctrl + K)"
            aria-label="Tìm kiếm nhanh trong bảng điều khiển"
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
              title="Xóa tìm kiếm"
            >
              <XIcon size={14} color="#475569" />
            </button>
          )}
        </div>
      </div>

      {/* Right: Status & User Info */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }} ref={notifRef}>

        {/* Notifications Button with Functional Dropdown (R-26, R-38) */}
        <div style={{ position: 'relative' }}>
          <button
            type="button"
            onClick={() => setShowNotifications(!showNotifications)}
            className="btn-action-touch"
            style={{
              position: 'relative',
              background: showNotifications ? '#e0f2fe' : '#f8fafc',
              border: '1px solid #cbd5e1',
              width: '36px',
              height: '36px',
              borderRadius: '8px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: '#334155',
            }}
            title={unreadCount > 0 ? `Có ${unreadCount} thông báo chưa đọc` : 'Thông báo hệ thống'}
            aria-label="Thông báo hệ thống"
            aria-expanded={showNotifications}
          >
            <BellIcon size={16} color="#334155" />
            {unreadCount > 0 && (
              <span
                style={{
                  position: 'absolute',
                  top: '6px',
                  right: '6px',
                  width: '7px',
                  height: '7px',
                  borderRadius: '50%',
                  backgroundColor: '#f97316',
                }}
              />
            )}
          </button>

          {/* Popover */}
          {showNotifications && (
            <div
              className="animate-fade-in"
              style={{
                position: 'absolute',
                top: '46px',
                right: 0,
                width: '340px',
                backgroundColor: '#ffffff',
                border: '1px solid #cbd5e1',
                borderRadius: '8px',
                boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
                zIndex: 100,
                overflow: 'hidden',
              }}
            >
              <div
                style={{
                  padding: '12px 14px',
                  borderBottom: '1px solid #f1f5f9',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <strong style={{ fontSize: '13px', color: '#0f172a' }}>
                    Thông báo {unreadCount > 0 ? `(${unreadCount})` : ''}
                  </strong>
                  <span style={{ fontSize: '11px', color: '#64748b' }}>[DEMO LOG]</span>
                </div>
                {unreadCount > 0 && (
                  <button
                    type="button"
                    onClick={handleMarkAllAsRead}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: '#0077b6',
                      fontSize: '11.5px',
                      fontWeight: 600,
                      cursor: 'pointer',
                      padding: '2px 4px',
                    }}
                  >
                    Đã đọc tất cả
                  </button>
                )}
              </div>

              <div style={{ maxHeight: '280px', overflowY: 'auto' }}>
                {notifications.length === 0 ? (
                  <div style={{ padding: '24px 16px', textAlign: 'center', color: '#64748b', fontSize: '13px' }}>
                    Không có thông báo nào
                  </div>
                ) : (
                  notifications.map((item) => (
                    <div
                      key={item.id}
                      style={{
                        padding: '10px 14px',
                        borderBottom: '1px solid #f8fafc',
                        display: 'flex',
                        gap: '10px',
                        backgroundColor: item.read ? '#ffffff' : '#f8fafc',
                        alignItems: 'flex-start',
                        transition: 'background-color 0.15s ease',
                      }}
                    >
                      {item.type === 'warning' && (
                        <AlertTriangleIcon size={16} color="#d97706" style={{ marginTop: '2px', flexShrink: 0 }} />
                      )}
                      {item.type === 'success' && (
                        <CheckCircleIcon size={16} color="#059669" style={{ marginTop: '2px', flexShrink: 0 }} />
                      )}
                      {item.type === 'info' && (
                        <InfoIcon size={16} color="#0284c7" style={{ marginTop: '2px', flexShrink: 0 }} />
                      )}

                      <div style={{ flex: 1, minWidth: 0 }}>
                        <p
                          style={{
                            margin: 0,
                            fontSize: '12px',
                            color: item.read ? '#475569' : '#0f172a',
                            fontWeight: item.read ? 500 : 600,
                          }}
                        >
                          {item.title}
                        </p>
                        <span style={{ fontSize: '11px', color: '#64748b' }}>{item.meta}</span>
                      </div>

                      <button
                        type="button"
                        onClick={() => handleDismissNotification(item.id)}
                        style={{
                          background: 'none',
                          border: 'none',
                          color: '#94a3b8',
                          cursor: 'pointer',
                          padding: '2px',
                          display: 'flex',
                          alignItems: 'center',
                          flexShrink: 0,
                        }}
                        title="Đóng thông báo này"
                        aria-label="Đóng thông báo"
                      >
                        <XIcon size={12} color="#94a3b8" />
                      </button>
                    </div>
                  ))
                )}
              </div>
            </div>
          )}
        </div>

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
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                <span style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a', lineHeight: 1.2 }}>
                  {currentUser?.fullName || 'Lan Nguyễn'}
                </span>
                <span style={{ fontSize: '11px', color: '#475569' }}>
                  {currentUser ? ROLE_LABELS[currentUser.role] : 'Quản trị viên'}
                </span>
              </div>
            </div>
          );
        })()}
      </div>
    </header>
  );
};

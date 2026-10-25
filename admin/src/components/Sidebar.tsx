import React, { useState, useEffect } from 'react';
import {
  WavesIcon,
  LayoutDashboardIcon,
  MapPinIcon,
  TagIcon,
  UsersIcon,
  ClipboardListIcon,
  SmartphoneIcon,
  LogOutIcon,
  ExternalLinkIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  LockIcon,
} from './Icons';
import { AuthUser, canManageUsers, canViewAuditLogs, ROLE_LABELS, ROLE_BADGE_STYLES } from '../types/auth';
import { clearStoredAuth } from '../core/authApi';

export type AdminTab = 'dashboard' | 'destinations' | 'categories' | 'users' | 'audit';

interface SidebarProps {
  currentTab: AdminTab;
  onTabChange: (tab: AdminTab) => void;
  destinationCount: number;
  isCollapsed?: boolean;
  onToggleCollapse?: () => void;
  currentUser?: AuthUser | null;
  onLogout?: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  currentTab,
  onTabChange,
  destinationCount,
  isCollapsed = false,
  onToggleCollapse,
  currentUser,
  onLogout,
}) => {
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  // Close modal with Escape key (R-32)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setShowLogoutModal(false);
      }
    };
    if (showLogoutModal) {
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [showLogoutModal]);

  const userRole = currentUser?.role || 'ROLE_ADMIN';
  const roleStyle = ROLE_BADGE_STYLES[userRole] || ROLE_BADGE_STYLES.ROLE_USER;

  const navItems = [
    {
      id: 'dashboard' as AdminTab,
      label: 'Tổng quan',
      Icon: LayoutDashboardIcon,
      allowed: true,
    },
    {
      id: 'destinations' as AdminTab,
      label: 'Quản lý địa điểm',
      Icon: MapPinIcon,
      badge: typeof destinationCount === 'number' && destinationCount > 0 ? String(destinationCount) : undefined,
      allowed: true,
    },
    {
      id: 'categories' as AdminTab,
      label: 'Danh mục',
      Icon: TagIcon,
      allowed: true,
    },
    {
      id: 'users' as AdminTab,
      label: 'Người dùng',
      Icon: UsersIcon,
      allowed: canManageUsers(userRole),
      lockBadge: !canManageUsers(userRole) ? 'Admin only' : undefined,
    },
    {
      id: 'audit' as AdminTab,
      label: 'Nhật ký thao tác',
      Icon: ClipboardListIcon,
      allowed: canViewAuditLogs(userRole),
      lockBadge: !canViewAuditLogs(userRole) ? 'Admin only' : undefined,
    },
  ];

  return (
    <aside
      style={{
        width: isCollapsed ? '68px' : '240px',
        backgroundColor: '#ffffff',
        borderRight: '1px solid #e5e7eb',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        flexShrink: 0,
        height: '100%',
        maxHeight: '100%',
        transition: 'width 0.2s cubic-bezier(0.16, 1, 0.3, 1)',
        userSelect: 'none',
        overflow: 'hidden',
      }}
    >
      {/* 1. Brand Logo Header (SmartTravel ADMIN) - Spacious & Clean without button overlap (R-03, C-1) */}
      <div
        style={{
          height: '64px',
          borderBottom: '1px solid #e5e7eb',
          display: 'flex',
          alignItems: 'center',
          justifyContent: isCollapsed ? 'center' : 'flex-start',
          padding: isCollapsed ? '0 12px' : '0 18px',
          flexShrink: 0,
          boxSizing: 'border-box',
          width: '100%',
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            cursor: isCollapsed ? 'pointer' : 'default',
            width: isCollapsed ? 'auto' : '100%',
          }}
          onClick={isCollapsed ? onToggleCollapse : undefined}
          title={isCollapsed ? 'Mở rộng thanh điều hướng (Sidebar)' : undefined}
        >
          <div
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '8px',
              backgroundColor: '#0077b6',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#ffffff',
              flexShrink: 0,
            }}
          >
            <WavesIcon size={18} color="#ffffff" strokeWidth={2.2} />
          </div>

          {!isCollapsed && (
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flex: 1, minWidth: 0 }}>
              <span
                style={{
                  fontSize: '17px',
                  fontWeight: 700,
                  color: '#0f172a',
                  letterSpacing: '-0.3px',
                  whiteSpace: 'nowrap',
                }}
              >
                SmartTravel
              </span>
              <span
                style={{
                  fontSize: '10px',
                  fontWeight: 700,
                  backgroundColor: '#f1f5f9',
                  color: '#475569',
                  padding: '2px 6px',
                  borderRadius: '4px',
                  border: '1px solid #e2e8f0',
                  textTransform: 'uppercase',
                  letterSpacing: '0.4px',
                  flexShrink: 0,
                }}
              >
                ADMIN
              </span>
            </div>
          )}
        </div>
      </div>

      {/* 2. Scrollable Navigation List Area */}
      <div
        style={{
          flex: 1,
          padding: isCollapsed ? '16px 8px' : '16px 14px',
          overflowY: 'auto',
          overflowX: 'hidden',
        }}
      >
        {/* Section title (R-06: Natural typography without harsh uppercase spacing) */}
        {!isCollapsed ? (
          <div
            style={{
              fontSize: '12px',
              fontWeight: 600,
              color: '#64748b',
              padding: '0 12px',
              marginBottom: '8px',
              whiteSpace: 'nowrap',
            }}
          >
            Bảng điều khiển
          </div>
        ) : (
          <div style={{ height: '8px' }} />
        )}

        {/* Navigation list */}
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
          {navItems.map((item) => {
            const isActive = currentTab === item.id;
            const ItemIcon = item.Icon;
            const isAllowed = item.allowed !== false;

            return (
              <button
                key={item.id}
                type="button"
                onClick={() => {
                  if (isAllowed) {
                    onTabChange(item.id);
                  }
                }}
                disabled={!isAllowed}
                className="btn-action-touch"
                title={!isAllowed ? `${item.label} (Yêu cầu quyền ROLE_ADMIN)` : item.label}
                aria-label={item.label}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: isCollapsed ? 'center' : 'space-between',
                  padding: isCollapsed ? '10px 0' : '10px 12px',
                  borderRadius: '8px',
                  border: 'none',
                  backgroundColor: isActive ? '#e0f2fe' : 'transparent',
                  color: !isAllowed ? '#94a3b8' : isActive ? '#0369a1' : '#334155',
                  fontWeight: isActive ? 600 : 500,
                  fontSize: '13.5px',
                  cursor: !isAllowed ? 'not-allowed' : 'pointer',
                  textAlign: 'left',
                  transition: 'all 0.15s ease',
                  position: 'relative',
                  width: '100%',
                  opacity: !isAllowed ? 0.65 : 1,
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <ItemIcon size={18} color={!isAllowed ? '#94a3b8' : isActive ? '#0284c7' : '#64748b'} />
                  {!isCollapsed && (
                    <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {item.label}
                    </span>
                  )}
                </div>

                {/* Badge or Lock */}
                {!isCollapsed && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    {item.lockBadge && (
                      <span
                        style={{
                          fontSize: '10px',
                          fontWeight: 600,
                          backgroundColor: '#f1f5f9',
                          color: '#64748b',
                          padding: '1px 5px',
                          borderRadius: '4px',
                          border: '1px solid #e2e8f0',
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '2px',
                        }}
                      >
                        <LockIcon size={10} color="#64748b" />
                        Admin
                      </span>
                    )}
                    {item.badge !== undefined && (
                      <span
                        style={{
                          fontSize: '11px',
                          fontWeight: 600,
                          backgroundColor: isActive ? '#bae6fd' : '#f1f5f9',
                          color: isActive ? '#075985' : '#475569',
                          padding: '2px 6px',
                          borderRadius: '6px',
                        }}
                      >
                        {item.badge}
                      </span>
                    )}
                  </div>
                )}
              </button>
            );
          })}
        </nav>
      </div>

      {/* 3. Bottom Footer Actions & Collapse Toggle */}
      <div
        style={{
          borderTop: '1px solid #e5e7eb',
          padding: isCollapsed ? '12px 8px' : '14px 14px',
          display: 'flex',
          flexDirection: 'column',
          gap: '6px',
          flexShrink: 0,
        }}
      >
        {/* User Card with Role Badge (R-09, C-1) */}
        {!isCollapsed && currentUser && (
          <div
            style={{
              padding: '8px 10px',
              backgroundColor: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0',
              marginBottom: '2px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '2px' }}>
              <span style={{ fontSize: '12px', fontWeight: 600, color: '#0f172a', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                {currentUser.fullName}
              </span>
              <span
                style={{
                  fontSize: '9.5px',
                  fontWeight: 700,
                  backgroundColor: roleStyle.bg,
                  color: roleStyle.text,
                  border: `1px solid ${roleStyle.border}`,
                  padding: '1px 5px',
                  borderRadius: '4px',
                  flexShrink: 0,
                }}
              >
                {ROLE_LABELS[currentUser.role]}
              </span>
            </div>
            <div style={{ fontSize: '11px', color: '#64748b', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {currentUser.email}
            </div>
          </div>
        )}

        {/* Clean Logout Button with In-App Confirmation Modal (R-26, C-2) */}
        <button
          type="button"
          onClick={() => setShowLogoutModal(true)}
          className="btn-action-touch"
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: isCollapsed ? 'center' : 'flex-start',
            gap: '10px',
            fontSize: '13px',
            color: '#dc2626',
            background: 'none',
            border: 'none',
            padding: isCollapsed ? '8px 0' : '8px 12px',
            borderRadius: '8px',
            fontWeight: 500,
            cursor: 'pointer',
            textAlign: 'left',
            width: '100%',
          }}
          title="Đăng xuất khỏi hệ thống"
        >
          <LogOutIcon size={16} color="#dc2626" />
          {!isCollapsed && <span style={{ whiteSpace: 'nowrap' }}>Đăng xuất</span>}
        </button>
      </div>

      {/* Logout Confirmation Modal (R-26, R-32, C-2) */}
      {showLogoutModal && (
        <div
          role="dialog"
          aria-modal="true"
          aria-labelledby="logout-dialog-title"
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'rgba(15, 23, 42, 0.45)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
            backdropFilter: 'blur(2px)',
          }}
          onClick={() => setShowLogoutModal(false)}
        >
          <div
            className="animate-fade-in"
            style={{
              backgroundColor: '#ffffff',
              borderRadius: '12px',
              padding: '24px',
              maxWidth: '400px',
              width: '90%',
              boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)',
              border: '1px solid #e2e8f0',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <h3
              id="logout-dialog-title"
              style={{ margin: '0 0 8px 0', fontSize: '16px', fontWeight: 600, color: '#0f172a' }}
            >
              Xác nhận đăng xuất
            </h3>
            <p style={{ margin: '0 0 20px 0', fontSize: '13.5px', color: '#475569', lineHeight: 1.5 }}>
              Bạn có chắc chắn muốn kết thúc phiên làm việc quản trị SmartTravel hiện tại không?
            </p>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                onClick={() => setShowLogoutModal(false)}
                className="btn-action-touch"
                style={{
                  padding: '8px 16px',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  backgroundColor: '#ffffff',
                  color: '#334155',
                  fontSize: '13px',
                  fontWeight: 500,
                  cursor: 'pointer',
                }}
              >
                Hủy bỏ
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowLogoutModal(false);
                  if (onLogout) {
                    onLogout();
                  } else {
                    clearStoredAuth();
                    window.location.reload();
                  }
                }}
                className="btn-action-touch"
                style={{
                  padding: '8px 16px',
                  borderRadius: '6px',
                  border: 'none',
                  backgroundColor: '#dc2626',
                  color: '#ffffff',
                  fontSize: '13px',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Đăng xuất
              </button>
            </div>
          </div>
        </div>
      )}
    </aside>
  );
};

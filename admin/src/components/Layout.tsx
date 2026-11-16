import { t } from '../core/language';
import React, { useEffect, useState } from 'react';
import { TopBar } from './TopBar';
import { Sidebar, AdminTab } from './Sidebar';
import { AuthUser } from '../types/auth';

interface LayoutProps {
  currentTab: AdminTab;
  onTabChange: (tab: AdminTab) => void;
  destinationCount: number;
  onSearch?: (query: string) => void;
  currentUser?: AuthUser | null;
  onLogout?: () => void;
  children: React.ReactNode;
}

const TAB_NAMES: Record<AdminTab, string> = {
  dashboard: t('Tổng quan Dashboard'),
  destinations: t('Quản lý địa điểm'),
  categories: t('Quản lý danh mục'),
  users: t('Quản lý tài khoản'),
  audit: t('Nhật ký thao tác hệ thống'),
  reviews: t('Kiểm duyệt đánh giá'),
  trips: t('Quản trị lịch trình'),
};

export const Layout: React.FC<LayoutProps> = ({
  currentTab,
  onTabChange,
  destinationCount,
  onSearch,
  currentUser,
  onLogout,
  children,
}) => {
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(() => window.matchMedia('(max-width: 768px)').matches);
  useEffect(() => {
    const screen = window.matchMedia('(max-width: 768px)');
    const adaptSidebar = () => setIsSidebarCollapsed(screen.matches);
    screen.addEventListener('change', adaptSidebar);
    return () => screen.removeEventListener('change', adaptSidebar);
  }, []);

  return (
    <div className="admin-shell">
      {/* 1. Sidebar fixed full-height on the left */}
      <Sidebar
        currentTab={currentTab}
        onTabChange={onTabChange}
        destinationCount={destinationCount}
        isCollapsed={isSidebarCollapsed}
        onToggleCollapse={() => setIsSidebarCollapsed((prev) => !prev)}
        currentUser={currentUser}
        onLogout={onLogout}
      />

      {/* 2. Right workspace: TopBar on top + independently scrollable Main content */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          flex: 1,
          minWidth: 0,
          overflow: 'hidden',
        }}
      >
        <TopBar
          currentTabName={t(TAB_NAMES[currentTab])}
          isSidebarCollapsed={isSidebarCollapsed}
          onToggleSidebar={() => setIsSidebarCollapsed((prev) => !prev)}
          onSearch={onSearch}
          currentUser={currentUser}
        />
        <main
          className="admin-workspace-main"
          style={{
            flex: 1,
            overflowY: 'auto',
            overflowX: 'hidden',
            backgroundColor: 'var(--admin-canvas)',
          }}
        >
          {children}
        </main>
      </div>
    </div>
  );
};

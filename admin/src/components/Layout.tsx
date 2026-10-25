import React, { useState } from 'react';
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
  dashboard: 'Tổng quan Dashboard',
  destinations: 'Quản lý địa điểm',
  categories: 'Quản lý danh mục',
  users: 'Quản lý tài khoản',
  audit: 'Nhật ký thao tác hệ thống',
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
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);

  return (
    <div
      style={{
        display: 'flex',
        height: '100vh',
        overflow: 'hidden',
        backgroundColor: '#f8fafc',
      }}
    >
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
          currentTabName={TAB_NAMES[currentTab]}
          isSidebarCollapsed={isSidebarCollapsed}
          onToggleSidebar={() => setIsSidebarCollapsed((prev) => !prev)}
          onSearch={onSearch}
          currentUser={currentUser}
        />
        <main
          style={{
            flex: 1,
            padding: '24px 32px',
            overflowY: 'auto',
            overflowX: 'hidden',
            backgroundColor: '#f8fafc',
          }}
        >
          {children}
        </main>
      </div>
    </div>
  );
};

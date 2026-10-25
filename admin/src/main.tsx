import React, { StrictMode, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Layout } from './components/Layout';
import { AdminTab } from './components/Sidebar';
import { DestinationList } from './features/destinations/DestinationList';
import { DashboardView } from './features/dashboard/DashboardView';
import { CategoriesView } from './features/categories/CategoriesView';
import { UsersView } from './features/users/UsersView';
import { AuditLogsView } from './features/audit/AuditLogsView';
import { AuthPage } from './features/auth/AuthPage';
import { AccessDeniedView } from './features/auth/AccessDeniedView';
import { AuthUser, canAccessAdmin, canManageUsers, canViewAuditLogs } from './types/auth';
import { getStoredUser, clearStoredAuth } from './core/authApi';
import './style.css';

const AdminApp: React.FC = () => {
  const [currentUser, setCurrentUser] = useState<AuthUser | null>(() => getStoredUser());
  const [currentTab, setCurrentTab] = useState<AdminTab>('destinations');
  const [destinationCount, setDestinationCount] = useState<number>(148);
  const [globalSearch, setGlobalSearch] = useState('');

  const handleLogout = () => {
    clearStoredAuth();
    setCurrentUser(null);
  };

  const handleTabChange = (tab: AdminTab) => {
    // Role-based navigation guard (RBAC)
    if (tab === 'users' && !canManageUsers(currentUser?.role)) {
      return;
    }
    if (tab === 'audit' && !canViewAuditLogs(currentUser?.role)) {
      return;
    }
    setCurrentTab(tab);
  };

  // 1. Unauthenticated: Render Auth Page with Scenic Da Nang Hero & Smooth Transitions
  if (!currentUser) {
    return (
      <AuthPage
        initialView="login"
        onLoginSuccess={(user) => {
          setCurrentUser(user);
        }}
        onRegisterSuccess={(user) => {
          setCurrentUser(user);
        }}
      />
    );
  }

  // 2. Authenticated but Role Restricted (e.g. ROLE_USER trying to access Admin)
  if (!canAccessAdmin(currentUser.role)) {
    return (
      <AccessDeniedView
        currentUser={currentUser}
        onLogout={handleLogout}
      />
    );
  }

  // 3. Authenticated Admin / Moderator: Render Full Admin Layout with RBAC
  return (
    <Layout
      currentTab={currentTab}
      onTabChange={handleTabChange}
      destinationCount={destinationCount}
      onSearch={setGlobalSearch}
      currentUser={currentUser}
      onLogout={handleLogout}
    >
      {currentTab === 'destinations' && (
        <DestinationList
          onTotalCountChange={setDestinationCount}
          externalSearchQuery={globalSearch}
          userRole={currentUser.role}
        />
      )}
      {currentTab === 'dashboard' && (
        <DashboardView
          destinationCount={destinationCount}
          onNavigateDestinations={() => setCurrentTab('destinations')}
        />
      )}
      {currentTab === 'categories' && <CategoriesView />}
      {currentTab === 'users' && canManageUsers(currentUser.role) && <UsersView currentUser={currentUser} />}
      {currentTab === 'audit' && canViewAuditLogs(currentUser.role) && <AuditLogsView />}
    </Layout>
  );
};

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AdminApp />
  </StrictMode>
);

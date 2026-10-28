import React, { StrictMode, useState, useMemo } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, Navigate, useLocation, useNavigate } from 'react-router-dom';
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
  const [destinationCount, setDestinationCount] = useState<number>(18);
  const [globalSearch, setGlobalSearch] = useState('');
  const location = useLocation();
  const navigate = useNavigate();

  // Derive currentTab from location.pathname (e.g. /destinations -> 'destinations')
  const currentTab = useMemo<AdminTab>(() => {
    const segment = location.pathname.replace(/^\/+/, '').split('/')[0];
    if (['dashboard', 'destinations', 'categories', 'users', 'audit'].includes(segment)) {
      return segment as AdminTab;
    }
    return 'destinations';
  }, [location.pathname]);

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
    navigate(`/${tab}`);
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

  // 3. Authenticated Admin / Moderator: Render Full Admin Layout with React Router Routes & RBAC
  return (
    <Layout
      currentTab={currentTab}
      onTabChange={handleTabChange}
      destinationCount={destinationCount}
      onSearch={setGlobalSearch}
      currentUser={currentUser}
      onLogout={handleLogout}
    >
      <Routes>
        <Route path="/" element={<Navigate to="/destinations" replace />} />
        <Route
          path="/destinations"
          element={
            <DestinationList
              onTotalCountChange={setDestinationCount}
              externalSearchQuery={globalSearch}
              userRole={currentUser.role}
            />
          }
        />
        <Route
          path="/dashboard"
          element={
            <DashboardView
              destinationCount={destinationCount}
              onNavigateDestinations={() => navigate('/destinations')}
            />
          }
        />
        <Route path="/categories" element={<CategoriesView />} />
        <Route
          path="/users"
          element={
            canManageUsers(currentUser.role) ? (
              <UsersView currentUser={currentUser} />
            ) : (
              <Navigate to="/destinations" replace />
            )
          }
        />
        <Route
          path="/audit"
          element={
            canViewAuditLogs(currentUser.role) ? (
              <AuditLogsView />
            ) : (
              <Navigate to="/destinations" replace />
            )
          }
        />
        <Route path="*" element={<Navigate to="/destinations" replace />} />
      </Routes>
    </Layout>
  );
};

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BrowserRouter>
      <AdminApp />
    </BrowserRouter>
  </StrictMode>
);

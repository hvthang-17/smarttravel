import { t } from './core/language';
import React, { StrictMode, useState, useMemo, useEffect, useRef } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { Layout } from './components/Layout';
import { AdminTab } from './components/Sidebar';
import { DestinationList } from './features/destinations/DestinationList';
import { DashboardView } from './features/dashboard/DashboardView';
import { AdminTripsView } from './features/itineraries/AdminTripsView';
import { CategoriesView } from './features/categories/CategoriesView';
import { UsersView } from './features/users/UsersView';
import { AuditLogsView } from './features/audit/AuditLogsView';
import { AuthPage } from './features/auth/AuthPage';
import { AccessDeniedView } from './features/auth/AccessDeniedView';
import { AuthUser, canAccessAdmin, canManageUsers, canViewAuditLogs } from './types/auth';
import { clearStoredAuth, refreshSession } from './core/authApi';
import { SESSION_EXPIRED, PERMISSIONS_CHANGED } from './core/session';
import './style.css';
import './admin-design.css';
import './admin-pages.css';
import { setUiLanguage, useUiLanguage } from './core/language';
import { LanguageSelect } from './components/LanguageSelect';

const ReviewsView = React.lazy(() => import('./features/reviews/ReviewsView').then(module => ({ default: module.ReviewsView })));

const AdminApp: React.FC = () => {
  const language = useUiLanguage();
  const [currentUser, setCurrentUser] = useState<AuthUser | null>(null);
  const [checkingSession, setCheckingSession] = useState(true);
  const sessionRequest = useRef(0);
  const [destinationCount, setDestinationCount] = useState(0);
  const [globalSearch, setGlobalSearch] = useState('');
  const location = useLocation();
  const navigate = useNavigate();
  useEffect(() => { document.documentElement.lang = language; }, [language]);
  useEffect(() => { setUiLanguage(currentUser?.language ?? 'vi'); }, [currentUser?.id, currentUser?.language]);

  useEffect(() => {
    let active = true;
    const refresh = () => {
      const request = ++sessionRequest.current;
      refreshSession().then(user => { if (active && request === sessionRequest.current) setCurrentUser(user); })
        .catch(() => { if (active && request === sessionRequest.current) setCurrentUser(null); })
        .finally(() => { if (active) setCheckingSession(false); });
    };
    const expired = () => { sessionRequest.current++; setCurrentUser(null); };
    refresh();
    window.addEventListener(SESSION_EXPIRED, expired);
    window.addEventListener(PERMISSIONS_CHANGED, refresh);
    return () => {
      active = false;
      window.removeEventListener(SESSION_EXPIRED, expired);
      window.removeEventListener(PERMISSIONS_CHANGED, refresh);
    };
  }, []);

  // Derive currentTab from location.pathname (e.g. /destinations -> 'destinations')
  const currentTab = useMemo<AdminTab>(() => {
    const segment = location.pathname.replace(/^\/+/, '').split('/')[0];
    if (['dashboard', 'destinations', 'categories', 'users', 'audit', 'reviews', 'trips'].includes(segment)) {
      return segment as AdminTab;
    }
    return 'destinations';
  }, [location.pathname]);

  const handleLogout = () => {
    sessionRequest.current++;
    clearStoredAuth();
    setUiLanguage('vi');
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

  if (checkingSession) return <p role="status">{t("Đang kiểm tra phiên đăng nhập...")}</p>;

  // 1. Unauthenticated: Render Auth Page with Scenic Da Nang Hero & Smooth Transitions
  if (!currentUser) {
    return (
      <><div style={{ position: 'absolute', right: 16, top: 16, zIndex: 10 }}><LanguageSelect user={null} /></div><AuthPage
        initialView="login"
        onLoginSuccess={(user) => {
          sessionRequest.current++;
          setCurrentUser(user);
        }}
        onRegisterSuccess={(user) => {
          sessionRequest.current++;
          setCurrentUser(user);
        }}
      /></>
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

  // Backend permissions remain authoritative after the client navigation check.
  return (
    <Layout
      currentTab={currentTab}
      onTabChange={handleTabChange}
      destinationCount={destinationCount}
      onSearch={currentTab === 'destinations' ? setGlobalSearch : undefined}
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
            <DashboardView />
          }
        />
        <Route path="/categories" element={<CategoriesView />} />
        <Route path="/trips" element={<AdminTripsView />} />
        <Route path="/reviews" element={
          <React.Suspense fallback={<p role="status">{t("Đang tải trang kiểm duyệt…")}</p>}>
            <ReviewsView />
          </React.Suspense>
        } />
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

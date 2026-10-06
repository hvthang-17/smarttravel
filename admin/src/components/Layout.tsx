import React from 'react';

interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  return (
    <div style={{ fontFamily: 'system-ui, -apple-system, sans-serif', minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <header style={{ backgroundColor: '#004d40', color: '#fff', padding: '16px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ margin: 0 }}>SmartTravel Admin</h2>
        <nav style={{ display: 'flex', gap: '16px' }}>
          <span style={{ cursor: 'pointer', fontWeight: 600 }}>Điểm đến</span>
          <span style={{ cursor: 'pointer', opacity: 0.8 }}>Lịch trình</span>
        </nav>
      </header>
      <main style={{ flex: 1, padding: '32px', backgroundColor: '#f4f6f8' }}>
        {children}
      </main>
      <footer style={{ padding: '16px 32px', backgroundColor: '#e0e0e0', textAlign: 'center', fontSize: '14px', color: '#666' }}>
        SmartTravel Admin Portal © 2026 - Da Nang Tourism Platform
      </footer>
    </div>
  );
};

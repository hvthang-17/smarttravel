import React from 'react';
import { UsersIcon, CheckCircleIcon, LockIcon, ShieldCheckIcon } from '../../components/Icons';

export interface UserStats {
  total: number;
  active: number;
  locked: number;
  admin: number;
}

interface UserStatsCardsProps {
  stats: UserStats;
  loading?: boolean;
}

export const UserStatsCards: React.FC<UserStatsCardsProps> = ({ stats, loading = false }) => {
  const cards = [
    {
      label: 'Tổng số tài khoản',
      value: stats.total,
      icon: <UsersIcon size={22} color="#0077b6" />,
      bg: '#e0f2fe',
      color: '#0f172a',
    },
    {
      label: 'Đang hoạt động',
      value: stats.active,
      icon: <CheckCircleIcon size={22} color="#059669" />,
      bg: '#ecfdf5',
      color: '#166534',
    },
    {
      label: 'Tạm khóa',
      value: stats.locked,
      icon: <LockIcon size={22} color="#dc2626" />,
      bg: '#fee2e2',
      color: '#991b1b',
    },
    {
      label: 'Quản trị viên',
      value: stats.admin,
      icon: <ShieldCheckIcon size={22} color="#7c3aed" />,
      bg: '#f3e8ff',
      color: '#7c3aed',
    },
  ];

  return (
    <div className="user-stats-grid">
      {cards.map((card, idx) => (
        <div key={idx} className="user-stat-card">
          <div className="user-stat-icon-box" style={{ backgroundColor: card.bg }}>
            {card.icon}
          </div>
          <div>
            <div className="user-stat-value" style={{ color: card.color }}>
              {loading ? '-' : card.value.toLocaleString('vi-VN')}
            </div>
            <div className="user-stat-label">{card.label}</div>
          </div>
        </div>
      ))}
    </div>
  );
};

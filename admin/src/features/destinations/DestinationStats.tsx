import React from 'react';
import { MapPinIcon, CheckCircleIcon, EyeOffIcon, StarIcon } from '../../components/Icons';

interface Props {
  totalCount: number;
  activeCount: number;
  inactiveCount: number;
  averageRating: number;
}

export const DestinationStats: React.FC<Props> = ({
  totalCount,
  activeCount,
  inactiveCount,
  averageRating,
}) => {
  return (
    <div className="destination-stats-grid">
      <div className="destination-stat-card">
        <div className="destination-stat-icon-box" style={{ backgroundColor: '#e0f2fe' }}>
          <MapPinIcon size={22} color="#0077b6" />
        </div>
        <div>
          <div className="destination-stat-value" style={{ color: '#0f172a' }}>
            {totalCount.toLocaleString('vi-VN')}
          </div>
          <div className="destination-stat-label">Tổng số địa điểm</div>
        </div>
      </div>

      <div className="destination-stat-card">
        <div className="destination-stat-icon-box" style={{ backgroundColor: '#ecfdf5' }}>
          <CheckCircleIcon size={22} color="#059669" />
        </div>
        <div>
          <div className="destination-stat-value" style={{ color: '#166534' }}>
            {activeCount.toLocaleString('vi-VN')}
          </div>
          <div className="destination-stat-label">Đang hoạt động</div>
        </div>
      </div>

      <div className="destination-stat-card">
        <div className="destination-stat-icon-box" style={{ backgroundColor: '#f1f5f9' }}>
          <EyeOffIcon size={22} color="#64748b" />
        </div>
        <div>
          <div className="destination-stat-value" style={{ color: '#475569' }}>
            {inactiveCount.toLocaleString('vi-VN')}
          </div>
          <div className="destination-stat-label">Tạm ẩn</div>
        </div>
      </div>

      <div className="destination-stat-card">
        <div className="destination-stat-icon-box" style={{ backgroundColor: '#fef3c7' }}>
          <StarIcon size={22} color="#d97706" fill="#f59e0b" strokeWidth={1.5} />
        </div>
        <div>
          <div className="destination-stat-value" style={{ color: '#b45309' }}>
            {averageRating > 0 ? averageRating.toFixed(1) : '4.5'}
            <span style={{ fontSize: '13px', fontWeight: 500, color: '#92400e', marginLeft: '4px' }}>/ 5.0</span>
          </div>
          <div className="destination-stat-label">Đánh giá trung bình</div>
        </div>
      </div>
    </div>
  );
};

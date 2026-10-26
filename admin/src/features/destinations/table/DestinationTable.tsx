import React from 'react';
import { Destination } from '../../../types/destination';
import { Category } from '../../../core/categoryApi';
import { AlertTriangleIcon, RefreshCwIcon } from '../../../components/Icons';
import { DestinationTableSkeleton } from './DestinationTableSkeleton';
import { DestinationTableRow } from './DestinationTableRow';
import { DestinationMobileCard } from './DestinationMobileCard';
import { DestinationPagination } from './DestinationPagination';

interface Props {
  destinations: Destination[];
  categoriesList: Category[];
  loading: boolean;
  error: string | null;
  currentPage: number;
  totalPages: number;
  itemsPerPage: number;
  totalFilteredCount: number;
  canDelete: boolean;
  actionPendingId: number | null;
  onPageChange: (page: number) => void;
  onToggleStatus: (destination: Destination) => void;
  onView: (destination: Destination) => void;
  onEdit: (destination: Destination) => void;
  onDelete: (destination: Destination) => void;
  onRetry?: () => void;
}

export const DestinationTable: React.FC<Props> = ({
  destinations,
  categoriesList,
  loading,
  error,
  currentPage,
  totalPages,
  itemsPerPage,
  totalFilteredCount,
  canDelete,
  actionPendingId,
  onPageChange,
  onToggleStatus,
  onView,
  onEdit,
  onDelete,
  onRetry,
}) => {
  // Skeleton Loading Shimmer (C-2)
  if (loading) {
    return <DestinationTableSkeleton />;
  }

  // Error Banner with Retry Action (C-4, R-27)
  if (error) {
    return (
      <div className="destination-table-container">
        <div className="destination-error-container" role="alert">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <AlertTriangleIcon size={20} color="#dc2626" />
            <span style={{ fontWeight: 500 }}>Lỗi tải dữ liệu: {error}</span>
          </div>
          {onRetry && (
            <button
              type="button"
              onClick={onRetry}
              className="destination-retry-btn"
              title="Nhấn để thử tải lại dữ liệu"
              aria-label="Tải lại dữ liệu điểm đến"
            >
              <RefreshCwIcon size={14} color="#b91c1c" />
              <span>Thử lại</span>
            </button>
          )}
        </div>
      </div>
    );
  }

  // Empty State (R-27)
  if (destinations.length === 0) {
    return (
      <div className="destination-table-container">
        <div style={{ padding: '64px 24px', textAlign: 'center', color: '#64748b' }}>
          <div style={{ fontSize: '15px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
            Không tìm thấy địa điểm nào
          </div>
          <p style={{ fontSize: '13px', margin: 0 }}>
            Thử thay đổi từ khóa tìm kiếm hoặc điều chỉnh lại các bộ lọc danh mục và trạng thái.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="destination-table-container">
      {/* Desktop Responsive Table (R-03 / AGENTS.md) */}
      <div className="destination-table-scroll">
        <table className="destination-table">
          <thead>
            <tr>
              <th scope="col" style={{ width: '320px' }}>Địa điểm & Địa chỉ</th>
              <th scope="col" style={{ width: '170px' }}>Danh mục</th>
              <th scope="col" style={{ width: '180px' }}>Tọa độ & Bản đồ</th>
              <th scope="col" style={{ width: '170px' }}>Chi phí ước tính</th>
              <th scope="col" style={{ width: '160px' }}>Giờ hoạt động</th>
              <th scope="col" style={{ width: '120px' }}>Đánh giá</th>
              <th scope="col" style={{ width: '120px' }}>Trạng thái</th>
              <th scope="col" style={{ width: '120px', textAlign: 'center' }}>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {destinations.map((d, index) => (
              <DestinationTableRow
                key={d.id || index}
                destination={d}
                index={index}
                categoriesList={categoriesList}
                canDelete={canDelete}
                isPending={actionPendingId === d.id}
                onToggleStatus={onToggleStatus}
                onView={onView}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile Card Reflow (< 768px) (R-03 / antislop-layoutmobile) */}
      <div className="destination-mobile-list">
        {destinations.map((d, index) => (
          <DestinationMobileCard
            key={`mob-${d.id || index}`}
            destination={d}
            index={index}
            categoriesList={categoriesList}
            canDelete={canDelete}
            isPending={actionPendingId === d.id}
            onToggleStatus={onToggleStatus}
            onView={onView}
            onEdit={onEdit}
            onDelete={onDelete}
          />
        ))}
      </div>

      {/* Pagination Footer (R-32) */}
      <DestinationPagination
        currentPage={currentPage}
        totalPages={totalPages}
        itemsPerPage={itemsPerPage}
        totalFilteredCount={totalFilteredCount}
        onPageChange={onPageChange}
      />
    </div>
  );
};

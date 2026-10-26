import React from 'react';
import { ChevronLeftIcon, ChevronRightIcon } from '../../../components/Icons';

interface Props {
  currentPage: number;
  totalPages: number;
  itemsPerPage: number;
  totalFilteredCount: number;
  onPageChange: (page: number) => void;
}

export const DestinationPagination: React.FC<Props> = ({
  currentPage,
  totalPages,
  itemsPerPage,
  totalFilteredCount,
  onPageChange,
}) => {
  const safeTotalPages = Math.max(1, totalPages);
  const startIndex = totalFilteredCount > 0 ? (currentPage - 1) * itemsPerPage + 1 : 0;
  const endIndex = Math.min(currentPage * itemsPerPage, totalFilteredCount);

  return (
    <div className="destination-pagination-bar" role="navigation" aria-label="Phân trang dữ liệu địa điểm">
      <div style={{ fontSize: '13px', color: '#64748b' }}>
        Hiển thị <strong>{startIndex}–{endIndex}</strong> trong tổng số <strong>{totalFilteredCount}</strong> địa điểm
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
        <button
          type="button"
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage <= 1}
          className="destination-page-btn"
          aria-label="Trang trước"
          title="Về trang trước"
        >
          <ChevronLeftIcon size={15} />
        </button>

        <span style={{ fontSize: '13px', fontWeight: 500, color: '#334155', padding: '0 8px' }}>
          Trang {currentPage} / {safeTotalPages}
        </span>

        <button
          type="button"
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage >= safeTotalPages}
          className="destination-page-btn"
          aria-label="Trang sau"
          title="Sang trang tiếp theo"
        >
          <ChevronRightIcon size={15} />
        </button>
      </div>
    </div>
  );
};

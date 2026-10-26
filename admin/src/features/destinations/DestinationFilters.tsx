import React from 'react';
import { SearchIcon, XIcon, DownloadIcon } from '../../components/Icons';
import { Category } from '../../core/categoryApi';

interface Props {
  searchQuery: string;
  onSearchChange: (value: string) => void;
  categoryFilter: string;
  onCategoryFilterChange: (value: string) => void;
  statusFilter: string;
  onStatusFilterChange: (value: string) => void;
  sortBy: string;
  onSortByChange: (value: string) => void;
  categoriesList: Category[];
  isFiltered: boolean;
  onResetFilters: () => void;
  onExportCsv: () => void;
}

export const DestinationFilters: React.FC<Props> = ({
  searchQuery,
  onSearchChange,
  categoryFilter,
  onCategoryFilterChange,
  statusFilter,
  onStatusFilterChange,
  sortBy,
  onSortByChange,
  categoriesList,
  isFiltered,
  onResetFilters,
  onExportCsv,
}) => {
  return (
    <div className="destination-filter-bar">
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap', flex: '1 1 auto' }}>
        {/* Search Input with centered icon */}
        <div style={{ position: 'relative', width: '260px', maxWidth: '100%', display: 'flex', alignItems: 'center' }}>
          <span style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none', display: 'flex', alignItems: 'center' }}>
            <SearchIcon size={14} color="#64748b" />
          </span>
          <input
            type="text"
            placeholder="Tìm theo tên, địa chỉ, mô tả..."
            aria-label="Tìm kiếm địa điểm"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            className="destination-filter-input"
            style={{ paddingLeft: '32px', paddingRight: searchQuery ? '30px' : '10px' }}
          />
          {searchQuery && (
            <button
              type="button"
              onClick={() => onSearchChange('')}
              aria-label="Xóa từ khóa tìm kiếm"
              style={{
                position: 'absolute',
                right: '8px',
                top: '50%',
                transform: 'translateY(-50%)',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                color: '#64748b',
                display: 'flex',
                alignItems: 'center',
                padding: '2px',
              }}
            >
              <XIcon size={13} />
            </button>
          )}
        </div>

        {/* Dynamic Category Selector */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Danh mục:</label>
          <select
            value={categoryFilter}
            onChange={(e) => onCategoryFilterChange(e.target.value)}
            aria-label="Lọc theo danh mục"
            className="destination-filter-select"
          >
            <option value="ALL">Tất cả danh mục</option>
            {categoriesList.map((cat) => (
              <option key={cat.id} value={cat.name}>
                {cat.name} ({cat.destinationsCount || 0})
              </option>
            ))}
            {categoriesList.length === 0 && (
              <>
                <option value="Culture">Văn hóa & Di sản</option>
                <option value="Beach">Biển & Thiên nhiên</option>
                <option value="Food">Ẩm thực & Đặc sản</option>
                <option value="Cafe">Cà phê & Thư giãn</option>
                <option value="Hotel">Nghỉ dưỡng & Khách sạn</option>
              </>
            )}
          </select>
        </div>

        {/* Status Selector */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Trạng thái:</label>
          <select
            value={statusFilter}
            onChange={(e) => onStatusFilterChange(e.target.value)}
            aria-label="Lọc theo trạng thái"
            className="destination-filter-select"
          >
            <option value="ALL">Tất cả</option>
            <option value="ACTIVE">Đang hoạt động</option>
            <option value="INACTIVE">Tạm ẩn</option>
          </select>
        </div>

        {/* Sorting Dropdown */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Sắp xếp:</label>
          <select
            value={sortBy}
            onChange={(e) => onSortByChange(e.target.value)}
            aria-label="Sắp xếp kết quả"
            className="destination-filter-select"
          >
            <option value="DEFAULT">Mặc định (ID)</option>
            <option value="RATING_DESC">Đánh giá cao nhất</option>
            <option value="REVIEWS_DESC">Nhiều đánh giá nhất</option>
            <option value="NAME_ASC">Tên A-Z</option>
            <option value="PRICE_ASC">Giá tăng dần</option>
          </select>
        </div>

        {/* Clear Filters Button with WCAG AA compliance (ratio 4.87:1) */}
        {isFiltered && (
          <button
            type="button"
            onClick={onResetFilters}
            className="btn-action-touch"
            style={{
              border: 'none',
              background: 'none',
              color: '#0077b6',
              fontSize: '13px',
              fontWeight: 600,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '4px',
              padding: '4px 6px',
            }}
            aria-label="Đặt lại tất cả bộ lọc tìm kiếm"
          >
            <XIcon size={13} color="#0077b6" />
            <span>Xóa bộ lọc</span>
          </button>
        )}
      </div>

      {/* Export CSV Button */}
      <button
        type="button"
        onClick={onExportCsv}
        className="btn-action-touch"
        style={{
          padding: '7px 14px',
          borderRadius: '8px',
          border: '1px solid #cbd5e1',
          backgroundColor: '#ffffff',
          color: '#334155',
          fontSize: '13px',
          fontWeight: 600,
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          gap: '6px',
          boxShadow: '0 1px 2px rgba(0, 0, 0, 0.05)',
        }}
        aria-label="Xuất dữ liệu danh sách địa điểm thành file CSV"
      >
        <DownloadIcon size={14} color="#475569" />
        <span>Xuất CSV</span>
      </button>
    </div>
  );
};

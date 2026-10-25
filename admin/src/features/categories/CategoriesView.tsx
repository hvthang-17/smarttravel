import React, { useState, useEffect, useCallback, useMemo } from 'react';
import {
  PlusIcon,
  TagIcon,
  SearchIcon,
  RefreshCwIcon,
  PencilIcon,
  TrashIcon,
  CheckCircleIcon,
  AlertTriangleIcon,
  XIcon,
  EyeOffIcon,
  MapPinIcon,
} from '../../components/Icons';
import {
  Category,
  fetchCategoriesApi,
  toggleCategoryStatusApi,
  resolveImageUrl,
} from '../../core/categoryApi';
import { renderCategoryIcon } from './categoryIcons';
import { AddCategoryModal } from './AddCategoryModal';
import { EditCategoryModal } from './EditCategoryModal';
import { DeleteCategoryModal } from './DeleteCategoryModal';

interface ToastState {
  message: string;
  type: 'success' | 'error';
}

export const CategoriesView: React.FC = () => {
  // Global & filtered categories
  const [allCategories, setAllCategories] = useState<Category[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Filters with debounce
  const [searchQuery, setSearchQuery] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Debounce search query 300ms (R-26, C-4)
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchQuery);
    }, 300);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  // Modals state
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);
  const [deletingCategory, setDeletingCategory] = useState<Category | null>(null);
  const [togglingId, setTogglingId] = useState<number | null>(null);

  // Toast
  const [toast, setToast] = useState<ToastState | null>(null);

  const showToast = (message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3500);
  };

  // Load categories from backend API
  const loadCategories = useCallback(async () => {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      // 1. Fetch filtered list
      const data = await fetchCategoriesApi({
        search: debouncedSearch,
        status: statusFilter,
      });
      setCategories(data);

      // 2. Fetch global categories once or when no filters active for accurate system metrics (R-17)
      if (!debouncedSearch && statusFilter === 'ALL') {
        setAllCategories(data);
      } else if (allCategories.length === 0) {
        const fullData = await fetchCategoriesApi();
        setAllCategories(fullData);
      }
    } catch (err: any) {
      setErrorMessage(err.message || 'Không thể tải danh sách danh mục từ máy chủ');
    } finally {
      setIsLoading(false);
    }
  }, [debouncedSearch, statusFilter, allCategories.length]);

  useEffect(() => {
    loadCategories();
  }, [loadCategories]);

  // Toggle active/inactive with pending state
  const handleToggleStatus = async (cat: Category) => {
    if (togglingId === cat.id) return;
    setTogglingId(cat.id);
    try {
      const updated = await toggleCategoryStatusApi(cat.id);
      setCategories((prev) =>
        prev.map((item) => (item.id === cat.id ? { ...item, status: updated.status } : item))
      );
      setAllCategories((prev) =>
        prev.map((item) => (item.id === cat.id ? { ...item, status: updated.status } : item))
      );
      showToast(
        `Đã chuyển trạng thái danh mục "${cat.name}" sang ${updated.status === 'ACTIVE' ? 'Hoạt động' : 'Tạm ẩn'}`,
        'success'
      );
    } catch (err: any) {
      showToast(err.message || 'Lỗi khi thay đổi trạng thái danh mục', 'error');
    } finally {
      setTogglingId(null);
    }
  };

  // Honest system metrics calculation (R-17)
  const metricsSource = allCategories.length > 0 ? allCategories : categories;
  const totalCount = metricsSource.length;
  const activeCount = useMemo(() => metricsSource.filter((c) => c.status === 'ACTIVE').length, [metricsSource]);
  const inactiveCount = useMemo(() => metricsSource.filter((c) => c.status === 'INACTIVE').length, [metricsSource]);
  const totalDestinations = useMemo(
    () => metricsSource.reduce((sum, c) => sum + (c.destinationsCount || 0), 0),
    [metricsSource]
  );

  const isFiltered = Boolean(debouncedSearch.trim() || statusFilter !== 'ALL');

  const handleResetFilters = () => {
    setSearchQuery('');
    setDebouncedSearch('');
    setStatusFilter('ALL');
  };

  return (
    <div>
      {/* Toast Alert */}
      {toast && (
        <div
          role="status"
          style={{
            position: 'fixed',
            bottom: '24px',
            right: '24px',
            zIndex: 1200,
            backgroundColor: toast.type === 'error' ? '#991B1B' : '#0F172A',
            color: '#FFFFFF',
            padding: '12px 18px',
            borderRadius: '8px',
            boxShadow: '0 10px 20px -3px rgba(0, 0, 0, 0.25)',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            fontSize: '13.5px',
            fontWeight: 500,
          }}
        >
          {toast.type === 'error' ? (
            <AlertTriangleIcon size={16} color="#FCA5A5" />
          ) : (
            <CheckCircleIcon size={16} color="#10B981" />
          )}
          <span>{toast.message}</span>
          <button
            type="button"
            onClick={() => setToast(null)}
            aria-label="Đóng thông báo"
            style={{
              background: 'none',
              border: 'none',
              color: '#94A3B8',
              cursor: 'pointer',
              marginLeft: '0.5rem',
              padding: '0.25rem',
              display: 'flex',
              alignItems: 'center',
            }}
          >
            <XIcon size={16} />
          </button>
        </div>
      )}

      {/* Header Section */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'flex-start',
          marginBottom: '20px',
          flexWrap: 'wrap',
          gap: '16px',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            <h1
              style={{
                fontSize: '22px',
                fontWeight: 700,
                color: '#0f172a',
                margin: 0,
                letterSpacing: '-0.3px',
              }}
            >
              Quản lý Danh mục Địa điểm
            </h1>
            <span
              style={{
                backgroundColor: '#e0f2fe',
                color: '#0369a1',
                fontSize: '12px',
                fontWeight: 600,
                padding: '3px 8px',
                borderRadius: '6px',
              }}
            >
              {isFiltered ? `Hiển thị ${categories.length}/${totalCount}` : `${totalCount}`} danh mục
            </span>
          </div>
          <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: '#475569' }}>
            Phân loại địa điểm du lịch Đà Nẵng, tùy biến mã icon, màu sắc HEX và hình ảnh trực tiếp từ cơ sở dữ liệu
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <button
            type="button"
            onClick={() => loadCategories()}
            disabled={isLoading}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '8px 14px',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              backgroundColor: '#ffffff',
              color: '#334155',
              fontSize: '13px',
              fontWeight: 600,
              cursor: 'pointer',
              boxShadow: '0 1px 2px rgba(0, 0, 0, 0.05)',
              minHeight: '38px',
            }}
          >
            <RefreshCwIcon size={15} color="#475569" />
            <span>Làm mới</span>
          </button>

          <button
            type="button"
            onClick={() => setIsAddModalOpen(true)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '8px 16px',
              borderRadius: '8px',
              border: 'none',
              backgroundColor: '#0077b6',
              color: '#ffffff',
              fontSize: '13.5px',
              fontWeight: 600,
              cursor: 'pointer',
              boxShadow: '0 2px 4px rgba(0, 119, 182, 0.2)',
              minHeight: '38px',
            }}
          >
            <PlusIcon size={16} color="#ffffff" />
            <span>Thêm danh mục mới</span>
          </button>
        </div>
      </div>

      {/* Honest Metrics Bar (R-17) */}
      <div className="category-stats-grid">
        <div className="category-stat-card">
          <div className="category-stat-icon-box" style={{ backgroundColor: '#e0f2fe' }}>
            <TagIcon size={22} color="#0077b6" />
          </div>
          <div>
            <div className="category-stat-value" style={{ color: '#0f172a' }}>
              {totalCount.toLocaleString('vi-VN')}
            </div>
            <div className="category-stat-label">Tổng số danh mục</div>
          </div>
        </div>

        <div className="category-stat-card">
          <div className="category-stat-icon-box" style={{ backgroundColor: '#ecfdf5' }}>
            <CheckCircleIcon size={22} color="#059669" />
          </div>
          <div>
            <div className="category-stat-value" style={{ color: '#166534' }}>
              {activeCount.toLocaleString('vi-VN')}
            </div>
            <div className="category-stat-label">Đang hoạt động</div>
          </div>
        </div>

        <div className="category-stat-card">
          <div className="category-stat-icon-box" style={{ backgroundColor: '#f1f5f9' }}>
            <EyeOffIcon size={22} color="#64748b" />
          </div>
          <div>
            <div className="category-stat-value" style={{ color: '#475569' }}>
              {inactiveCount.toLocaleString('vi-VN')}
            </div>
            <div className="category-stat-label">Tạm ẩn</div>
          </div>
        </div>

        <div className="category-stat-card">
          <div className="category-stat-icon-box" style={{ backgroundColor: '#f3e8ff' }}>
            <MapPinIcon size={22} color="#7c3aed" />
          </div>
          <div>
            <div className="category-stat-value" style={{ color: '#7c3aed' }}>
              {totalDestinations.toLocaleString('vi-VN')}
            </div>
            <div className="category-stat-label">Tổng địa điểm liên kết</div>
          </div>
        </div>
      </div>

      {/* Search and Filters Bar with Debounce & Clear (R-26, C-4) */}
      <div className="category-filter-bar">
        <div style={{ position: 'relative', flex: '1 1 300px', maxWidth: '420px' }}>
          <div
            style={{
              position: 'absolute',
              left: '12px',
              top: '50%',
              transform: 'translateY(-50%)',
              color: '#94a3b8',
              display: 'flex',
              alignItems: 'center',
            }}
          >
            <SearchIcon size={16} />
          </div>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Tìm theo tên danh mục, tên tiếng Anh, mã code..."
            className="category-input"
            style={{ paddingLeft: '36px', paddingRight: searchQuery ? '36px' : '12px' }}
          />
          {searchQuery && (
            <button
              type="button"
              onClick={() => setSearchQuery('')}
              aria-label="Xóa từ khóa tìm kiếm"
              style={{
                position: 'absolute',
                right: '10px',
                top: '50%',
                transform: 'translateY(-50%)',
                background: 'none',
                border: 'none',
                color: '#94a3b8',
                cursor: 'pointer',
                padding: '4px',
                display: 'flex',
                alignItems: 'center',
              }}
            >
              <XIcon size={14} />
            </button>
          )}
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <label style={{ fontSize: '13px', fontWeight: 600, color: '#475569' }}>
            Trạng thái:
          </label>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="category-select"
            style={{ width: 'auto', minWidth: '160px' }}
          >
            <option value="ALL">Tất cả trạng thái</option>
            <option value="ACTIVE">Đang hoạt động</option>
            <option value="INACTIVE">Tạm ẩn</option>
          </select>

          {isFiltered && (
            <button
              type="button"
              onClick={handleResetFilters}
              style={{
                padding: '8px 12px',
                borderRadius: '8px',
                border: '1px solid #cbd5e1',
                backgroundColor: '#ffffff',
                color: '#475569',
                fontSize: '12.5px',
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              Đặt lại
            </button>
          )}
        </div>
      </div>

      {/* Error Message */}
      {errorMessage && (
        <div
          style={{
            padding: '1rem',
            borderRadius: '0.75rem',
            backgroundColor: '#FEF2F2',
            border: '1px solid #FCA5A5',
            color: '#991B1B',
            fontSize: '0.875rem',
            marginBottom: '1.5rem',
          }}
        >
          {errorMessage}
        </div>
      )}

      {/* Categories Grid with Skeleton Loading (R-27) */}
      {isLoading ? (
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(min(100%, 300px), 1fr))',
            gap: '1.5rem',
          }}
        >
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="category-skeleton-card">
              <div className="skeleton-pulse" style={{ height: '140px' }} />
              <div style={{ padding: '1.25rem', display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>
                  <div className="skeleton-pulse" style={{ width: '44px', height: '44px', borderRadius: '12px' }} />
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '6px' }}>
                    <div className="skeleton-pulse" style={{ height: '18px', width: '70%', borderRadius: '4px' }} />
                    <div className="skeleton-pulse" style={{ height: '12px', width: '40%', borderRadius: '4px' }} />
                  </div>
                </div>
                <div className="skeleton-pulse" style={{ height: '36px', width: '100%', borderRadius: '4px' }} />
                <div className="skeleton-pulse" style={{ height: '28px', width: '100%', borderRadius: '6px', marginTop: '0.5rem' }} />
              </div>
            </div>
          ))}
        </div>
      ) : categories.length === 0 ? (
        /* Empty State (R-27) */
        <div className="category-empty-state">
          <div
            style={{
              width: '3.5rem',
              height: '3.5rem',
              borderRadius: '9999px',
              backgroundColor: '#F1F5F9',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 1rem auto',
            }}
          >
            <TagIcon size={28} color="#94A3B8" />
          </div>
          <h3 style={{ fontSize: '1.125rem', fontWeight: 600, color: '#0F172A', margin: '0 0 0.5rem 0' }}>
            {isFiltered ? 'Không tìm thấy danh mục phù hợp' : 'Chưa có danh mục nào được khởi tạo'}
          </h3>
          <p style={{ fontSize: '0.875rem', color: '#64748B', margin: '0 0 1.25rem 0', maxWidth: '420px', marginLeft: 'auto', marginRight: 'auto' }}>
            {isFiltered
              ? 'Thử điều chỉnh từ khóa tìm kiếm hoặc bấm nút "Đặt lại bộ lọc" bên dưới để xem toàn bộ danh mục.'
              : 'Hãy bắt đầu phân loại các điểm tham quan Đà Nẵng bằng cách tạo mới danh mục đầu tiên.'}
          </p>
          {isFiltered ? (
            <button
              type="button"
              onClick={handleResetFilters}
              style={{
                padding: '8px 16px',
                borderRadius: '8px',
                border: '1px solid #CBD5E1',
                backgroundColor: '#FFFFFF',
                color: '#334155',
                fontSize: '13px',
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              Đặt lại bộ lọc
            </button>
          ) : (
            <button
              type="button"
              onClick={() => setIsAddModalOpen(true)}
              style={{
                padding: '8px 16px',
                borderRadius: '8px',
                border: 'none',
                backgroundColor: '#0077B6',
                color: '#FFFFFF',
                fontSize: '13.5px',
                fontWeight: 600,
                cursor: 'pointer',
              }}
            >
              Thêm danh mục mới
            </button>
          )}
        </div>
      ) : (
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(min(100%, 300px), 1fr))',
            gap: '1.5rem',
          }}
        >
          {categories.map((cat) => {
            const hasImage = Boolean(cat.imageUrl);
            const imageSrc = resolveImageUrl(cat.imageUrl);
            const color = cat.colorHex || '#0077B6';
            const isToggling = togglingId === cat.id;

            return (
              <div key={cat.id} className="category-card">
                {/* Header Banner */}
                <div
                  style={{
                    height: '140px',
                    position: 'relative',
                    backgroundColor: hasImage ? '#0F172A' : color,
                    backgroundImage: hasImage
                      ? `url(${imageSrc})`
                      : `linear-gradient(135deg, ${color} 0%, #0F172A 100%)`,
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                  }}
                >
                  {/* Status Badge (WCAG AA: #15803D 5.02:1, #334155 10.35:1) */}
                  <div
                    style={{
                      position: 'absolute',
                      top: '0.75rem',
                      right: '0.75rem',
                      padding: '0.25rem 0.625rem',
                      borderRadius: '9999px',
                      backgroundColor: cat.status === 'ACTIVE' ? '#15803D' : '#334155',
                      color: '#FFFFFF',
                      fontSize: '0.6875rem',
                      fontWeight: 700,
                      letterSpacing: '0.025em',
                      boxShadow: '0 1px 3px rgba(0,0,0,0.3)',
                    }}
                  >
                    {cat.status === 'ACTIVE' ? 'HOẠT ĐỘNG' : 'TẠM ẨN'}
                  </div>

                  {/* Order Badge */}
                  <div
                    style={{
                      position: 'absolute',
                      top: '0.75rem',
                      left: '0.75rem',
                      padding: '0.25rem 0.5rem',
                      borderRadius: '0.375rem',
                      backgroundColor: 'rgba(15, 23, 42, 0.75)',
                      backdropFilter: 'blur(4px)',
                      color: '#FFFFFF',
                      fontSize: '0.6875rem',
                      fontWeight: 600,
                    }}
                  >
                    Thứ tự: #{cat.displayOrder}
                  </div>
                </div>

                {/* Card Content */}
                <div style={{ padding: '1.25rem', flex: 1, display: 'flex', flexDirection: 'column' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
                    <div
                      style={{
                        width: '2.75rem',
                        height: '2.75rem',
                        borderRadius: '0.75rem',
                        backgroundColor: `${color}18`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        flexShrink: 0,
                      }}
                    >
                      {renderCategoryIcon(cat.icon, color, 24)}
                    </div>
                    <div style={{ overflow: 'hidden' }}>
                      <h3
                        style={{
                          margin: 0,
                          fontSize: '1.0625rem',
                          fontWeight: 700,
                          color: '#0F172A',
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                        }}
                      >
                        {cat.name}
                      </h3>
                      <div
                        style={{
                          fontSize: '0.75rem',
                          color: '#64748B',
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                        }}
                      >
                        {cat.nameEn || cat.slug}
                      </div>
                    </div>
                  </div>

                  <p
                    style={{
                      fontSize: '0.8125rem',
                      color: '#475569',
                      lineHeight: 1.5,
                      margin: '0 0 1rem 0',
                      flex: 1,
                      display: '-webkit-box',
                      WebkitLineClamp: 3,
                      WebkitBoxOrient: 'vertical',
                      overflow: 'hidden',
                    }}
                  >
                    {cat.description || 'Chưa có thông tin mô tả giới thiệu cho danh mục này.'}
                  </p>

                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '0.625rem 0',
                      borderTop: '1px solid #F1F5F9',
                      borderBottom: '1px solid #F1F5F9',
                      marginBottom: '1rem',
                      fontSize: '0.75rem',
                    }}
                  >
                    <span
                      style={{
                        padding: '0.2rem 0.5rem',
                        borderRadius: '0.25rem',
                        backgroundColor: '#F1F5F9',
                        fontWeight: 700,
                        color: '#475569',
                        fontFamily: 'monospace',
                      }}
                    >
                      {cat.code}
                    </span>
                    <span style={{ color: '#0077B6', fontWeight: 600 }}>
                      {cat.destinationsCount} địa điểm liên kết
                    </span>
                  </div>

                  {/* Actions */}
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      gap: '0.5rem',
                    }}
                  >
                    <button
                      type="button"
                      onClick={() => handleToggleStatus(cat)}
                      disabled={isToggling}
                      title={cat.status === 'ACTIVE' ? 'Tạm ẩn danh mục' : 'Kích hoạt danh mục'}
                      style={{
                        flex: 1,
                        padding: '0.5rem',
                        borderRadius: '0.5rem',
                        border: '1px solid #E2E8F0',
                        backgroundColor: cat.status === 'ACTIVE' ? '#F0FDF4' : '#F8FAFC',
                        color: cat.status === 'ACTIVE' ? '#166534' : '#475569',
                        fontSize: '0.75rem',
                        fontWeight: 600,
                        cursor: isToggling ? 'not-allowed' : 'pointer',
                        opacity: isToggling ? 0.6 : 1,
                        minHeight: '38px',
                      }}
                    >
                      {isToggling
                        ? 'Đang đổi...'
                        : cat.status === 'ACTIVE'
                        ? 'Đang hoạt động'
                        : 'Tạm ẩn'}
                    </button>

                    <button
                      type="button"
                      onClick={() => setEditingCategory(cat)}
                      title="Chỉnh sửa danh mục"
                      style={{
                        padding: '0.5rem 0.75rem',
                        borderRadius: '0.5rem',
                        border: '1px solid #CBD5E1',
                        backgroundColor: '#FFFFFF',
                        color: '#334155',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        minHeight: '38px',
                        minWidth: '38px',
                      }}
                    >
                      <PencilIcon size={16} />
                    </button>

                    <button
                      type="button"
                      onClick={() => setDeletingCategory(cat)}
                      title="Xóa danh mục"
                      style={{
                        padding: '0.5rem 0.75rem',
                        borderRadius: '0.5rem',
                        border: '1px solid #FCA5A5',
                        backgroundColor: '#FEF2F2',
                        color: '#DC2626',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        minHeight: '38px',
                        minWidth: '38px',
                      }}
                    >
                      <TrashIcon size={16} />
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Modals */}
      <AddCategoryModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onSuccess={() => {
          loadCategories();
          showToast('Đã thêm mới danh mục thành công!', 'success');
        }}
      />

      <EditCategoryModal
        isOpen={Boolean(editingCategory)}
        category={editingCategory}
        onClose={() => setEditingCategory(null)}
        onSuccess={() => {
          loadCategories();
          showToast('Đã cập nhật danh mục thành công!', 'success');
        }}
      />

      <DeleteCategoryModal
        isOpen={Boolean(deletingCategory)}
        category={deletingCategory}
        onClose={() => setDeletingCategory(null)}
        onSuccess={() => {
          loadCategories();
          showToast('Đã xóa danh mục thành công!', 'success');
        }}
      />
    </div>
  );
};

import React, { useEffect, useState, useCallback, useMemo, useRef } from 'react';
import { fetchDestinations, createDestination, updateDestination, deleteDestination } from '../../core/api';
import { fetchCategoriesApi, Category } from '../../core/categoryApi';
import { Destination } from '../../types/destination';
import { RoleType, canDeleteDestinations } from '../../types/auth';
import { DestinationStats } from './DestinationStats';
import { DestinationFilters } from './DestinationFilters';
import { DestinationTable } from './table/DestinationTable';
import { DestinationDetailModal } from './modals/DestinationDetailModal';
import { AddDestinationModal } from './form/AddDestinationModal';
import { EditDestinationDrawer } from './form/EditDestinationDrawer';
import { DeleteConfirmModal } from './modals/DeleteConfirmModal';
import {
  PlusIcon,
  RefreshCwIcon,
  CheckCircleIcon,
  AlertTriangleIcon,
  XIcon,
} from '../../components/Icons';

interface Props {
  onTotalCountChange?: (count: number) => void;
  externalSearchQuery?: string;
  userRole?: RoleType;
}

interface ToastState {
  message: string;
  type: 'success' | 'error';
}

interface GlobalStats {
  total: number;
  active: number;
  inactive: number;
  averageRating: number;
}

export const DestinationList: React.FC<Props> = ({ onTotalCountChange, externalSearchQuery, userRole }) => {
  const [allDestinations, setAllDestinations] = useState<Destination[]>([]);
  const [categoriesList, setCategoriesList] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Global metrics unaffected by filtering (R-17)
  const [globalStats, setGlobalStats] = useState<GlobalStats>({
    total: 0,
    active: 0,
    inactive: 0,
    averageRating: 4.5,
  });

  // Request sequencing guard against race conditions (R-26)
  const activeRequestId = useRef(0);

  // Row-level action pending state (R-27)
  const [actionPendingId, setActionPendingId] = useState<number | null>(null);

  // Filters & Search
  const [searchQuery, setSearchQuery] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [sortBy, setSortBy] = useState('DEFAULT');

  // Modals & Drawer State
  const [addModalOpen, setAddModalOpen] = useState(false);
  const [viewingDest, setViewingDest] = useState<Destination | null>(null);
  const [editingDest, setEditingDest] = useState<Destination | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Destination | null>(null);
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [toast, setToast] = useState<ToastState | null>(null);

  // Pagination
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  // Sync TopBar search query
  useEffect(() => {
    if (externalSearchQuery !== undefined) {
      setSearchQuery(externalSearchQuery);
      setCurrentPage(1);
    }
  }, [externalSearchQuery]);

  // Debounce search input
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchQuery);
      setCurrentPage(1);
    }, 250);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  const showToast = (message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3500);
  };

  // Load Categories for dynamic classification
  const loadCategories = useCallback(async () => {
    try {
      const cats = await fetchCategoriesApi();
      setCategoriesList(cats);
    } catch {
      // Fallback silently if categories table is being loaded
    }
  }, []);

  // Fetch true global metrics independent of active filters
  const refreshGlobalStats = useCallback(async () => {
    try {
      const all = await fetchDestinations({});
      const total = all.length;
      const active = all.filter((d) => d.status === 'ACTIVE').length;
      const inactive = all.filter((d) => d.status === 'INACTIVE').length;
      const avgRating = total > 0 ? all.reduce((sum, d) => sum + Number(d.rating || 4.5), 0) / total : 4.5;
      setGlobalStats({ total, active, inactive, averageRating: avgRating });
      onTotalCountChange?.(total);
    } catch {
      // Keep previous global stats if refresh fails
    }
  }, [onTotalCountChange]);

  // Load Destinations from backend API with request sequencing
  const loadDestinations = useCallback(async () => {
    const reqId = ++activeRequestId.current;
    setLoading(true);
    setError(null);
    try {
      const data = await fetchDestinations({
        category: categoryFilter !== 'ALL' ? categoryFilter : undefined,
        status: statusFilter,
        search: debouncedSearch,
      });
      if (reqId === activeRequestId.current) {
        setAllDestinations(data);
      }
    } catch (err: unknown) {
      if (reqId === activeRequestId.current) {
        setError(err instanceof Error ? err.message : 'Lỗi tải danh sách địa điểm');
      }
    } finally {
      if (reqId === activeRequestId.current) {
        setLoading(false);
      }
    }
  }, [categoryFilter, statusFilter, debouncedSearch]);

  useEffect(() => {
    loadCategories();
    refreshGlobalStats();
  }, [loadCategories, refreshGlobalStats]);

  useEffect(() => {
    loadDestinations();
  }, [loadDestinations]);

  // Sorting
  const sortedDestinations = useMemo(() => {
    const list = [...allDestinations];
    switch (sortBy) {
      case 'RATING_DESC':
        return list.sort((a, b) => Number(b.rating || 0) - Number(a.rating || 0));
      case 'REVIEWS_DESC':
        return list.sort((a, b) => (b.reviewCount || 0) - (a.reviewCount || 0));
      case 'NAME_ASC':
        return list.sort((a, b) => a.name.localeCompare(b.name, 'vi'));
      case 'PRICE_ASC':
        return list.sort((a, b) => Number(a.priceMinVnd || 0) - Number(b.priceMinVnd || 0));
      default:
        return list;
    }
  }, [allDestinations, sortBy]);

  // Paginated slice
  const paginatedDestinations = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    return sortedDestinations.slice(startIndex, startIndex + itemsPerPage);
  }, [sortedDestinations, currentPage]);

  const totalPages = Math.max(1, Math.ceil(sortedDestinations.length / itemsPerPage));
  const isFiltered = Boolean(debouncedSearch.trim() || categoryFilter !== 'ALL' || statusFilter !== 'ALL' || sortBy !== 'DEFAULT');

  const handleResetFilters = () => {
    setSearchQuery('');
    setDebouncedSearch('');
    setCategoryFilter('ALL');
    setStatusFilter('ALL');
    setSortBy('DEFAULT');
    setCurrentPage(1);
  };

  // Toggle active / hidden status with row-level actionPendingId
  const handleToggleStatus = async (dest: Destination) => {
    if (!dest.id || actionPendingId === dest.id) return;
    const newStatus = dest.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    setActionPendingId(dest.id);
    try {
      setAllDestinations((prev) =>
        prev.map((d) => (d.id === dest.id ? { ...d, status: newStatus } : d))
      );
      await updateDestination(dest.id, {
        name: dest.name,
        category: dest.category,
        categoryId: dest.categoryId,
        latitude: dest.latitude,
        longitude: dest.longitude,
        description: dest.description,
        address: dest.address,
        openingHours: dest.openingHours,
        phone: dest.phone,
        website: dest.website,
        priceMinVnd: dest.priceMinVnd,
        priceMaxVnd: dest.priceMaxVnd,
        rating: dest.rating,
        reviewCount: dest.reviewCount,
        osmId: dest.osmId,
        imageUrl: dest.imageUrl,
        subImages: dest.subImages,
        status: newStatus,
      });
      showToast(`Đã chuyển trạng thái "${dest.name}" sang ${newStatus === 'ACTIVE' ? 'Hoạt động' : 'Tạm ẩn'}`);
      refreshGlobalStats();
    } catch (err: unknown) {
      showToast(err instanceof Error ? err.message : 'Lỗi cập nhật trạng thái', 'error');
      loadDestinations();
    } finally {
      setActionPendingId(null);
    }
  };

  // Create Destination
  const handleCreateDestination = async (data: Omit<Destination, 'id'>) => {
    await createDestination(data);
    showToast(`Đã thêm địa điểm "${data.name}" thành công`);
    loadDestinations();
    refreshGlobalStats();
    loadCategories();
  };

  // Update Destination
  const handleUpdateDestination = async (data: Omit<Destination, 'id'>) => {
    if (!editingDest?.id) return;
    await updateDestination(editingDest.id, data);
    showToast(`Đã cập nhật thông tin "${data.name}" thành công`);
    setEditingDest(null);
    loadDestinations();
    refreshGlobalStats();
    loadCategories();
  };

  // Delete Destination
  const handleDeleteDestination = async () => {
    if (!deleteTarget?.id) return;
    try {
      setDeleteLoading(true);
      await deleteDestination(deleteTarget.id);
      showToast(`Đã xóa điểm đến "${deleteTarget.name}" khỏi hệ thống.`);
      setDeleteTarget(null);
      loadDestinations();
      refreshGlobalStats();
      loadCategories();
    } catch (err: unknown) {
      showToast(err instanceof Error ? err.message : 'Lỗi xóa địa điểm', 'error');
    } finally {
      setDeleteLoading(false);
    }
  };

  // Export CSV with UTF-8 BOM
  const handleExportCsv = () => {
    if (allDestinations.length === 0) return;
    const headers = ['ID,Tên địa điểm,Danh mục,Địa chỉ,Vĩ độ,Kinh độ,Giờ mở cửa,Số điện thoại,Website,Giá thấp nhất (VNĐ),Giá cao nhất (VNĐ),Đánh giá,Lượt đánh giá,Trạng thái'];
    const rows = allDestinations.map((d) =>
      `"${d.id || ''}","${d.name || ''}","${d.category || ''}","${d.address || ''}","${d.latitude || ''}","${d.longitude || ''}","${d.openingHours || ''}","${d.phone || ''}","${d.website || ''}","${d.priceMinVnd || 0}","${d.priceMaxVnd || 0}","${d.rating || 4.5}","${d.reviewCount || 0}","${d.status}"`
    );
    const csvContent = '\uFEFF' + headers.concat(rows).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `smarttravel_danang_destinations_${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
    showToast('Đã xuất file CSV địa điểm thành công!');
  };

  return (
    <div>
      {/* Toast Feedback */}
      {toast && (
        <div
          role="status"
          style={{
            position: 'fixed',
            bottom: '24px',
            right: '24px',
            zIndex: 1200,
            backgroundColor: toast.type === 'error' ? '#991b1b' : '#0f172a',
            color: '#ffffff',
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
            <AlertTriangleIcon size={16} color="#fca5a5" />
          ) : (
            <CheckCircleIcon size={16} color="#10b981" />
          )}
          <span>{toast.message}</span>
          <button
            type="button"
            onClick={() => setToast(null)}
            aria-label="Đóng thông báo"
            className="btn-action-touch"
            style={{
              background: 'none',
              border: 'none',
              color: '#94a3b8',
              cursor: 'pointer',
              marginLeft: '0.5rem',
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
              Quản lý Địa điểm Đà Nẵng
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
              {isFiltered ? `Hiển thị ${sortedDestinations.length}/${globalStats.total}` : `${globalStats.total}`} địa điểm
            </span>
          </div>
          <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: '#475569' }}>
            Kho dữ liệu điểm đến du lịch Đà Nẵng, tọa độ GPS, chi phí và thông tin liên hệ cho thuật toán SmartTravel
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <button
            type="button"
            onClick={() => { loadDestinations(); refreshGlobalStats(); }}
            disabled={loading}
            className="btn-action-touch"
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
            onClick={() => setAddModalOpen(true)}
            className="btn-action-touch"
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
            <span>Thêm địa điểm mới</span>
          </button>
        </div>
      </div>

      {/* Honest Metrics Bar */}
      <DestinationStats
        totalCount={globalStats.total}
        activeCount={globalStats.active}
        inactiveCount={globalStats.inactive}
        averageRating={globalStats.averageRating}
      />

      {/* Filters Bar */}
      <DestinationFilters
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
        categoryFilter={categoryFilter}
        onCategoryFilterChange={(c) => { setCategoryFilter(c); setCurrentPage(1); }}
        statusFilter={statusFilter}
        onStatusFilterChange={(s) => { setStatusFilter(s); setCurrentPage(1); }}
        sortBy={sortBy}
        onSortByChange={(b) => { setSortBy(b); setCurrentPage(1); }}
        categoriesList={categoriesList}
        isFiltered={isFiltered}
        onResetFilters={handleResetFilters}
        onExportCsv={handleExportCsv}
      />

      {/* Data Table with Mobile Reflow & Skeleton Loading */}
      <DestinationTable
        destinations={paginatedDestinations}
        categoriesList={categoriesList}
        loading={loading}
        error={error}
        currentPage={currentPage}
        totalPages={totalPages}
        itemsPerPage={itemsPerPage}
        totalFilteredCount={sortedDestinations.length}
        canDelete={canDeleteDestinations(userRole)}
        actionPendingId={actionPendingId}
        onPageChange={setCurrentPage}
        onToggleStatus={handleToggleStatus}
        onView={(dest) => setViewingDest(dest)}
        onEdit={(dest) => setEditingDest(dest)}
        onDelete={(dest) => setDeleteTarget(dest)}
        onRetry={loadDestinations}
      />

      {/* View Detail Modal */}
      <DestinationDetailModal
        isOpen={Boolean(viewingDest)}
        destination={viewingDest}
        categoriesList={categoriesList}
        onClose={() => setViewingDest(null)}
        onEdit={() => {
          const target = viewingDest;
          setViewingDest(null);
          setEditingDest(target);
        }}
      />

      {/* Add Modal */}
      <AddDestinationModal
        isOpen={addModalOpen}
        categoriesList={categoriesList}
        onClose={() => setAddModalOpen(false)}
        onSubmit={handleCreateDestination}
      />

      {/* Edit Drawer */}
      <EditDestinationDrawer
        isOpen={Boolean(editingDest)}
        destination={editingDest}
        categoriesList={categoriesList}
        onClose={() => setEditingDest(null)}
        onSubmit={handleUpdateDestination}
      />

      {/* Delete Confirmation Modal */}
      <DeleteConfirmModal
        isOpen={Boolean(deleteTarget)}
        destinationName={deleteTarget?.name || ''}
        loading={deleteLoading}
        onClose={() => setDeleteTarget(null)}
        onConfirm={handleDeleteDestination}
      />
    </div>
  );
};

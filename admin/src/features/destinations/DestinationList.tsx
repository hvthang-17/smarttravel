import React, { useEffect, useState, useCallback, useMemo } from 'react';
import { fetchDestinations, createDestination, updateDestination, deleteDestination } from '../../core/api';
import { Destination } from '../../types/destination';
import { RoleType, canDeleteDestinations } from '../../types/auth';
import { AddDestinationModal } from './AddDestinationModal';
import { EditDestinationDrawer } from './EditDestinationDrawer';
import { DeleteConfirmModal } from './DeleteConfirmModal';
import {
  SearchIcon,
  PlusIcon,
  DownloadIcon,
  XIcon,
  ClockIcon,
  MapIcon,
  PencilIcon,
  TrashIcon,
  LandmarkIcon,
  UtensilsIcon,
  PalmtreeIcon,
  CameraIcon,
  CoffeeIcon,
  AlertTriangleIcon,
  CheckCircleIcon,
} from '../../components/Icons';

interface Props {
  onTotalCountChange?: (count: number) => void;
  externalSearchQuery?: string;
  userRole?: RoleType;
}

const CATEGORY_OPTIONS = [
  'Tất cả',
  'Tham quan / Văn hóa',
  'Ẩm thực',
  'Biển / Tham quan',
  'Sống ảo',
  'Cafe',
  'Khách sạn & Lưu trú',
  'Culture',
  'Beach',
  'Food',
];

export const DestinationList: React.FC<Props> = ({ onTotalCountChange, externalSearchQuery, userRole }) => {
  const [destinations, setDestinations] = useState<Destination[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [searchKeyword, setSearchKeyword] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('Tất cả');
  const [statusFilter, setStatusFilter] = useState('Tất cả');

  // Synchronize global search from TopBar (R-26, C-2)
  useEffect(() => {
    if (externalSearchQuery !== undefined) {
      setSearchKeyword(externalSearchQuery);
      setCurrentPage(1);
    }
  }, [externalSearchQuery]);

  const [addModalOpen, setAddModalOpen] = useState(false);
  const [editingDest, setEditingDest] = useState<Destination | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Destination | null>(null);
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const loadData = useCallback(() => {
    setLoading(true);
    setError(null);
    fetchDestinations({
      category: categoryFilter !== 'Tất cả' ? categoryFilter : undefined,
      status: statusFilter === 'Active' ? 'ACTIVE' : statusFilter === 'Hidden' ? 'INACTIVE' : 'ALL',
      search: searchKeyword,
    })
      .then((data) => {
        setDestinations(data);
        onTotalCountChange?.(data.length);
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [categoryFilter, statusFilter, searchKeyword, onTotalCountChange]);

  useEffect(() => {
    const timer = setTimeout(() => {
      loadData();
    }, 200);
    return () => clearTimeout(timer);
  }, [loadData]);

  const handleToggleStatus = async (dest: Destination) => {
    if (!dest.id) return;
    const newStatus = dest.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    try {
      await updateDestination(dest.id, {
        name: dest.name,
        category: dest.category,
        latitude: dest.latitude,
        longitude: dest.longitude,
        description: dest.description,
        address: dest.address,
        openingHours: dest.openingHours,
        priceMinVnd: dest.priceMinVnd,
        priceMaxVnd: dest.priceMaxVnd,
        imageUrl: dest.imageUrl,
        status: newStatus,
      });
      showToast(`Đã chuyển trạng thái sang ${newStatus === 'ACTIVE' ? 'Hoạt động' : 'Ẩn'}`);
      loadData();
    } catch (err: unknown) {
      showToast(err instanceof Error ? err.message : 'Lỗi khi cập nhật trạng thái');
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget?.id) return;
    try {
      setDeleteLoading(true);
      await deleteDestination(deleteTarget.id);
      showToast(`Đã xóa điểm đến "${deleteTarget.name}" thành công.`);
      setDeleteTarget(null);
      loadData();
    } catch (err: unknown) {
      showToast(err instanceof Error ? err.message : 'Lỗi khi xóa địa điểm');
    } finally {
      setDeleteLoading(false);
    }
  };

  const handleExportCsv = () => {
    if (destinations.length === 0) return;
    const headers = ['ID,Tên,Danh mục,Địa chỉ,Giờ mở cửa,Giá min (VNĐ),Giá max (VNĐ),Trạng thái'];
    const rows = destinations.map((d) =>
      `"${d.id || ''}","${d.name || ''}","${d.category || ''}","${d.address || ''}","${d.openingHours || ''}","${d.priceMinVnd || 0}","${d.priceMaxVnd || 0}","${d.status}"`
    );
    const blob = new Blob([headers.concat(rows).join('\n')], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `smarttravel_destinations_${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
    showToast('Đã xuất file CSV thành công!');
  };

  const paginatedDestinations = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    return destinations.slice(startIndex, startIndex + itemsPerPage);
  }, [destinations, currentPage]);

  const totalPages = Math.max(1, Math.ceil(destinations.length / itemsPerPage));

  const getCategoryMeta = (cat: string) => {
    const lower = cat.toLowerCase();
    if (lower.includes('ẩm thực') || lower.includes('food')) {
      return { Icon: UtensilsIcon, label: 'Ẩm thực', bg: '#fff7ed', color: '#c2410c' };
    }
    if (lower.includes('biển') || lower.includes('beach')) {
      return { Icon: PalmtreeIcon, label: 'Biển / Tham quan', bg: '#f0fdf4', color: '#15803d' };
    }
    if (lower.includes('sống ảo') || lower.includes('check-in')) {
      return { Icon: CameraIcon, label: 'Sống ảo', bg: '#faf5ff', color: '#7e22ce' };
    }
    if (lower.includes('cafe')) {
      return { Icon: CoffeeIcon, label: 'Quán Cafe', bg: '#fefce8', color: '#a16207' };
    }
    return { Icon: LandmarkIcon, label: 'Tham quan', bg: '#f0f9ff', color: '#0369a1' };
  };

  return (
    <div>
      {/* Toast Feedback Banner (R-26: Replaces alert() popup) */}
      {toastMessage && (
        <div
          className="animate-fade-in"
          style={{
            position: 'fixed',
            bottom: '24px',
            right: '24px',
            backgroundColor: '#0f172a',
            color: '#ffffff',
            padding: '12px 18px',
            borderRadius: '8px',
            boxShadow: '0 10px 15px -3px rgba(0,0,0,0.2)',
            zIndex: 1000,
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            fontSize: '13px',
            fontWeight: 500,
          }}
        >
          <CheckCircleIcon size={16} color="#10b981" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Page Title & Add Button */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
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
              {destinations.length} địa điểm
            </span>
          </div>
          <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: '#475569' }}>
            Duy trì danh mục địa điểm tham quan, ẩm thực và lưu trú cho ứng dụng SmartTravel
          </p>
        </div>

        <button
          type="button"
          onClick={() => setAddModalOpen(true)}
          className="btn-action-touch"
          style={{
            backgroundColor: '#ea580c',
            color: '#ffffff',
            border: 'none',
            padding: '10px 18px',
            borderRadius: '8px',
            fontSize: '13.5px',
            fontWeight: 600,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            boxShadow: '0 2px 4px rgba(234, 88, 12, 0.25)',
          }}
        >
          <PlusIcon size={15} color="#ffffff" strokeWidth={2.5} />
          <span>Thêm địa điểm mới</span>
        </button>
      </div>

      {/* Filter Bar */}
      <div
        style={{
          backgroundColor: '#ffffff',
          borderRadius: '12px',
          border: '1px solid #e2e8f0',
          padding: '12px 16px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '12px',
          marginBottom: '16px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
          <div style={{ position: 'relative', width: '240px', display: 'flex', alignItems: 'center' }}>
            <span style={{ position: 'absolute', left: '10px', pointerEvents: 'none' }}>
              <SearchIcon size={14} color="#64748b" />
            </span>
            <input
              type="text"
              placeholder="Tìm tên địa điểm, địa chỉ..."
              aria-label="Tìm kiếm địa điểm"
              value={searchKeyword}
              onChange={(e) => { setSearchKeyword(e.target.value); setCurrentPage(1); }}
              style={{
                width: '100%',
                padding: '7px 12px 7px 32px',
                borderRadius: '8px',
                border: '1px solid #cbd5e1',
                fontSize: '13px',
                color: '#0f172a',
                outline: 'none',
              }}
            />
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Danh mục:</label>
            <select
              value={categoryFilter}
              onChange={(e) => { setCategoryFilter(e.target.value); setCurrentPage(1); }}
              aria-label="Lọc theo danh mục"
              style={{ padding: '7px 10px', borderRadius: '8px', border: '1px solid #cbd5e1', fontSize: '13px', backgroundColor: '#ffffff', color: '#0f172a' }}
            >
              {CATEGORY_OPTIONS.map((c) => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Trạng thái:</label>
            <select
              value={statusFilter}
              onChange={(e) => { setStatusFilter(e.target.value); setCurrentPage(1); }}
              aria-label="Lọc theo trạng thái"
              style={{ padding: '7px 10px', borderRadius: '8px', border: '1px solid #cbd5e1', fontSize: '13px', backgroundColor: '#ffffff', color: '#0f172a' }}
            >
              <option value="Tất cả">Tất cả</option>
              <option value="Active">Active</option>
              <option value="Hidden">Hidden</option>
            </select>
          </div>

          {(searchKeyword || categoryFilter !== 'Tất cả' || statusFilter !== 'Tất cả') && (
            <button
              type="button"
              onClick={() => { setSearchKeyword(''); setCategoryFilter('Tất cả'); setStatusFilter('Tất cả'); setCurrentPage(1); }}
              style={{ border: 'none', background: 'none', color: '#475569', fontSize: '13px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
            >
              <XIcon size={12} color="#475569" />
              <span>Xóa bộ lọc</span>
            </button>
          )}
        </div>

        <button
          type="button"
          onClick={handleExportCsv}
          className="btn-action-touch"
          style={{
            padding: '7px 14px',
            borderRadius: '8px',
            border: '1px solid #cbd5e1',
            backgroundColor: '#ffffff',
            color: '#334155',
            fontSize: '13px',
            fontWeight: 500,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
          }}
        >
          <DownloadIcon size={14} color="#475569" />
          <span>Xuất CSV</span>
        </button>
      </div>

      {/* Table Container */}
      <div
        style={{
          backgroundColor: '#ffffff',
          borderRadius: '12px',
          border: '1px solid #e2e8f0',
          boxShadow: '0 1px 3px rgba(0, 0, 0, 0.05)',
          overflow: 'hidden',
        }}
      >
        {loading && <div style={{ padding: '36px', textAlign: 'center', color: '#475569' }}>Đang tải danh sách địa điểm...</div>}
        {error && <div style={{ padding: '16px', color: '#991b1b', backgroundColor: '#fee2e2' }}>Lỗi: {error}</div>}

        {!loading && !error && destinations.length === 0 && (
          <div style={{ padding: '48px', textAlign: 'center', color: '#475569' }}>
            Không tìm thấy địa điểm nào phù hợp với bộ lọc hiện tại.
          </div>
        )}

        {!loading && !error && destinations.length > 0 && (
          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid #e2e8f0', backgroundColor: '#f8fafc', color: '#475569', fontSize: '11.5px', textTransform: 'uppercase', letterSpacing: '0.4px' }}>
                  <th style={{ padding: '12px 16px', fontWeight: 600 }}>Địa điểm & Địa chỉ</th>
                  <th style={{ padding: '12px 16px', fontWeight: 600 }}>Danh mục</th>
                  <th style={{ padding: '12px 16px', fontWeight: 600 }}>Chi phí ước tính</th>
                  <th style={{ padding: '12px 16px', fontWeight: 600 }}>Giờ mở cửa</th>
                  <th style={{ padding: '12px 16px', fontWeight: 600 }}>Trạng thái</th>
                  <th style={{ padding: '12px 16px', fontWeight: 600, textAlign: 'center' }}>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {paginatedDestinations.map((d, index) => {
                  const meta = getCategoryMeta(d.category);
                  const CategoryIcon = meta.Icon;
                  const destCode = `#DEST-${String(d.id || index + 1).padStart(3, '0')}`;
                  const isActive = d.status === 'ACTIVE';

                  return (
                    <tr key={d.id} style={{ borderBottom: '1px solid #f1f5f9', fontSize: '13.5px' }}>
                      {/* Name & Address */}
                      <td style={{ padding: '12px 16px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                          <div
                            style={{
                              width: '42px',
                              height: '42px',
                              borderRadius: '8px',
                              backgroundColor: meta.bg,
                              color: meta.color,
                              overflow: 'hidden',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              flexShrink: 0,
                            }}
                          >
                            {d.imageUrl ? (
                              <img src={d.imageUrl} alt={d.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} onError={(e) => { (e.target as HTMLElement).style.display = 'none'; }} />
                            ) : (
                              <CategoryIcon size={18} color={meta.color} />
                            )}
                          </div>
                          <div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                              <span style={{ fontWeight: 600, color: '#0f172a' }}>{d.name}</span>
                              <span style={{ fontSize: '11px', color: '#475569', backgroundColor: '#f1f5f9', padding: '1px 5px', borderRadius: '4px' }}>
                                {destCode}
                              </span>
                            </div>
                            <div style={{ fontSize: '12px', color: '#475569', marginTop: '2px', maxWidth: '300px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                              {d.address || 'Đà Nẵng'}
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* Category */}
                      <td style={{ padding: '12px 16px' }}>
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '5px',
                            backgroundColor: meta.bg,
                            color: meta.color,
                            padding: '3px 8px',
                            borderRadius: '6px',
                            fontSize: '12px',
                            fontWeight: 600,
                          }}
                        >
                          <CategoryIcon size={13} color={meta.color} />
                          <span>{meta.label}</span>
                        </span>
                      </td>

                      {/* Cost */}
                      <td style={{ padding: '12px 16px' }}>
                        <div style={{ fontWeight: 600, color: '#0f172a' }}>
                          {d.priceMinVnd && d.priceMinVnd > 0 ? `${d.priceMinVnd.toLocaleString('vi-VN')} VNĐ` : 'Miễn phí'}
                        </div>
                        <div style={{ fontSize: '11px', color: '#475569' }}>
                          {d.priceMaxVnd && d.priceMaxVnd > d.priceMinVnd! ? `Khoảng giá: ${(d.priceMinVnd!/1000).toFixed(0)}k - ${(d.priceMaxVnd/1000).toFixed(0)}k` : 'Vé tham quan'}
                        </div>
                      </td>

                      {/* Hours */}
                      <td style={{ padding: '12px 16px' }}>
                        {d.openingHours ? (
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: '#334155' }}>
                            <ClockIcon size={13} color="#475569" />
                            <span>{d.openingHours}</span>
                          </div>
                        ) : (
                          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', fontSize: '11.5px', color: '#92400e', backgroundColor: '#fef3c7', padding: '2px 8px', borderRadius: '6px' }}>
                            <AlertTriangleIcon size={11} color="#92400e" />
                            <span>Chưa cập nhật</span>
                          </span>
                        )}
                      </td>

                      {/* Status Toggle Switch */}
                      <td style={{ padding: '12px 16px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <label className="toggle-switch">
                            <input
                              type="checkbox"
                              checked={isActive}
                              onChange={() => handleToggleStatus(d)}
                              aria-label={`Bật tắt trạng thái cho ${d.name}`}
                            />
                            <span className="toggle-slider" />
                          </label>
                          <span style={{ fontSize: '12.5px', fontWeight: 600, color: isActive ? '#059669' : '#64748b' }}>
                            {isActive ? 'Active' : 'Hidden'}
                          </span>
                        </div>
                      </td>

                      {/* Actions with accessible tap targets (R-03 & R-32) */}
                      <td style={{ padding: '12px 16px', textAlign: 'center' }}>
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
                          <a
                            href={`https://www.google.com/maps/search/?api=1&query=${d.latitude},${d.longitude}`}
                            target="_blank"
                            rel="noreferrer"
                            className="btn-action-touch"
                            style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', fontSize: '12.5px', color: '#0077b6', textDecoration: 'none', fontWeight: 600, padding: '4px 8px', borderRadius: '6px' }}
                            title="Xem trên bản đồ"
                          >
                            <MapIcon size={14} color="#0077b6" />
                            <span>Bản đồ</span>
                          </a>

                          <button
                            type="button"
                            onClick={() => setEditingDest(d)}
                            className="btn-action-touch"
                            style={{ border: '1px solid #e2e8f0', background: '#ffffff', borderRadius: '6px', cursor: 'pointer', padding: '6px 8px', color: '#334155' }}
                            title="Chỉnh sửa"
                            aria-label={`Chỉnh sửa ${d.name}`}
                          >
                            <PencilIcon size={14} color="#334155" />
                          </button>

                          {canDeleteDestinations(userRole) ? (
                            <button
                              type="button"
                              onClick={() => setDeleteTarget(d)}
                              className="btn-action-touch"
                              style={{ border: '1px solid #fee2e2', background: '#fff5f5', borderRadius: '6px', cursor: 'pointer', padding: '6px 8px', color: '#dc2626' }}
                              title="Xóa địa điểm (Yêu cầu quyền ROLE_ADMIN)"
                              aria-label={`Xóa ${d.name}`}
                            >
                              <TrashIcon size={14} color="#dc2626" />
                            </button>
                          ) : (
                            <button
                              type="button"
                              disabled
                              className="btn-action-touch"
                              style={{ border: '1px solid #e2e8f0', background: '#f8fafc', borderRadius: '6px', cursor: 'not-allowed', padding: '6px 8px', color: '#94a3b8', opacity: 0.6 }}
                              title="Chỉ Quản trị viên (ROLE_ADMIN) mới có quyền xóa địa điểm"
                              aria-label={`Xóa ${d.name} bị khóa`}
                            >
                              <TrashIcon size={14} color="#94a3b8" />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination Bar (R-02: hyphen "-" replaces em dash "—") */}
        {!loading && destinations.length > 0 && (
          <div
            style={{
              padding: '14px 20px',
              borderTop: '1px solid #e2e8f0',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              backgroundColor: '#ffffff',
              flexWrap: 'wrap',
              gap: '12px',
            }}
          >
            <div style={{ fontSize: '13px', color: '#475569' }}>
              Hiển thị <strong>{Math.min((currentPage - 1) * itemsPerPage + 1, destinations.length)} - {Math.min(currentPage * itemsPerPage, destinations.length)}</strong> trong tổng số <strong>{destinations.length}</strong> địa điểm
            </div>

            <div style={{ display: 'flex', gap: '6px' }}>
              <button
                type="button"
                disabled={currentPage <= 1}
                onClick={() => setCurrentPage((p) => p - 1)}
                className="btn-action-touch"
                style={{
                  padding: '5px 12px',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  background: '#ffffff',
                  color: currentPage <= 1 ? '#94a3b8' : '#334155',
                  cursor: currentPage <= 1 ? 'not-allowed' : 'pointer',
                  fontSize: '13px',
                }}
              >
                Trước
              </button>

              {Array.from({ length: totalPages }).map((_, i) => {
                const pageNum = i + 1;
                const isCurrent = pageNum === currentPage;
                return (
                  <button
                    key={pageNum}
                    type="button"
                    onClick={() => setCurrentPage(pageNum)}
                    className="btn-action-touch"
                    style={{
                      padding: '5px 11px',
                      borderRadius: '6px',
                      border: isCurrent ? '1px solid #0077b6' : '1px solid #cbd5e1',
                      backgroundColor: isCurrent ? '#0077b6' : '#ffffff',
                      color: isCurrent ? '#ffffff' : '#334155',
                      fontWeight: isCurrent ? 700 : 500,
                      cursor: 'pointer',
                      fontSize: '13px',
                    }}
                  >
                    {pageNum}
                  </button>
                );
              })}

              <button
                type="button"
                disabled={currentPage >= totalPages}
                onClick={() => setCurrentPage((p) => p + 1)}
                className="btn-action-touch"
                style={{
                  padding: '5px 12px',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  background: '#ffffff',
                  color: currentPage >= totalPages ? '#94a3b8' : '#334155',
                  cursor: currentPage >= totalPages ? 'not-allowed' : 'pointer',
                  fontSize: '13px',
                }}
              >
                Sau
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Modals & Drawers */}
      <AddDestinationModal
        isOpen={addModalOpen}
        onClose={() => setAddModalOpen(false)}
        onSubmit={async (data) => {
          await createDestination(data);
          showToast(`Đã tạo mới địa điểm "${data.name}" thành công!`);
          loadData();
        }}
      />

      <EditDestinationDrawer
        isOpen={Boolean(editingDest)}
        destination={editingDest}
        onClose={() => setEditingDest(null)}
        onSubmit={async (data) => {
          if (!editingDest?.id) return;
          await updateDestination(editingDest.id, data);
          showToast(`Đã cập nhật thông tin "${data.name}" thành công!`);
          loadData();
        }}
      />

      <DeleteConfirmModal
        isOpen={Boolean(deleteTarget)}
        destinationName={deleteTarget?.name || ''}
        destinationId={deleteTarget?.id}
        loading={deleteLoading}
        onClose={() => setDeleteTarget(null)}
        onConfirm={handleDelete}
      />
    </div>
  );
};

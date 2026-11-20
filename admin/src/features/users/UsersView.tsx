import { t } from '../../core/language';
import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  CheckCircleIcon,
  AlertTriangleIcon,
  RefreshCwIcon,
  PlusIcon,
} from '../../components/Icons';
import {
  ManagedUser,
  createUserApi,
  updateUserApi,
  toggleUserLockApi,
  deleteUserApi,
  CreateUserData,
  UpdateUserData,
} from '../../core/userApi';
import { adminUsers, dashboard } from '../../core/operationsApi';
import { UserStatsCards, UserStats } from './UserStatsCards';
import { UserFilterBar } from './UserFilterBar';
import { UserTable } from './UserTable';
import { UserFormModal } from './UserFormModal';
import { UserDetailModal } from './UserDetailModal';
import { DeleteUserModal } from './DeleteUserModal';

interface ToastState {
  message: string;
  type: 'success' | 'error';
}

interface UsersViewProps {
  currentUser?: {
    id?: number;
    email?: string;
    fullName?: string;
    role?: string;
  };
}

export const UsersView: React.FC<UsersViewProps> = ({ currentUser: propCurrentUser }) => {
  // Data & loading state
  const [users, setUsers] = useState<ManagedUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [globalStats, setGlobalStats] = useState<UserStats | null>(null);
  const [globalError, setGlobalError] = useState(false);
  const [page, setPage] = useState(0);
  const [hasNext, setHasNext] = useState(false);

  // Filter criteria
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');

  // Action status
  const [actionPendingId, setActionPendingId] = useState<number | null>(null);
  const [toast, setToast] = useState<ToastState | null>(null);

  // Modals state
  const [modalMode, setModalMode] = useState<'create' | 'edit' | null>(null);
  const [selectedUser, setSelectedUser] = useState<ManagedUser | null>(null);
  const [isDetailOpen, setIsDetailOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [modalLoading, setModalLoading] = useState(false);

  // Request sequencing ref to prevent race conditions
  const activeRequestId = useRef(0);

  // Current logged in admin
  const currentUser = propCurrentUser || (() => {
    try {
      const saved = localStorage.getItem('smarttravel_admin_user');
      return saved ? JSON.parse(saved) : null;
    } catch {
      return null;
    }
  })();
  const currentUserEmail = currentUser?.email || '';

  const showToast = useCallback((message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => {
      setToast((prev) => (prev?.message === message ? null : prev));
    }, 3500);
  }, []);

  // Fetch true global metrics without filter bias (R-17)
  const refreshGlobalStats = useCallback(async () => {
    try {
      const metrics = await dashboard();
      setGlobalStats({
        total: metrics.totalUsers,
        active: metrics.activeUsers,
        locked: metrics.lockedUsers,
        admin: metrics.administrators,
      });
      setGlobalError(false);
    } catch {
      setGlobalError(true);
    }
  }, []);

  // Fetch filtered users for the table with request cancellation guard (R-26)
  const loadUsers = useCallback(async () => {
    const requestId = ++activeRequestId.current;
    setLoading(true);

    try {
      const data = await adminUsers(search, roleFilter, statusFilter, page);

      // Discard response if a newer query has fired
      if (requestId === activeRequestId.current) {
        setUsers(data.items);
        setHasNext(data.hasNext);
      }
    } catch (err: any) {
      if (requestId === activeRequestId.current) {
        setUsers([]);
        setHasNext(false);
        showToast(err.message || t('Lỗi truy vấn cơ sở dữ liệu người dùng'), 'error');
      }
    } finally {
      if (requestId === activeRequestId.current) {
        setLoading(false);
      }
    }
  }, [search, roleFilter, statusFilter, page, showToast]);

  // Initial load
  useEffect(() => {
    refreshGlobalStats();
  }, [refreshGlobalStats]);

  useEffect(() => {
    loadUsers();
  }, [loadUsers]);

  // Handlers
  const handleClearFilters = () => {
    setPage(0);
    setSearch('');
    setRoleFilter('ALL');
    setStatusFilter('ALL');
  };

  const handleToggleLock = async (targetUser: ManagedUser) => {
    if (actionPendingId !== null) return;
    setActionPendingId(targetUser.id);

    try {
      const updated = await toggleUserLockApi(targetUser.id, targetUser.status);
      await loadUsers();
      refreshGlobalStats();
      showToast(
        updated.status === 'LOCKED'
          ? `Đã tạm khóa tài khoản ${updated.fullName}`
          : `Đã mở khóa tài khoản ${updated.fullName}`,
        'success'
      );
    } catch (err: any) {
      showToast(err.message || t('Không thể cập nhật trạng thái người dùng'), 'error');
    } finally {
      setActionPendingId(null);
    }
  };

  const handleCreateSubmit = async (data: CreateUserData) => {
    setModalLoading(true);
    try {
      const created = await createUserApi(data);
      if (page === 0) await loadUsers(); else setPage(0);
      refreshGlobalStats();
      setModalMode(null);
      showToast(`Tạo thành công tài khoản ${created.fullName}`, 'success');
    } catch (err: any) {
      showToast(err.message || t('Không thể tạo tài khoản người dùng'), 'error');
    } finally {
      setModalLoading(false);
    }
  };

  const handleEditSubmit = async (id: number, data: UpdateUserData) => {
    setModalLoading(true);
    try {
      const updated = await updateUserApi(id, data);
      await loadUsers();
      refreshGlobalStats();
      setModalMode(null);
      setSelectedUser(null);
      showToast(`Cập nhật thông tin ${updated.fullName} thành công`, 'success');
    } catch (err: any) {
      showToast(err.message || t('Không thể cập nhật người dùng'), 'error');
    } finally {
      setModalLoading(false);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!selectedUser) return;
    setModalLoading(true);

    try {
      await deleteUserApi(selectedUser.id);
      if (users.length === 1 && page > 0) setPage(page - 1); else await loadUsers();
      refreshGlobalStats();
      setIsDeleteOpen(false);
      showToast(`${t('Đã xóa tài khoản')}: ${selectedUser.fullName}`, 'success');
      setSelectedUser(null);
    } catch (err: any) {
      showToast(err.message || t('Không thể xóa tài khoản người dùng'), 'error');
    } finally {
      setModalLoading(false);
    }
  };

  return (
    <div className="user-page-container admin-page admin-page-users">
      {/* Header section */}
      <div className="user-header-section admin-page-heading">
        <div className="user-title-group">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            <h1>{t("Quản lý Tài khoản Người dùng")}</h1>
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
              {globalStats ? `${globalStats.total} tài khoản` : t('Tài khoản')}
            </span>
          </div>
          <p>{t("Phân quyền tài khoản quản trị, giám sát trạng thái du khách và kiểm soát vi phạm hệ thống")}</p>
        </div>

        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <button
            type="button"
            onClick={() => {
              loadUsers();
              refreshGlobalStats();
            }}
            disabled={loading}
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
            <RefreshCwIcon size={15} color="#475569" className={loading ? 'animate-spin' : ''} />
            <span>{t("Làm mới")}</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSelectedUser(null);
              setModalMode('create');
            }}
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
            <span>{t("Thêm người dùng mới")}</span>
          </button>
        </div>
      </div>

      {/* Global Overview KPI Cards (R-17) */}
      {globalStats && <UserStatsCards stats={globalStats} loading={false} />}
      {globalError && <p role="alert">{t("Không tải được số liệu tài khoản.")}</p>}

      {/* Search & Filter Toolbar with 300ms Debounce (R-26) */}
      <UserFilterBar
        search={search}
        onSearchChange={value => { setPage(0); setSearch(value); }}
        roleFilter={roleFilter}
        onRoleFilterChange={value => { setPage(0); setRoleFilter(value); }}
        statusFilter={statusFilter}
        onStatusFilterChange={value => { setPage(0); setStatusFilter(value); }}

        onRefresh={() => {
          loadUsers();
          refreshGlobalStats();
        }}
        loading={loading}
      />

      {/* User Table with Mobile Card Fallback & Skeleton Loading (R-03, C-2) */}
      <UserTable
        users={users}
        loading={loading}
        currentUserEmail={currentUserEmail}
        actionPendingId={actionPendingId}
        onViewDetail={(u) => {
          setSelectedUser(u);
          setIsDetailOpen(true);
        }}
        onEdit={(u) => {
          setSelectedUser(u);
          setModalMode('edit');
        }}
        onToggleLock={handleToggleLock}
        onDelete={(u) => {
          setSelectedUser(u);
          setIsDeleteOpen(true);
        }}
        onClearFilters={handleClearFilters}
      />
      <nav aria-label={t("Phân trang tài khoản")} className="operations-filters">
        <button type="button" disabled={loading || page === 0} onClick={() => setPage(page - 1)}>{t("Trang trước")}</button>
        <span>Trang {page + 1}</span>
        <button type="button" disabled={loading || !hasNext} onClick={() => setPage(page + 1)}>Trang sau</button>
      </nav>

      {/* Unified User Form Modal (Create / Edit) */}
      <UserFormModal
        isOpen={modalMode !== null}
        mode={modalMode || 'create'}
        user={selectedUser}
        loading={modalLoading}
        onClose={() => {
          setModalMode(null);
          setSelectedUser(null);
        }}
        onSubmitCreate={handleCreateSubmit}
        onSubmitEdit={handleEditSubmit}
      />

      {/* User Detail Profile Modal */}
      <UserDetailModal
        isOpen={isDetailOpen}
        user={selectedUser}
        isSelf={Boolean(
          selectedUser &&
          currentUserEmail &&
          selectedUser.email.toLowerCase() === currentUserEmail.toLowerCase()
        )}
        onClose={() => {
          setIsDetailOpen(false);
          setSelectedUser(null);
        }}
        onEdit={() => {
          setIsDetailOpen(false);
          setModalMode('edit');
        }}
      />

      {/* Delete User Confirmation Modal */}
      <DeleteUserModal
        isOpen={isDeleteOpen}
        user={selectedUser}
        loading={modalLoading}
        onClose={() => {
          setIsDeleteOpen(false);
          setSelectedUser(null);
        }}
        onConfirm={handleDeleteConfirm}
      />

      {/* Truthful Toast Feedback (R-26) */}
      {toast && (
        <div className="user-toast-container">
          <div
            className={`user-toast ${
              toast.type === 'success' ? 'user-toast-success' : 'user-toast-error'
            }`}
            role="status"
            aria-live="polite"
          >
            {toast.type === 'success' ? (
              <CheckCircleIcon size={18} color="#059669" />
            ) : (
              <AlertTriangleIcon size={18} color="#dc2626" />
            )}
            <span>{toast.message}</span>
          </div>
        </div>
      )}
    </div>
  );
};

import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  CheckCircleIcon,
  AlertTriangleIcon,
  RefreshCwIcon,
  PlusIcon,
} from '../../components/Icons';
import {
  ManagedUser,
  fetchUsersApi,
  createUserApi,
  updateUserApi,
  toggleUserLockApi,
  deleteUserApi,
  CreateUserData,
  UpdateUserData,
} from '../../core/userApi';
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
  const [globalStats, setGlobalStats] = useState<UserStats>({
    total: 0,
    active: 0,
    locked: 0,
    admin: 0,
  });

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
      const allUsers = await fetchUsersApi({});
      setGlobalStats({
        total: allUsers.length,
        active: allUsers.filter((u) => u.status === 'ACTIVE').length,
        locked: allUsers.filter((u) => u.status === 'LOCKED').length,
        admin: allUsers.filter((u) => u.role === 'ROLE_ADMIN').length,
      });
    } catch {
      // Ignore background stats fetch errors
    }
  }, []);

  // Fetch filtered users for the table with request cancellation guard (R-26)
  const loadUsers = useCallback(async () => {
    const requestId = ++activeRequestId.current;
    setLoading(true);

    try {
      const data = await fetchUsersApi({
        search,
        role: roleFilter,
        status: statusFilter,
      });

      // Discard response if a newer query has fired
      if (requestId === activeRequestId.current) {
        setUsers(data);
      }
    } catch (err: any) {
      if (requestId === activeRequestId.current) {
        showToast(err.message || 'Lỗi truy vấn cơ sở dữ liệu người dùng', 'error');
      }
    } finally {
      if (requestId === activeRequestId.current) {
        setLoading(false);
      }
    }
  }, [search, roleFilter, statusFilter, showToast]);

  // Initial load
  useEffect(() => {
    refreshGlobalStats();
  }, [refreshGlobalStats]);

  useEffect(() => {
    loadUsers();
  }, [loadUsers]);

  // Handlers
  const handleClearFilters = () => {
    setSearch('');
    setRoleFilter('ALL');
    setStatusFilter('ALL');
  };

  const handleToggleLock = async (targetUser: ManagedUser) => {
    if (actionPendingId !== null) return;
    setActionPendingId(targetUser.id);

    try {
      const updated = await toggleUserLockApi(targetUser.id, targetUser.status);
      setUsers((prev) => prev.map((u) => (u.id === updated.id ? updated : u)));
      refreshGlobalStats();
      showToast(
        updated.status === 'LOCKED'
          ? `Đã tạm khóa tài khoản ${updated.fullName}`
          : `Đã mở khóa tài khoản ${updated.fullName}`,
        'success'
      );
    } catch (err: any) {
      showToast(err.message || 'Không thể cập nhật trạng thái người dùng', 'error');
    } finally {
      setActionPendingId(null);
    }
  };

  const handleCreateSubmit = async (data: CreateUserData) => {
    setModalLoading(true);
    try {
      const created = await createUserApi(data);
      setUsers((prev) => [created, ...prev]);
      refreshGlobalStats();
      setModalMode(null);
      showToast(`Tạo thành công tài khoản ${created.fullName}`, 'success');
    } catch (err: any) {
      showToast(err.message || 'Không thể tạo tài khoản người dùng', 'error');
    } finally {
      setModalLoading(false);
    }
  };

  const handleEditSubmit = async (id: number, data: UpdateUserData) => {
    setModalLoading(true);
    try {
      const updated = await updateUserApi(id, data);
      setUsers((prev) => prev.map((u) => (u.id === updated.id ? updated : u)));
      refreshGlobalStats();
      setModalMode(null);
      setSelectedUser(null);
      showToast(`Cập nhật thông tin ${updated.fullName} thành công`, 'success');
    } catch (err: any) {
      showToast(err.message || 'Không thể cập nhật người dùng', 'error');
    } finally {
      setModalLoading(false);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!selectedUser) return;
    setModalLoading(true);

    try {
      await deleteUserApi(selectedUser.id);
      setUsers((prev) => prev.filter((u) => u.id !== selectedUser.id));
      refreshGlobalStats();
      setIsDeleteOpen(false);
      showToast(`Đã xóa vĩnh viễn tài khoản ${selectedUser.fullName}`, 'success');
      setSelectedUser(null);
    } catch (err: any) {
      showToast(err.message || 'Không thể xóa tài khoản người dùng', 'error');
    } finally {
      setModalLoading(false);
    }
  };

  return (
    <div className="user-page-container">
      {/* Header section */}
      <div className="user-header-section">
        <div className="user-title-group">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            <h1>Quản lý Tài khoản Người dùng</h1>
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
              {globalStats.total} tài khoản
            </span>
          </div>
          <p>Phân quyền tài khoản quản trị, giám sát trạng thái du khách và kiểm soát vi phạm hệ thống</p>
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
            <span>Làm mới</span>
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
            <span>Thêm người dùng mới</span>
          </button>
        </div>
      </div>

      {/* Global Overview KPI Cards (R-17) */}
      <UserStatsCards stats={globalStats} loading={loading && users.length === 0} />

      {/* Search & Filter Toolbar with 300ms Debounce (R-26) */}
      <UserFilterBar
        search={search}
        onSearchChange={setSearch}
        roleFilter={roleFilter}
        onRoleFilterChange={setRoleFilter}
        statusFilter={statusFilter}
        onStatusFilterChange={setStatusFilter}
        onAddClick={() => {
          setSelectedUser(null);
          setModalMode('create');
        }}
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

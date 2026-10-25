import { RoleType } from '../types/auth';

const API_BASE_URL = 'http://localhost:8080/api/v1';

export interface ManagedUser {
  id: number;
  email: string;
  fullName: string;
  role: RoleType;
  status: 'ACTIVE' | 'LOCKED' | 'INACTIVE';
  createdAt: string;
  updatedAt?: string;
  tripsCount: number;
}

export interface UserFilterOptions {
  search?: string;
  role?: string;
  status?: string;
}

/**
 * Lấy danh sách tài khoản người dùng trực tiếp từ Database thông qua Backend REST API
 */
export async function fetchUsersApi(options?: UserFilterOptions): Promise<ManagedUser[]> {
  const params = new URLSearchParams();
  if (options?.search?.trim()) {
    params.append('search', options.search.trim());
  }
  if (options?.role && options.role !== 'Tất cả' && options.role !== 'ALL') {
    params.append('role', options.role);
  }
  if (options?.status && options.status !== 'Tất cả' && options.status !== 'ALL') {
    params.append('status', options.status);
  }

  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/admin/users?${params.toString()}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi truy vấn cơ sở dữ liệu người dùng (Mã: ${response.status})`);
  }

  const json = await response.json();
  const list = json.data || [];

  return list.map((u: any) => ({
    id: u.id,
    email: u.email,
    fullName: u.fullName,
    role: (u.role as RoleType) || 'ROLE_USER',
    status: (u.status as 'ACTIVE' | 'LOCKED' | 'INACTIVE') || 'ACTIVE',
    createdAt: u.createdAt || new Date().toISOString(),
    updatedAt: u.updatedAt,
    tripsCount: u.tripsCount !== undefined ? u.tripsCount : 0,
  }));
}

export interface CreateUserData {
  fullName: string;
  email: string;
  password: string;
  role: RoleType;
  status: 'ACTIVE' | 'LOCKED';
}

/**
 * Tạo người dùng mới và lưu trực tiếp vào cơ sở dữ liệu
 */
export async function createUserApi(data: CreateUserData): Promise<ManagedUser> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/admin/users`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({
      email: data.email.trim().toLowerCase(),
      password: data.password,
      fullName: data.fullName.trim(),
      role: data.role,
      status: data.status,
    }),
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi lưu người dùng vào database (Mã: ${response.status})`);
  }

  const json = await response.json();
  const u = json.data;

  return {
    id: u.id,
    email: u.email,
    fullName: u.fullName,
    role: u.role,
    status: u.status,
    createdAt: u.createdAt || new Date().toISOString(),
    tripsCount: u.tripsCount || 0,
  };
}

export interface UpdateUserData {
  fullName: string;
  role: RoleType;
  status: 'ACTIVE' | 'LOCKED';
  password?: string;
}

/**
 * Cập nhật thông tin người dùng trực tiếp vào Database
 */
export async function updateUserApi(id: number, data: UpdateUserData): Promise<ManagedUser> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/admin/users/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({
      fullName: data.fullName.trim(),
      role: data.role,
      status: data.status,
      ...(data.password ? { password: data.password } : {}),
    }),
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi cập nhật người dùng trong database (Mã: ${response.status})`);
  }

  const json = await response.json();
  const u = json.data;

  return {
    id: u.id,
    email: u.email,
    fullName: u.fullName,
    role: u.role,
    status: u.status,
    createdAt: u.createdAt || new Date().toISOString(),
    tripsCount: u.tripsCount || 0,
  };
}

/**
 * Khóa hoặc Mở khóa người dùng trực tiếp trong Database
 */
export async function toggleUserLockApi(id: number, currentStatus: string): Promise<ManagedUser> {
  const nextStatus = currentStatus === 'LOCKED' ? 'ACTIVE' : 'LOCKED';
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/admin/users/${id}/status`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ status: nextStatus }),
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi cập nhật trạng thái trong database (Mã: ${response.status})`);
  }

  const json = await response.json();
  const u = json.data;

  return {
    id: u.id,
    email: u.email,
    fullName: u.fullName,
    role: u.role,
    status: u.status,
    createdAt: u.createdAt || new Date().toISOString(),
    tripsCount: u.tripsCount || 0,
  };
}

/**
 * Xóa tài khoản người dùng vĩnh viễn khỏi Database
 */
export async function deleteUserApi(id: number): Promise<void> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/admin/users/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi xóa người dùng khỏi database (Mã: ${response.status})`);
  }
}

export type RoleType = 'ROLE_ADMIN' | 'ROLE_MODERATOR' | 'ROLE_USER';

export interface AuthUser {
  id: number;
  email: string;
  fullName: string;
  role: RoleType;
}

export interface AuthResponseData {
  token: string;
  id: number;
  email: string;
  fullName: string;
  role: string;
}

export const ROLE_LABELS: Record<RoleType, string> = {
  ROLE_ADMIN: 'Quản trị viên',
  ROLE_MODERATOR: 'Điều hành viên',
  ROLE_USER: 'Người dùng',
};

export const ROLE_DESCRIPTIONS: Record<RoleType, string> = {
  ROLE_ADMIN: 'Toàn quyền quản trị hệ thống: Thêm, sửa, xóa địa điểm, quản trị người dùng và nhật ký kiểm toán.',
  ROLE_MODERATOR: 'Quản lý nội dung & dữ liệu: Xem dashboard, thêm và chỉnh sửa thông tin địa điểm, quản lý danh mục (không có quyền xóa).',
  ROLE_USER: 'Người dùng thông thường: Tài khoản trải nghiệm, không có quyền can thiệp vào các cài đặt quản trị.',
};

export const ROLE_BADGE_STYLES: Record<RoleType, { bg: string; text: string; border: string }> = {
  ROLE_ADMIN: {
    bg: '#fef3c7',
    text: '#92400e',
    border: '#fde68a',
  },
  ROLE_MODERATOR: {
    bg: '#e0f2fe',
    text: '#0369a1',
    border: '#bae6fd',
  },
  ROLE_USER: {
    bg: '#f1f5f9',
    text: '#475569',
    border: '#e2e8f0',
  },
};

/**
 * Kiểm tra xem vai trò có được phép vào trang quản trị Admin không.
 * ROLE_ADMIN và ROLE_MODERATOR được phép vào, ROLE_USER bị chặn.
 */
export function canAccessAdmin(role?: string): boolean {
  return role === 'ROLE_ADMIN' || role === 'ROLE_MODERATOR';
}

/**
 * Kiểm tra xem vai trò có quyền xóa vĩnh viễn địa điểm không (chỉ ROLE_ADMIN).
 */
export function canDeleteDestinations(role?: string): boolean {
  return role === 'ROLE_ADMIN';
}

/**
 * Kiểm tra xem vai trò có quyền quản lý người dùng không (chỉ ROLE_ADMIN).
 */
export function canManageUsers(role?: string): boolean {
  return role === 'ROLE_ADMIN';
}

/**
 * Kiểm tra xem vai trò có quyền xem nhật ký thao tác (Audit Logs) không (chỉ ROLE_ADMIN).
 */
export function canViewAuditLogs(role?: string): boolean {
  return role === 'ROLE_ADMIN';
}

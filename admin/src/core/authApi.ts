import { AuthUser, RoleType } from '../types/auth';

const API_BASE_URL = 'http://localhost:8080/api/v1';

const STORAGE_KEY_USER = 'smarttravel_admin_user';
const STORAGE_KEY_TOKEN = 'smarttravel_admin_token';
const STORAGE_KEY_USERS_DB = 'smarttravel_registered_users_db';

// Preset demo accounts for rapid testing and offline resilience (C-4 Resilience)
export const DEMO_ACCOUNTS: Array<{
  email: string;
  pass: string;
  fullName: string;
  role: RoleType;
  label: string;
}> = [
  {
    email: 'admin@smarttravel.vn',
    pass: 'admin123',
    fullName: 'Lan Nguyễn (Admin)',
    role: 'ROLE_ADMIN',
    label: 'Quản trị viên (ROLE_ADMIN)',
  },
  {
    email: 'mod@smarttravel.vn',
    pass: 'mod123',
    fullName: 'Hoàng Nam (Biên tập)',
    role: 'ROLE_MODERATOR',
    label: 'Điều hành viên (ROLE_MODERATOR)',
  },
  {
    email: 'user@smarttravel.vn',
    pass: 'user123',
    fullName: 'Thành Long (Khách)',
    role: 'ROLE_USER',
    label: 'Người dùng (ROLE_USER - Bị hạn chế)',
  },
];

interface StoredUserItem {
  id: number;
  email: string;
  fullName: string;
  role: RoleType;
  passwordHash: string;
}

function getRegisteredUsers(): StoredUserItem[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_USERS_DB);
    if (!raw) {
      const initial: StoredUserItem[] = DEMO_ACCOUNTS.map((acc, index) => ({
        id: index + 1,
        email: acc.email.toLowerCase(),
        fullName: acc.fullName,
        role: acc.role,
        passwordHash: acc.pass,
      }));
      localStorage.setItem(STORAGE_KEY_USERS_DB, JSON.stringify(initial));
      return initial;
    }
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

function saveRegisteredUser(user: StoredUserItem): void {
  const list = getRegisteredUsers();
  list.push(user);
  localStorage.setItem(STORAGE_KEY_USERS_DB, JSON.stringify(list));
}

export function getStoredUser(): AuthUser | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_USER) || sessionStorage.getItem(STORAGE_KEY_USER);
    if (!raw) return null;
    return JSON.parse(raw) as AuthUser;
  } catch {
    return null;
  }
}

export function getStoredToken(): string | null {
  return localStorage.getItem(STORAGE_KEY_TOKEN) || sessionStorage.getItem(STORAGE_KEY_TOKEN);
}

export function setStoredAuth(user: AuthUser, token: string, remember: boolean = true): void {
  if (remember) {
    localStorage.setItem(STORAGE_KEY_USER, JSON.stringify(user));
    localStorage.setItem(STORAGE_KEY_TOKEN, token);
    sessionStorage.removeItem(STORAGE_KEY_USER);
    sessionStorage.removeItem(STORAGE_KEY_TOKEN);
  } else {
    sessionStorage.setItem(STORAGE_KEY_USER, JSON.stringify(user));
    sessionStorage.setItem(STORAGE_KEY_TOKEN, token);
    localStorage.removeItem(STORAGE_KEY_USER);
    localStorage.removeItem(STORAGE_KEY_TOKEN);
  }
}

export function clearStoredAuth(): void {
  localStorage.removeItem(STORAGE_KEY_USER);
  localStorage.removeItem(STORAGE_KEY_TOKEN);
  sessionStorage.removeItem(STORAGE_KEY_USER);
  sessionStorage.removeItem(STORAGE_KEY_TOKEN);
}

export interface LoginParams {
  email: string;
  password: string;
  remember?: boolean;
}

export async function loginApi(params: LoginParams): Promise<AuthUser> {
  const normalizedEmail = params.email.trim().toLowerCase();
  const remember = params.remember ?? true;

  // 1. Attempt real Backend API
  try {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: normalizedEmail, password: params.password }),
    });

    if (response.ok) {
      const json = await response.json();
      const data = json.data;
      const user: AuthUser = {
        id: data.id,
        email: data.email,
        fullName: data.fullName,
        role: (data.role as RoleType) || 'ROLE_USER',
      };
      setStoredAuth(user, data.token || 'mock_jwt_token', remember);
      return user;
    } else {
      const errJson = await response.json().catch(() => null);
      if (errJson?.message) {
        throw new Error(errJson.message);
      }
    }
  } catch (err: any) {
    // If backend refused connection or is offline, try offline mock database
    if (err.message && !err.message.includes('Failed to fetch') && !err.message.includes('NetworkError')) {
      throw err;
    }
  }

  // 2. Fallback to Local Auth Store (For offline demo and resiliency)
  const users = getRegisteredUsers();
  const matched = users.find(
    (u) => u.email === normalizedEmail && u.passwordHash === params.password
  );

  if (!matched) {
    throw new Error('Email hoặc mật khẩu không chính xác.');
  }

  const user: AuthUser = {
    id: matched.id,
    email: matched.email,
    fullName: matched.fullName,
    role: matched.role,
  };

  setStoredAuth(user, `mock_jwt_token_${user.id}_${Date.now()}`, remember);
  return user;
}

export interface RegisterParams {
  email: string;
  password: string;
  fullName: string;
  role?: RoleType;
}

export async function registerApi(params: RegisterParams): Promise<AuthUser> {
  const normalizedEmail = params.email.trim().toLowerCase();
  const assignedRole: RoleType = params.role || 'ROLE_USER';

  // 1. Attempt real Backend API
  try {
    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: normalizedEmail,
        password: params.password,
        fullName: params.fullName.trim(),
        role: assignedRole,
      }),
    });

    if (response.ok) {
      const json = await response.json();
      const data = json.data;
      const user: AuthUser = {
        id: data.id,
        email: data.email,
        fullName: data.fullName,
        role: (data.role as RoleType) || assignedRole,
      };
      setStoredAuth(user, data.token || 'mock_jwt_token');
      return user;
    } else {
      const errJson = await response.json().catch(() => null);
      if (errJson?.message) {
        throw new Error(errJson.message);
      }
    }
  } catch (err: any) {
    if (err.message && !err.message.includes('Failed to fetch') && !err.message.includes('NetworkError')) {
      throw err;
    }
  }

  // 2. Fallback to Local Auth Store
  const users = getRegisteredUsers();
  if (users.some((u) => u.email === normalizedEmail)) {
    throw new Error('Email này đã được sử dụng. Vui lòng chọn email khác.');
  }

  const newUser: StoredUserItem = {
    id: users.length + 1,
    email: normalizedEmail,
    fullName: params.fullName.trim(),
    role: assignedRole,
    passwordHash: params.password,
  };

  saveRegisteredUser(newUser);

  const user: AuthUser = {
    id: newUser.id,
    email: newUser.email,
    fullName: newUser.fullName,
    role: newUser.role,
  };

  setStoredAuth(user, `mock_jwt_token_${user.id}_${Date.now()}`);
  return user;
}

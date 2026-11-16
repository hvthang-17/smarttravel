import type { AuthUser, AuthResponseData, RoleType } from '../types/auth';
import { API_BASE_URL, apiFetch, getStoredToken, setStoredAuth, clearStoredAuth } from './session';
export { getStoredUser, getStoredToken, setStoredAuth, clearStoredAuth } from './session';

export interface LoginParams {
  email: string;
  password: string;
  remember?: boolean;
}

export interface RegisterParams {
  email: string;
  password: string;
  fullName: string;
}

async function authenticate(path: string, body: object, remember: boolean): Promise<AuthUser> {
  const response = await apiFetch(`${API_BASE_URL}/auth/${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const json = await response.json();
  if (!response.ok || !json.success) throw new Error(json.message || 'Không thể xác thực tài khoản');
  const data = json.data as AuthResponseData;
  if (!data?.token || data.token.split('.').length !== 3) throw new Error('Phiên đăng nhập không hợp lệ');
  const user: AuthUser = { id: data.id, email: data.email, fullName: data.fullName, role: data.role as RoleType,
    ...(data.travelerProfile?.language ? { language: data.travelerProfile.language } : {}) };
  setStoredAuth(user, data.token, remember);
  return user;
}

export function loginApi(params: LoginParams): Promise<AuthUser> {
  return authenticate('login', { email: params.email.trim().toLowerCase(), password: params.password }, params.remember ?? true);
}

export function registerApi(params: RegisterParams): Promise<AuthUser> {
  return authenticate('register', {
    email: params.email.trim().toLowerCase(), password: params.password, fullName: params.fullName.trim(),
  }, true);
}

export async function refreshSession(): Promise<AuthUser | null> {
  const token = getStoredToken();
  if (!token) { clearStoredAuth(); return null; }
  const response = await apiFetch(`${API_BASE_URL}/auth/profile`);
  if (!response.ok) {
    if (response.status === 401) clearStoredAuth();
    throw new Error('Không thể xác minh phiên đăng nhập');
  }
  const json = await response.json();
  const data = json.data as AuthResponseData;
  if (getStoredToken() !== token) return null;
  const user: AuthUser = { id: data.id, email: data.email, fullName: data.fullName, role: data.role as RoleType,
    ...(data.travelerProfile?.language ? { language: data.travelerProfile.language } : {}) };
  const remember = localStorage.getItem('smarttravel_admin_token') !== null;
  setStoredAuth(user, data.token || token, remember);
  return user;
}

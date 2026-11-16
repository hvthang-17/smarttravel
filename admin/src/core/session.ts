import type { AuthUser } from '../types/auth';

const USER_KEY = 'smarttravel_admin_user';
const TOKEN_KEY = 'smarttravel_admin_token';
export const SESSION_EXPIRED = 'smarttravel:session-expired';
export const PERMISSIONS_CHANGED = 'smarttravel:permissions-changed';

export function getStoredToken(): string | null {
  const token = localStorage.getItem(TOKEN_KEY) || sessionStorage.getItem(TOKEN_KEY);
  return token && token.split('.').length === 3 ? token : null;
}

export function getStoredUser(): AuthUser | null {
  localStorage.removeItem('smarttravel_registered_users_db');
  if (!getStoredToken()) return null;
  try {
    const raw = localStorage.getItem(USER_KEY) || sessionStorage.getItem(USER_KEY);
    return raw ? JSON.parse(raw) as AuthUser : null;
  } catch {
    return null;
  }
}

export function setStoredAuth(user: AuthUser, token: string, remember = true): void {
  clearStoredAuth();
  const storage = remember ? localStorage : sessionStorage;
  storage.setItem(USER_KEY, JSON.stringify(user));
  storage.setItem(TOKEN_KEY, token);
}

export function clearStoredAuth(): void {
  for (const storage of [localStorage, sessionStorage]) {
    storage.removeItem(USER_KEY);
    storage.removeItem(TOKEN_KEY);
    storage.removeItem('smarttravel_registered_users_db');
  }
}

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api/v1';

export async function apiFetch(input: string, options: RequestInit = {}): Promise<Response> {
  const headers = new Headers(options.headers);
  const token = getStoredToken();
  if (token) headers.set('Authorization', `Bearer ${token}`);
  const controller = new AbortController();
  const cancel = () => controller.abort();
  options.signal?.addEventListener('abort', cancel, { once: true });
  if (options.signal?.aborted) controller.abort();
  const timer = window.setTimeout(cancel, 20000);
  let response: Response;
  try {
    response = await fetch(input, { ...options, headers, signal: controller.signal });
  } catch (error) {
    if (controller.signal.aborted && !options.signal?.aborted) {
      throw new Error('Kết nối quá thời gian. Hãy thử lại. / Connection timed out. Please retry.');
    }
    if (error instanceof TypeError) {
      throw new Error('Không thể kết nối máy chủ. Kiểm tra mạng rồi thử lại. / Cannot reach the server. Check your connection and retry.');
    }
    throw error;
  } finally {
    window.clearTimeout(timer);
    options.signal?.removeEventListener('abort', cancel);
  }
  if (response.status === 401 && token && token === getStoredToken() && !/\/auth\/(login|register)$/.test(input)) {
    clearStoredAuth();
    window.dispatchEvent(new Event(SESSION_EXPIRED));
  }
  if (response.status === 403) window.dispatchEvent(new Event(PERMISSIONS_CHANGED));
  return response;
}

import { API_BASE_URL, apiFetch } from './session';
import type { ApiResponse } from '../types/destination';
import type { ManagedUser } from './userApi';

export interface Slice<T> { items: T[]; hasNext: boolean }
export interface DashboardMetrics {
  from: string; to: string; activeDestinations: number; totalUsers: number;
  activeUsers: number; lockedUsers: number; administrators: number;
  newUsers: number; createdSavedTrips: number; publishedReviews: number; reportedReviews: number;
}

export interface AuditRow {
  id: number; actorId: number | null; actorName: string | null;
  action: string; entity: string; entityId: number | null; createdAt: string;
  details: Record<string, string | number | boolean | string[]>;
}
export interface AuditFilter { actor: string; actorId: string; action: string; entity: string; from: string; to: string }
export interface ManagedTrip { id: number; title: string; owner: string; status: string; startDate: string; endDate: string }

async function get<T>(path: string, params: URLSearchParams, signal?: AbortSignal): Promise<T> {
  const response = await apiFetch(`${API_BASE_URL}/admin/${path}?${params}`, { signal });
  const body = await response.json().catch(() => null) as ApiResponse<T> | null;
  if (!response.ok || body?.success !== true) throw new Error(body?.message || 'Không tải được dữ liệu.');
  return body.data;
}

function query(values: Record<string, string | number>): URLSearchParams {
  return new URLSearchParams(Object.entries(values).filter(([, value]) => value !== '')
    .map(([key, value]) => [key, String(value)]));
}

export const dashboard = (days = 7, signal?: AbortSignal) =>
  get<DashboardMetrics>('dashboard', query({ days }), signal);
export const auditPage = (filter: AuditFilter, page: number, signal?: AbortSignal) =>
  get<Slice<AuditRow>>('audit', query({ ...filter, page }), signal);
export const auditExport = (filter: AuditFilter) =>
  get<{filename: string; csv: string}>('audit/export', query({ ...filter }));
export const adminTrips = (search: string, status: string, page: number, signal?: AbortSignal) =>
  get<Slice<ManagedTrip>>('itineraries/page', query({ search, status, page }), signal);
export const adminUsers = (search: string, role: string, status: string, page: number) =>
  get<Slice<ManagedUser>>('users/page', query({ search, role, status, page }));

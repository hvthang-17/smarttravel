import { API_BASE_URL, apiFetch } from './session';
import type { ApiResponse } from '../types/destination';

export type ReviewStatus = 'PUBLISHED' | 'HIDDEN';
export type ReportReason = 'SPAM' | 'ABUSE' | 'IRRELEVANT' | 'OTHER';

export interface ModerationReview {
  id: number;
  destinationId: number;
  destinationName: string;
  rating: number;
  comment: string | null;
  status: ReviewStatus;
  createdAt: string;
  reports: Partial<Record<ReportReason, number>>;
}

export interface ModerationPage {
  items: ModerationReview[];
  hasNext: boolean;
}

async function data<T>(response: Response): Promise<T> {
  const body = await response.json().catch(() => null) as ApiResponse<T> | null;
  if (!response.ok || body?.success !== true) throw new Error(body?.message || 'Không thể tải đánh giá.');
  return body.data;
}

export async function fetchReviewPage(status: ReviewStatus | 'ALL', reportedOnly: boolean, page: number,
    destinationId: string | null, signal: AbortSignal): Promise<ModerationPage> {
  const params = new URLSearchParams({ status, reportedOnly: String(reportedOnly), page: String(page) });
  if (destinationId) params.set('destinationId', destinationId);
  return data(await apiFetch(`${API_BASE_URL}/admin/reviews?${params}`, { signal }));
}

export async function updateReviewStatus(id: number, status: ReviewStatus): Promise<void> {
  await data(await apiFetch(`${API_BASE_URL}/admin/reviews/${id}/status`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status }),
  }));
}

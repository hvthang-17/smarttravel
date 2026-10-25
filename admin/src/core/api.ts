import { ApiResponse, Destination } from '../types/destination';

const API_BASE_URL = 'http://localhost:8080/api/v1';

export interface FetchDestinationsOptions {
  category?: string;
  status?: string;
  search?: string;
}

export async function fetchDestinations(options?: FetchDestinationsOptions): Promise<Destination[]> {
  const params = new URLSearchParams();
  if (options?.category && options.category !== 'Tất cả') {
    params.append('category', options.category);
  }
  if (options?.status && options.status !== 'ALL') {
    params.append('status', options.status);
  } else {
    // Default to 'ALL' for admin view to see both ACTIVE and INACTIVE
    params.append('status', 'ALL');
  }
  if (options?.search && options.search.trim()) {
    params.append('search', options.search.trim());
  }

  const response = await fetch(`${API_BASE_URL}/destinations?${params.toString()}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch destinations: ${response.statusText}`);
  }
  const json: ApiResponse<Destination[]> = await response.json();
  return json.data || [];
}

export async function fetchDestinationById(id: number): Promise<Destination> {
  const response = await fetch(`${API_BASE_URL}/destinations/${id}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch destination: ${response.statusText}`);
  }
  const json: ApiResponse<Destination> = await response.json();
  return json.data;
}

export async function createDestination(destination: Omit<Destination, 'id'>): Promise<Destination> {
  const response = await fetch(`${API_BASE_URL}/destinations`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(destination),
  });
  if (!response.ok) {
    const json = await response.json().catch(() => null);
    const msg = json?.message || response.statusText;
    throw new Error(`Failed to create destination: ${msg}`);
  }
  const json: ApiResponse<Destination> = await response.json();
  return json.data;
}

export async function updateDestination(id: number, destination: Omit<Destination, 'id'>): Promise<Destination> {
  const response = await fetch(`${API_BASE_URL}/destinations/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(destination),
  });
  if (!response.ok) {
    const json = await response.json().catch(() => null);
    const msg = json?.message || response.statusText;
    throw new Error(`Failed to update destination: ${msg}`);
  }
  const json: ApiResponse<Destination> = await response.json();
  return json.data;
}

export async function deleteDestination(id: number): Promise<void> {
  const response = await fetch(`${API_BASE_URL}/destinations/${id}`, {
    method: 'DELETE',
  });
  if (!response.ok) {
    const json = await response.json().catch(() => null);
    const msg = json?.message || response.statusText;
    throw new Error(`Failed to delete destination: ${msg}`);
  }
}

import { ApiResponse, Destination } from '../types/destination';

const API_BASE_URL = 'http://localhost:8080/api/v1';

export async function fetchDestinations(category?: string): Promise<Destination[]> {
  const url = category && category !== 'Tất cả'
    ? `${API_BASE_URL}/destinations?category=${encodeURIComponent(category)}`
    : `${API_BASE_URL}/destinations`;

  const response = await fetch(url);
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


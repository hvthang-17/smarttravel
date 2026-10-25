const API_BASE_URL = 'http://localhost:8080/api/v1';

export interface Category {
  id: number;
  code: string;
  slug: string;
  name: string;
  nameEn?: string;
  description?: string;
  imageUrl?: string;
  icon: string;
  colorHex: string;
  displayOrder: number;
  status: 'ACTIVE' | 'INACTIVE';
  destinationsCount: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateCategoryPayload {
  name: string;
  nameEn?: string;
  slug?: string;
  code?: string;
  description?: string;
  imageUrl?: string;
  icon: string;
  colorHex: string;
  displayOrder?: number;
  status?: 'ACTIVE' | 'INACTIVE';
}

export interface UpdateCategoryPayload {
  name: string;
  nameEn?: string;
  description?: string;
  imageUrl?: string;
  icon: string;
  colorHex: string;
  displayOrder?: number;
  status?: 'ACTIVE' | 'INACTIVE';
}

export interface CategoryFilterOptions {
  search?: string;
  status?: string;
}

/**
 * Helper chuyển đổi đường dẫn ảnh lưu trữ nội bộ thành URL đầy đủ
 */
export function resolveImageUrl(url?: string): string {
  if (!url) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  if (url.startsWith('/')) {
    return `http://localhost:8080${url}`;
  }
  return `http://localhost:8080/${url}`;
}

/**
 * Lấy danh sách danh mục trực tiếp từ database thông qua Backend REST API
 */
export async function fetchCategoriesApi(options?: CategoryFilterOptions): Promise<Category[]> {
  const params = new URLSearchParams();
  if (options?.search?.trim()) {
    params.append('search', options.search.trim());
  }
  if (options?.status && options.status !== 'Tất cả' && options.status !== 'ALL') {
    params.append('status', options.status);
  }

  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/categories?${params.toString()}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi truy vấn danh mục địa điểm (Mã: ${response.status})`);
  }

  const json = await response.json();
  const list = json.data || [];

  return list.map((c: any) => ({
    id: c.id,
    code: c.code,
    slug: c.slug,
    name: c.name,
    nameEn: c.nameEn || '',
    description: c.description || '',
    imageUrl: c.imageUrl || '',
    icon: c.icon || 'tag',
    colorHex: c.colorHex || '#0077B6',
    displayOrder: c.displayOrder || 0,
    status: (c.status as 'ACTIVE' | 'INACTIVE') || 'ACTIVE',
    destinationsCount: typeof c.destinationsCount === 'number' ? c.destinationsCount : 0,
    createdAt: c.createdAt || new Date().toISOString(),
    updatedAt: c.updatedAt || new Date().toISOString(),
  }));
}

/**
 * Tạo danh mục mới trong cơ sở dữ liệu
 */
export async function createCategoryApi(payload: CreateCategoryPayload): Promise<Category> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/categories`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi tạo mới danh mục (Mã: ${response.status})`);
  }

  const json = await response.json();
  return json.data;
}

/**
 * Cập nhật thông tin danh mục
 */
export async function updateCategoryApi(id: number, payload: UpdateCategoryPayload): Promise<Category> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/categories/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi cập nhật danh mục (Mã: ${response.status})`);
  }

  const json = await response.json();
  return json.data;
}

/**
 * Bật/tắt trạng thái ACTIVE / INACTIVE của danh mục
 */
export async function toggleCategoryStatusApi(id: number): Promise<Category> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/categories/${id}/status`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi chuyển đổi trạng thái (Mã: ${response.status})`);
  }

  const json = await response.json();
  return json.data;
}

/**
 * Xóa danh mục khỏi cơ sở dữ liệu
 */
export async function deleteCategoryApi(id: number): Promise<void> {
  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/categories/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi xóa danh mục (Mã: ${response.status})`);
  }
}

/**
 * Tải ảnh trực tiếp từ thiết bị máy tính lên server backend và lưu trữ vào thư mục uploads/categories
 */
export async function uploadCategoryImageApi(file: File): Promise<{ url: string; filename: string }> {
  const formData = new FormData();
  formData.append('file', file);

  const token = localStorage.getItem('smarttravel_admin_token') || '';
  const response = await fetch(`${API_BASE_URL}/categories/upload-image`, {
    method: 'POST',
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: formData,
  });

  if (!response.ok) {
    const errJson = await response.json().catch(() => null);
    throw new Error(errJson?.message || `Lỗi tải ảnh lên hệ thống (Mã: ${response.status})`);
  }

  const json = await response.json();
  return json.data;
}

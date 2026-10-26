export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  errors?: string[];
  timestamp: string;
}

export interface Destination {
  id?: number;
  name: string;
  category: string;
  categoryId?: number;
  description?: string;
  address?: string;
  openingHours?: string;
  phone?: string;
  website?: string;
  imageUrl?: string;
  subImages?: string[];
  rating?: number;
  reviewCount?: number;
  osmId?: string;
  latitude: number;
  longitude: number;
  priceMinVnd?: number;
  priceMaxVnd?: number;
  status: 'ACTIVE' | 'INACTIVE';
}

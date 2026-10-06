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
  description?: string;
  latitude: number;
  longitude: number;
  priceMinVnd?: number;
  priceMaxVnd?: number;
  status: 'ACTIVE' | 'INACTIVE';
}

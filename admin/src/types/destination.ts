export interface OpeningSchedule {
  schema_version: 1;
  timezone: 'Asia/Ho_Chi_Minh';
  week: Record<string, [number, number][] | null>;
}

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
  nameEn?: string | null;
  descriptionEn?: string | null;
  visitDurationMinutes?: number | null;
  openingSchedule?: OpeningSchedule | null;
  googleRating?: number | null;
  googleReviewCount?: number | null;
  appRating?: number | null;
  appReviewCount?: number;
  category: string;
  categoryId?: number;
  categoryCode?: string | null;
  categoryIcon?: string | null;
  categoryColor?: string | null;
  description?: string | null;
  address?: string | null;
  openingHours?: string | null;
  phone?: string | null;
  website?: string | null;
  imageUrl?: string | null;
  subImages?: string[];
  rating?: number | null;
  reviewCount?: number | null;
  osmId?: string | null;
  latitude: number;
  longitude: number;
  priceMinVnd?: number | null;
  priceMaxVnd?: number | null;
  status: 'ACTIVE' | 'INACTIVE';
}

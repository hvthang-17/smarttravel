import React from 'react';
import {
  LandmarkIcon,
  UtensilsIcon,
  PalmtreeIcon,
  CameraIcon,
  CoffeeIcon,
  HotelIcon,
  SparklesIcon,
  TagIcon,
  IconProps,
} from '../../components/Icons';
import { Category } from '../../core/categoryApi';

export interface CategoryMeta {
  Icon: React.FC<IconProps>;
  label: string;
  bg: string;
  color: string;
  code: string;
}

export const FALLBACK_CATEGORIES: CategoryMeta[] = [
  { code: 'BEACH', label: 'Biển & Thiên nhiên', Icon: PalmtreeIcon, bg: '#f0fdf4', color: '#15803d' },
  { code: 'FOOD', label: 'Ẩm thực & Đặc sản', Icon: UtensilsIcon, bg: '#fff7ed', color: '#c2410c' },
  { code: 'CULTURE', label: 'Văn hóa & Di sản', Icon: LandmarkIcon, bg: '#f0f9ff', color: '#0369a1' },
  { code: 'CHECKIN', label: 'Sống ảo & Check-in', Icon: CameraIcon, bg: '#faf5ff', color: '#7e22ce' },
  { code: 'HOTEL', label: 'Nghỉ dưỡng & Khách sạn', Icon: HotelIcon, bg: '#eff6ff', color: '#1d4ed8' },
  { code: 'NIGHTLIFE', label: 'Chợ đêm & Giải trí', Icon: SparklesIcon, bg: '#fef2f2', color: '#b91c1c' },
  { code: 'CAFE', label: 'Cà phê & Thư giãn', Icon: CoffeeIcon, bg: '#fefce8', color: '#a16207' },
];

export function getCategoryMeta(categoryName?: string, categoriesList: Category[] = []): CategoryMeta {
  if (!categoryName) {
    return { code: 'OTHER', label: 'Khác', Icon: TagIcon, bg: '#f1f5f9', color: '#475569' };
  }

  const normalized = categoryName.trim().toLowerCase();

  // 1. Try to match from dynamic categories list
  const matched = categoriesList.find(
    (c) =>
      c.code.toLowerCase() === normalized ||
      c.name.toLowerCase() === normalized ||
      c.slug.toLowerCase() === normalized
  );

  if (matched) {
    let IconComponent = TagIcon;
    const iconCode = matched.icon?.toLowerCase() || '';
    if (iconCode.includes('palm') || iconCode.includes('beach')) IconComponent = PalmtreeIcon;
    else if (iconCode.includes('utensil') || iconCode.includes('food')) IconComponent = UtensilsIcon;
    else if (iconCode.includes('landmark') || iconCode.includes('culture')) IconComponent = LandmarkIcon;
    else if (iconCode.includes('camera') || iconCode.includes('checkin')) IconComponent = CameraIcon;
    else if (iconCode.includes('hotel')) IconComponent = HotelIcon;
    else if (iconCode.includes('coffee') || iconCode.includes('cafe')) IconComponent = CoffeeIcon;
    else if (iconCode.includes('sparkle') || iconCode.includes('nightlife')) IconComponent = SparklesIcon;

    return {
      code: matched.code,
      label: matched.name,
      Icon: IconComponent,
      bg: `${matched.colorHex || '#0077B6'}15`,
      color: matched.colorHex || '#0077B6',
    };
  }

  // 2. Fallback heuristic
  if (normalized.includes('ẩm thực') || normalized.includes('food')) {
    return FALLBACK_CATEGORIES[1];
  }
  if (normalized.includes('biển') || normalized.includes('beach')) {
    return FALLBACK_CATEGORIES[0];
  }
  if (normalized.includes('sống ảo') || normalized.includes('check-in') || normalized.includes('camera')) {
    return FALLBACK_CATEGORIES[3];
  }
  if (normalized.includes('cafe') || normalized.includes('cà phê') || normalized.includes('coffee')) {
    return FALLBACK_CATEGORIES[6];
  }
  if (normalized.includes('khách sạn') || normalized.includes('hotel') || normalized.includes('resort')) {
    return FALLBACK_CATEGORIES[4];
  }
  if (normalized.includes('chợ đêm') || normalized.includes('nightlife') || normalized.includes('giải trí')) {
    return FALLBACK_CATEGORIES[5];
  }
  if (normalized.includes('văn hóa') || normalized.includes('culture') || normalized.includes('di sản') || normalized.includes('tham quan')) {
    return FALLBACK_CATEGORIES[2];
  }

  return { code: 'OTHER', label: categoryName, Icon: TagIcon, bg: '#f1f5f9', color: '#475569' };
}

export function formatVndPrice(min?: number, max?: number): string {
  const minVal = min ?? 0;
  const maxVal = max ?? 0;

  if (minVal === 0 && maxVal === 0) {
    return 'Miễn phí';
  }
  if (minVal > 0 && maxVal > minVal) {
    return `${(minVal / 1000).toLocaleString('vi-VN')}k - ${(maxVal / 1000).toLocaleString('vi-VN')}k VNĐ`;
  }
  if (minVal > 0) {
    return `${minVal.toLocaleString('vi-VN')} VNĐ`;
  }
  if (maxVal > 0) {
    return `Tối đa ${maxVal.toLocaleString('vi-VN')} VNĐ`;
  }
  return 'Miễn phí';
}

export function buildGoogleMapsUrl(latitude: number, longitude: number): string {
  return `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`;
}

/**
 * Parses coordinates from Google Maps URLs or raw coordinate strings.
 * Supports:
 * - Google Maps Place pin: !3d15.9848823!4d108.25616
 * - Google Maps Viewport: /@15.9848823,108.2535851,17z
 * - Query params: ?q=16.061,108.227 or query=16.061,108.227 or ll=...
 * - Raw string: "15.9848823, 108.25616"
 */
export function parseCoordinatesFromInput(input: string): { latitude: string; longitude: string } | null {
  if (!input || typeof input !== 'string') return null;
  const trimmed = input.trim();

  // 1. Check for Google Maps exact place pin: !3d<lat>!4d<lng>
  const pinMatch = trimmed.match(/!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)/);
  if (pinMatch) {
    const lat = Number(pinMatch[1]);
    const lng = Number(pinMatch[2]);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      return { latitude: String(lat), longitude: String(lng) };
    }
  }

  // 2. Check for @<lat>,<lng> in Google Maps URL
  const atMatch = trimmed.match(/@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)/);
  if (atMatch) {
    const lat = Number(atMatch[1]);
    const lng = Number(atMatch[2]);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      return { latitude: String(lat), longitude: String(lng) };
    }
  }

  // 3. Check for query/q/ll/loc parameter
  const queryMatch = trimmed.match(/(?:[?&](?:q|query|ll)=|loc:)(-?\d+(?:\.\d+)?)(?:%2C|,)(-?\d+(?:\.\d+)?)/i);
  if (queryMatch) {
    const lat = Number(queryMatch[1]);
    const lng = Number(queryMatch[2]);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      return { latitude: String(lat), longitude: String(lng) };
    }
  }

  // 4. Check for direct raw coordinates (e.g. "16.0610, 108.2274" or "16.0610; 108.2274")
  const rawMatch = trimmed.match(/^(-?\d+(?:\.\d+)?)[,\s;]+(-?\d+(?:\.\d+)?)$/);
  if (rawMatch) {
    const lat = Number(rawMatch[1]);
    const lng = Number(rawMatch[2]);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      return { latitude: String(lat), longitude: String(lng) };
    }
  }

  return null;
}

export interface GeocodeResult {
  latitude: string;
  longitude: string;
  osmId?: string;
  displayName?: string;
}

/**
 * Free geocoding using OpenStreetMap Nominatim API biased towards Da Nang.
 */
export async function geocodeAddressOsm(query: string): Promise<GeocodeResult | null> {
  const trimmed = query.trim();
  if (!trimmed) return null;

  let fullQuery = trimmed;
  if (!trimmed.toLowerCase().includes('đà nẵng') && !trimmed.toLowerCase().includes('da nang')) {
    fullQuery = `${trimmed}, Đà Nẵng, Việt Nam`;
  }

  const endpoint = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(
    fullQuery
  )}&format=json&addressdetails=1&limit=1`;

  const response = await fetch(endpoint, {
    headers: {
      'Accept-Language': 'vi,en',
    },
  });

  if (!response.ok) {
    throw new Error(`Lỗi kết nối OpenStreetMap (${response.status})`);
  }

  const data = await response.json();
  if (!Array.isArray(data) || data.length === 0) {
    return null;
  }

  const first = data[0];
  const osmId = first.osm_type && first.osm_id ? `${first.osm_type}/${first.osm_id}` : undefined;

  return {
    latitude: Number(first.lat).toFixed(6),
    longitude: Number(first.lon).toFixed(6),
    osmId,
    displayName: first.display_name,
  };
}

import { t } from '../../core/language';
import React from 'react';
import {
  PalmtreeIcon,
  UtensilsIcon,
  LandmarkIcon,
  CameraIcon,
  HotelIcon,
  ShoppingBagIcon,
  CoffeeIcon,
  WavesIcon,
  CompassIcon,
  TagIcon,
  MapPinIcon,
  StarIcon,
} from '../../components/Icons';

export interface CategoryIconMeta {
  id: string;
  label: string;
  Icon: React.FC<{ size?: number | string; color?: string; style?: React.CSSProperties }>;
}

export const PRESET_ICONS: CategoryIconMeta[] = [
  { id: 'palmtree', label: t('Biển & Thiên nhiên'), Icon: PalmtreeIcon },
  { id: 'utensils', label: t('Ẩm thực & Món ngon'), Icon: UtensilsIcon },
  { id: 'landmark', label: t('Văn hóa & Di tích'), Icon: LandmarkIcon },
  { id: 'camera', label: t('Sống ảo & Check-in'), Icon: CameraIcon },
  { id: 'hotel', label: t('Khách sạn & Resort'), Icon: HotelIcon },
  { id: 'shopping-bag', label: t('Chợ đêm & Mua sắm'), Icon: ShoppingBagIcon },
  { id: 'coffee', label: t('Cà phê & Thư giãn'), Icon: CoffeeIcon },
  { id: 'waves', label: t('Sóng biển sông Hàn'), Icon: WavesIcon },
  { id: 'compass', label: t('Khám phá & Tour'), Icon: CompassIcon },
  { id: 'map-pin', label: t('Địa điểm nổi bật'), Icon: MapPinIcon },
  { id: 'star', label: t('Đặc sắc & Nổi bật'), Icon: StarIcon },
  { id: 'tag', label: t('Thẻ phân loại'), Icon: TagIcon },
];

export const PRESET_COLORS = [
  { hex: '#0077B6', label: t('Ocean Blue (Màu chủ đạo)') },
  { hex: '#10B981', label: t('Emerald Green (Thiên nhiên)') },
  { hex: '#F97316', label: t('Sunset Orange (Ẩm thực)') },
  { hex: '#8B5CF6', label: t('Purple Violet (Sống ảo)') },
  { hex: '#0284C7', label: t('Sky Blue (Nghỉ dưỡng)') },
  { hex: '#EF4444', label: t('Vibrant Red (Giải trí)') },
  { hex: '#D97706', label: t('Warm Amber (Cà phê)') },
  { hex: '#EC4899', label: t('Pink Rose (Lãng mạn)') },
  { hex: '#0D9488', label: t('Teal (Sinh thái)') },
  { hex: '#6366F1', label: t('Indigo (Sự kiện)') },
];

export function renderCategoryIcon(iconName: string, color: string = 'currentColor', size: number = 20) {
  const normalized = (iconName || '').toLowerCase();
  // Backward compatibility: map legacy 'sparkles' to ShoppingBagIcon
  if (normalized === 'sparkles') {
    return <ShoppingBagIcon size={size} color={color} />;
  }
  const meta = PRESET_ICONS.find((item) => item.id.toLowerCase() === normalized);
  if (meta) {
    const Component = meta.Icon;
    return <Component size={size} color={color} />;
  }
  return <TagIcon size={size} color={color} />;
}

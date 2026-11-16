import type { Destination, OpeningSchedule } from '../../../types/destination';
import { googleRating as readRating, googleReviewCount as readCount } from '../destinationContract.ts';
import { requireCatalogCode, imageUrl, galleryImages } from '../catalogContract.ts';
import type { Category } from '../../../core/categoryApi';

export const DAY_LABELS = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
export type DayMode = 'unknown' | 'closed' | 'allDay' | 'custom';
export interface DayDraft { mode: DayMode; periods: { start: string; end: string }[] }
export interface DestinationDraft {
  name: string; nameEn: string; description: string; descriptionEn: string;
  category: string; address: string; latitude: string; longitude: string; osmId: string;
  phone: string; website: string; priceMinVnd: string; priceMaxVnd: string;
  rating: string; reviewCount: string; visitDurationMinutes: string;
  imageUrl: string; subImages: string[]; status: 'ACTIVE' | 'INACTIVE';
}
export const durationDefaults: Record<string, number> = {
  BEACH: 90, FOOD: 60, CULTURE: 90, CHECKIN: 45, CAFE: 60, NIGHTLIFE: 120,
};
const timeText = (minute: number): string => `${String(Math.floor(minute / 60)).padStart(2, '0')}:${String(minute % 60).padStart(2, '0')}`;
export function scheduleDraft(schedule?: OpeningSchedule | null): DayDraft[] {
  return DAY_LABELS.map((_, index) => {
    const periods = schedule?.week[String(index + 1)];
    if (periods == null) return { mode: 'unknown', periods: [] };
    if (!periods.length) return { mode: 'closed', periods: [] };
    if (periods.length === 1 && periods[0][0] === 0 && periods[0][1] === 1440) return { mode: 'allDay', periods: [] };
    return { mode: 'custom', periods: periods.map(([start, end]) => ({ start: timeText(start), end: timeText(end) })) };
  });
}
export function serializeSchedule(days: DayDraft[]): OpeningSchedule | null {
  if (days.length !== 7) throw new Error('Lịch hoạt động phải đủ 7 ngày.');
  const week: OpeningSchedule['week'] = {};
  for (const [index, day] of days.entries()) {
    const key = String(index + 1);
    if (day.mode === 'unknown') { week[key] = null; continue; }
    if (day.mode === 'closed') { week[key] = []; continue; }
    if (day.mode === 'allDay') { week[key] = [[0, 1440]]; continue; }
    if (!day.periods.length) throw new Error(`${DAY_LABELS[index]}: cần ít nhất một khung giờ.`);
    week[key] = day.periods.map(({ start, end }): [number, number] => {
      const minute = (value: string): number => {
        if (value === '24:00') return 1440;
        if (!/^([01]\d|2[0-3]):[0-5]\d$/.test(value)) throw new Error(`${DAY_LABELS[index]}: giờ phải có dạng HH:mm.`);
        const [hour, min] = value.split(':').map(Number);
        return hour * 60 + min;
      };
      return [minute(start), minute(end)];
    }).sort((a, b) => a[0] - b[0]);
    let previousEnd = 0;
    for (const [start, end] of week[key]) {
      if (start >= end || start < previousEnd) throw new Error(`${DAY_LABELS[index]}: giờ kết thúc phải sau giờ bắt đầu và các ca không được chồng nhau.`);
      previousEnd = end;
    }
  }
  return days.every(day => day.mode === 'unknown') ? null : {
    schema_version: 1, timezone: 'Asia/Ho_Chi_Minh', week,
  };
}
export function initialDraft(destination: Destination | undefined | null, categories: Category[]): DestinationDraft {
  const category = destination
    ? categories.find(c => c.id === destination.categoryId || c.name === destination.category || c.code === destination.categoryCode)
    : categories[0];
  const value = (number?: number | null): string => number == null ? '' : String(number);
  return {
    name: destination?.name ?? '', nameEn: destination?.nameEn ?? '', description: destination?.description ?? '', descriptionEn: destination?.descriptionEn ?? '',
    category: category?.name ?? '', address: destination?.address ?? '', latitude: value(destination?.latitude), longitude: value(destination?.longitude),
    osmId: destination?.osmId ?? '', phone: destination?.phone ?? '', website: destination?.website ?? '',
    priceMinVnd: value(destination?.priceMinVnd), priceMaxVnd: value(destination?.priceMaxVnd),
    rating: value(destination ? readRating(destination) : undefined), reviewCount: value(destination ? readCount(destination) : undefined),
    visitDurationMinutes: value(destination?.visitDurationMinutes ?? durationDefaults[category?.code ?? '']),
    imageUrl: destination?.imageUrl ?? '', subImages: destination?.subImages ?? [], status: destination?.status ?? 'ACTIVE',
  };
}
export function buildDestinationPayload(draft: DestinationDraft, days: DayDraft[], categories: Category[], currentCategoryId?: number): Omit<Destination, 'id'> {
  const category = categories.find(c => c.name === draft.category || c.code === draft.category);
  if (!category || (category.status !== 'ACTIVE' && category.id !== currentCategoryId)) throw new Error('Vui lòng chọn danh mục đang hoạt động trong phạm vi đề tài.');
  requireCatalogCode(category.code);
  if (!draft.name.trim() || draft.name.trim().length > 180) throw new Error('Tên địa điểm phải có từ 1 đến 180 ký tự.');
  if (draft.nameEn.trim().length > 180) throw new Error('Tên tiếng Anh không được quá 180 ký tự.');
  const number = (value: string, label: string, min: number, max = Number.MAX_SAFE_INTEGER, integer = false): number | undefined => {
    if (!value.trim()) return undefined;
    const parsed = Number(value);
    if (!Number.isFinite(parsed) || parsed < min || parsed > max || (integer && !Number.isSafeInteger(parsed))) throw new Error(`${label} không hợp lệ.`);
    return parsed;
  };
  const latitude = number(draft.latitude, 'Vĩ độ', -90, 90);
  const longitude = number(draft.longitude, 'Kinh độ', -180, 180);
  if (latitude == null || longitude == null) throw new Error('Vui lòng nhập đầy đủ tọa độ địa điểm.');
  const priceMinVnd = number(draft.priceMinVnd, 'Giá tối thiểu', 0, undefined, true);
  const priceMaxVnd = number(draft.priceMaxVnd, 'Giá tối đa', 0, undefined, true);
  if (priceMinVnd != null && priceMaxVnd != null && priceMinVnd > priceMaxVnd) throw new Error('Giá tối đa phải lớn hơn hoặc bằng giá tối thiểu.');
  const googleRating = number(draft.rating, 'Điểm Google Maps (1–5)', 1, 5);
  if (googleRating != null && Math.abs(googleRating * 10 - Math.round(googleRating * 10)) > 1e-8) throw new Error('Điểm Google Maps chỉ có tối đa một chữ số thập phân.');
  const googleReviewCount = number(draft.reviewCount, 'Lượt đánh giá Google Maps', 0, 2147483647, true);
  const visitDurationMinutes = number(draft.visitDurationMinutes, 'Thời lượng tham quan (phút)', 1, 2147483647, true);
  for (const [label, value, max] of [['Địa chỉ', draft.address, 255], ['Số điện thoại', draft.phone, 50], ['Website', draft.website, 255], ['OSM ID', draft.osmId, 50], ['Ảnh chính', draft.imageUrl, 500]] as const) {
    if (value.trim().length > max) throw new Error(`${label} không được quá ${max} ký tự.`);
  }
  return {
    name: draft.name.trim(), nameEn: draft.nameEn.trim() || null, description: draft.description.trim() || null,
    descriptionEn: draft.descriptionEn.trim() || null, category: category.code, categoryId: category.id,
    address: draft.address.trim() || null, latitude, longitude, osmId: draft.osmId.trim() || null,
    openingSchedule: serializeSchedule(days), phone: draft.phone.trim() || null, website: draft.website.trim() || null,
    priceMinVnd: priceMinVnd ?? null, priceMaxVnd: priceMaxVnd ?? null, googleRating: googleRating ?? null, googleReviewCount: googleReviewCount ?? null, visitDurationMinutes,
    imageUrl: imageUrl(draft.imageUrl), subImages: galleryImages(draft.subImages), status: draft.status,
  };
}

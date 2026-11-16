import type { Destination } from '../../types/destination';
export function googleRating(destination: Destination): number | null {
  return Object.prototype.hasOwnProperty.call(destination, 'googleRating') ? destination.googleRating ?? null : destination.rating ?? null;
}
export function googleReviewCount(destination: Destination): number | null {
  return Object.prototype.hasOwnProperty.call(destination, 'googleReviewCount') ? destination.googleReviewCount ?? null : destination.reviewCount ?? null;
}
export function smartTravelReviewLabel(destination: Destination): string {
  return `${destination.appRating?.toFixed(1) ?? 'Chưa có'} · ${destination.appReviewCount ?? 0} lượt`;
}
export function averageGoogleRating(destinations: Destination[]): number | null {
  const ratings = destinations.map(googleRating).filter((rating): rating is number => rating != null);
  return ratings.length ? ratings.reduce((sum, value) => sum + value, 0) / ratings.length : null;
}
export function formatPrice(min?: number | null, max?: number | null): string {
  if (min == null && max == null) return 'Chưa rõ giá';
  if (min === 0 && max === 0) return 'Miễn phí';
  const money = (value: number): string => `${value.toLocaleString('vi-VN')} VNĐ`;
  if (min != null && max != null) return min === max ? money(min) : `${money(min)}–${money(max)}`;
  return min != null ? `Từ ${money(min)}` : `Tối đa ${money(max!)}`;
}
export function destinationCsvRow(destination: Destination): string {
  const values = [destination.id, destination.name, destination.category, destination.address, destination.latitude, destination.longitude,
    destination.openingHours, destination.phone, destination.website, destination.priceMinVnd, destination.priceMaxVnd,
    googleRating(destination), googleReviewCount(destination), destination.status];
  return values.map(value => `"${String(value ?? '').replace(/"/g, '""')}"`).join(',');
}

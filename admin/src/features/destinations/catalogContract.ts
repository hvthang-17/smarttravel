export const CATALOG_CODES = ['BEACH', 'FOOD', 'CULTURE', 'CHECKIN', 'CAFE', 'NIGHTLIFE'] as const;
export const MAX_GALLERY_IMAGES = 10;
export function requireCatalogCode(code: string): void {
  if (!(CATALOG_CODES as readonly string[]).includes(code)) throw new Error('Chỉ dùng BEACH, FOOD, CULTURE, CHECKIN, CAFE hoặc NIGHTLIFE. HOTEL đã bỏ khỏi phạm vi.');
}
export function imageUrl(value: string): string | null {
  const url = value.trim();
  if (!url) return null;
  if (url.length > 500) throw new Error('Đường dẫn ảnh không được quá 500 ký tự.');
  if (/^\/uploads\/(categories|destinations)\/[A-Za-z0-9_-]+\.(png|jpg|jpeg|gif)$/.test(url)) return url;
  try {
    const parsed = new URL(url);
    if (['http:', 'https:'].includes(parsed.protocol) && parsed.hostname && !parsed.username && !parsed.password) return url;
  } catch { /* Invalid URLs use the same validation message below. */ }
  throw new Error('Ảnh phải là URL HTTP(S) hoặc ảnh đã tải lên.');
}
export function galleryImages(values: string[]): string[] {
  if (values.length > MAX_GALLERY_IMAGES) throw new Error('Tối đa 10 ảnh phụ cho mỗi địa điểm.');
  const urls = values.map(imageUrl);
  if (urls.some(url => !url) || new Set(urls).size !== urls.length) throw new Error('Ảnh phụ không được trống hoặc trùng nhau.');
  return urls as string[];
}
export function validateImageFiles(files: Pick<File, 'size' | 'type'>[]): void {
  if (!files.length || files.length > 10 || files.reduce((sum, file) => sum + file.size, 0) > 25 * 1024 * 1024) throw new Error('Chọn 1–10 ảnh, tổng dung lượng tối đa 25MB.');
  if (files.some(file => file.size <= 0 || file.size > 5 * 1024 * 1024 || !['image/png', 'image/jpeg', 'image/gif'].includes(file.type))) throw new Error('Mỗi ảnh phải là PNG, JPG hoặc GIF, dung lượng từ 1 byte đến 5MB.');
}

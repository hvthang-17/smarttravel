import { useSyncExternalStore } from 'react';
import english from '../../../mobile/assets/translations/en.json';

export type Language = 'vi' | 'en';
let language: Language = 'vi';
const listeners = new Set<() => void>();
const adminEnglish: Record<string, string> = {
  'Theo dõi catalog, tài khoản và hoạt động du lịch trên SmartTravel.': 'Monitor destinations, accounts and travel activity on SmartTravel.',
  'Tra cứu chuyến đi theo chủ chuyến, ngày đi và trạng thái lưu.': 'Find saved trips by owner, travel dates and status.',
  'Tra cứu thay đổi dữ liệu theo người thực hiện, đối tượng và thời gian.': 'Find data changes by actor, entity and date.',
  'Số liệu tại thời điểm tải': 'Figures at the time of loading',
  'Giờ Đà Nẵng': 'Da Nang time',
  'Cập nhật': 'Update',
  'Đổi trạng thái': 'Change status',
  'Kiểm duyệt': 'Moderation',
  'Báo cáo': 'Report',
};

export function setUiLanguage(value: Language) {
  if (language === value) return;
  language = value;
  for (const listener of listeners) listener();
}

export function useUiLanguage(): Language {
  return useSyncExternalStore(
    listener => { listeners.add(listener); return () => listeners.delete(listener); },
    () => language,
  );
}

export function t(text: string): string {
  if (language !== 'en') return text;
  const exact = adminEnglish[text] ?? (english as Record<string, string>)[text];
  if (exact != null) return exact;
  const days: Record<string, string> = { T2: 'Mon', T3: 'Tue', T4: 'Wed', T5: 'Thu', T6: 'Fri', T7: 'Sat', CN: 'Sun' };
  return text.replace(/\b(T[2-7]|CN)\b/g, day => days[day])
    .replace(/\blượt\b/g, 'reviews')
    .replace(/^Từ /, 'From ').replace(/^Tối đa /, 'Up to ');
}

export function localizedText(vietnamese: string, english?: string | null): string {
  return language === 'en' && english?.trim() ? english : vietnamese;
}

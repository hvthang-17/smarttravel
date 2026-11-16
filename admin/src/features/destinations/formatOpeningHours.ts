const DAYS = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

export function formatOpeningHours(value?: string | null): string {
  if (!value?.trim()) return 'Chưa cập nhật';
  const parts = value.split(';').map((part) => part.trim());
  const entries: { day: number; hours: string }[] = [];

  for (const part of parts) {
    const match = /^(T[2-7]|CN):\s*(.+)$/.exec(part);
    if (!match) return value;
    const day = DAYS.indexOf(match[1]);
    if (entries.length && day <= entries[entries.length - 1].day) return value;
    entries.push({ day, hours: match[2].trim() });
  }

  const groups: string[] = [];
  for (let start = 0; start < entries.length;) {
    let end = start;
    while (end + 1 < entries.length
      && entries[end + 1].day === entries[end].day + 1
      && entries[end + 1].hours === entries[start].hours) {
      end++;
    }
    const label = start === end
      ? DAYS[entries[start].day]
      : `${DAYS[entries[start].day]}–${DAYS[entries[end].day]}`;
    groups.push(`${label}: ${entries[start].hours}`);
    start = end + 1;
  }
  return groups.join('; ');
}

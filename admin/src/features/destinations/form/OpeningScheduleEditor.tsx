import { t } from '../../../core/language';
import React from 'react';
import { DAY_LABELS, type DayDraft, type DayMode } from './destinationForm';

interface Props { value: DayDraft[]; onChange: (value: DayDraft[]) => void; disabled?: boolean }
export const OpeningScheduleEditor: React.FC<Props> = ({ value, onChange, disabled = false }) => {
  const update = (index: number, day: DayDraft): void => onChange(value.map((current, i) => i === index ? day : current));
  const setMode = (index: number, mode: DayMode): void => update(index, {
    mode, periods: mode === 'custom' ? value[index].periods.length ? value[index].periods : [{ start: '08:00', end: '17:00' }] : [],
  });
  return (
    <fieldset className="destination-section-box destination-hours-editor" disabled={disabled}>
      <legend className="destination-hours-title">{t("Giờ hoạt động")}</legend>
      <p id="destination-hours-help" className="destination-field-help">{t("Giờ địa phương Đà Nẵng. Có thể thêm nhiều ca; ca qua đêm cần tách sang ngày tiếp theo. Giờ đóng cửa cuối ngày ghi 24:00.")}</p>
      <button type="button" className="destination-hours-action" onClick={() => onChange(value.map(() => ({
        mode: value[0].mode, periods: value[0].periods.map(period => ({ ...period })),
      })))}>{t("Áp dụng lịch T2 cho cả tuần")}</button>
      {value.map((day, index) => (
        <div className="destination-hours-day" key={t(DAY_LABELS[index])}>
          <div className="destination-hours-day-header">
            <label htmlFor={`hours-mode-${index}`}>{t(DAY_LABELS[index])}</label>
            <select id={`hours-mode-${index}`} aria-label={`Trạng thái ${t(DAY_LABELS[index])}`} className="user-form-select"
              value={day.mode} onChange={event => setMode(index, event.target.value as DayMode)}>
              <option value="unknown">{t("Chưa rõ")}</option><option value="closed">{t("Đóng cửa")}</option>
              <option value="allDay">{t("Mở cả ngày")}</option><option value="custom">{t("Theo khung giờ")}</option>
            </select>
          </div>
          {day.mode === 'custom' && <>
            {day.periods.map((period, periodIndex) => (
              <div className="destination-hours-period" key={periodIndex}>
                {(['start', 'end'] as const).map(field => (
                  <label key={field} className="destination-hours-time-label">
                    {field === 'start' ? 'Mở cửa' : t('Đóng cửa')}
                    <input type="text" className="user-form-input" value={period[field]} placeholder="HH:mm"
                      pattern={field === 'end' ? '([01][0-9]|2[0-3]):[0-5][0-9]|24:00' : '([01][0-9]|2[0-3]):[0-5][0-9]'}
                      maxLength={5} required aria-describedby="destination-hours-help"
                      aria-label={`${t(DAY_LABELS[index])} ca ${periodIndex + 1} ${field === 'start' ? 'mở cửa' : t('đóng cửa')}`}
                      onChange={event => update(index, { ...day, periods: day.periods.map((current, i) => i === periodIndex ? { ...current, [field]: event.target.value } : current) })} />
                  </label>
                ))}
                <button type="button" className="destination-hours-action" aria-label={`Xóa ca ${periodIndex + 1} ${t(DAY_LABELS[index])}`}
                  disabled={day.periods.length === 1} onClick={() => update(index, { ...day, periods: day.periods.filter((_, i) => i !== periodIndex) })}>{t("Xóa ca")}</button>
              </div>
            ))}
            <button type="button" className="destination-hours-action" onClick={() => update(index, { ...day, periods: [...day.periods, { start: '', end: '' }] })}>{t("Thêm ca")} {t(DAY_LABELS[index])}</button>
          </>}
        </div>
      ))}
    </fieldset>
  );
};

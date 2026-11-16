import { t } from '../../../core/language';
import React from 'react';
interface Props {
  priceMinVnd: string; priceMaxVnd: string; phone: string; website: string; visitDurationMinutes: string;
  onChangePriceMinVnd: (value: string) => void; onChangePriceMaxVnd: (value: string) => void;
  onChangePhone: (value: string) => void; onChangeWebsite: (value: string) => void;
  onChangeVisitDurationMinutes: (value: string) => void; disabled?: boolean;
}
export const DestinationOperationalSection: React.FC<Props> = (props) => (
  <div className="destination-section-box">
    <label className="user-form-label" htmlFor="destination-duration">{t("Thời lượng tham quan (phút)")}</label>
    <input id="destination-duration" type="number" min={1} max={2147483647} step={1} className="user-form-input"
      value={props.visitDurationMinutes} onChange={event => props.onChangeVisitDurationMinutes(event.target.value)} disabled={props.disabled} />
    <p className="destination-field-help">{t("Ước tính cho hoạt động, không gồm di chuyển và khoảng đệm. Có thể điều chỉnh mức gợi ý theo danh mục.")}</p>
    <div className="destination-field-row">
      {([{ id: 'price-min', label: t('Giá tối thiểu (đ/người)'), value: props.priceMinVnd, onChange: props.onChangePriceMinVnd },
        { id: 'price-max', label: t('Giá tối đa (đ/người)'), value: props.priceMaxVnd, onChange: props.onChangePriceMaxVnd }]).map(field => (
        <div className="user-form-group" style={{ marginBottom: 0 }} key={field.id}>
          <label className="user-form-label" htmlFor={`destination-${field.id}`}>{field.label}</label>
          <input id={`destination-${field.id}`} type="number" min={0} step={1} className="user-form-input" placeholder={t("Chưa rõ giá")}
            value={field.value} onChange={event => field.onChange(event.target.value)} disabled={props.disabled} />
        </div>
      ))}
    </div>
    <p className="destination-field-help">{t("Để trống khi chưa biết; nhập 0 nếu miễn phí. Giá cố định: nhập cùng số tiền ở hai ô.")}</p>
    <label className="user-form-label" htmlFor="destination-phone">{t("Số điện thoại")}</label>
    <input id="destination-phone" type="tel" maxLength={50} value={props.phone} className="user-form-input"
      onChange={event => props.onChangePhone(event.target.value)} disabled={props.disabled} />
    <label className="user-form-label" htmlFor="destination-website">Website</label>
    <input id="destination-website" type="url" maxLength={255} value={props.website} placeholder="https://..." className="user-form-input"
      onChange={event => props.onChangeWebsite(event.target.value)} disabled={props.disabled} />
  </div>
);

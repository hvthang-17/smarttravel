import { t, localizedText } from '../../../core/language';
import React from 'react';
import type { Category } from '../../../core/categoryApi';

interface Props {
  name: string; nameEn: string; category: string; status: 'ACTIVE' | 'INACTIVE';
  description: string; descriptionEn: string; categoriesList: Category[];
  onChangeName: (value: string) => void; onChangeNameEn: (value: string) => void;
  onChangeCategory: (value: string) => void; onChangeStatus: (value: 'ACTIVE' | 'INACTIVE') => void;
  onChangeDescription: (value: string) => void; onChangeDescriptionEn: (value: string) => void;
  disabled?: boolean; hasNameError?: boolean;
}
export const DestinationBasicInfoSection: React.FC<Props> = (props) => (
  <div className="destination-section-box">
    <div className="user-form-group" style={{ marginBottom: 0 }}>
      <label className="user-form-label" htmlFor="destination-name">{t("Tên địa điểm (tiếng Việt) *")}</label>
      <input id="destination-name" type="text" value={props.name} maxLength={180} required disabled={props.disabled}
        onChange={event => props.onChangeName(event.target.value)} className="user-form-input" aria-invalid={props.hasNameError} />
    </div>
    <div className="user-form-group" style={{ marginBottom: 0 }}>
      <label className="user-form-label" htmlFor="destination-name-en">{t("Tên tiếng Anh (tùy chọn)")}</label>
      <input id="destination-name-en" type="text" value={props.nameEn} maxLength={180} disabled={props.disabled}
        onChange={event => props.onChangeNameEn(event.target.value)} className="user-form-input" />
    </div>
    <div className="destination-field-row">
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label" htmlFor="destination-category">{t("Danh mục *")}</label>
        <select id="destination-category" className="user-form-select" value={props.category} required disabled={props.disabled}
          onChange={event => props.onChangeCategory(event.target.value)}>
          {!props.category && <option value="">{props.categoriesList.length ? 'Chọn danh mục hoạt động' : t('Chưa có danh mục hoạt động')}</option>}
          {props.categoriesList.map(category => <option key={category.id} value={category.name}>{localizedText(category.name, category.nameEn)}</option>)}
        </select>
      </div>
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label" htmlFor="destination-status">{t("Trạng thái hiển thị")}</label>
        <select id="destination-status" className="user-form-select" value={props.status} disabled={props.disabled}
          onChange={event => props.onChangeStatus(event.target.value as 'ACTIVE' | 'INACTIVE')}>
          <option value="ACTIVE">{t("Hoạt động (Hiển thị)")}</option><option value="INACTIVE">{t("Tạm ẩn")}</option>
        </select>
      </div>
    </div>
    {([{ id: 'description', label: t('Mô tả tiếng Việt'), value: props.description, onChange: props.onChangeDescription },
      { id: 'description-en', label: t('Mô tả tiếng Anh (tùy chọn)'), value: props.descriptionEn, onChange: props.onChangeDescriptionEn }]).map(field => (
      <div className="user-form-group" style={{ marginBottom: 0 }} key={field.id}>
        <label className="user-form-label" htmlFor={`destination-${field.id}`}>{field.label}</label>
        <textarea id={`destination-${field.id}`} value={field.value} onChange={event => field.onChange(event.target.value)}
          className="user-form-textarea" rows={3} disabled={props.disabled} />
      </div>
    ))}
  </div>
);

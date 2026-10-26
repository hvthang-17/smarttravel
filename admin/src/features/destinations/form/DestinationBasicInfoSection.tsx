import React from 'react';
import { Category } from '../../../core/categoryApi';

interface Props {
  name: string;
  category: string;
  status: 'ACTIVE' | 'INACTIVE';
  description: string;
  categoriesList: Category[];
  onChangeName: (val: string) => void;
  onChangeCategory: (val: string) => void;
  onChangeStatus: (val: 'ACTIVE' | 'INACTIVE') => void;
  onChangeDescription: (val: string) => void;
  disabled?: boolean;
  hasNameError?: boolean;
}

export const DestinationBasicInfoSection: React.FC<Props> = ({
  name,
  category,
  status,
  description,
  categoriesList,
  onChangeName,
  onChangeCategory,
  onChangeStatus,
  onChangeDescription,
  disabled = false,
  hasNameError = false,
}) => {
  return (
    <div className="destination-section-box">
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label">
          Tên địa điểm <span style={{ color: '#ef4444' }}>*</span>
        </label>
        <input
          type="text"
          value={name}
          onChange={(e) => onChangeName(e.target.value)}
          className={`user-form-input ${hasNameError ? 'input-field-error' : ''}`}
          placeholder="VD: Cầu Rồng, Bãi biển Mỹ Khê..."
          required
          disabled={disabled}
          aria-invalid={hasNameError}
        />
      </div>

      <div className="destination-field-row">
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Danh mục</label>
          <select
            value={category}
            onChange={(e) => onChangeCategory(e.target.value)}
            className="user-form-select"
            disabled={disabled}
          >
            {categoriesList.length > 0 ? (
              categoriesList.map((cat) => (
                <option key={cat.code} value={cat.name}>
                  {cat.name}
                </option>
              ))
            ) : (
              <>
                <option value="Biển & Thiên nhiên">Biển & Thiên nhiên</option>
                <option value="Ẩm thực & Đặc sản">Ẩm thực & Đặc sản</option>
                <option value="Văn hóa & Di sản">Văn hóa & Di sản</option>
                <option value="Sống ảo & Check-in">Sống ảo & Check-in</option>
                <option value="Nghỉ dưỡng & Khách sạn">Nghỉ dưỡng & Khách sạn</option>
                <option value="Chợ đêm & Giải trí">Chợ đêm & Giải trí</option>
                <option value="Cà phê & Thư giãn">Cà phê & Thư giãn</option>
              </>
            )}
          </select>
        </div>

        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Trạng thái hiển thị</label>
          <select
            value={status}
            onChange={(e) => onChangeStatus(e.target.value as 'ACTIVE' | 'INACTIVE')}
            className="user-form-select"
            disabled={disabled}
          >
            <option value="ACTIVE">Hoạt động (Hiển thị)</option>
            <option value="INACTIVE">Tạm ẩn</option>
          </select>
        </div>
      </div>

      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label">Mô tả chi tiết</label>
        <textarea
          value={description}
          onChange={(e) => onChangeDescription(e.target.value)}
          className="user-form-textarea"
          rows={3}
          placeholder="Giới thiệu nét đặc sắc, lịch sử, lưu ý khi ghé thăm..."
          disabled={disabled}
        />
      </div>
    </div>
  );
};

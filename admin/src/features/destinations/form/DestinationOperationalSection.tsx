import React from 'react';

interface Props {
  openingHours: string;
  priceMinVnd: string;
  priceMaxVnd: string;
  phone: string;
  website: string;
  onChangeOpeningHours: (val: string) => void;
  onChangePriceMinVnd: (val: string) => void;
  onChangePriceMaxVnd: (val: string) => void;
  onChangePhone: (val: string) => void;
  onChangeWebsite: (val: string) => void;
  disabled?: boolean;
}

export const DestinationOperationalSection: React.FC<Props> = ({
  openingHours,
  priceMinVnd,
  priceMaxVnd,
  phone,
  website,
  onChangeOpeningHours,
  onChangePriceMinVnd,
  onChangePriceMaxVnd,
  onChangePhone,
  onChangeWebsite,
  disabled = false,
}) => {
  return (
    <div className="destination-section-box">
      <span style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a' }}>
        Thời gian & Chi phí
      </span>

      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label">Giờ hoạt động</label>
        <input
          type="text"
          value={openingHours}
          onChange={(e) => onChangeOpeningHours(e.target.value)}
          className="user-form-input"
          placeholder="VD: 07:00 - 22:00 hoặc Mở cả ngày"
          disabled={disabled}
        />
      </div>

      <div className="destination-field-row">
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Giá tối thiểu (VNĐ)</label>
          <input
            type="number"
            min="0"
            step="1000"
            value={priceMinVnd}
            onChange={(e) => onChangePriceMinVnd(e.target.value)}
            className="user-form-input"
            placeholder="0 (nếu miễn phí)"
            disabled={disabled}
          />
        </div>
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Giá tối đa (VNĐ)</label>
          <input
            type="number"
            min="0"
            step="1000"
            value={priceMaxVnd}
            onChange={(e) => onChangePriceMaxVnd(e.target.value)}
            className="user-form-input"
            placeholder="Để trống nếu đồng giá"
            disabled={disabled}
          />
        </div>
      </div>

      <div className="destination-field-row">
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Số điện thoại liên hệ</label>
          <input
            type="text"
            value={phone}
            onChange={(e) => onChangePhone(e.target.value)}
            className="user-form-input"
            placeholder="VD: 0236 3822 555"
            disabled={disabled}
          />
        </div>
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Website / Fanpage</label>
          <input
            type="text"
            value={website}
            onChange={(e) => onChangeWebsite(e.target.value)}
            className="user-form-input"
            placeholder="https://..."
            disabled={disabled}
          />
        </div>
      </div>
    </div>
  );
};

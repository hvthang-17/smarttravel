import { t } from '../../../core/language';
import React from 'react';
interface Props {
  rating: string; reviewCount: string; onChangeRating: (value: string) => void;
  onChangeReviewCount: (value: string) => void; disabled?: boolean;
}
export const DestinationStarRating: React.FC<Props> = ({ rating, reviewCount, onChangeRating, onChangeReviewCount, disabled }) => (
  <div className="destination-section-box">
    <span className="destination-hours-title">{t("Đánh giá Google Maps")}</span>
    <div className="destination-field-row">
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label" htmlFor="destination-google-rating">{t("Điểm Google Maps (1–5)")}</label>
        <input id="destination-google-rating" type="number" min={1} max={5} step={0.1} value={rating} placeholder={t("Chưa có dữ liệu")}
          onChange={event => onChangeRating(event.target.value)} className="user-form-input" disabled={disabled} />
      </div>
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label" htmlFor="destination-google-count">{t("Lượt đánh giá Google Maps")}</label>
        <input id="destination-google-count" type="number" min={0} max={2147483647} step={1} value={reviewCount} placeholder={t("Chưa có dữ liệu")}
          onChange={event => onChangeReviewCount(event.target.value)} className="user-form-input" disabled={disabled} />
      </div>
    </div>
    <p className="destination-field-help">{t("Để trống nếu chưa thu thập. Đánh giá của người dùng SmartTravel được tính riêng.")}</p>
  </div>
);

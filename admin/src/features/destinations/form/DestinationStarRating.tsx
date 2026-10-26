import React from 'react';
import { StarIcon } from '../../../components/Icons';

interface Props {
  rating: string;
  reviewCount: string;
  onChangeRating: (val: string) => void;
  onChangeReviewCount: (val: string) => void;
  disabled?: boolean;
}

export const DestinationStarRating: React.FC<Props> = ({
  rating,
  reviewCount,
  onChangeRating,
  onChangeReviewCount,
  disabled = false,
}) => {
  const currentRatingNum = parseFloat(rating) || 0;

  const handleRatingInputChange = (val: string) => {
    if (val === '') {
      onChangeRating('');
      return;
    }
    const num = parseFloat(val);
    if (!isNaN(num)) {
      if (num < 0) onChangeRating('0');
      else if (num > 5) onChangeRating('5.0');
      else onChangeRating(val);
    } else {
      onChangeRating(val);
    }
  };

  const handleStarKeyDown = (e: React.KeyboardEvent<HTMLButtonElement>, starValue: number) => {
    if (e.key === 'ArrowRight' || e.key === 'ArrowUp') {
      e.preventDefault();
      const next = Math.min(5, starValue + 1);
      onChangeRating(next.toFixed(1));
    } else if (e.key === 'ArrowLeft' || e.key === 'ArrowDown') {
      e.preventDefault();
      const prev = Math.max(1, starValue - 1);
      onChangeRating(prev.toFixed(1));
    }
  };

  return (
    <div className="destination-section-box">
      <span style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a' }}>
        Đánh giá ban đầu
      </span>

      <div className="destination-field-row" style={{ alignItems: 'flex-start' }}>
        {/* Điểm số sao: Ô nhập trực tiếp số sao + Cụm sao tương tác */}
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Điểm số sao (0.0 - 5.0)</label>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <input
              type="number"
              step="0.1"
              min="0"
              max="5"
              value={rating}
              onChange={(e) => handleRatingInputChange(e.target.value)}
              className="user-form-input"
              placeholder="VD: 4.5"
              disabled={disabled}
              style={{ width: '84px', flexShrink: 0, fontWeight: 600 }}
              aria-label="Nhập điểm số sao đánh giá"
            />

            <div
              className="destination-star-group"
              role="radiogroup"
              aria-label="Chọn điểm đánh giá sao từ 1 đến 5"
              style={{ display: 'flex', alignItems: 'center', gap: '1px' }}
            >
              {[1, 2, 3, 4, 5].map((s) => {
                const isSelected = Math.round(currentRatingNum) >= s;
                const isCurrent = Math.round(currentRatingNum) === s || (currentRatingNum === 0 && s === 1);
                return (
                  <button
                    key={s}
                    type="button"
                    role="radio"
                    aria-checked={isSelected}
                    tabIndex={isCurrent ? 0 : -1}
                    onClick={() => onChangeRating(s.toFixed(1))}
                    onKeyDown={(e) => handleStarKeyDown(e, s)}
                    disabled={disabled}
                    className="destination-star-btn"
                    title={`Chọn ${s} sao`}
                    aria-label={`${s} sao`}
                    style={{ minWidth: '30px', minHeight: '30px', padding: '4px' }}
                  >
                    <StarIcon
                      size={18}
                      color={isSelected ? '#f59e0b' : '#cbd5e1'}
                      fill={isSelected ? '#f59e0b' : 'none'}
                    />
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Lượt đánh giá */}
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Lượt đánh giá</label>
          <input
            type="number"
            min="0"
            value={reviewCount}
            onChange={(e) => onChangeReviewCount(e.target.value)}
            className="user-form-input"
            placeholder="0"
            disabled={disabled}
          />
        </div>
      </div>
    </div>
  );
};

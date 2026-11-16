import { t, localizedText } from '../../../core/language';
import { googleRating, googleReviewCount, smartTravelReviewLabel } from '../destinationContract';
import React, { useState } from 'react';
import { Destination } from '../../../types/destination';
import { Category, resolveImageUrl } from '../../../core/categoryApi';
import { getCategoryMeta, formatVndPrice } from '../destinationUtils';
import {
  MapPinIcon,
  StarIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  RefreshCwIcon,
} from '../../../components/Icons';

interface Props {
  destination: Destination;
  index: number;
  categoriesList: Category[];
  canDelete: boolean;
  isPending: boolean;
  onToggleStatus: (d: Destination) => void;
  onView: (d: Destination) => void;
  onEdit: (d: Destination) => void;
  onDelete: (d: Destination) => void;
}

export const DestinationMobileCard: React.FC<Props> = ({
  destination: d,
  index,
  categoriesList,
  canDelete,
  isPending,
  onToggleStatus,
  onView,
  onEdit,
  onDelete,
}) => {
  const [imgFailed, setImgFailed] = useState(false);
  const meta = getCategoryMeta(d.category, categoriesList);
  const CategoryIcon = meta.Icon;
  const destCode = d.id == null ? 'Chưa có ID' : `#DEST-${String(d.id).padStart(3, '0')}`;
  const isActive = d.status === 'ACTIVE';
  const resolvedImg = resolveImageUrl(d.imageUrl);
  const showImage = Boolean(resolvedImg && !imgFailed);

  return (
    <div className="destination-mobile-card">
      <div className="destination-mobile-card-top">
        <button
          type="button"
          onClick={() => onView(d)}
          className="destination-mobile-thumb-btn"
          style={{ backgroundColor: meta.bg }}
          title={t("Bấm để xem chi tiết địa điểm")}
          aria-label={`Xem ảnh và chi tiết ${localizedText(d.name, d.nameEn)}`}
        >
          {showImage ? (
            <img
              src={resolvedImg}
              alt={localizedText(d.name, d.nameEn)}
              style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              onError={() => setImgFailed(true)}
            />
          ) : (
            <CategoryIcon size={24} color={meta.color} />
          )}
        </button>

        <div className="destination-name-col">
          <div className="destination-name-row">
            <button
              type="button"
              onClick={() => onView(d)}
              style={{
                background: 'none',
                border: 'none',
                padding: 0,
                fontWeight: 600,
                fontSize: '14px',
                color: '#0f172a',
                textAlign: 'left',
                cursor: 'pointer',
              }}
              title={t("Bấm để xem chi tiết địa điểm")}
            >
              {localizedText(d.name, d.nameEn)}
            </button>
            <span className="destination-code-tag">{destCode}</span>
          </div>
          <div className="destination-address-text">
            <MapPinIcon size={12} color="#94a3b8" />
            <span>{d.address || t('TP. Đà Nẵng')}</span>
          </div>
        </div>
      </div>

      <div className="destination-mobile-card-row">
        <span>{t("Danh mục:")}</span>
        <span className="destination-category-badge" style={{ backgroundColor: meta.bg, color: meta.color }}>
          <CategoryIcon size={12} color={meta.color} />
          <span>{t(meta.label)}</span>
        </span>
      </div>

      <div className="destination-mobile-card-row">
        <span>{t("Chi phí:")}</span>
        <span className="destination-price-text">{t(formatVndPrice(d.priceMinVnd, d.priceMaxVnd))}</span>
      </div>

      <div className="destination-mobile-card-row">
        <span>Google Maps</span>
        <span style={{ display: 'flex', alignItems: 'center', gap: '4px', fontWeight: 600 }}>
          <StarIcon size={13} color="#f59e0b" />
          <span>{googleRating(d)?.toFixed(1) ?? t('Chưa có')} ({googleReviewCount(d) ?? t('chưa rõ lượt')})</span>
        </span>
      </div>
      <div className="destination-mobile-card-row">
        <span>SmartTravel</span>
        <span>{t(smartTravelReviewLabel(d))}</span>
      </div>

      <div className="destination-mobile-card-row">
        <span>{t("Trạng thái:")}</span>
        <div className="destination-status-wrapper">
          <label className="toggle-switch">
            <input
              type="checkbox"
              checked={isActive}
              disabled={isPending}
              onChange={() => onToggleStatus(d)}
              aria-label={`Bật tắt trạng thái cho ${localizedText(d.name, d.nameEn)}`}
            />
            <span className="toggle-slider" />
          </label>
          {isPending ? (
            <span className="destination-status-pending">
              <RefreshCwIcon size={12} className="spin-animation" color="#0077b6" />
              <span>{t("Đang lưu...")}</span>
            </span>
          ) : (
            <span style={{ fontSize: '12px', fontWeight: 600, color: isActive ? '#15803d' : '#475569' }}>
              {isActive ? 'Hoạt động' : t('Tạm ẩn')}
            </span>
          )}
        </div>
      </div>

      <div className="destination-mobile-card-actions">
        <button
          type="button"
          onClick={() => onView(d)}
          className="destination-action-btn"
          aria-label={`Xem chi tiết ${localizedText(d.name, d.nameEn)}`}
          style={{ minWidth: '40px', minHeight: '40px' }}
        >
          <EyeIcon size={16} color="#0077b6" />
        </button>
        <button
          type="button"
          onClick={() => onEdit(d)}
          className="destination-action-btn"
          aria-label={`Chỉnh sửa ${localizedText(d.name, d.nameEn)}`}
          style={{ minWidth: '40px', minHeight: '40px' }}
        >
          <PencilIcon size={15} color="#0077b6" />
        </button>
        {canDelete && (
          <button
            type="button"
            onClick={() => onDelete(d)}
            disabled={isPending}
            className="destination-action-btn delete-btn"
              aria-label={`Ẩn ${localizedText(d.name, d.nameEn)}`}
            style={{ minWidth: '40px', minHeight: '40px' }}
          >
            <TrashIcon size={15} color="#dc2626" />
          </button>
        )}
      </div>
    </div>
  );
};

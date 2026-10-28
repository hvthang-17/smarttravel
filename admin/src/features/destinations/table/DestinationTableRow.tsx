import React, { useState } from 'react';
import { Destination } from '../../../types/destination';
import { Category, resolveImageUrl } from '../../../core/categoryApi';
import { getCategoryMeta, formatVndPrice, buildGoogleMapsUrl } from '../destinationUtils';
import {
  MapPinIcon,
  ClockIcon,
  StarIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  ExternalLinkIcon,
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

export const DestinationTableRow: React.FC<Props> = ({
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
  const destCode = `#DEST-${String(d.id || index + 1).padStart(3, '0')}`;
  const isActive = d.status === 'ACTIVE';
  const resolvedImg = resolveImageUrl(d.imageUrl);
  const mapsUrl = buildGoogleMapsUrl(d.latitude, d.longitude);
  const showImage = Boolean(resolvedImg && !imgFailed);

  return (
    <tr key={d.id || index}>
      {/* Name, Image & Address */}
      <td>
        <div className="destination-cell-name">
          <button
            type="button"
            onClick={() => onView(d)}
            className="destination-thumb-btn"
            style={{ backgroundColor: meta.bg }}
            title="Bấm để xem chi tiết địa điểm"
            aria-label={`Xem ảnh và chi tiết ${d.name}`}
          >
            {showImage ? (
              <img
                src={resolvedImg}
                alt={d.name}
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                onError={() => setImgFailed(true)}
              />
            ) : (
              <CategoryIcon size={20} color={meta.color} />
            )}
            {d.subImages && d.subImages.length > 0 && (
              <span
                className="destination-badge-counter"
                title={`Gồm 1 ảnh đại diện + ${d.subImages.length} ảnh phụ`}
              >
                +{d.subImages.length}
              </span>
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
                  color: '#0f172a',
                  fontSize: '13.5px',
                  textAlign: 'left',
                  cursor: 'pointer',
                }}
                className="destination-name-btn"
                title="Bấm để xem chi tiết địa điểm"
              >
                {d.name}
              </button>
              <span className="destination-code-tag">{destCode}</span>
            </div>
            <div className="destination-address-text" title={d.address || 'Đà Nẵng'}>
              <MapPinIcon size={12} color="#94a3b8" />
              <span>{d.address || 'TP. Đà Nẵng'}</span>
            </div>
          </div>
        </div>
      </td>

      {/* Category */}
      <td>
        <span
          className="destination-category-badge"
          style={{ backgroundColor: meta.bg, color: meta.color }}
        >
          <CategoryIcon size={13} color={meta.color} />
          <span>{meta.label}</span>
        </span>
      </td>

      {/* Coordinates & Google Maps (WCAG AA 5.57:1) */}
      <td>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
          <a
            href={mapsUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="destination-gps-pill"
            title="Bấm để xem vị trí chính xác trên Google Maps"
          >
            <span>{Number(d.latitude).toFixed(4)}, {Number(d.longitude).toFixed(4)}</span>
            <ExternalLinkIcon size={11} color="#0369a1" />
          </a>
          {/* {d.osmId && (
            <span style={{ fontSize: '11px', color: '#64748b', paddingLeft: '2px' }}>
              OSM: {d.osmId}
            </span>
          )} */}
        </div>
      </td>

      {/* Price */}
      <td>
        <div className="destination-price-text">
          {formatVndPrice(d.priceMinVnd, d.priceMaxVnd)}
        </div>
        <div className="destination-price-hint">
          {d.priceMinVnd && d.priceMinVnd > 0 ? 'Giá vé / tham khảo' : 'Điểm đến công cộng'}
        </div>
      </td>

      {/* Opening Hours */}
      <td>
        {d.openingHours ? (
          <div style={{ display: 'flex', alignItems: 'center', gap: '5px', fontSize: '12.5px', color: '#334155' }}>
            <ClockIcon size={12} color="#64748b" />
            <span title={d.openingHours}>{d.openingHours}</span>
          </div>
        ) : (
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: '#92400e', backgroundColor: '#fef3c7', padding: '2px 7px', borderRadius: '4px' }}>
            <span>Chưa cập nhật</span>
          </span>
        )}
      </td>

      {/* Rating */}
      <td>
        <div className="destination-rating-row">
          <StarIcon size={13} color="#f59e0b" />
          <span className="destination-rating-score">
            {d.rating != null ? Number(d.rating).toFixed(1) : '4.5'}
          </span>
          <span className="destination-rating-count">
            ({d.reviewCount ?? 0})
          </span>
        </div>
      </td>

      {/* Toggle Status with Loading Spinner & Focus Ring */}
      <td>
        <div className="destination-status-wrapper">
          <label className="toggle-switch">
            <input
              type="checkbox"
              checked={isActive}
              disabled={isPending}
              onChange={() => onToggleStatus(d)}
              aria-label={`Bật tắt trạng thái cho ${d.name}`}
            />
            <span className="toggle-slider" />
          </label>
          {isPending ? (
            <span className="destination-status-pending">
              <RefreshCwIcon size={12} className="spin-animation" color="#0077b6" />
              <span>Đang lưu...</span>
            </span>
          ) : (
            <span style={{ fontSize: '12px', fontWeight: 600, color: isActive ? '#15803d' : '#475569' }}>
              {isActive ? '' : ''}
            </span>
          )}
        </div>
      </td>

      {/* Actions (Min 36px tap targets) */}
      <td style={{ textAlign: 'center' }}>
        <div className="destination-actions-wrapper">
          <button
            type="button"
            onClick={() => onView(d)}
            className="destination-action-btn view-btn"
            title="Xem chi tiết địa điểm"
            aria-label={`Xem chi tiết ${d.name}`}
          >
            <EyeIcon size={15} color="#0077b6" />
          </button>

          <button
            type="button"
            onClick={() => onEdit(d)}
            className="destination-action-btn"
            title="Chỉnh sửa thông tin chi tiết"
            aria-label={`Chỉnh sửa ${d.name}`}
          >
            <PencilIcon size={15} color="#0077b6" />
          </button>

          {canDelete && (
            <button
              type="button"
              onClick={() => onDelete(d)}
              disabled={isPending}
              className="destination-action-btn delete-btn"
              title="Xóa điểm đến"
              aria-label={`Xóa ${d.name}`}
            >
              <TrashIcon size={15} color="#dc2626" />
            </button>
          )}
        </div>
      </td>
    </tr>
  );
};

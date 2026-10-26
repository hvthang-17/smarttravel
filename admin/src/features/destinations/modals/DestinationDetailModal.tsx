import React, { useState, useEffect, useMemo } from 'react';
import { Destination } from '../../../types/destination';
import { Category, resolveImageUrl } from '../../../core/categoryApi';
import { getCategoryMeta, formatVndPrice, buildGoogleMapsUrl } from '../destinationUtils';
import {
  XIcon,
  MapPinIcon,
  ClockIcon,
  PhoneIcon,
  GlobeIcon,
  StarIcon,
  ExternalLinkIcon,
  PencilIcon,
  CheckCircleIcon,
  EyeOffIcon,
} from '../../../components/Icons';

interface Props {
  isOpen: boolean;
  destination: Destination | null;
  categoriesList: Category[];
  onClose: () => void;
  onEdit: () => void;
}

export const DestinationDetailModal: React.FC<Props> = ({
  isOpen,
  destination,
  categoriesList,
  onClose,
  onEdit,
}) => {
  const [activeImgUrl, setActiveImgUrl] = useState<string>('');

  // Close on Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    if (isOpen) {
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  // Sync active image with destination
  useEffect(() => {
    if (destination) {
      setActiveImgUrl(destination.imageUrl || (destination.subImages && destination.subImages[0]) || '');
    }
  }, [destination]);

  const allGalleryImages = useMemo(() => {
    if (!destination) return [];
    const list: string[] = [];
    if (destination.imageUrl) list.push(destination.imageUrl);
    if (destination.subImages) {
      destination.subImages.forEach((url) => {
        if (url && !list.includes(url)) list.push(url);
      });
    }
    return list;
  }, [destination]);

  if (!isOpen || !destination) return null;

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  const meta = getCategoryMeta(destination.category, categoriesList);
  const CategoryIcon = meta.Icon;
  const destCode = `#DEST-${String(destination.id || 1).padStart(3, '0')}`;
  const isActive = destination.status === 'ACTIVE';
  const currentDisplayUrl = resolveImageUrl(activeImgUrl || destination.imageUrl);
  const mapsUrl = buildGoogleMapsUrl(destination.latitude, destination.longitude);

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(15, 23, 42, 0.55)',
        backdropFilter: 'blur(3px)',
        zIndex: 1150,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px',
        animation: 'fadeIn 0.2s ease-out',
      }}
      onClick={handleBackdropClick}
      role="dialog"
      aria-modal="true"
      aria-labelledby="destination-detail-title"
    >
      <div
        className="destination-modal-panel"
        style={{ width: '640px', maxWidth: '95vw', maxHeight: '90vh' }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Banner Cover Image or Fallback */}
        <div style={{ position: 'relative', width: '100%', height: '190px', backgroundColor: '#0f172a', overflow: 'hidden', flexShrink: 0 }}>
          {currentDisplayUrl ? (
            <img
              src={currentDisplayUrl}
              alt={destination.name}
              style={{ width: '100%', height: '100%', objectFit: 'cover', opacity: 0.9, transition: 'opacity 0.2s ease' }}
            />
          ) : (
            <div
              style={{
                width: '100%',
                height: '100%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: meta.bg,
              }}
            >
              <CategoryIcon size={56} color={meta.color} />
            </div>
          )}

          {/* Close button on banner */}
          <button
            type="button"
            onClick={onClose}
            aria-label="Đóng cửa sổ chi tiết"
            className="btn-action-touch"
            style={{
              position: 'absolute',
              top: '14px',
              right: '14px',
              width: '32px',
              height: '32px',
              borderRadius: '50%',
              backgroundColor: 'rgba(15, 23, 42, 0.65)',
              color: '#ffffff',
              border: 'none',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              transition: 'background-color 0.15s',
            }}
          >
            <XIcon size={16} />
          </button>

          {/* Badges on banner */}
          <div
            style={{
              position: 'absolute',
              bottom: '12px',
              left: '16px',
              right: '16px',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              flexWrap: 'wrap',
              gap: '8px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '5px',
                  backgroundColor: '#ffffff',
                  color: meta.color,
                  padding: '4px 10px',
                  borderRadius: '6px',
                  fontSize: '12px',
                  fontWeight: 700,
                  boxShadow: '0 2px 4px rgba(0,0,0,0.15)',
                }}
              >
                <CategoryIcon size={13} color={meta.color} />
                <span>{meta.label}</span>
              </span>

              <span
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '5px',
                  backgroundColor: isActive ? '#ecfdf5' : '#f1f5f9',
                  color: isActive ? '#15803d' : '#334155',
                  padding: '4px 10px',
                  borderRadius: '6px',
                  fontSize: '12px',
                  fontWeight: 600,
                  boxShadow: '0 2px 4px rgba(0,0,0,0.15)',
                }}
              >
                {isActive ? <CheckCircleIcon size={13} color="#15803d" /> : <EyeOffIcon size={13} color="#334155" />}
                <span>{isActive ? 'Đang hoạt động' : 'Tạm ẩn'}</span>
              </span>
            </div>

            <span
              style={{
                backgroundColor: 'rgba(15, 23, 42, 0.8)',
                color: '#ffffff',
                padding: '3px 8px',
                borderRadius: '6px',
                fontSize: '11.5px',
                fontFamily: 'monospace',
                fontWeight: 600,
              }}
            >
              {destCode}
            </span>
          </div>
        </div>

        {/* Thumbnail Strip if multi-images exist */}
        {allGalleryImages.length > 1 && (
          <div
            style={{
              display: 'flex',
              gap: '8px',
              padding: '8px 16px',
              backgroundColor: '#0f172a',
              overflowX: 'auto',
              borderTop: '1px solid rgba(255,255,255,0.1)',
              flexShrink: 0,
            }}
          >
            {allGalleryImages.map((img, i) => {
              const isSelected = (activeImgUrl || destination.imageUrl) === img;
              const isMain = img === destination.imageUrl;
              const thumbUrl = resolveImageUrl(img);
              return (
                <button
                  key={i}
                  type="button"
                  onClick={() => setActiveImgUrl(img)}
                  aria-label={`Xem ảnh ${isMain ? 'chính' : i + 1}`}
                  style={{
                    width: '54px',
                    height: '42px',
                    borderRadius: '6px',
                    border: isSelected ? '2px solid #38bdf8' : '1px solid rgba(255,255,255,0.25)',
                    overflow: 'hidden',
                    padding: 0,
                    cursor: 'pointer',
                    position: 'relative',
                    opacity: isSelected ? 1 : 0.6,
                    flexShrink: 0,
                    transition: 'all 0.15s ease',
                    backgroundColor: '#1e293b',
                  }}
                  title={isMain ? 'Ảnh chính' : `Ảnh phụ ${i}`}
                >
                  <img src={thumbUrl} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  {isMain && (
                    <span
                      style={{
                        position: 'absolute',
                        bottom: '2px',
                        left: '2px',
                        backgroundColor: '#f59e0b',
                        color: '#ffffff',
                        fontSize: '8px',
                        fontWeight: 700,
                        padding: '1px 3px',
                        borderRadius: '2px',
                        lineHeight: 1,
                      }}
                    >
                      Bìa
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        )}

        {/* Modal Content */}
        <div className="destination-modal-body" style={{ padding: '20px 24px' }}>
          {/* Title & Address */}
          <div style={{ marginBottom: '16px' }}>
            <h2 id="destination-detail-title" style={{ fontSize: '20px', fontWeight: 700, color: '#0f172a', margin: '0 0 6px 0' }}>
              {destination.name}
            </h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '13px', color: '#475569' }}>
              <MapPinIcon size={14} color="#0077b6" />
              <span>{destination.address || 'TP. Đà Nẵng, Việt Nam'}</span>
            </div>
          </div>

          {/* Quick Metrics Grid */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))',
              gap: '10px',
              marginBottom: '20px',
            }}
          >
            <div style={{ backgroundColor: '#fef3c7', padding: '10px 12px', borderRadius: '8px', border: '1px solid #fde68a' }}>
              <div style={{ fontSize: '11px', color: '#92400e', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '4px' }}>
                <StarIcon size={12} color="#d97706" fill="#f59e0b" />
                <span>ĐÁNH GIÁ</span>
              </div>
              <div style={{ fontSize: '16px', fontWeight: 700, color: '#92400e', marginTop: '2px' }}>
                {destination.rating != null ? Number(destination.rating).toFixed(1) : '4.5'}
                <span style={{ fontSize: '11px', fontWeight: 500, color: '#92400e', marginLeft: '4px' }}>
                  ({destination.reviewCount || 0} lượt)
                </span>
              </div>
            </div>

            <div style={{ backgroundColor: '#f0fdf4', padding: '10px 12px', borderRadius: '8px', border: '1px solid #bbf7d0' }}>
              <div style={{ fontSize: '11px', color: '#166534', fontWeight: 600 }}>CHI PHÍ THAM KHẢO</div>
              <div style={{ fontSize: '14px', fontWeight: 700, color: '#15803d', marginTop: '3px' }}>
                {formatVndPrice(destination.priceMinVnd, destination.priceMaxVnd)}
              </div>
            </div>

            <div style={{ backgroundColor: '#f0f9ff', padding: '10px 12px', borderRadius: '8px', border: '1px solid #bae6fd' }}>
              <div style={{ fontSize: '11px', color: '#0369a1', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '4px' }}>
                <ClockIcon size={12} color="#0369a1" />
                <span>GIỜ MỞ CỬA</span>
              </div>
              <div style={{ fontSize: '13px', fontWeight: 600, color: '#0369a1', marginTop: '3px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                {destination.openingHours || 'Chưa cập nhật'}
              </div>
            </div>
          </div>

          {/* Description Section */}
          <div style={{ marginBottom: '20px' }}>
            <h3 style={{ fontSize: '13px', fontWeight: 600, color: '#334155', margin: '0 0 6px 0', textTransform: 'uppercase', letterSpacing: '0.3px' }}>
              Mô tả điểm đến
            </h3>
            <div
              style={{
                fontSize: '13.5px',
                color: '#334155',
                lineHeight: '1.6',
                backgroundColor: '#f8fafc',
                padding: '12px 14px',
                borderRadius: '8px',
                border: '1px solid #e2e8f0',
              }}
            >
              {destination.description || 'Chưa có thông tin mô tả chi tiết cho địa điểm này.'}
            </div>
          </div>

          {/* Location & Coordinates Section */}
          <div style={{ marginBottom: '20px' }}>
            <h3 style={{ fontSize: '13px', fontWeight: 600, color: '#334155', margin: '0 0 8px 0', textTransform: 'uppercase', letterSpacing: '0.3px' }}>
              Tọa độ địa lý & Bản đồ
            </h3>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', backgroundColor: '#f8fafc', padding: '10px 14px', borderRadius: '8px', border: '1px solid #e2e8f0', flexWrap: 'wrap', gap: '8px' }}>
              <div style={{ fontSize: '13px', color: '#0f172a', fontFamily: 'monospace' }}>
                <strong>Vĩ độ:</strong> {Number(destination.latitude).toFixed(6)} | <strong>Kinh độ:</strong> {Number(destination.longitude).toFixed(6)}
                {destination.osmId && (
                  <span style={{ marginLeft: '10px', color: '#64748b' }}>(OSM: {destination.osmId})</span>
                )}
              </div>
              <a
                href={mapsUrl}
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '5px',
                  backgroundColor: '#0077b6',
                  color: '#ffffff',
                  padding: '6px 12px',
                  borderRadius: '6px',
                  fontSize: '12.5px',
                  fontWeight: 600,
                  textDecoration: 'none',
                  boxShadow: '0 1px 2px rgba(0, 119, 182, 0.2)',
                }}
              >
                <span>Xem Google Maps</span>
                <ExternalLinkIcon size={12} color="#ffffff" />
              </a>
            </div>
          </div>

          {/* Contact Details */}
          {(destination.phone || destination.website) && (
            <div style={{ marginBottom: '16px' }}>
              <h3 style={{ fontSize: '13px', fontWeight: 600, color: '#334155', margin: '0 0 8px 0', textTransform: 'uppercase', letterSpacing: '0.3px' }}>
                Thông tin liên hệ
              </h3>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '10px' }}>
                {destination.phone && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', color: '#0f172a' }}>
                    <PhoneIcon size={14} color="#0077b6" />
                    <a href={`tel:${destination.phone}`} style={{ color: '#0077b6', textDecoration: 'none', fontWeight: 500 }}>
                      {destination.phone}
                    </a>
                  </div>
                )}
                {destination.website && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', color: '#0f172a' }}>
                    <GlobeIcon size={14} color="#0077b6" />
                    <a href={destination.website} target="_blank" rel="noopener noreferrer" style={{ color: '#0077b6', textDecoration: 'none', fontWeight: 500, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '240px' }}>
                      {destination.website}
                    </a>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="destination-modal-footer">
          <button type="button" onClick={onClose} className="destination-btn-cancel">
            Đóng
          </button>
          <button
            type="button"
            onClick={onEdit}
            className="destination-btn-submit"
            style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
          >
            <PencilIcon size={14} color="#ffffff" />
            <span>Chỉnh sửa địa điểm này</span>
          </button>
        </div>
      </div>
    </div>
  );
};

import React, { useState } from 'react';
import {
  ExternalLinkIcon,
  SearchIcon,
  CompassIcon,
  RefreshCwIcon,
  CheckCircleIcon,
  AlertTriangleIcon,
} from '../../../components/Icons';
import { parseCoordinatesFromInput, geocodeAddressOsm } from '../destinationUtils';

interface Props {
  address: string;
  latitude: string;
  longitude: string;
  osmId: string;
  destinationName?: string;
  onChangeAddress: (val: string) => void;
  onChangeLatitude: (val: string) => void;
  onChangeLongitude: (val: string) => void;
  onChangeOsmId: (val: string) => void;
  onResetDefaultDaNang: () => void;
  disabled?: boolean;
  hasCoordError?: boolean;
}

export const DestinationLocationSection: React.FC<Props> = ({
  address,
  latitude,
  longitude,
  osmId,
  destinationName,
  onChangeAddress,
  onChangeLatitude,
  onChangeLongitude,
  onChangeOsmId,
  onResetDefaultDaNang,
  disabled = false,
  hasCoordError = false,
}) => {
  const [quickCoordInput, setQuickCoordInput] = useState('');
  const [coordFeedback, setCoordFeedback] = useState<{
    message: string;
    type: 'success' | 'error' | 'info';
  } | null>(null);
  const [isGeocoding, setIsGeocoding] = useState(false);

  const parsedLat = parseFloat(latitude);
  const parsedLng = parseFloat(longitude);
  const isValidCoordinates =
    !isNaN(parsedLat) &&
    !isNaN(parsedLng) &&
    parsedLat >= -90 &&
    parsedLat <= 90 &&
    parsedLng >= -180 &&
    parsedLng <= 180;

  // Handle instant coordinate parsing from Google Maps URLs or raw coordinates
  const handleQuickCoordChange = (value: string) => {
    setQuickCoordInput(value);
    if (!value.trim()) {
      setCoordFeedback(null);
      return;
    }

    const result = parseCoordinatesFromInput(value);
    if (result) {
      onChangeLatitude(result.latitude);
      onChangeLongitude(result.longitude);
      setCoordFeedback({
        message: `Đã nhận diện tọa độ: ${result.latitude}, ${result.longitude}`,
        type: 'success',
      });
    } else if (value.includes('http') || value.includes('maps') || value.includes(',') || value.includes('!')) {
      setCoordFeedback({
        message: 'Chưa tìm thấy tọa độ từ liên kết. Hãy thử copy đường link đầy đủ của Google Maps.',
        type: 'error',
      });
    }
  };

  // Handle automatic geocoding using OpenStreetMap Nominatim API
  const handleGeocodeFromAddress = async () => {
    const query = address.trim() || destinationName?.trim();
    if (!query) {
      setCoordFeedback({
        message: 'Vui lòng nhập Tên địa điểm hoặc Địa chỉ trước khi tìm kiếm tọa độ.',
        type: 'info',
      });
      return;
    }

    setIsGeocoding(true);
    setCoordFeedback(null);
    try {
      const res = await geocodeAddressOsm(query);
      if (res) {
        onChangeLatitude(res.latitude);
        onChangeLongitude(res.longitude);
        if (res.osmId && !osmId) {
          onChangeOsmId(res.osmId);
        }
        setCoordFeedback({
          message: `Đã định vị thành công: ${res.latitude}, ${res.longitude}`,
          type: 'success',
        });
      } else {
        setCoordFeedback({
          message: `Không tìm thấy vị trí khớp với "${query}". Bạn có thể dán trực tiếp link Google Maps vào ô bên dưới.`,
          type: 'error',
        });
      }
    } catch (err: unknown) {
      setCoordFeedback({
        message: err instanceof Error ? err.message : 'Lỗi kết nối tra cứu tọa độ trực tuyến.',
        type: 'error',
      });
    } finally {
      setIsGeocoding(false);
    }
  };

  return (
    <div className="destination-section-box">
      {/* Header with Quick Actions */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '8px' }}>
        <span style={{ fontSize: '13px', fontWeight: 600, color: '#0f172a' }}>
          Vị trí & Bản đồ
        </span>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
          <button
            type="button"
            onClick={onResetDefaultDaNang}
            disabled={disabled}
            className="destination-quick-link"
            title="Đặt tọa độ trung tâm Đà Nẵng (16.0610, 108.2274)"
          >
            Mặc định Đà Nẵng
          </button>

          <button
            type="button"
            onClick={handleGeocodeFromAddress}
            disabled={disabled || isGeocoding}
            className="destination-quick-link"
            title="Tự động tìm kiếm tọa độ từ Địa chỉ / Tên qua OpenStreetMap"
            style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}
          >
            {isGeocoding ? (
              <>
                <RefreshCwIcon size={12} className="spin-animation" color="#0077b6" />
                <span>Đang tìm...</span>
              </>
            ) : (
              <>
                <SearchIcon size={12} color="#0077b6" />
                <span>Tìm từ địa chỉ</span>
              </>
            )}
          </button>

          {isValidCoordinates && (
            <a
              href={`https://www.google.com/maps/search/?api=1&query=${parsedLat},${parsedLng}`}
              target="_blank"
              rel="noopener noreferrer"
              className="destination-external-link"
              title="Mở Google Maps kiểm tra vị trí ghim"
            >
              <span>Xem Maps</span>
              <ExternalLinkIcon size={12} color="#475569" />
            </a>
          )}
        </div>
      </div>

      {/* Quick Coordinates Assistant Box */}
      <div className="destination-coord-helper-box">
        <label className="user-form-label" style={{ fontSize: '12px', display: 'flex', alignItems: 'center', gap: '5px' }}>
          <CompassIcon size={13} color="#0077b6" />
          <span>Lấy nhanh tọa độ từ link Google Maps hoặc chuỗi số:</span>
        </label>
        <input
          type="text"
          value={quickCoordInput}
          onChange={(e) => handleQuickCoordChange(e.target.value)}
          className="user-form-input"
          placeholder="Dán link Google Maps hoặc tọa độ (VD: 16.0610, 108.2274)..."
          disabled={disabled}
          style={{ fontSize: '12.5px' }}
          aria-label="Dán link Google Maps hoặc tọa độ để tự động điền"
        />
        {coordFeedback && (
          <div role="status" className={`destination-coord-feedback ${coordFeedback.type}`}>
            {coordFeedback.type === 'success' && <CheckCircleIcon size={14} color="#15803d" />}
            {coordFeedback.type === 'error' && <AlertTriangleIcon size={14} color="#b91c1c" />}
            {coordFeedback.type === 'info' && <RefreshCwIcon size={14} color="#0369a1" />}
            <span>{coordFeedback.message}</span>
          </div>
        )}
      </div>

      {/* Address */}
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label">Địa chỉ</label>
        <input
          type="text"
          value={address}
          onChange={(e) => onChangeAddress(e.target.value)}
          className="user-form-input"
          placeholder="Số nhà, tên đường, quận/huyện..."
          disabled={disabled}
        />
      </div>

      {/* Lat & Lng */}
      <div className="destination-field-row">
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Vĩ độ (Lat) *</label>
          <input
            type="number"
            step="0.0000001"
            value={latitude}
            onChange={(e) => onChangeLatitude(e.target.value)}
            className={`user-form-input ${hasCoordError ? 'input-field-error' : ''}`}
            placeholder="16.0610"
            required
            disabled={disabled}
            aria-invalid={hasCoordError}
          />
        </div>
        <div className="user-form-group" style={{ marginBottom: 0 }}>
          <label className="user-form-label">Kinh độ (Lng) *</label>
          <input
            type="number"
            step="0.0000001"
            value={longitude}
            onChange={(e) => onChangeLongitude(e.target.value)}
            className={`user-form-input ${hasCoordError ? 'input-field-error' : ''}`}
            placeholder="108.2274"
            required
            disabled={disabled}
            aria-invalid={hasCoordError}
          />
        </div>
      </div>

      {/* OSM ID */}
      <div className="user-form-group" style={{ marginBottom: 0 }}>
        <label className="user-form-label">Mã OpenStreetMap (tùy chọn)</label>
        <input
          type="text"
          value={osmId}
          onChange={(e) => onChangeOsmId(e.target.value)}
          className="user-form-input"
          placeholder="VD: way/304384"
          disabled={disabled}
        />
      </div>
    </div>
  );
};

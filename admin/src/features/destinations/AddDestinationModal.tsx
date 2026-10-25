import React, { useState, useEffect } from 'react';
import { Destination } from '../../types/destination';
import { MapPinIcon, ClockIcon, XIcon } from '../../components/Icons';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: Omit<Destination, 'id'>) => Promise<void>;
}

const CATEGORIES = [
  'Tham quan / Văn hóa',
  'Ẩm thực',
  'Biển / Tham quan',
  'Sống ảo',
  'Cafe',
  'Khách sạn & Lưu trú',
  'Giải trí',
];

export const AddDestinationModal: React.FC<Props> = ({ isOpen, onClose, onSubmit }) => {
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Tham quan / Văn hóa');
  const [costText, setCostText] = useState('Miễn phí');
  const [address, setAddress] = useState('');
  const [openingHours, setOpeningHours] = useState('08:00 - 22:00');
  const [gps, setGps] = useState('16.0612, 108.2321');
  const [description, setDescription] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // R-32: Keyboard accessibility - close modal with Escape key
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

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) { setError('Vui lòng nhập tên địa điểm.'); return; }
    if (!address.trim()) { setError('Vui lòng nhập địa chỉ đầy đủ.'); return; }

    const parts = gps.split(',').map((p) => p.trim());
    const lat = parseFloat(parts[0] || '16.0544');
    const lng = parseFloat(parts[1] || '108.2022');
    if (isNaN(lat) || isNaN(lng)) {
      setError('Tọa độ GPS không hợp lệ (định dạng: lat, lng).');
      return;
    }

    let minPrice = 0;
    const cleanCost = costText.replace(/[^\d]/g, '');
    if (cleanCost) {
      minPrice = parseInt(cleanCost, 10);
    }

    try {
      setLoading(true);
      setError(null);
      await onSubmit({
        name: name.trim(),
        category,
        address: address.trim(),
        openingHours: openingHours.trim(),
        latitude: lat,
        longitude: lng,
        priceMinVnd: minPrice,
        priceMaxVnd: minPrice,
        description: description.trim() || undefined,
        imageUrl: imageUrl.trim() || undefined,
        status: 'ACTIVE',
      });
      onClose();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Lỗi khi tạo địa điểm');
    } finally {
      setLoading(false);
    }
  };

  const inputStyle: React.CSSProperties = {
    width: '100%',
    padding: '9px 12px',
    borderRadius: '8px',
    border: '1px solid #cbd5e1',
    fontSize: '13.5px',
    color: '#0f172a',
    backgroundColor: '#ffffff',
    outline: 'none',
  };

  const labelStyle: React.CSSProperties = {
    display: 'block',
    fontSize: '13px',
    fontWeight: 600,
    color: '#334155',
    marginBottom: '6px',
  };

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(15, 23, 42, 0.45)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
        backdropFilter: 'blur(3px)',
      }}
      role="dialog"
      aria-modal="true"
      aria-labelledby="add-destination-modal-title"
    >
      <div
        className="animate-fade-in"
        style={{
          background: '#ffffff',
          borderRadius: '12px',
          width: '560px',
          maxWidth: '92%',
          boxShadow: '0 20px 40px rgba(0, 0, 0, 0.2)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '92vh',
        }}
      >
        {/* Header */}
        <div style={{ padding: '20px 24px', borderBottom: '1px solid #f1f5f9', display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '8px',
                backgroundColor: '#e0f2fe',
                color: '#0284c7',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <MapPinIcon size={18} color="#0284c7" />
            </div>
            <div>
              <h3 id="add-destination-modal-title" style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: '#0f172a' }}>
                Thêm địa điểm Đà Nẵng mới
              </h3>
              <p style={{ margin: '2px 0 0 0', fontSize: '12px', color: '#475569' }}>
                Thông tin sẽ cập nhật vào hệ thống gợi ý lịch trình AI
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="btn-action-touch"
            style={{ border: 'none', background: 'none', color: '#475569', cursor: 'pointer', padding: '6px', borderRadius: '6px' }}
            aria-label="Đóng hộp thoại"
          >
            <XIcon size={18} color="#475569" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} style={{ padding: '24px', overflowY: 'auto', flex: 1 }}>
          {error && (
            <div style={{ backgroundColor: '#fee2e2', color: '#991b1b', padding: '10px 14px', borderRadius: '8px', fontSize: '13px', marginBottom: '16px' }}>
              {error}
            </div>
          )}

          <div style={{ marginBottom: '14px' }}>
            <label style={labelStyle}>Tên địa điểm *</label>
            <input
              type="text"
              placeholder="Ví dụ: Chợ Đêm Sơn Trà"
              value={name}
              onChange={(e) => setName(e.target.value)}
              style={inputStyle}
            />
          </div>

          <div style={{ display: 'flex', gap: '12px', marginBottom: '14px' }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Danh mục *</label>
              <select value={category} onChange={(e) => setCategory(e.target.value)} style={inputStyle}>
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Chi phí tham khảo (VNĐ) *</label>
              <input
                type="text"
                placeholder="Ví dụ: 50.000 hoặc Miễn phí"
                value={costText}
                onChange={(e) => setCostText(e.target.value)}
                style={inputStyle}
              />
            </div>
          </div>

          <div style={{ marginBottom: '14px' }}>
            <label style={labelStyle}>Địa chỉ đầy đủ (Đà Nẵng) *</label>
            <input
              type="text"
              placeholder="Ví dụ: Đường Mai Hắc Đế, An Hải Trung, Sơn Trà, Đà Nẵng"
              value={address}
              onChange={(e) => setAddress(e.target.value)}
              style={inputStyle}
            />
          </div>

          <div style={{ display: 'flex', gap: '12px', marginBottom: '14px' }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Giờ mở cửa</label>
              <input
                type="text"
                placeholder="08:00 - 22:00"
                value={openingHours}
                onChange={(e) => setOpeningHours(e.target.value)}
                style={inputStyle}
              />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Tọa độ GPS (Lat, Lng)</label>
              <input
                type="text"
                placeholder="16.0612, 108.2321"
                value={gps}
                onChange={(e) => setGps(e.target.value)}
                style={inputStyle}
              />
            </div>
          </div>

          <div style={{ marginBottom: '14px' }}>
            <label style={labelStyle}>URL Ảnh đại diện</label>
            <input
              type="url"
              placeholder="https://images.unsplash.com/photo-..."
              value={imageUrl}
              onChange={(e) => setImageUrl(e.target.value)}
              style={inputStyle}
            />
          </div>

          <div style={{ marginBottom: '6px' }}>
            <label style={labelStyle}>Mô tả ngắn gọn</label>
            <textarea
              rows={3}
              placeholder="Mô tả đặc trưng phục vụ thuật toán chấm điểm sở thích..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              style={{ ...inputStyle, resize: 'vertical' }}
            />
          </div>

          {/* Footer Controls */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              marginTop: '20px',
              paddingTop: '16px',
              borderTop: '1px solid #f1f5f9',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: '#475569' }}>
              <ClockIcon size={13} color="#475569" />
              <span>Ghi nhận tức thời vào nhật ký hệ thống</span>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                type="button"
                onClick={onClose}
                className="btn-action-touch"
                style={{
                  padding: '9px 18px',
                  borderRadius: '8px',
                  border: '1px solid #cbd5e1',
                  background: '#ffffff',
                  color: '#475569',
                  fontWeight: 600,
                  fontSize: '13.5px',
                  cursor: 'pointer',
                }}
              >
                Hủy
              </button>
              <button
                type="submit"
                disabled={loading}
                className="btn-action-touch"
                style={{
                  padding: '9px 20px',
                  borderRadius: '8px',
                  border: 'none',
                  background: '#0077b6',
                  color: '#ffffff',
                  fontWeight: 600,
                  fontSize: '13.5px',
                  cursor: loading ? 'not-allowed' : 'pointer',
                }}
              >
                {loading ? 'Đang lưu...' : 'Lưu địa điểm'}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

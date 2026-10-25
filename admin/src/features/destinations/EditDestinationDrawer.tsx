import React, { useState, useEffect } from 'react';
import { Destination } from '../../types/destination';
import {
  PencilIcon,
  InfoIcon,
  MapPinIcon,
  CheckIcon,
  PlusIcon,
  ExternalLinkIcon,
  XIcon,
} from '../../components/Icons';

interface Props {
  isOpen: boolean;
  destination: Destination | null;
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

const AVAILABLE_TAGS = ['Thiên nhiên', 'Ngắm cảnh', 'Tâm linh', 'Đi bộ', 'Biển', 'Lịch sử', 'Ẩm thực', 'Check-in'];

export const EditDestinationDrawer: React.FC<Props> = ({ isOpen, destination, onClose, onSubmit }) => {
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Tham quan / Văn hóa');
  const [selectedTags, setSelectedTags] = useState<string[]>(['Thiên nhiên', 'Ngắm cảnh']);
  const [address, setAddress] = useState('');
  const [latitude, setLatitude] = useState('16.0544');
  const [longitude, setLongitude] = useState('108.2022');
  const [openingHours, setOpeningHours] = useState('');
  const [priceMinVnd, setPriceMinVnd] = useState('0');
  const [imageUrl, setImageUrl] = useState('');
  const [description, setDescription] = useState('');
  const [status, setStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // R-32: Keyboard accessibility - close drawer with Escape key
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

  useEffect(() => {
    if (destination) {
      setName(destination.name || '');
      setCategory(destination.category || 'Tham quan / Văn hóa');
      setAddress(destination.address || '');
      setLatitude(String(destination.latitude ?? '16.0544'));
      setLongitude(String(destination.longitude ?? '108.2022'));
      setOpeningHours(destination.openingHours || '');
      setPriceMinVnd(String(destination.priceMinVnd ?? 0));
      setImageUrl(destination.imageUrl || '');
      setDescription(destination.description || '');
      setStatus(destination.status || 'ACTIVE');
      setError(null);
    }
  }, [destination]);

  if (!isOpen || !destination) return null;

  const toggleTag = (tag: string) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter((t) => t !== tag));
    } else {
      setSelectedTags([...selectedTags, tag]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) { setError('Tên địa điểm không được để trống.'); return; }
    const lat = parseFloat(latitude), lng = parseFloat(longitude);
    if (isNaN(lat) || isNaN(lng)) { setError('Tọa độ GPS không hợp lệ.'); return; }

    try {
      setLoading(true);
      setError(null);
      await onSubmit({
        name: name.trim(),
        category,
        address: address.trim() || undefined,
        latitude: lat,
        longitude: lng,
        openingHours: openingHours.trim() || undefined,
        priceMinVnd: parseInt(priceMinVnd, 10) || 0,
        priceMaxVnd: parseInt(priceMinVnd, 10) || 0,
        imageUrl: imageUrl.trim() || undefined,
        description: description.trim() || undefined,
        status,
      });
      onClose();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Lỗi khi cập nhật');
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

  const destCode = `#DEST-${String(destination.id || 1).padStart(3, '0')}`;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(15, 23, 42, 0.4)',
        zIndex: 1050,
        display: 'flex',
        justifyContent: 'flex-end',
        backdropFilter: 'blur(3px)',
      }}
      role="dialog"
      aria-modal="true"
      aria-labelledby="edit-drawer-title"
    >
      <div
        className="animate-slide-right"
        style={{
          width: '580px',
          maxWidth: '100%',
          backgroundColor: '#ffffff',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          boxShadow: '-10px 0 30px rgba(0, 0, 0, 0.15)',
        }}
      >
        {/* Header */}
        <div
          style={{
            padding: '20px 24px',
            borderBottom: '1px solid #f1f5f9',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
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
              <PencilIcon size={18} color="#0284c7" />
            </div>
            <div>
              <h3 id="edit-drawer-title" style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: '#0f172a' }}>
                Chỉnh sửa: {destination.name}
              </h3>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '2px', fontSize: '12px', color: '#475569' }}>
                <span style={{ fontWeight: 600, color: '#0077b6' }}>{destCode}</span>
                <span>•</span>
                <span>Chỉnh sửa thông tin địa điểm</span>
              </div>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="btn-action-touch"
            style={{ border: 'none', background: 'none', color: '#475569', cursor: 'pointer', padding: '6px', borderRadius: '6px' }}
            aria-label="Đóng ngăn kéo"
          >
            <XIcon size={18} color="#475569" />
          </button>
        </div>

        {/* Content Body */}
        <form onSubmit={handleSubmit} style={{ padding: '24px', overflowY: 'auto', flex: 1 }}>
          {error && (
            <div style={{ backgroundColor: '#fee2e2', color: '#991b1b', padding: '10px 14px', borderRadius: '8px', fontSize: '13px', marginBottom: '16px' }}>
              {error}
            </div>
          )}

          {/* Section 1: Thông tin cơ bản */}
          <div style={{ marginBottom: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <span style={{ fontSize: '13.5px', fontWeight: 700, color: '#0f172a', display: 'flex', alignItems: 'center', gap: '6px' }}>
                <InfoIcon size={15} color="#0077b6" />
                <span>Thông tin cơ bản</span>
              </span>
              <span style={{ fontSize: '11px', fontWeight: 600, backgroundColor: '#fef2f2', color: '#dc2626', padding: '2px 8px', borderRadius: '4px' }}>
                Bắt buộc
              </span>
            </div>

            <div style={{ marginBottom: '12px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '4px' }}>
                Tên địa điểm *
              </label>
              <input type="text" value={name} onChange={(e) => setName(e.target.value)} style={inputStyle} />
            </div>

            <div style={{ marginBottom: '14px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '4px' }}>
                Danh mục chính *
              </label>
              <select value={category} onChange={(e) => setCategory(e.target.value)} style={inputStyle}>
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>

            {/* Interest Tags (R-07: standardized 6px border radius) */}
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '8px' }}>
                <span style={{ fontWeight: 600, color: '#334155' }}>Thẻ sở thích (Interests Tags)</span>
                <span style={{ color: '#475569' }}>Đã chọn: {selectedTags.length} thẻ</span>
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                {AVAILABLE_TAGS.map((tag) => {
                  const isChecked = selectedTags.includes(tag);
                  return (
                    <button
                      key={tag}
                      type="button"
                      onClick={() => toggleTag(tag)}
                      className="btn-action-touch"
                      style={{
                        padding: '4px 10px',
                        borderRadius: '6px',
                        border: isChecked ? '1px solid #0077b6' : '1px solid #cbd5e1',
                        backgroundColor: isChecked ? '#e0f2fe' : '#ffffff',
                        color: isChecked ? '#0369a1' : '#334155',
                        fontSize: '12px',
                        fontWeight: 600,
                        cursor: 'pointer',
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '4px',
                      }}
                    >
                      {isChecked && <CheckIcon size={12} color="#0077b6" />}
                      <span>{tag}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Section 2: Vị trí & Giờ mở cửa */}
          <div style={{ marginBottom: '24px', paddingTop: '16px', borderTop: '1px solid #f1f5f9' }}>
            <span style={{ fontSize: '13.5px', fontWeight: 700, color: '#0f172a', display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '12px' }}>
              <MapPinIcon size={15} color="#0077b6" />
              <span>Vị trí & Thông tin bổ sung</span>
            </span>

            <div style={{ marginBottom: '12px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '4px' }}>
                Địa chỉ thực tế
              </label>
              <input type="text" value={address} onChange={(e) => setAddress(e.target.value)} style={inputStyle} />
            </div>

            <div style={{ display: 'flex', gap: '10px', marginBottom: '12px' }}>
              <div style={{ flex: 1 }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#475569', marginBottom: '4px' }}>
                  Vĩ độ (Latitude)
                </label>
                <input type="text" value={latitude} onChange={(e) => setLatitude(e.target.value)} style={inputStyle} />
              </div>
              <div style={{ flex: 1 }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#475569', marginBottom: '4px' }}>
                  Kinh độ (Longitude)
                </label>
                <input type="text" value={longitude} onChange={(e) => setLongitude(e.target.value)} style={inputStyle} />
              </div>
            </div>

            <div style={{ display: 'flex', gap: '10px', marginBottom: '12px' }}>
              <div style={{ flex: 1 }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#475569', marginBottom: '4px' }}>
                  Giờ mở cửa
                </label>
                <input type="text" value={openingHours} onChange={(e) => setOpeningHours(e.target.value)} style={inputStyle} />
              </div>
              <div style={{ flex: 1 }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: 600, color: '#475569', marginBottom: '4px' }}>
                  Giá vé tối thiểu (VNĐ)
                </label>
                <input type="number" value={priceMinVnd} onChange={(e) => setPriceMinVnd(e.target.value)} style={inputStyle} />
              </div>
            </div>

            <div style={{ marginBottom: '12px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '4px' }}>
                URL Ảnh đại diện
              </label>
              <input type="url" value={imageUrl} onChange={(e) => setImageUrl(e.target.value)} style={inputStyle} />
            </div>

            <div style={{ marginBottom: '12px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '4px' }}>
                Mô tả chi tiết
              </label>
              <textarea rows={3} value={description} onChange={(e) => setDescription(e.target.value)} style={{ ...inputStyle, resize: 'vertical' }} />
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <label style={{ fontSize: '13px', fontWeight: 600, color: '#334155' }}>Trạng thái hoạt động:</label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value as 'ACTIVE' | 'INACTIVE')}
                style={{ padding: '6px 12px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '13px', backgroundColor: '#ffffff', color: '#0f172a' }}
              >
                <option value="ACTIVE">ACTIVE (Hiển thị)</option>
                <option value="INACTIVE">INACTIVE (Tạm ẩn)</option>
              </select>
            </div>
          </div>

          {/* Footer Controls */}
          <div
            style={{
              paddingTop: '16px',
              borderTop: '1px solid #f1f5f9',
              display: 'flex',
              justifyContent: 'flex-end',
              gap: '10px',
            }}
          >
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
                padding: '9px 22px',
                borderRadius: '8px',
                border: 'none',
                background: '#0077b6',
                color: '#ffffff',
                fontWeight: 600,
                fontSize: '13.5px',
                cursor: loading ? 'not-allowed' : 'pointer',
              }}
            >
              {loading ? 'Đang lưu...' : 'Lưu thay đổi'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

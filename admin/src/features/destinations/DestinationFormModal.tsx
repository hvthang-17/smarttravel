import React, { useState, useEffect } from 'react';
import { Destination } from '../../types/destination';

interface Props {
  isOpen: boolean;
  initialData?: Destination | null;
  onClose: () => void;
  onSubmit: (data: Omit<Destination, 'id'>) => Promise<void>;
}

export const DestinationFormModal: React.FC<Props> = ({ isOpen, initialData, onClose, onSubmit }) => {
  const [name, setName] = useState('');
  const [category, setCategory] = useState('Tham quan');
  const [description, setDescription] = useState('');
  const [latitude, setLatitude] = useState('16.0544');
  const [longitude, setLongitude] = useState('108.2022');
  const [priceMinVnd, setPriceMinVnd] = useState('0');
  const [priceMaxVnd, setPriceMaxVnd] = useState('0');
  const [status, setStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (initialData) {
      setName(initialData.name); setCategory(initialData.category);
      setDescription(initialData.description || '');
      setLatitude(String(initialData.latitude)); setLongitude(String(initialData.longitude));
      setPriceMinVnd(String(initialData.priceMinVnd ?? 0)); setPriceMaxVnd(String(initialData.priceMaxVnd ?? 0));
      setStatus(initialData.status);
    } else {
      setName(''); setCategory('Tham quan'); setDescription('');
      setLatitude('16.0544'); setLongitude('108.2022');
      setPriceMinVnd('0'); setPriceMaxVnd('0'); setStatus('ACTIVE');
    }
    setError(null);
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const validate = (): Omit<Destination, 'id'> | null => {
    if (!name.trim()) { setError('Tên không được trống.'); return null; }
    const lat = parseFloat(latitude), lng = parseFloat(longitude);
    if (isNaN(lat) || lat < -90 || lat > 90) { setError('Vĩ độ [-90, 90].'); return null; }
    if (isNaN(lng) || lng < -180 || lng > 180) { setError('Kinh độ [-180, 180].'); return null; }
    const minP = parseInt(priceMinVnd), maxP = parseInt(priceMaxVnd);
    if (isNaN(minP) || minP < 0) { setError('Giá min >= 0.'); return null; }
    if (isNaN(maxP) || maxP < 0) { setError('Giá max >= 0.'); return null; }
    return { name: name.trim(), category, description: description.trim() || undefined, latitude: lat, longitude: lng, priceMinVnd: minP, priceMaxVnd: maxP, status };
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setError(null);
    const data = validate(); if (!data) return;
    try { setLoading(true); await onSubmit(data); onClose(); }
    catch (err: unknown) { setError(err instanceof Error ? err.message : 'Lỗi lưu.'); }
    finally { setLoading(false); }
  };

  const inputStyle = { width: '100%', padding: '8px', borderRadius: '6px', border: '1px solid #ccc', boxSizing: 'border-box' as const };
  const labelStyle = { display: 'block' as const, marginBottom: '4px', fontWeight: 600 as const };

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
      <div style={{ background: '#fff', borderRadius: '12px', width: '480px', maxWidth: '90%', padding: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
          <h3 style={{ margin: 0 }}>{initialData ? 'Sửa địa điểm' : 'Thêm địa điểm mới'}</h3>
          <button onClick={onClose} style={{ border: 'none', background: 'none', fontSize: '20px', cursor: 'pointer' }}>×</button>
        </div>
        {error && <div style={{ background: '#ffebee', color: '#c62828', padding: '8px 12px', borderRadius: '6px', marginBottom: '12px', fontSize: '13px' }}>{error}</div>}
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '10px' }}>
            <label style={labelStyle}>Tên địa điểm *</label>
            <input type="text" value={name} onChange={(e) => setName(e.target.value)} style={inputStyle} />
          </div>
          <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Danh mục *</label>
              <select value={category} onChange={(e) => setCategory(e.target.value)} style={inputStyle}>
                {['Tham quan','Ăn uống','Lưu trú','Giải trí'].map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Trạng thái</label>
              <select value={status} onChange={(e) => setStatus(e.target.value as 'ACTIVE'|'INACTIVE')} style={inputStyle}>
                <option value="ACTIVE">ACTIVE</option><option value="INACTIVE">INACTIVE</option>
              </select>
            </div>
          </div>
          <div style={{ marginBottom: '10px' }}>
            <label style={labelStyle}>Mô tả</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} rows={2} style={inputStyle} />
          </div>
          <div style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
            <div style={{ flex: 1 }}><label style={labelStyle}>Vĩ độ *</label><input type="text" value={latitude} onChange={(e) => setLatitude(e.target.value)} style={inputStyle} /></div>
            <div style={{ flex: 1 }}><label style={labelStyle}>Kinh độ *</label><input type="text" value={longitude} onChange={(e) => setLongitude(e.target.value)} style={inputStyle} /></div>
          </div>
          <div style={{ display: 'flex', gap: '10px', marginBottom: '18px' }}>
            <div style={{ flex: 1 }}><label style={labelStyle}>Giá min (VNĐ)</label><input type="number" value={priceMinVnd} onChange={(e) => setPriceMinVnd(e.target.value)} style={inputStyle} /></div>
            <div style={{ flex: 1 }}><label style={labelStyle}>Giá max (VNĐ)</label><input type="number" value={priceMaxVnd} onChange={(e) => setPriceMaxVnd(e.target.value)} style={inputStyle} /></div>
          </div>
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
            <button type="button" onClick={onClose} style={{ padding: '8px 16px', borderRadius: '6px', border: '1px solid #ccc', background: '#fff', cursor: 'pointer' }}>Hủy</button>
            <button type="submit" disabled={loading} style={{ padding: '8px 18px', borderRadius: '6px', border: 'none', background: '#00796b', color: '#fff', fontWeight: 600, cursor: loading ? 'not-allowed' : 'pointer' }}>
              {loading ? 'Đang lưu...' : 'Lưu'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};


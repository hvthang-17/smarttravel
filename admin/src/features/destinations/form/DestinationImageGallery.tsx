import React, { useState } from 'react';
import { resolveImageUrl } from '../../../core/categoryApi';
import { uploadDestinationImage, uploadDestinationMultipleImages } from '../../../core/api';
import {
  ImageIcon,
  PlusIcon,
  XIcon,
  StarIcon,
  AlertTriangleIcon,
} from '../../../components/Icons';

interface Props {
  mainImage: string;
  subImages: string[];
  onChange: (mainImage: string, subImages: string[]) => void;
}

export const DestinationImageGallery: React.FC<Props> = ({
  mainImage,
  subImages,
  onChange,
}) => {
  const [newSubUrl, setNewSubUrl] = useState('');
  const [uploadingMain, setUploadingMain] = useState(false);
  const [uploadingSub, setUploadingSub] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleUploadMain = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    try {
      setUploadingMain(true);
      setError(null);
      const res = await uploadDestinationImage(file);
      onChange(res.url, subImages);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Không thể tải ảnh lên');
    } finally {
      setUploadingMain(false);
    }
  };

  const handleUploadMultipleSub = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files ? Array.from(e.target.files) : [];
    if (files.length === 0) return;
    try {
      setUploadingSub(true);
      setError(null);
      const urls = await uploadDestinationMultipleImages(files);
      onChange(mainImage, [...subImages, ...urls]);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Không thể tải ảnh phụ');
    } finally {
      setUploadingSub(false);
    }
  };

  const handleAddSubUrl = () => {
    const url = newSubUrl.trim();
    if (!url) return;
    if (subImages.includes(url) || url === mainImage) {
      setError('Đường dẫn ảnh đã tồn tại trong danh sách');
      return;
    }
    onChange(mainImage, [...subImages, url]);
    setNewSubUrl('');
    setError(null);
  };

  const handleRemoveSub = (idx: number) => {
    onChange(mainImage, subImages.filter((_, i) => i !== idx));
  };

  const handlePromoteToMain = (url: string, idx: number) => {
    const nextSubs = [...subImages];
    if (mainImage) {
      nextSubs[idx] = mainImage;
    } else {
      nextSubs.splice(idx, 1);
    }
    onChange(url, nextSubs);
  };

  const resolvedMain = resolveImageUrl(mainImage);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
      {error && (
        <div
          role="alert"
          style={{
            padding: '8px 12px',
            backgroundColor: '#fef2f2',
            border: '1px solid #fecaca',
            borderRadius: '6px',
            color: '#b91c1c',
            fontSize: '12.5px',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <AlertTriangleIcon size={14} color="#b91c1c" />
          <span>{error}</span>
        </div>
      )}

      {/* Ảnh đại diện */}
      <div>
        <label className="user-form-label" style={{ marginBottom: '6px' }}>
          Ảnh đại diện
        </label>

        {resolvedMain ? (
          <div
            style={{
              position: 'relative',
              width: '100%',
              height: '140px',
              borderRadius: '8px',
              overflow: 'hidden',
              backgroundColor: '#0f172a',
              border: '1px solid #cbd5e1',
            }}
          >
            <img
              src={resolvedMain}
              alt="Ảnh đại diện điểm đến"
              style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              onError={(e) => {
                (e.target as HTMLElement).style.display = 'none';
              }}
            />
            <div
              style={{
                position: 'absolute',
                top: '8px',
                right: '8px',
                display: 'flex',
                gap: '6px',
              }}
            >
              <input
                type="file"
                accept="image/*"
                id="change-cover-file"
                onChange={handleUploadMain}
                style={{ display: 'none' }}
              />
              <label
                htmlFor="change-cover-file"
                title="Đổi ảnh đại diện"
                aria-label="Đổi ảnh đại diện từ máy tính"
                className="btn-action-touch"
                style={{
                  height: '28px',
                  padding: '0 8px',
                  borderRadius: '6px',
                  backgroundColor: 'rgba(15, 23, 42, 0.75)',
                  color: '#ffffff',
                  fontSize: '12px',
                  fontWeight: 500,
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '4px',
                  cursor: 'pointer',
                  border: 'none',
                }}
              >
                <span>{uploadingMain ? 'Đang tải...' : 'Đổi ảnh'}</span>
              </label>

              <button
                type="button"
                onClick={() => onChange('', subImages)}
                aria-label="Xóa ảnh đại diện"
                title="Xóa ảnh đại diện"
                className="btn-action-touch"
                style={{
                  width: '28px',
                  height: '28px',
                  borderRadius: '6px',
                  backgroundColor: 'rgba(220, 38, 38, 0.85)',
                  color: '#ffffff',
                  border: 'none',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                }}
              >
                <XIcon size={14} />
              </button>
            </div>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <div
              style={{
                width: '100%',
                height: '110px',
                borderRadius: '8px',
                border: '1.5px dashed #cbd5e1',
                backgroundColor: '#f8fafc',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
              }}
            >
              <input
                type="file"
                accept="image/*"
                id="main-cover-upload"
                onChange={handleUploadMain}
                style={{ display: 'none' }}
              />
              <label
                htmlFor="main-cover-upload"
                className="destination-upload-btn btn-action-touch"
                style={{
                  backgroundColor: '#ffffff',
                  borderColor: '#cbd5e1',
                  color: '#0f172a',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '6px',
                }}
              >
                <ImageIcon size={15} color="#0077b6" />
                <span>{uploadingMain ? 'Đang tải ảnh...' : 'Tải ảnh từ máy tính'}</span>
              </label>
            </div>

            <input
              type="text"
              value={mainImage}
              onChange={(e) => onChange(e.target.value, subImages)}
              placeholder="Hoặc dán URL ảnh trực tiếp..."
              className="user-form-input"
              style={{ fontSize: '12.5px', padding: '7px 10px' }}
            />
          </div>
        )}
      </div>

      {/* Ảnh phụ */}
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
          <label className="user-form-label" style={{ margin: 0 }}>
            Ảnh phụ {subImages.length > 0 && `(${subImages.length})`}
          </label>
        </div>

        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', alignItems: 'center', marginBottom: '8px' }}>
          {subImages.map((imgUrl, idx) => {
            const resolvedSub = resolveImageUrl(imgUrl);
            return (
              <div
                key={idx}
                style={{
                  position: 'relative',
                  width: '60px',
                  height: '60px',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  overflow: 'hidden',
                  backgroundColor: '#f1f5f9',
                  flexShrink: 0,
                }}
              >
                <img
                  src={resolvedSub}
                  alt={`Ảnh phụ ${idx + 1}`}
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  onError={(e) => {
                    (e.target as HTMLElement).style.display = 'none';
                  }}
                />
                <div
                  style={{
                    position: 'absolute',
                    inset: 0,
                    backgroundColor: 'rgba(15, 23, 42, 0.65)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '4px',
                    opacity: 0,
                    transition: 'opacity 0.15s ease',
                  }}
                  onMouseEnter={(e) => { e.currentTarget.style.opacity = '1'; }}
                  onMouseLeave={(e) => { e.currentTarget.style.opacity = '0'; }}
                  onFocus={(e) => { e.currentTarget.style.opacity = '1'; }}
                  onBlur={(e) => { e.currentTarget.style.opacity = '0'; }}
                >
                  <button
                    type="button"
                    onClick={() => handlePromoteToMain(imgUrl, idx)}
                    title="Đặt làm ảnh chính"
                    aria-label={`Đặt ảnh phụ ${idx + 1} làm ảnh đại diện`}
                    style={{
                      width: '24px',
                      height: '24px',
                      borderRadius: '4px',
                      backgroundColor: '#f59e0b',
                      color: '#ffffff',
                      border: 'none',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                  >
                    <StarIcon size={12} color="#ffffff" />
                  </button>

                  <button
                    type="button"
                    onClick={() => handleRemoveSub(idx)}
                    title="Xóa ảnh này"
                    aria-label={`Xóa ảnh phụ ${idx + 1}`}
                    style={{
                      width: '24px',
                      height: '24px',
                      borderRadius: '4px',
                      backgroundColor: '#dc2626',
                      color: '#ffffff',
                      border: 'none',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      cursor: 'pointer',
                    }}
                  >
                    <XIcon size={12} />
                  </button>
                </div>
              </div>
            );
          })}

          {/* Nút thêm ảnh từ máy tính */}
          <div>
            <input
              type="file"
              multiple
              accept="image/*"
              id="sub-file-picker"
              onChange={handleUploadMultipleSub}
              style={{ display: 'none' }}
            />
            <label
              htmlFor="sub-file-picker"
              title="Thêm ảnh từ máy tính"
              style={{
                width: '60px',
                height: '60px',
                borderRadius: '6px',
                border: '1.5px dashed #94a3b8',
                backgroundColor: '#ffffff',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                color: '#475569',
                transition: 'all 0.15s',
                flexShrink: 0,
              }}
            >
              <PlusIcon size={16} color="#475569" />
              <span style={{ fontSize: '10px', marginTop: '2px', fontWeight: 600 }}>
                {uploadingSub ? 'Tải...' : 'Thêm'}
              </span>
            </label>
          </div>
        </div>

        {/* Thêm link URL phụ */}
        <div style={{ display: 'flex', gap: '6px' }}>
          <input
            type="text"
            value={newSubUrl}
            onChange={(e) => setNewSubUrl(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                e.preventDefault();
                handleAddSubUrl();
              }
            }}
            placeholder="Dán link ảnh phụ rồi nhấn Enter..."
            className="user-form-input"
            style={{ fontSize: '12px', padding: '6px 9px', flex: 1 }}
          />
          <button
            type="button"
            onClick={handleAddSubUrl}
            className="btn-action-touch"
            style={{
              padding: '6px 12px',
              borderRadius: '6px',
              border: '1px solid #cbd5e1',
              backgroundColor: '#f8fafc',
              color: '#334155',
              fontSize: '12px',
              fontWeight: 600,
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            Thêm
          </button>
        </div>
      </div>
    </div>
  );
};

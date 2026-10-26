import React, { useState, useEffect, useRef } from 'react';
import { Destination } from '../../../types/destination';
import { Category } from '../../../core/categoryApi';
import { XIcon, AlertTriangleIcon } from '../../../components/Icons';
import { DestinationBasicInfoSection } from './DestinationBasicInfoSection';
import { DestinationImageGallery } from './DestinationImageGallery';
import { DestinationLocationSection } from './DestinationLocationSection';
import { DestinationOperationalSection } from './DestinationOperationalSection';
import { DestinationStarRating } from './DestinationStarRating';

interface Props {
  isOpen: boolean;
  mode: 'create' | 'edit';
  destination?: Destination | null;
  categoriesList: Category[];
  onClose: () => void;
  onSubmit: (data: Omit<Destination, 'id'>) => Promise<void>;
}

export const DestinationFormModal: React.FC<Props> = ({
  isOpen,
  mode,
  destination,
  categoriesList,
  onClose,
  onSubmit,
}) => {
  const [name, setName] = useState('');
  const [category, setCategory] = useState('');
  const [categoryId, setCategoryId] = useState<number | undefined>(undefined);
  const [description, setDescription] = useState('');
  const [address, setAddress] = useState('');
  const [latitude, setLatitude] = useState('16.0610');
  const [longitude, setLongitude] = useState('108.2274');
  const [osmId, setOsmId] = useState('');
  const [openingHours, setOpeningHours] = useState('07:30 - 21:00');
  const [phone, setPhone] = useState('');
  const [website, setWebsite] = useState('');
  const [priceMinVnd, setPriceMinVnd] = useState('0');
  const [priceMaxVnd, setPriceMaxVnd] = useState('0');
  const [rating, setRating] = useState('0');
  const [reviewCount, setReviewCount] = useState('0');
  const [imageUrl, setImageUrl] = useState('');
  const [subImages, setSubImages] = useState<string[]>([]);
  const [status, setStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [hasCoordError, setHasCoordError] = useState(false);

  const modalBodyRef = useRef<HTMLDivElement>(null);

  // Sync form values on open
  useEffect(() => {
    if (!isOpen) return;
    const isEdit = mode === 'edit' && !!destination;
    setName(isEdit ? destination.name || '' : '');
    setCategory(isEdit ? destination.category || (categoriesList[0]?.name || 'Culture') : (categoriesList[0]?.name || 'Culture'));
    setCategoryId(isEdit ? destination.categoryId : categoriesList[0]?.id);
    setDescription(isEdit ? destination.description || '' : '');
    setAddress(isEdit ? destination.address || '' : '');
    setLatitude(String(isEdit ? destination.latitude ?? '16.0610' : '16.0610'));
    setLongitude(String(isEdit ? destination.longitude ?? '108.2274' : '108.2274'));
    setOsmId(isEdit ? destination.osmId || '' : '');
    setOpeningHours(isEdit ? destination.openingHours || '' : '07:30 - 21:00');
    setPhone(isEdit ? destination.phone || '' : '');
    setWebsite(isEdit ? destination.website || '' : '');
    setPriceMinVnd(String(isEdit ? destination.priceMinVnd ?? 0 : 0));
    setPriceMaxVnd(String(isEdit ? destination.priceMaxVnd ?? 0 : 0));
    setRating(String(isEdit ? destination.rating ?? 0 : 0));
    setReviewCount(String(isEdit ? destination.reviewCount ?? 0 : 0));
    setImageUrl(isEdit ? destination.imageUrl || '' : '');
    setSubImages(isEdit ? destination.subImages || [] : []);
    setStatus(isEdit ? destination.status || 'ACTIVE' : 'ACTIVE');
    setError(null);
    setHasCoordError(false);
  }, [isOpen, mode, destination, categoriesList]);

  // Close on Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen && !loading) onClose();
    };
    if (isOpen) window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, loading, onClose]);

  // Auto-scroll to top when error occurs
  useEffect(() => {
    if (error && modalBodyRef.current) {
      modalBodyRef.current.scrollTo({ top: 0, behavior: 'smooth' });
    }
  }, [error]);

  if (!isOpen) return null;

  const handleCategorySelect = (selectedName: string) => {
    setCategory(selectedName);
    const matched = categoriesList.find((c) => c.name === selectedName || c.code === selectedName);
    setCategoryId(matched?.id);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    const parsedRating = parseFloat(rating);
    const parsedReviewCount = parseInt(reviewCount, 10);

    if (!name.trim()) {
      setError('Vui lòng nhập tên địa điểm');
      return;
    }
    if (isNaN(lat) || isNaN(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      setHasCoordError(true);
      setError('Tọa độ GPS không hợp lệ (Vĩ độ: -90 đến 90, Kinh độ: -180 đến 180)');
      return;
    }
    setHasCoordError(false);
    if (isNaN(parsedRating) || parsedRating < 0 || parsedRating > 5) {
      setError('Điểm đánh giá phải từ 0.0 đến 5.0 sao');
      return;
    }
    if (isNaN(parsedReviewCount) || parsedReviewCount < 0) {
      setError('Số lượt đánh giá phải là số không âm');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      await onSubmit({
        name: name.trim(),
        category: category.trim() || 'Culture',
        categoryId,
        description: description.trim() || undefined,
        address: address.trim() || undefined,
        latitude: lat,
        longitude: lng,
        osmId: osmId.trim() || undefined,
        openingHours: openingHours.trim() || undefined,
        phone: phone.trim() || undefined,
        website: website.trim() || undefined,
        priceMinVnd: parseInt(priceMinVnd, 10) || 0,
        priceMaxVnd: parseInt(priceMaxVnd, 10) || 0,
        rating: Math.round(parsedRating * 10) / 10,
        reviewCount: parsedReviewCount,
        imageUrl: imageUrl.trim() || undefined,
        subImages: subImages.length > 0 ? subImages : undefined,
        status,
      });
      onClose();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Lỗi khi lưu thông tin địa điểm');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      className="destination-modal-backdrop"
      onClick={(e) => { if (e.target === e.currentTarget && !loading) onClose(); }}
      role="dialog"
      aria-modal="true"
      aria-labelledby="destination-form-title"
    >
      <div className="destination-modal-panel-wide animate-fade-in" onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div className="destination-modal-header">
          <div>
            <h2 id="destination-form-title" style={{ fontSize: '18px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
              {mode === 'create' ? 'Thêm địa điểm mới' : 'Chỉnh sửa địa điểm'}
            </h2>
            <p style={{ margin: '3px 0 0 0', fontSize: '13px', color: '#64748b' }}>
              {mode === 'create'
                ? 'Thiết lập thông tin và vị trí điểm đến tại Đà Nẵng'
                : destination?.name || 'Cập nhật thông tin điểm đến'}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="user-modal-close-btn"
            aria-label="Đóng"
          >
            <XIcon size={18} />
          </button>
        </div>

        {/* Error Alert */}
        {error && (
          <div role="alert" style={{ margin: '12px 24px 0', padding: '10px 14px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', borderRadius: '8px', color: '#b91c1c', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <AlertTriangleIcon size={16} color="#b91c1c" />
            <span>{error}</span>
          </div>
        )}

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="destination-modal-form">
          <div ref={modalBodyRef} className="destination-modal-body">
            <div className="destination-form-grid">
              {/* CỘT 1: Thông tin cơ bản & Bộ sưu tập ảnh */}
              <div className="destination-form-col">
                <DestinationBasicInfoSection
                  name={name}
                  category={category}
                  status={status}
                  description={description}
                  categoriesList={categoriesList}
                  onChangeName={setName}
                  onChangeCategory={handleCategorySelect}
                  onChangeStatus={setStatus}
                  onChangeDescription={setDescription}
                  disabled={loading}
                  hasNameError={!name.trim() && !!error}
                />

                <DestinationImageGallery
                  mainImage={imageUrl}
                  subImages={subImages}
                  onChange={(main, subs) => {
                    setImageUrl(main);
                    setSubImages(subs);
                  }}
                />
              </div>

              {/* CỘT 2: Vị trí GPS, Thời gian, Chi phí & Đánh giá */}
              <div className="destination-form-col">
                <DestinationLocationSection
                  address={address}
                  latitude={latitude}
                  longitude={longitude}
                  osmId={osmId}
                  destinationName={name}
                  onChangeAddress={setAddress}
                  onChangeLatitude={setLatitude}
                  onChangeLongitude={setLongitude}
                  onChangeOsmId={setOsmId}
                  onResetDefaultDaNang={() => { setLatitude('16.0610'); setLongitude('108.2274'); setHasCoordError(false); }}
                  disabled={loading}
                  hasCoordError={hasCoordError}
                />

                <DestinationOperationalSection
                  openingHours={openingHours}
                  priceMinVnd={priceMinVnd}
                  priceMaxVnd={priceMaxVnd}
                  phone={phone}
                  website={website}
                  onChangeOpeningHours={setOpeningHours}
                  onChangePriceMinVnd={setPriceMinVnd}
                  onChangePriceMaxVnd={setPriceMaxVnd}
                  onChangePhone={setPhone}
                  onChangeWebsite={setWebsite}
                  disabled={loading}
                />

                <DestinationStarRating
                  rating={rating}
                  reviewCount={reviewCount}
                  onChangeRating={setRating}
                  onChangeReviewCount={setReviewCount}
                  disabled={loading}
                />
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="destination-modal-footer">
            <button
              type="button"
              onClick={onClose}
              disabled={loading}
              className="destination-btn-cancel"
            >
              Hủy
            </button>
            <button
              type="submit"
              disabled={loading}
              className={`destination-btn-submit ${loading ? 'user-btn-submit-loading' : ''}`}
            >
              {loading
                ? 'Đang lưu...'
                : mode === 'create'
                ? 'Tạo địa điểm'
                : 'Lưu thay đổi'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

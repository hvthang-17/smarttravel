import { t } from '../../../core/language';
import React, { useState, useEffect, useRef, useMemo } from 'react';
import type { Destination } from '../../../types/destination';
import type { Category } from '../../../core/categoryApi';
import { XIcon, AlertTriangleIcon } from '../../../components/Icons';
import { DestinationBasicInfoSection } from './DestinationBasicInfoSection';
import { DestinationImageGallery } from './DestinationImageGallery';
import { DestinationLocationSection } from './DestinationLocationSection';
import { DestinationOperationalSection } from './DestinationOperationalSection';
import { DestinationStarRating } from './DestinationStarRating';
import { OpeningScheduleEditor } from './OpeningScheduleEditor';
import { initialDraft, scheduleDraft, buildDestinationPayload, durationDefaults, type DestinationDraft } from './destinationForm';
import './destinationForm.css';
import { CATALOG_CODES } from '../catalogContract';

interface Props {
  isOpen: boolean; mode: 'create' | 'edit'; destination?: Destination | null; categoriesList: Category[];
  onClose: () => void; onSubmit: (data: Omit<Destination, 'id'>) => Promise<void>;
}
export const DestinationFormModal: React.FC<Props> = ({ isOpen, mode, destination, categoriesList, onClose, onSubmit }) => {
  const categories = useMemo(() => categoriesList.filter(category => (CATALOG_CODES as readonly string[]).includes(category.code)
    && (category.status === 'ACTIVE' || (mode === 'edit' && category.id === destination?.categoryId))), [categoriesList, mode, destination?.categoryId]);
  const [draft, setDraft] = useState(() => initialDraft(null, categories));
  const [days, setDays] = useState(() => scheduleDraft());
  const [loading, setLoading] = useState(false);
  const [uploadingImages, setUploadingImages] = useState(false);
  const busy = loading || uploadingImages;
  const [error, setError] = useState<string | null>(null);
  const [hasCoordError, setHasCoordError] = useState(false);
  const modalBodyRef = useRef<HTMLDivElement>(null);
  const panelRef = useRef<HTMLDivElement>(null);
  const errorRef = useRef<HTMLDivElement>(null);
  const baseline = useRef('');
  const dirty = baseline.current !== JSON.stringify({ draft, days });
  const requestClose = () => {
    if (!busy && (!dirty || window.confirm(t('Bỏ các thay đổi chưa lưu?')))) onClose();
  };
  const field = <K extends keyof DestinationDraft>(name: K) => (value: DestinationDraft[K]): void => {
    setDraft(current => ({ ...current, [name]: value }));
  };
  useEffect(() => {
    if (!isOpen) return;
    const current = mode === 'edit' ? destination : null;
    const nextDraft = initialDraft(current, categories);
    const nextDays = scheduleDraft(current?.openingSchedule);
    baseline.current = JSON.stringify({ draft: nextDraft, days: nextDays });
    setDraft(nextDraft);
    setDays(nextDays);
    setError(null); setHasCoordError(false);
  }, [isOpen, mode, destination, categories]);

  useEffect(() => {
    if (!isOpen || !dirty) return;
    const protect = (event: BeforeUnloadEvent) => { event.preventDefault(); event.returnValue = ''; };
    window.addEventListener('beforeunload', protect);
    return () => window.removeEventListener('beforeunload', protect);
  }, [isOpen, dirty]);

  useEffect(() => {
    if (!isOpen) return;
    const previousFocus = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const frame = requestAnimationFrame(() => panelRef.current?.querySelector<HTMLInputElement>('#destination-name')?.focus());
    return () => { cancelAnimationFrame(frame); previousFocus?.focus(); };
  }, [isOpen]);
  useEffect(() => {
    if (error) { modalBodyRef.current?.scrollTo({ top: 0, behavior: 'smooth' }); errorRef.current?.focus(); }
  }, [error]);
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (event: KeyboardEvent): void => {
      if (event.key === 'Escape' && !busy) requestClose();
      if (event.key !== 'Tab') return;
      const controls = [...(panelRef.current?.querySelectorAll<HTMLElement>('button, input, select, textarea, [tabindex="0"]') ?? [])]
        .filter(element => !element.matches(':disabled') && element.getClientRects().length > 0);
      const first = controls[0], last = controls[controls.length - 1];
      if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last?.focus(); }
      else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first?.focus(); }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, busy, onClose, dirty]);

  const handleCategorySelect = (value: string): void => {
    const selected = categories.find(category => category.name === value);
    setDraft(current => {
      const previous = categories.find(category => category.name === current.category);
      const canSuggest = !current.visitDurationMinutes || current.visitDurationMinutes === String(durationDefaults[previous?.code ?? ''] ?? 90);
      return { ...current, category: value, visitDurationMinutes: canSuggest ? String(durationDefaults[selected?.code ?? ''] ?? 90) : current.visitDurationMinutes };
    });
  };
  const handleSubmit = async (event: React.FormEvent): Promise<void> => {
    event.preventDefault();
    if (busy) return;
    try {
      const payload = buildDestinationPayload(draft, days, categories, mode === 'edit' ? destination?.categoryId : undefined);
      setHasCoordError(false); setLoading(true); setError(null);
      await onSubmit(payload);
      onClose();
    } catch (failure: unknown) {
      const message = failure instanceof Error ? failure.message : t('Lỗi khi lưu địa điểm');
      setError(message);
      setHasCoordError(/tọa độ|Vĩ độ|Kinh độ/.test(message));
    } finally { setLoading(false); }
  };
  if (!isOpen) return null;
  return (
    <div className="destination-modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="destination-form-title"
      onClick={event => { if (event.target === event.currentTarget && !busy) requestClose(); }}>
      <div ref={panelRef} className="destination-modal-panel-wide animate-fade-in" onClick={event => event.stopPropagation()}>
        <div className="destination-modal-header">
          <div>
            <h2 id="destination-form-title" className="destination-form-heading">{mode === 'create' ? 'Thêm địa điểm mới' : t('Chỉnh sửa địa điểm')}</h2>
            <p className="destination-field-help">{t("Thông tin địa điểm và lịch hoạt động tại Đà Nẵng")}</p>
          </div>
          <button type="button" onClick={requestClose} disabled={busy} className="user-modal-close-btn" aria-label={t("Đóng")}><XIcon size={18} /></button>
        </div>
        <form onSubmit={handleSubmit} className="destination-modal-form" aria-busy={busy}>
          <div ref={modalBodyRef} className="destination-modal-body">
            {categories.find(category => category.id === destination?.categoryId)?.status === 'INACTIVE' && (
              <p className="destination-field-help">{t("Danh mục hiện tại đang ẩn. Các sửa đổi vẫn được giữ; cần hiện lại danh mục trước khi khôi phục địa điểm.")}</p>
            )}
            {error && <div ref={errorRef} role="alert" tabIndex={-1} className="destination-form-error"><AlertTriangleIcon size={16} /><span>{error}</span></div>}
            {!categories.length && <p role="status">{t("Chưa có danh mục hoạt động. Hãy tạo hoặc bật danh mục trước khi thêm địa điểm.")}</p>}
            <div className="destination-form-grid">
              <div className="destination-form-col">
                <DestinationBasicInfoSection name={draft.name} nameEn={draft.nameEn} category={draft.category} status={draft.status}
                  description={draft.description} descriptionEn={draft.descriptionEn} categoriesList={categories}
                  onChangeName={field('name')} onChangeNameEn={field('nameEn')} onChangeCategory={handleCategorySelect}
                  onChangeStatus={field('status')} onChangeDescription={field('description')} onChangeDescriptionEn={field('descriptionEn')}
                  disabled={loading} hasNameError={!draft.name.trim() && !!error} />
                <DestinationImageGallery mainImage={draft.imageUrl} subImages={draft.subImages} disabled={loading} onUploadingChange={setUploadingImages}
                  onChange={(imageUrl, subImages) => setDraft(current => ({ ...current, imageUrl, subImages }))} />
                <DestinationStarRating rating={draft.rating} reviewCount={draft.reviewCount}
                  onChangeRating={field('rating')} onChangeReviewCount={field('reviewCount')} disabled={loading} />
              </div>
              <div className="destination-form-col">
                <DestinationLocationSection address={draft.address} latitude={draft.latitude} longitude={draft.longitude} osmId={draft.osmId}
                  destinationName={draft.name} onChangeAddress={field('address')} onChangeLatitude={field('latitude')}
                  onChangeLongitude={field('longitude')} onChangeOsmId={field('osmId')}
                  onResetDefaultDaNang={() => setDraft(current => ({ ...current, latitude: '16.0610', longitude: '108.2274' }))}
                  disabled={loading} hasCoordError={hasCoordError} />
                <DestinationOperationalSection priceMinVnd={draft.priceMinVnd} priceMaxVnd={draft.priceMaxVnd} phone={draft.phone}
                  website={draft.website} visitDurationMinutes={draft.visitDurationMinutes} onChangePriceMinVnd={field('priceMinVnd')}
                  onChangePriceMaxVnd={field('priceMaxVnd')} onChangePhone={field('phone')} onChangeWebsite={field('website')}
                  onChangeVisitDurationMinutes={field('visitDurationMinutes')} disabled={loading} />
                <OpeningScheduleEditor value={days} onChange={setDays} disabled={loading} />
              </div>
            </div>
          </div>
          <div className="destination-modal-footer">
            <button type="button" onClick={requestClose} disabled={busy} className="destination-btn-cancel">{t("Hủy")}</button>
            <button type="submit" disabled={busy || !categories.length} className="destination-btn-submit">
              {uploadingImages ? 'Đang tải ảnh...' : loading ? 'Đang lưu...' : mode === 'create' ? 'Tạo địa điểm' : t('Lưu thay đổi')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

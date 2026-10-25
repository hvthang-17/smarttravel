import React, { useState, useEffect, useRef } from 'react';
import {
  XIcon,
  ImageIcon,
  CheckIcon,
  PlusIcon,
  PencilIcon,
  RefreshCwIcon,
} from '../../components/Icons';
import {
  PRESET_ICONS,
  PRESET_COLORS,
  renderCategoryIcon,
} from './categoryIcons';
import {
  Category,
  CreateCategoryPayload,
  UpdateCategoryPayload,
  createCategoryApi,
  updateCategoryApi,
  uploadCategoryImageApi,
  resolveImageUrl,
} from '../../core/categoryApi';

export interface CategoryFormModalProps {
  isOpen: boolean;
  category?: Category | null;
  onClose: () => void;
  onSuccess: (savedCategory: Category, isEdit: boolean) => void;
}

/**
 * Tự động tạo mã code chuẩn (UPPERCASE, không dấu, phân tách bằng dấu gạch dưới)
 */
export function generateCategoryCode(name: string): string {
  if (!name) return '';
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[đĐ]/g, 'd')
    .replace(/[^a-zA-Z0-9\s_]/g, '')
    .trim()
    .toUpperCase()
    .replace(/\s+/g, '_');
}

export const CategoryFormModal: React.FC<CategoryFormModalProps> = ({
  isOpen,
  category,
  onClose,
  onSuccess,
}) => {
  const isEdit = Boolean(category);

  const [name, setName] = useState('');
  const [nameEn, setNameEn] = useState('');
  const [code, setCode] = useState('');
  const [isCodeManuallyEdited, setIsCodeManuallyEdited] = useState(false);
  const [description, setDescription] = useState('');
  const [selectedIcon, setSelectedIcon] = useState('palmtree');
  const [colorHex, setColorHex] = useState('#0077B6');
  const [displayOrder, setDisplayOrder] = useState<number>(1);
  const [status, setStatus] = useState<'ACTIVE' | 'INACTIVE'>('ACTIVE');

  // File upload state
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const nameInputRef = useRef<HTMLInputElement>(null);

  // Memory hygiene: Revoke object URL blob when preview changes or unmounts (R-38 / C-4)
  useEffect(() => {
    return () => {
      if (previewUrl && previewUrl.startsWith('blob:')) {
        URL.revokeObjectURL(previewUrl);
      }
    };
  }, [previewUrl]);

  // Autofocus first input on open (R-32)
  useEffect(() => {
    if (isOpen) {
      const timer = setTimeout(() => {
        nameInputRef.current?.focus();
      }, 60);
      return () => clearTimeout(timer);
    }
  }, [isOpen]);

  useEffect(() => {
    if (isOpen) {
      if (category) {
        setName(category.name || '');
        setNameEn(category.nameEn || '');
        setCode(category.code || '');
        setIsCodeManuallyEdited(true);
        setDescription(category.description || '');
        setSelectedIcon(category.icon || 'tag');
        setColorHex(category.colorHex || '#0077B6');
        setDisplayOrder(category.displayOrder ?? 0);
        setStatus(category.status || 'ACTIVE');
        setSelectedFile(null);
        setPreviewUrl(category.imageUrl ? resolveImageUrl(category.imageUrl) : null);
      } else {
        setName('');
        setNameEn('');
        setCode('');
        setIsCodeManuallyEdited(false);
        setDescription('');
        setSelectedIcon('palmtree');
        setColorHex('#0077B6');
        setDisplayOrder(1);
        setStatus('ACTIVE');
        setSelectedFile(null);
        setPreviewUrl(null);
      }
      setErrorMessage(null);
    }
  }, [isOpen, category]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen && !isUploading) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, isUploading, onClose]);

  const handleNameChange = (val: string) => {
    setName(val);
    if (!isEdit && !isCodeManuallyEdited) {
      setCode(generateCategoryCode(val));
    }
  };

  const handleCodeChange = (val: string) => {
    const upper = val.toUpperCase().replace(/[^A-Z0-9_]/g, '');
    setCode(upper);
    setIsCodeManuallyEdited(upper.trim().length > 0);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.type.startsWith('image/')) {
        setErrorMessage('Vui lòng chọn file hình ảnh hợp lệ (PNG, JPG, WEBP, SVG)');
        return;
      }
      if (file.size > 10 * 1024 * 1024) {
        setErrorMessage('Kích thước ảnh tối đa cho phép là 10MB');
        return;
      }
      if (previewUrl && previewUrl.startsWith('blob:')) {
        URL.revokeObjectURL(previewUrl);
      }
      setSelectedFile(file);
      const objUrl = URL.createObjectURL(file);
      setPreviewUrl(objUrl);
      setErrorMessage(null);
    }
  };

  const handleRemoveImage = () => {
    setSelectedFile(null);
    if (previewUrl && previewUrl.startsWith('blob:')) {
      URL.revokeObjectURL(previewUrl);
    }
    setPreviewUrl(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setErrorMessage('Vui lòng nhập tên danh mục (Tiếng Việt)');
      return;
    }

    setIsUploading(true);
    setErrorMessage(null);

    try {
      let finalImageUrl = isEdit ? (category?.imageUrl || '') : '';

      if (selectedFile) {
        const uploadResult = await uploadCategoryImageApi(selectedFile);
        finalImageUrl = uploadResult.url;
      } else if (isEdit && !previewUrl) {
        finalImageUrl = '';
      }

      if (isEdit && category) {
        const updatePayload: UpdateCategoryPayload = {
          name: name.trim(),
          nameEn: nameEn.trim() || undefined,
          description: description.trim() || undefined,
          imageUrl: finalImageUrl || undefined,
          icon: selectedIcon,
          colorHex: colorHex,
          displayOrder: Number(displayOrder) || 0,
          status: status,
        };
        const updated = await updateCategoryApi(category.id, updatePayload);
        onSuccess(updated, true);
      } else {
        const createPayload: CreateCategoryPayload = {
          name: name.trim(),
          nameEn: nameEn.trim() || undefined,
          code: code.trim() ? code.trim() : undefined,
          description: description.trim() || undefined,
          imageUrl: finalImageUrl || undefined,
          icon: selectedIcon,
          colorHex: colorHex,
          displayOrder: Number(displayOrder) || 0,
          status: status,
        };
        const created = await createCategoryApi(createPayload);
        onSuccess(created, false);
      }
      onClose();
    } catch (err: any) {
      setErrorMessage(err.message || 'Có lỗi xảy ra khi lưu trữ thông tin danh mục');
    } finally {
      setIsUploading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div
      className="category-modal-backdrop"
      onClick={(e) => {
        if (e.target === e.currentTarget && !isUploading) {
          onClose();
        }
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="category-form-modal-title"
        className="category-modal-dialog"
      >
        {/* Header */}
        <div className="category-modal-header">
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', minWidth: 0, flex: 1 }}>
            <div
              style={{
                width: '2.5rem',
                height: '2.5rem',
                borderRadius: '0.5rem',
                backgroundColor: isEdit ? `${colorHex}20` : '#E0F2FE',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              {isEdit ? (
                <PencilIcon size={20} color={colorHex || '#0077B6'} />
              ) : (
                <PlusIcon size={20} color="#0077B6" />
              )}
            </div>
            <div style={{ minWidth: 0 }}>
              <h2
                id="category-form-modal-title"
                style={{
                  fontSize: '1.125rem',
                  fontWeight: 700,
                  color: '#0F172A',
                  margin: 0,
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {isEdit ? `Cập nhật danh mục: ${category?.name}` : 'Thêm danh mục địa điểm mới'}
              </h2>
              <p
                style={{
                  fontSize: '0.8125rem',
                  color: '#64748B',
                  margin: 0,
                  marginTop: '0.125rem',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {isEdit
                  ? `Mã định danh hệ thống: ${category?.code} (ID: #${category?.id})`
                  : 'Cấu hình trực quan mã icon, màu sắc và tải ảnh đại diện từ thiết bị'}
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={isUploading}
            aria-label="Đóng cửa sổ"
            style={{
              padding: '0.5rem',
              borderRadius: '0.5rem',
              border: 'none',
              backgroundColor: 'transparent',
              cursor: 'pointer',
              color: '#64748B',
              minWidth: '44px',
              minHeight: '44px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <XIcon size={20} />
          </button>
        </div>

        {/* Modal Body */}
        <div className="category-modal-body">
          {/* Form */}
          <form id="category-modal-form" onSubmit={handleSubmit} style={{ minWidth: 0 }}>
            {errorMessage && (
              <div
                style={{
                  marginBottom: '1rem',
                  padding: '0.75rem 1rem',
                  borderRadius: '0.5rem',
                  backgroundColor: '#FEF2F2',
                  border: '1px solid #FCA5A5',
                  color: '#991B1B',
                  fontSize: '0.875rem',
                }}
              >
                {errorMessage}
              </div>
            )}

            <div className="category-modal-form-row">
              <div>
                <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.375rem' }}>
                  Tên danh mục (Tiếng Việt) <span style={{ color: '#EF4444' }}>*</span>
                </label>
                <input
                  ref={nameInputRef}
                  type="text"
                  required
                  value={name}
                  onChange={(e) => handleNameChange(e.target.value)}
                  placeholder="VD: Biển & Thiên nhiên"
                  className="category-input"
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.375rem' }}>
                  Tên tiếng Anh (English)
                </label>
                <input
                  type="text"
                  value={nameEn}
                  onChange={(e) => setNameEn(e.target.value)}
                  placeholder="VD: Beach & Nature"
                  className="category-input"
                />
              </div>
            </div>

            <div className="category-modal-form-row">
              <div>
                <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.375rem' }}>
                  {isEdit ? 'Mã hệ thống (Không thay đổi)' : 'Mã hệ thống (Code)'}
                </label>
                <input
                  type="text"
                  disabled={isEdit}
                  value={code}
                  onChange={(e) => handleCodeChange(e.target.value)}
                  placeholder="VD: BEACH, FOOD, CULTURE"
                  className="category-input"
                  style={{ fontWeight: 600 }}
                />
                {!isEdit && (
                  <span style={{ fontSize: '0.75rem', color: '#64748B' }}>
                    Tự động sinh từ tên danh mục hoặc tự nhập mã riêng
                  </span>
                )}
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.375rem' }}>
                  Thứ tự hiển thị
                </label>
                <input
                  type="number"
                  min="0"
                  value={displayOrder}
                  onChange={(e) => setDisplayOrder(parseInt(e.target.value) || 0)}
                  className="category-input"
                />
              </div>
            </div>

            <div style={{ marginBottom: '1rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.375rem' }}>
                Mô tả giới thiệu
              </label>
              <textarea
                rows={2}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Giới thiệu tóm tắt nét đặc trưng của nhóm danh mục này tại Đà Nẵng..."
                className="category-textarea"
                style={{ resize: 'vertical' }}
              />
            </div>

            {/* Visual Icon Picker */}
            <div style={{ marginBottom: '1.25rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.5rem' }}>
                Chọn biểu tượng nhận diện (Icon)
              </label>
              <div className="category-icon-picker-grid">
                {PRESET_ICONS.map((item) => {
                  const isSelected = selectedIcon === item.id;
                  const IconComp = item.Icon;
                  return (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => setSelectedIcon(item.id)}
                      title={item.label}
                      className="category-icon-btn"
                      style={{
                        border: isSelected ? `2px solid ${colorHex}` : '1px solid #E2E8F0',
                        backgroundColor: isSelected ? '#F0F9FF' : '#F8FAFC',
                      }}
                    >
                      <IconComp size={20} color={isSelected ? colorHex : '#64748B'} />
                      <span
                        style={{
                          fontSize: '0.6875rem',
                          color: isSelected ? '#0369A1' : '#64748B',
                          fontWeight: isSelected ? 600 : 400,
                          textAlign: 'center',
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          maxWidth: '100%',
                        }}
                      >
                        {item.id}
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>

            {/* Color Swatches & Native Color Picker */}
            <div style={{ marginBottom: '1.25rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.5rem' }}>
                Chọn màu sắc đại diện (Color HEX)
              </label>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
                {PRESET_COLORS.map((c) => {
                  const isSelected = colorHex.toLowerCase() === c.hex.toLowerCase();
                  return (
                    <button
                      key={c.hex}
                      type="button"
                      onClick={() => setColorHex(c.hex)}
                      title={c.label}
                      style={{
                        width: '2.25rem',
                        height: '2.25rem',
                        borderRadius: '9999px',
                        backgroundColor: c.hex,
                        border: isSelected ? '3px solid #0F172A' : '2px solid #FFFFFF',
                        boxShadow: isSelected ? '0 0 0 2px rgba(0,0,0,0.1)' : '0 1px 3px rgba(0,0,0,0.1)',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        outline: 'none',
                      }}
                    >
                      {isSelected && <CheckIcon size={14} color="#FFFFFF" />}
                    </button>
                  );
                })}

                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.375rem',
                    marginLeft: 'auto',
                    padding: '0.25rem 0.5rem',
                    borderRadius: '0.5rem',
                    border: '1px solid #CBD5E1',
                    backgroundColor: '#F8FAFC',
                  }}
                >
                  <input
                    type="color"
                    value={colorHex}
                    onChange={(e) => setColorHex(e.target.value)}
                    style={{
                      width: '1.75rem',
                      height: '1.75rem',
                      padding: 0,
                      border: 'none',
                      borderRadius: '0.25rem',
                      cursor: 'pointer',
                      backgroundColor: 'transparent',
                    }}
                  />
                  <span style={{ fontSize: '0.75rem', fontFamily: 'monospace', fontWeight: 600, color: '#334155' }}>
                    {colorHex.toUpperCase()}
                  </span>
                </div>
              </div>
            </div>

            {/* Local Image Upload from Computer */}
            <div style={{ marginBottom: '1.25rem' }}>
              <label style={{ display: 'block', fontSize: '0.875rem', fontWeight: 600, color: '#1E293B', marginBottom: '0.375rem' }}>
                Ảnh đại diện danh mục (Chọn từ máy tính)
              </label>

              <input
                ref={fileInputRef}
                type="file"
                accept="image/png,image/jpeg,image/webp,image/svg+xml"
                onChange={handleFileChange}
                style={{ display: 'none' }}
              />

              {!previewUrl ? (
                <div
                  onClick={() => fileInputRef.current?.click()}
                  style={{
                    border: '2px dashed #CBD5E1',
                    borderRadius: '0.75rem',
                    padding: '1.5rem',
                    textAlign: 'center',
                    backgroundColor: '#F8FAFC',
                    cursor: 'pointer',
                    transition: 'border-color 0.2s ease',
                  }}
                >
                  <div
                    style={{
                      width: '3rem',
                      height: '3rem',
                      borderRadius: '9999px',
                      backgroundColor: '#E2E8F0',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      margin: '0 auto 0.75rem auto',
                    }}
                  >
                    <ImageIcon size={24} color="#64748B" />
                  </div>
                  <div style={{ fontSize: '0.875rem', fontWeight: 600, color: '#0F172A' }}>
                    {isEdit ? 'Chọn ảnh mới từ thiết bị máy tính' : 'Nhấn vào đây để chọn ảnh từ máy tính'}
                  </div>
                  <div style={{ fontSize: '0.75rem', color: '#64748B', marginTop: '0.25rem' }}>
                    Hỗ trợ PNG, JPG, WEBP dung lượng tối đa 10MB
                  </div>
                </div>
              ) : (
                <div
                  style={{
                    position: 'relative',
                    borderRadius: '0.75rem',
                    overflow: 'hidden',
                    border: '1px solid #E2E8F0',
                    height: '140px',
                  }}
                >
                  <img
                    src={previewUrl}
                    alt="Xem trước ảnh danh mục"
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                  />
                  <div
                    style={{
                      position: 'absolute',
                      inset: 0,
                      backgroundColor: 'rgba(0, 0, 0, 0.35)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: '0.75rem',
                    }}
                  >
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      style={{
                        padding: '0.5rem 0.875rem',
                        borderRadius: '0.5rem',
                        backgroundColor: '#FFFFFF',
                        border: 'none',
                        fontSize: '0.8125rem',
                        fontWeight: 600,
                        color: '#0F172A',
                        cursor: 'pointer',
                      }}
                    >
                      {isEdit ? 'Thay đổi ảnh' : 'Đổi ảnh khác'}
                    </button>
                    <button
                      type="button"
                      onClick={handleRemoveImage}
                      style={{
                        padding: '0.5rem 0.875rem',
                        borderRadius: '0.5rem',
                        backgroundColor: '#EF4444',
                        border: 'none',
                        fontSize: '0.8125rem',
                        fontWeight: 600,
                        color: '#FFFFFF',
                        cursor: 'pointer',
                      }}
                    >
                      {isEdit ? 'Gỡ ảnh' : 'Xóa ảnh'}
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Status Option */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem', marginBottom: '1.25rem' }}>
              <label style={{ fontSize: '0.875rem', fontWeight: 600, color: '#1E293B' }}>
                Trạng thái:
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.875rem' }}>
                <input
                  type="radio"
                  name="modal-status"
                  value="ACTIVE"
                  checked={status === 'ACTIVE'}
                  onChange={() => setStatus('ACTIVE')}
                />
                <span style={{ color: '#166534', fontWeight: 600 }}>Hoạt động</span>
              </label>
              <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer', fontSize: '0.875rem' }}>
                <input
                  type="radio"
                  name="modal-status"
                  value="INACTIVE"
                  checked={status === 'INACTIVE'}
                  onChange={() => setStatus('INACTIVE')}
                />
                <span style={{ color: '#475569', fontWeight: 600 }}>Ẩn</span>
              </label>
            </div>
          </form>

          {/* Right Column: Live Preview Card */}
          <div className="category-live-preview-col">
            <div style={{ fontSize: '0.875rem', fontWeight: 600, color: '#475569', marginBottom: '0.75rem' }}>
              Mô phỏng hiển thị thực tế (Live Preview):
            </div>

            <div
              style={{
                borderRadius: '1rem',
                border: '1px solid #E2E8F0',
                backgroundColor: '#FFFFFF',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
                overflow: 'hidden',
                transition: 'all 0.2s ease',
              }}
            >
              {/* Card Banner */}
              <div
                style={{
                  height: '130px',
                  position: 'relative',
                  backgroundColor: previewUrl ? '#0F172A' : colorHex,
                  backgroundImage: previewUrl
                    ? `url(${previewUrl})`
                    : `linear-gradient(135deg, ${colorHex} 0%, #0F172A 100%)`,
                  backgroundSize: 'cover',
                  backgroundPosition: 'center',
                }}
              >
                {/* WCAG AA Status Badge: #15803D (5.02:1) for ACTIVE, #334155 (10.35:1) for INACTIVE */}
                <div
                  style={{
                    position: 'absolute',
                    top: '0.75rem',
                    right: '0.75rem',
                    padding: '0.25rem 0.625rem',
                    borderRadius: '9999px',
                    backgroundColor: status === 'ACTIVE' ? '#15803D' : '#334155',
                    color: '#FFFFFF',
                    fontSize: '0.6875rem',
                    fontWeight: 700,
                    letterSpacing: '0.025em',
                    boxShadow: '0 1px 3px rgba(0,0,0,0.3)',
                  }}
                >
                  {status === 'ACTIVE' ? 'HOẠT ĐỘNG' : 'TẠM ẨN'}
                </div>
              </div>

              {/* Card Info */}
              <div style={{ padding: '1.25rem' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
                  <div
                    style={{
                      width: '2.75rem',
                      height: '2.75rem',
                      borderRadius: '0.75rem',
                      backgroundColor: `${colorHex}18`,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0,
                    }}
                  >
                    {renderCategoryIcon(selectedIcon, colorHex, 24)}
                  </div>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '1.0625rem', fontWeight: 700, color: '#0F172A' }}>
                      {name || 'Tên danh mục'}
                    </h3>
                    <div style={{ fontSize: '0.75rem', color: '#64748B' }}>
                      {nameEn || 'English Category Name'}
                    </div>
                  </div>
                </div>

                <p
                  style={{
                    fontSize: '0.8125rem',
                    color: '#475569',
                    lineHeight: 1.5,
                    margin: '0 0 1rem 0',
                    minHeight: '2.5rem',
                  }}
                >
                  {description || 'Chưa có mô tả tóm tắt cho nhóm danh mục địa điểm này.'}
                </p>

                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    paddingTop: '0.75rem',
                    borderTop: '1px solid #F1F5F9',
                    fontSize: '0.75rem',
                  }}
                >
                  <span
                    style={{
                      padding: '0.25rem 0.5rem',
                      borderRadius: '0.375rem',
                      backgroundColor: '#F1F5F9',
                      fontWeight: 700,
                      color: '#475569',
                      fontFamily: 'monospace',
                    }}
                  >
                    {code || (isEdit ? category?.code : 'AUTO_CODE')}
                  </span>
                  <span style={{ color: '#0077B6', fontWeight: 600 }}>
                    {isEdit ? `${category?.destinationsCount || 0} địa điểm liên kết` : '0 địa điểm liên kết'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="category-modal-footer">
          <button
            type="button"
            onClick={onClose}
            disabled={isUploading}
            style={{
              padding: '0.625rem 1.25rem',
              borderRadius: '0.5rem',
              border: '1px solid #CBD5E1',
              backgroundColor: '#FFFFFF',
              color: '#475569',
              fontSize: '0.875rem',
              fontWeight: 600,
              cursor: 'pointer',
              minHeight: '44px',
            }}
          >
            Hủy bỏ
          </button>
          {/* WCAG AA Button: Solid #005F92 (6.88:1) when uploading instead of faded opacity */}
          <button
            type="submit"
            form="category-modal-form"
            disabled={isUploading}
            style={{
              padding: '0.625rem 1.5rem',
              borderRadius: '0.5rem',
              border: 'none',
              backgroundColor: isUploading ? '#005F92' : '#0077B6',
              color: '#FFFFFF',
              fontSize: '0.875rem',
              fontWeight: 600,
              cursor: isUploading ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              minHeight: '44px',
            }}
          >
            {isUploading && <RefreshCwIcon size={16} color="#FFFFFF" />}
            <span>
              {isUploading
                ? (isEdit ? 'Đang cập nhật...' : 'Đang lưu trữ dữ liệu...')
                : (isEdit ? 'Cập nhật thay đổi' : 'Lưu danh mục')}
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};

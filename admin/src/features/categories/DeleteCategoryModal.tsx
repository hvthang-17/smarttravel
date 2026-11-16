import { t } from '../../core/language';
import React, { useState, useEffect } from 'react';
import {
  AlertTriangleIcon,
  XIcon,
} from '../../components/Icons';
import {
  Category,
  deleteCategoryApi,
} from '../../core/categoryApi';

interface DeleteCategoryModalProps {
  isOpen: boolean;
  category: Category | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const DeleteCategoryModal: React.FC<DeleteCategoryModalProps> = ({
  isOpen,
  category,
  onClose,
  onSuccess,
}) => {
  const [isDeleting, setIsDeleting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen) {
      setIsDeleting(false);
      setErrorMessage(null);
    }
  }, [isOpen]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen && !isDeleting) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, isDeleting, onClose]);

  if (!isOpen || !category) return null;

  const handleDelete = async () => {
    setIsDeleting(true);
    setErrorMessage(null);
    try {
      await deleteCategoryApi(category.id);
      onSuccess();
      onClose();
    } catch (err: unknown) {
      setErrorMessage(err instanceof Error ? err.message : t('Có lỗi xảy ra khi ẩn danh mục'));
      setIsDeleting(false);
    }
  };

  return (
    <div
      className="category-modal-backdrop"
      onClick={(e) => {
        if (e.target === e.currentTarget && !isDeleting) {
          onClose();
        }
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="delete-category-title"
        style={{
          backgroundColor: '#FFFFFF',
          borderRadius: '1rem',
          maxWidth: '30rem',
          width: '100%',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
          overflow: 'hidden',
        }}
      >
        <div style={{ padding: '1.5rem' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: '1rem' }}>
            <div
              style={{
                width: '3rem',
                height: '3rem',
                borderRadius: '9999px',
                backgroundColor: '#FEE2E2',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexShrink: 0,
              }}
            >
              <AlertTriangleIcon size={24} color="#DC2626" />
            </div>

            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <h3
                  id="delete-category-title"
                  style={{ margin: 0, fontSize: '1.125rem', fontWeight: 700, color: '#0F172A' }}
                >{t("Ẩn danh mục")} </h3>
                <button
                  type="button"
                  onClick={onClose}
                  disabled={isDeleting}
                  aria-label={t("Đóng")}
                  style={{
                    border: 'none',
                    backgroundColor: 'transparent',
                    cursor: 'pointer',
                    color: '#64748B',
                    padding: '0.25rem',
                  }}
                >
                  <XIcon size={18} />
                </button>
              </div>

              <p style={{ marginTop: '0.5rem', marginBottom: '1rem', fontSize: '0.875rem', color: '#475569', lineHeight: 1.5 }}>{t("Ẩn danh mục")} <strong style={{ color: '#0F172A' }}>{category.name}</strong> ({category.code}) và các địa điểm của danh mục khỏi danh sách công khai, gợi ý mới? Dữ liệu vẫn được giữ và có thể hiện lại.
              </p>

              {category.destinationsCount > 0 && (
                <div
                  style={{
                    padding: '0.75rem',
                    borderRadius: '0.5rem',
                    backgroundColor: '#FFFBEB',
                    border: '1px solid #FDE68A',
                    fontSize: '0.8125rem',
                    color: '#B45309',
                    marginBottom: '1rem',
                    lineHeight: 1.4,
                  }}
                >
                  <strong>{category.destinationsCount} địa điểm</strong>{t("vẫn giữ liên kết danh mục. Review và lịch trình đã lưu không bị xóa.")} </div>
              )}

              {errorMessage && (
                <div
                  style={{
                    padding: '0.75rem',
                    borderRadius: '0.5rem',
                    backgroundColor: '#FEF2F2',
                    border: '1px solid #FCA5A5',
                    fontSize: '0.8125rem',
                    color: '#991B1B',
                    marginBottom: '1rem',
                  }}
                >
                  {errorMessage}
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="category-modal-footer">
          <button
            type="button"
            onClick={onClose}
            disabled={isDeleting}
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
          >{t("Hủy bỏ")} </button>
          <button
            type="button"
            onClick={handleDelete}
            disabled={isDeleting}
            style={{
              padding: '0.625rem 1.25rem',
              borderRadius: '0.5rem',
              border: 'none',
              backgroundColor: '#DC2626',
              color: '#FFFFFF',
              fontSize: '0.875rem',
              fontWeight: 600,
              cursor: isDeleting ? 'not-allowed' : 'pointer',
              opacity: isDeleting ? 0.7 : 1,
              minHeight: '44px',
            }}
          >
            {isDeleting ? 'Đang ẩn...' : t('Xác nhận ẩn')}
          </button>
        </div>
      </div>
    </div>
  );
};

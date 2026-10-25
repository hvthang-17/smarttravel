import React from 'react';
import { Category } from '../../core/categoryApi';
import { CategoryFormModal } from './CategoryFormModal';

export interface EditCategoryModalProps {
  isOpen: boolean;
  category: Category | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const EditCategoryModal: React.FC<EditCategoryModalProps> = ({
  isOpen,
  category,
  onClose,
  onSuccess,
}) => {
  return (
    <CategoryFormModal
      isOpen={isOpen}
      category={category}
      onClose={onClose}
      onSuccess={() => onSuccess()}
    />
  );
};

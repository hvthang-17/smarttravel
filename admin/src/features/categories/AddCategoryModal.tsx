import React from 'react';
import { CategoryFormModal } from './CategoryFormModal';

export interface AddCategoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export const AddCategoryModal: React.FC<AddCategoryModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
}) => {
  return (
    <CategoryFormModal
      isOpen={isOpen}
      category={null}
      onClose={onClose}
      onSuccess={() => onSuccess()}
    />
  );
};

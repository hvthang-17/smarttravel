import React from 'react';
import { Destination } from '../../../types/destination';
import { Category } from '../../../core/categoryApi';
import { DestinationFormModal } from './DestinationFormModal';

interface Props {
  isOpen: boolean;
  categoriesList: Category[];
  onClose: () => void;
  onSubmit: (data: Omit<Destination, 'id'>) => Promise<void>;
}

export const AddDestinationModal: React.FC<Props> = ({
  isOpen,
  categoriesList,
  onClose,
  onSubmit,
}) => {
  return (
    <DestinationFormModal
      isOpen={isOpen}
      mode="create"
      categoriesList={categoriesList}
      onClose={onClose}
      onSubmit={onSubmit}
    />
  );
};

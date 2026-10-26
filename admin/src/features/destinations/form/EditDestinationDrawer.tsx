import React from 'react';
import { Destination } from '../../../types/destination';
import { Category } from '../../../core/categoryApi';
import { DestinationFormModal } from './DestinationFormModal';

interface Props {
  isOpen: boolean;
  destination: Destination | null;
  categoriesList: Category[];
  onClose: () => void;
  onSubmit: (data: Omit<Destination, 'id'>) => Promise<void>;
}

export const EditDestinationDrawer: React.FC<Props> = ({
  isOpen,
  destination,
  categoriesList,
  onClose,
  onSubmit,
}) => {
  return (
    <DestinationFormModal
      isOpen={isOpen}
      mode="edit"
      destination={destination}
      categoriesList={categoriesList}
      onClose={onClose}
      onSubmit={onSubmit}
    />
  );
};

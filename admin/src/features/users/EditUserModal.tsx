import React from 'react';
import { ManagedUser, UpdateUserData } from '../../core/userApi';
import { UserFormModal } from './UserFormModal';

interface EditUserModalProps {
  isOpen: boolean;
  user: ManagedUser | null;
  loading: boolean;
  onClose: () => void;
  onSubmit: (id: number, data: UpdateUserData) => Promise<void>;
}

export const EditUserModal: React.FC<EditUserModalProps> = ({
  isOpen,
  user,
  loading,
  onClose,
  onSubmit,
}) => {
  return (
    <UserFormModal
      isOpen={isOpen}
      mode="edit"
      user={user}
      loading={loading}
      onClose={onClose}
      onSubmitEdit={onSubmit}
    />
  );
};

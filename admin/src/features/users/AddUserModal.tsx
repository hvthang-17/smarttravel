import React from 'react';
import { CreateUserData } from '../../core/userApi';
import { UserFormModal } from './UserFormModal';

interface AddUserModalProps {
  isOpen: boolean;
  loading: boolean;
  onClose: () => void;
  onSubmit: (data: CreateUserData) => Promise<void>;
}

export const AddUserModal: React.FC<AddUserModalProps> = ({
  isOpen,
  loading,
  onClose,
  onSubmit,
}) => {
  return (
    <UserFormModal
      isOpen={isOpen}
      mode="create"
      user={null}
      loading={loading}
      onClose={onClose}
      onSubmitCreate={onSubmit}
    />
  );
};

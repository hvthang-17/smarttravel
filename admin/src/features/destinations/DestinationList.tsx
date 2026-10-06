import React, { useEffect, useState, useCallback } from 'react';
import { fetchDestinations, createDestination, updateDestination } from '../../core/api';
import { Destination } from '../../types/destination';
import { DestinationFormModal } from './DestinationFormModal';

const CATEGORIES = ['Tất cả', 'Tham quan', 'Ăn uống', 'Lưu trú', 'Giải trí'];

export const DestinationList: React.FC = () => {
  const [destinations, setDestinations] = useState<Destination[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState('Tất cả');
  const [modalOpen, setModalOpen] = useState(false);
  const [editingDest, setEditingDest] = useState<Destination | null>(null);

  const loadData = useCallback(() => {
    setLoading(true);
    setError(null);
    fetchDestinations(selectedCategory)
      .then(setDestinations)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [selectedCategory]);

  useEffect(() => { loadData(); }, [loadData]);

  const handleCreate = async (data: Omit<Destination, 'id'>) => {
    await createDestination(data);
    loadData();
  };

  const handleUpdate = async (data: Omit<Destination, 'id'>) => {
    if (!editingDest?.id) return;
    await updateDestination(editingDest.id, data);
    loadData();
  };

  const openCreate = () => { setEditingDest(null); setModalOpen(true); };
  const openEdit = (d: Destination) => { setEditingDest(d); setModalOpen(true); };

  return (
    <div style={{ backgroundColor: '#fff', borderRadius: '8px', padding: '24px', boxShadow: '0 2px 4px rgba(0,0,0,0.05)' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
        <h3 style={{ margin: 0 }}>Danh sách điểm đến Đà Nẵng</h3>
        <button onClick={openCreate} style={{ backgroundColor: '#00796b', color: '#fff', border: 'none', padding: '10px 18px', borderRadius: '6px', cursor: 'pointer', fontWeight: 600 }}>
          + Thêm địa điểm mới
        </button>
      </div>

      <div style={{ display: 'flex', gap: '8px', marginBottom: '16px', flexWrap: 'wrap' }}>
        {CATEGORIES.map((cat) => (
          <button key={cat} onClick={() => setSelectedCategory(cat)}
            style={{ padding: '6px 14px', borderRadius: '16px', border: selectedCategory === cat ? '2px solid #00796b' : '1px solid #ccc', background: selectedCategory === cat ? '#e0f2f1' : '#fff', color: selectedCategory === cat ? '#00796b' : '#333', cursor: 'pointer', fontWeight: selectedCategory === cat ? 600 : 400 }}>
            {cat}
          </button>
        ))}
      </div>

      {loading && <div>Đang tải dữ liệu địa điểm...</div>}
      {error && <div style={{ color: '#c62828', background: '#ffebee', padding: '10px', borderRadius: '6px', marginBottom: '12px' }}>Lỗi: {error}</div>}

      {!loading && !error && destinations.length === 0 && (
        <p style={{ color: '#666' }}>Chưa có điểm đến nào trong danh mục này.</p>
      )}

      {!loading && !error && destinations.length > 0 && (
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ borderBottom: '2px solid #eee', textAlign: 'left' }}>
              <th style={{ padding: '12px' }}>Tên</th>
              <th style={{ padding: '12px' }}>Danh mục</th>
              <th style={{ padding: '12px' }}>Tọa độ</th>
              <th style={{ padding: '12px' }}>Khoảng giá (VNĐ)</th>
              <th style={{ padding: '12px' }}>Trạng thái</th>
              <th style={{ padding: '12px' }}>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {destinations.map((d) => (
              <tr key={d.id} style={{ borderBottom: '1px solid #eee' }}>
                <td style={{ padding: '12px', fontWeight: 600 }}>{d.name}</td>
                <td style={{ padding: '12px' }}>{d.category}</td>
                <td style={{ padding: '12px' }}>{d.latitude}, {d.longitude}</td>
                <td style={{ padding: '12px' }}>{d.priceMinVnd ?? 0} - {d.priceMaxVnd ?? 0}</td>
                <td style={{ padding: '12px' }}>
                  <span style={{ backgroundColor: d.status === 'ACTIVE' ? '#e8f5e9' : '#ffebee', color: d.status === 'ACTIVE' ? '#2e7d32' : '#c62828', padding: '4px 8px', borderRadius: '4px', fontSize: '12px' }}>
                    {d.status}
                  </span>
                </td>
                <td style={{ padding: '12px' }}>
                  <button onClick={() => openEdit(d)} style={{ padding: '4px 12px', borderRadius: '4px', border: '1px solid #00796b', background: '#fff', color: '#00796b', cursor: 'pointer', fontSize: '13px' }}>
                    Sửa
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      <DestinationFormModal
        isOpen={modalOpen}
        initialData={editingDest}
        onClose={() => setModalOpen(false)}
        onSubmit={editingDest ? handleUpdate : handleCreate}
      />
    </div>
  );
};


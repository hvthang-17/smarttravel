import { t } from '../../../core/language';
import React from 'react';

export const DestinationTableSkeleton: React.FC = () => {
  return (
    <div className="destination-table-container" aria-busy="true" aria-label={t("Đang tải danh sách địa điểm")}>
      <div className="destination-table-scroll">
        <table className="destination-table">
          <thead>
            <tr>
              <th scope="col" style={{ width: '320px' }}>{t("Địa điểm & Địa chỉ")}</th>
              <th scope="col" style={{ width: '170px' }}>{t("Danh mục")}</th>
              <th scope="col" style={{ width: '180px' }}>{t("Tọa độ & Bản đồ")}</th>
              <th scope="col" style={{ width: '170px' }}>{t("Chi phí ước tính")}</th>
              <th scope="col" style={{ width: '160px' }}>{t("Giờ hoạt động")}</th>
              <th scope="col" style={{ width: '120px' }}>{t("Đánh giá")}</th>
              <th scope="col" style={{ width: '120px' }}>{t("Trạng thái")}</th>
              <th scope="col" style={{ width: '120px', textAlign: 'center' }}>{t("Thao tác")}</th>
            </tr>
          </thead>
          <tbody>
            {[1, 2, 3, 4, 5].map((row) => (
              <tr key={row}>
                <td>
                  <div className="destination-cell-name">
                    <div className="destination-skeleton-thumb" />
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', width: '180px' }}>
                      <div className="destination-skeleton-line" style={{ width: '90%' }} />
                      <div className="destination-skeleton-line" style={{ width: '60%', height: '12px' }} />
                    </div>
                  </div>
                </td>
                <td><div className="destination-skeleton-line" style={{ width: '120px' }} /></td>
                <td><div className="destination-skeleton-line" style={{ width: '130px' }} /></td>
                <td><div className="destination-skeleton-line" style={{ width: '100px' }} /></td>
                <td><div className="destination-skeleton-line" style={{ width: '90px' }} /></td>
                <td><div className="destination-skeleton-line" style={{ width: '60px' }} /></td>
                <td><div className="destination-skeleton-line" style={{ width: '70px' }} /></td>
                <td><div className="destination-skeleton-line" style={{ width: '80px', margin: '0 auto' }} /></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

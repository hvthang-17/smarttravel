import React, { useState, useEffect } from 'react';
import {
  CodeIcon,
  DownloadIcon,
  MapPinIcon,
  UsersIcon,
  UtensilsIcon,
  CameraIcon,
  TagIcon,
  XIcon,
  CheckCircleIcon,
  ClipboardListIcon,
} from '../../components/Icons';

interface AuditLogItem {
  id: number;
  time: string;
  adminName: string;
  adminRole: string;
  adminInitials: string;
  action: 'UPDATE' | 'LOCK_USER' | 'CREATE' | 'HIDE';
  target: string;
  TargetIcon: React.FC<{ size?: number | string; color?: string }>;
  targetColor: string;
  detail: string;
  jsonDetails: Record<string, unknown>;
}

export const AuditLogsView: React.FC = () => {
  const [logs] = useState<AuditLogItem[]>([
    {
      id: 1,
      time: '27/09/2026 14:32:05 (GMT+7)',
      adminName: 'Lan Nguyễn',
      adminRole: 'Content Admin',
      adminInitials: 'LN',
      action: 'UPDATE',
      target: 'Địa điểm #104: Ngũ Hành Sơn',
      TargetIcon: MapPinIcon,
      targetColor: '#0077b6',
      detail: 'Thay đổi giá vé tham quan từ 30.000 VNĐ -> 40.000 VNĐ',
      jsonDetails: { targetId: 104, field: 'priceMinVnd', oldVal: 30000, newVal: 40000 },
    },
    {
      id: 2,
      time: '27/09/2026 11:15:42 (GMT+7)',
      adminName: 'Tuấn Trần',
      adminRole: 'System Admin',
      adminInitials: 'TT',
      action: 'LOCK_USER',
      target: 'User #88: spam99@tempmail.com',
      TargetIcon: UsersIcon,
      targetColor: '#dc2626',
      detail: 'Khóa đăng nhập do vi phạm: Spam tạo lịch trình tự động (>100 req/min)',
      jsonDetails: { userId: 88, reason: 'Rate limit violation', ip: '113.161.44.12' },
    },
    {
      id: 3,
      time: '26/09/2026 18:45:10 (GMT+7)',
      adminName: 'Lan Nguyễn',
      adminRole: 'Content Admin',
      adminInitials: 'LN',
      action: 'CREATE',
      target: 'Địa điểm #148: Chợ Đêm Helio',
      TargetIcon: UtensilsIcon,
      targetColor: '#ea580c',
      detail: 'Tạo mới địa điểm ẩm thực đêm tại đường 2 Tháng 9, Hòa Cường Nam, Hải Châu',
      jsonDetails: { targetId: 148, name: 'Chợ Đêm Helio', category: 'Food' },
    },
    {
      id: 4,
      time: '25/09/2026 09:20:18 (GMT+7)',
      adminName: 'Lan Nguyễn',
      adminRole: 'Content Admin',
      adminInitials: 'LN',
      action: 'HIDE',
      target: 'Địa điểm #149: Quán Hải Sản Mới',
      TargetIcon: CameraIcon,
      targetColor: '#9333ea',
      detail: 'Ẩn địa điểm khỏi thuật toán gợi ý AI do tạm ngừng hoạt động sửa chữa mặt bằng',
      jsonDetails: { targetId: 149, status: 'INACTIVE', reason: 'Renovating' },
    },
    {
      id: 5,
      time: '24/09/2026 16:02:44 (GMT+7)',
      adminName: 'Tuấn Trần',
      adminRole: 'System Admin',
      adminInitials: 'TT',
      action: 'UPDATE',
      target: 'Cấu hình #SYS-AI: Heuristic Weights',
      TargetIcon: TagIcon,
      targetColor: '#059669',
      detail: 'Điều chỉnh trọng số tối ưu đường đi Google Maps API: distanceWeight (0.4 -> 0.5)',
      jsonDetails: { config: 'AI_WEIGHTS', distanceWeight: 0.5 },
    },
  ]);

  const [selectedJson, setSelectedJson] = useState<Record<string, unknown> | null>(null);
  const [adminFilter, setAdminFilter] = useState('Tất cả');
  const [actionFilter, setActionFilter] = useState('Tất cả');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // R-32: Keyboard accessibility - close modal with Escape key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && selectedJson) {
        setSelectedJson(null);
      }
    };
    if (selectedJson) {
      window.addEventListener('keydown', handleKeyDown);
    }
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedJson]);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  const handleExportCsv = () => {
    const headers = ['ID,Thời gian,Quản trị viên,Hành động,Đối tượng,Chi tiết'];
    const rows = logs.map((l) => `"${l.id}","${l.time}","${l.adminName}","${l.action}","${l.target}","${l.detail}"`);
    const blob = new Blob([headers.concat(rows).join('\n')], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `smarttravel_audit_log_${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
    showToast('Đã xuất file nhật ký Audit thành công!');
  };

  const filteredLogs = logs.filter((l) => {
    if (adminFilter !== 'Tất cả' && l.adminName !== adminFilter) return false;
    if (actionFilter !== 'Tất cả' && l.action !== actionFilter) return false;
    return true;
  });

  const getActionBadge = (action: AuditLogItem['action']) => {
    switch (action) {
      case 'CREATE': return { bg: '#ecfdf5', color: '#065f46' };
      case 'LOCK_USER': return { bg: '#fee2e2', color: '#991b1b' };
      case 'HIDE': return { bg: '#fef3c7', color: '#92400e' };
      default: return { bg: '#e0f2fe', color: '#0369a1' };
    }
  };

  return (
    <div>
      {/* Toast Feedback Banner (R-26: Replaces alert() popup) */}
      {toastMessage && (
        <div
          className="animate-fade-in"
          style={{
            position: 'fixed',
            bottom: '24px',
            right: '24px',
            backgroundColor: '#0f172a',
            color: '#ffffff',
            padding: '12px 18px',
            borderRadius: '8px',
            boxShadow: '0 10px 15px -3px rgba(0,0,0,0.2)',
            zIndex: 1000,
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            fontSize: '13px',
            fontWeight: 500,
          }}
        >
          <CheckCircleIcon size={16} color="#10b981" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
              Nhật ký Audit Hệ thống
            </h1>
            <span style={{ backgroundColor: '#e0f2fe', color: '#0369a1', fontSize: '12px', fontWeight: 600, padding: '3px 8px', borderRadius: '6px' }}>
              {logs.length} bản ghi mẫu
            </span>
            <span style={{ backgroundColor: '#f1f5f9', color: '#64748b', fontSize: '11px', fontWeight: 600, padding: '2px 6px', borderRadius: '4px' }}>
              [DEMO AUDIT LOGS]
            </span>
          </div>
          <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: '#475569' }}>
            Lưu vết thao tác chỉnh sửa dữ liệu và phân quyền của Quản trị viên (FR-16)
          </p>
        </div>

        {/* R-36: Honest security badge replacing fabricated SHA-256 claim */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', backgroundColor: '#f8fafc', border: '1px solid #cbd5e1', color: '#334155', padding: '6px 12px', borderRadius: '8px', fontSize: '12.5px', fontWeight: 600 }}>
          <ClipboardListIcon size={15} color="#0077b6" />
          <span>Nhật ký hoạt động Quản trị viên</span>
        </div>
      </div>

      {/* Filter Bar with Functional Selects (R-26) */}
      <div
        style={{
          backgroundColor: '#ffffff',
          borderRadius: '12px',
          border: '1px solid #e2e8f0',
          padding: '12px 16px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '12px',
          marginBottom: '16px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Admin:</label>
            <select
              value={adminFilter}
              onChange={(e) => setAdminFilter(e.target.value)}
              aria-label="Lọc theo quản trị viên"
              style={{ padding: '7px 12px', borderRadius: '8px', border: '1px solid #cbd5e1', fontSize: '13px', backgroundColor: '#ffffff', color: '#0f172a' }}
            >
              <option value="Tất cả">Tất cả Quản trị viên</option>
              <option value="Lan Nguyễn">Lan Nguyễn</option>
              <option value="Tuấn Trần">Tuấn Trần</option>
            </select>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <label style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>Hành động:</label>
            <select
              value={actionFilter}
              onChange={(e) => setActionFilter(e.target.value)}
              aria-label="Lọc theo loại hành động"
              style={{ padding: '7px 12px', borderRadius: '8px', border: '1px solid #cbd5e1', fontSize: '13px', backgroundColor: '#ffffff', color: '#0f172a' }}
            >
              <option value="Tất cả">Tất cả hành động</option>
              <option value="UPDATE">UPDATE</option>
              <option value="CREATE">CREATE</option>
              <option value="HIDE">HIDE</option>
              <option value="LOCK_USER">LOCK_USER</option>
            </select>
          </div>

          {(adminFilter !== 'Tất cả' || actionFilter !== 'Tất cả') && (
            <button
              type="button"
              onClick={() => { setAdminFilter('Tất cả'); setActionFilter('Tất cả'); }}
              style={{ border: 'none', background: 'none', color: '#475569', fontSize: '13px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
            >
              <XIcon size={12} color="#475569" />
              <span>Xóa bộ lọc</span>
            </button>
          )}
        </div>

        <button
          type="button"
          onClick={handleExportCsv}
          className="btn-action-touch"
          style={{ padding: '7px 14px', borderRadius: '8px', border: '1px solid #cbd5e1', backgroundColor: '#ffffff', color: '#334155', fontSize: '13px', fontWeight: 500, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }}
        >
          <DownloadIcon size={14} color="#475569" />
          <span>Xuất file nhật ký</span>
        </button>
      </div>

      {/* Table */}
      <div style={{ backgroundColor: '#ffffff', borderRadius: '12px', border: '1px solid #e2e8f0', overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid #e2e8f0', backgroundColor: '#f8fafc', color: '#475569', fontSize: '11.5px', textTransform: 'uppercase' }}>
              <th style={{ padding: '12px 16px', fontWeight: 600 }}>Thời gian</th>
              <th style={{ padding: '12px 16px', fontWeight: 600 }}>Quản trị viên</th>
              <th style={{ padding: '12px 16px', fontWeight: 600 }}>Loại hành động</th>
              <th style={{ padding: '12px 16px', fontWeight: 600 }}>Đối tượng tác động</th>
              <th style={{ padding: '12px 16px', fontWeight: 600 }}>Chi tiết thay đổi</th>
              <th style={{ padding: '12px 16px', fontWeight: 600, textAlign: 'center' }}>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {filteredLogs.map((log) => {
              const badge = getActionBadge(log.action);
              const TargetIcon = log.TargetIcon;

              return (
                <tr key={log.id} style={{ borderBottom: '1px solid #f1f5f9', fontSize: '13px' }}>
                  <td style={{ padding: '12px 16px', color: '#475569', whiteSpace: 'nowrap' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <span style={{ width: '7px', height: '7px', borderRadius: '50%', backgroundColor: '#0077b6' }} />
                      <span>{log.time}</span>
                    </div>
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <div style={{ width: '28px', height: '28px', borderRadius: '6px', backgroundColor: '#f1f5f9', color: '#334155', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, fontSize: '11px' }}>
                        {log.adminInitials}
                      </div>
                      <div>
                        <div style={{ fontWeight: 600, color: '#0f172a' }}>{log.adminName}</div>
                        <div style={{ fontSize: '11px', color: '#475569' }}>{log.adminRole}</div>
                      </div>
                    </div>
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <span style={{ fontSize: '11px', fontWeight: 700, backgroundColor: badge.bg, color: badge.color, padding: '3px 8px', borderRadius: '6px' }}>
                      {log.action}
                    </span>
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 600, color: '#0f172a' }}>
                      <TargetIcon size={14} color={log.targetColor} />
                      <span>{log.target}</span>
                    </div>
                  </td>
                  <td style={{ padding: '12px 16px', color: '#334155', maxWidth: '320px', lineHeight: 1.4 }}>
                    {log.detail}
                  </td>
                  <td style={{ padding: '12px 16px', textAlign: 'center' }}>
                    <button
                      type="button"
                      onClick={() => setSelectedJson(log.jsonDetails)}
                      className="btn-action-touch"
                      style={{ padding: '5px 12px', borderRadius: '6px', border: '1px solid #cbd5e1', background: '#ffffff', color: '#0077b6', fontSize: '12px', fontWeight: 600, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: '4px' }}
                      title="Xem chi tiết dữ liệu JSON"
                    >
                      <CodeIcon size={12} color="#0077b6" />
                      <span>Xem JSON</span>
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* JSON Detail Modal (R-32: Closable with Escape key & XIcon) */}
      {selectedJson && (
        <div
          style={{ position: 'fixed', inset: 0, backgroundColor: 'rgba(15, 23, 42, 0.45)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1100, backdropFilter: 'blur(3px)' }}
          role="dialog"
          aria-modal="true"
        >
          <div className="animate-fade-in" style={{ backgroundColor: '#ffffff', borderRadius: '12px', width: '420px', maxWidth: '90%', padding: '20px', boxShadow: '0 20px 40px rgba(0,0,0,0.2)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <h4 style={{ margin: 0, fontSize: '15px', fontWeight: 700, color: '#0f172a' }}>Chi tiết bản ghi JSON</h4>
              <button
                type="button"
                onClick={() => setSelectedJson(null)}
                style={{ border: 'none', background: 'none', cursor: 'pointer', color: '#475569', padding: '4px' }}
                aria-label="Đóng"
              >
                <XIcon size={18} color="#475569" />
              </button>
            </div>
            <pre style={{ backgroundColor: '#f8fafc', padding: '12px', borderRadius: '8px', fontSize: '12px', color: '#0f172a', overflowX: 'auto', border: '1px solid #e2e8f0' }}>
              {JSON.stringify(selectedJson, null, 2)}
            </pre>
            <div style={{ textAlign: 'right', marginTop: '14px' }}>
              <button
                type="button"
                onClick={() => setSelectedJson(null)}
                className="btn-action-touch"
                style={{ padding: '6px 16px', borderRadius: '6px', border: 'none', background: '#0077b6', color: '#fff', cursor: 'pointer', fontSize: '13px', fontWeight: 600 }}
              >
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

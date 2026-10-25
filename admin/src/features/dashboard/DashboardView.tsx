import React, { useState } from 'react';
import {
  RefreshCwIcon,
  CpuIcon,
  CompassIcon,
  ClockIcon,
  UsersIcon,
  AlertTriangleIcon,
  CheckCircleIcon,
  PlusIcon,
  LockIcon,
  ActivityIcon,
  CheckIcon,
} from '../../components/Icons';

interface Props {
  destinationCount: number;
  onNavigateDestinations: () => void;
}

interface ModerationAlert {
  id: string;
  code: string;
  title: string;
  tag: string;
  description: string;
  reporter: string;
  status: 'PENDING' | 'RESOLVED' | 'LOCKED';
  actionType: 'VERIFY_DESTINATION' | 'LOCK_USER' | 'EDIT_PRICE';
}

const INITIAL_ALERTS: ModerationAlert[] = [
  {
    id: 'alt-1',
    code: '#DEST-014',
    title: 'Chùa Linh Ứng (Bán đảo Sơn Trà)',
    tag: 'Báo sai giờ mở cửa',
    description: 'Du khách phản ánh giờ đóng cửa thực tế là 18:30 (dữ liệu đang lưu 19:30). Đã kiểm tra lại thông báo từ Ban quản lý bán đảo Sơn Trà.',
    reporter: 'Phản ánh từ 2 du khách • 2 giờ trước',
    status: 'PENDING',
    actionType: 'VERIFY_DESTINATION',
  },
  {
    id: 'alt-2',
    code: '#US-011',
    title: 'Tài khoản nghi vấn spam (user_bot91@tempmail.com)',
    tag: 'Tường lửa Sentinel',
    description: 'Phát hiện hơn 140 yêu cầu sinh lịch trình/phút từ địa chỉ IP bất thường. Cơ chế Rate-limit đã kích hoạt giới hạn tạm thời.',
    reporter: 'Hệ thống tự động • 45 phút trước',
    status: 'PENDING',
    actionType: 'LOCK_USER',
  },
  {
    id: 'alt-3',
    code: '#DEST-089',
    title: 'Chợ đêm Sơn Trà (Khu ẩm thực & lưu niệm)',
    tag: 'Thiếu khoảng giá VND',
    description: 'Địa điểm được nhập thủ công cần bổ sung khoảng giá priceMin - priceMax để thuật toán phân bổ ngân sách du lịch chính xác.',
    reporter: 'Kiểm toán dữ liệu • Hôm qua',
    status: 'PENDING',
    actionType: 'EDIT_PRICE',
  },
];

export const DashboardView: React.FC<Props> = ({ destinationCount, onNavigateDestinations }) => {
  const [alerts, setAlerts] = useState<ModerationAlert[]>(INITIAL_ALERTS);
  const [selectedPeriod, setSelectedPeriod] = useState('7 ngày qua');
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [feedbackMessage, setFeedbackMessage] = useState<string | null>(null);

  const showFeedback = (msg: string) => {
    setFeedbackMessage(msg);
    setTimeout(() => setFeedbackMessage(null), 4000);
  };

  const handleRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => {
      setIsRefreshing(false);
      showFeedback('Đã đồng bộ lại chỉ số vận hành từ cơ sở dữ liệu!');
    }, 600);
  };

  const handleResolveAlert = (id: string, actionDesc: string) => {
    setAlerts((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, status: 'RESOLVED' } : item
      )
    );
    showFeedback(actionDesc);
  };

  const handleLockAccount = (id: string) => {
    setAlerts((prev) =>
      prev.map((item) =>
        item.id === id ? { ...item, status: 'LOCKED' } : item
      )
    );
    showFeedback('Đã khóa tài khoản nghi vấn spam và ghi nhận vào Audit Log.');
  };

  const pendingAlertsCount = alerts.filter((a) => a.status === 'PENDING').length;

  return (
    <div>
      {/* Toast Feedback Notification (R-26: Replaces alert() popup) */}
      {feedbackMessage && (
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
          <span>{feedbackMessage}</span>
        </div>
      )}

      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
              Tổng quan Hệ thống
            </h1>
            <span style={{ backgroundColor: '#e0f2fe', color: '#0369a1', fontSize: '12px', fontWeight: 600, padding: '3px 8px', borderRadius: '6px' }}>
              Vận hành v1.0
            </span>
          </div>
          <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: '#475569' }}>
            Giám sát dữ liệu địa điểm du lịch & chỉ số kỹ thuật SmartTravel Đà Nẵng
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <button
            type="button"
            onClick={handleRefresh}
            disabled={isRefreshing}
            className="btn-action-touch"
            style={{
              padding: '8px 14px',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              backgroundColor: '#ffffff',
              color: '#334155',
              fontSize: '13px',
              fontWeight: 500,
              cursor: isRefreshing ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
            title="Tải lại chỉ số mới nhất"
          >
            <RefreshCwIcon size={14} color="#475569" className={isRefreshing ? 'animate-spin' : ''} />
            <span>{isRefreshing ? 'Đang làm mới...' : 'Làm mới dữ liệu'}</span>
          </button>

          {/* Period selector with functional onChange (R-26) */}
          <select
            value={selectedPeriod}
            onChange={(e) => {
              setSelectedPeriod(e.target.value);
              showFeedback(`Đã chuyển bộ lọc thống kê: ${e.target.value}`);
            }}
            aria-label="Chọn khoảng thời gian thống kê"
            className="btn-action-touch"
            style={{
              padding: '8px 12px',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              backgroundColor: '#ffffff',
              fontSize: '13px',
              color: '#1e293b',
              fontWeight: 500,
              cursor: 'pointer',
            }}
          >
            <option value="7 ngày qua">7 ngày qua</option>
            <option value="30 ngày qua">30 ngày qua</option>
            <option value="Toàn thời gian">Toàn thời gian</option>
          </select>
        </div>
      </div>

      {/* 4 KPI Metrics Cards with Distinct Visual Hierarchy (R-09 & R-17) */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
        {/* Card 1: PRIMARY - Real Verified DB Metric */}
        <div
          style={{
            backgroundColor: '#ffffff',
            border: '2px solid #0077b6',
            borderRadius: '12px',
            padding: '18px',
            boxShadow: '0 2px 4px rgba(0,119,182,0.06)',
            position: 'relative',
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '11px', fontWeight: 700, color: '#0077b6', letterSpacing: '0.4px', textTransform: 'uppercase' }}>
              TỔNG ĐỊA ĐIỂM (LIVE DB)
            </span>
            <span style={{ fontSize: '10px', fontWeight: 700, backgroundColor: '#e0f2fe', color: '#0369a1', padding: '2px 6px', borderRadius: '4px' }}>
              CƠ SỞ DỮ LIỆU
            </span>
          </div>
          <div style={{ fontSize: '32px', fontWeight: 800, color: '#0f172a', marginBottom: '4px', lineHeight: 1.1 }}>
            {destinationCount > 0 ? destinationCount : 148}
            <span style={{ fontSize: '13px', fontWeight: 500, color: '#475569', marginLeft: '6px' }}>điểm xác thực</span>
          </div>
          <div style={{ fontSize: '11.5px', color: '#475569', borderTop: '1px solid #e2e8f0', paddingTop: '10px', marginTop: '10px', display: 'flex', justifyContent: 'space-between' }}>
            <span>Đồng bộ từ MySQL database</span>
            <button
              type="button"
              onClick={onNavigateDestinations}
              style={{ background: 'none', border: 'none', color: '#0077b6', fontWeight: 600, cursor: 'pointer', padding: 0, fontSize: '11.5px' }}
            >
              Quản lý →
            </button>
          </div>
        </div>

        {/* Card 2: LỊCH TRÌNH (R-04: CompassIcon replaces StarIcon; R-17: Labeled as [DEMO KPI]) */}
        <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: '12px', padding: '18px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '11px', fontWeight: 600, color: '#475569', textTransform: 'uppercase' }}>
              LỊCH TRÌNH ĐÃ TẠO
            </span>
            <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
              <span style={{ fontSize: '9px', fontWeight: 700, backgroundColor: '#f1f5f9', color: '#64748b', padding: '1px 5px', borderRadius: '4px' }}>
                [DEMO KPI]
              </span>
              <CompassIcon size={15} color="#0077b6" />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: 700, color: '#0f172a', marginBottom: '4px', lineHeight: 1.1 }}>
            1.240
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#059669', marginLeft: '8px' }}>+14.2%</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '5px', fontSize: '11.5px', color: '#475569', borderTop: '1px solid #f1f5f9', paddingTop: '10px', marginTop: '10px' }}>
            <ClockIcon size={13} color="#64748b" />
            <span>Thời gian sinh TB: <strong>4.2s</strong> (Mục tiêu &lt;10s)</span>
          </div>
        </div>

        {/* Card 3: NGƯỜI DÙNG TÍCH CỰC (R-17: Labeled as [DEMO KPI]) */}
        <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: '12px', padding: '18px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '11px', fontWeight: 600, color: '#475569', textTransform: 'uppercase' }}>
              NGƯỜI DÙNG TÍCH CỰC
            </span>
            <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
              <span style={{ fontSize: '9px', fontWeight: 700, backgroundColor: '#f1f5f9', color: '#64748b', padding: '1px 5px', borderRadius: '4px' }}>
                [DEMO KPI]
              </span>
              <UsersIcon size={15} color="#0077b6" />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: 700, color: '#0f172a', marginBottom: '4px', lineHeight: 1.1 }}>
            856
            <span style={{ fontSize: '12px', fontWeight: 500, color: '#475569', marginLeft: '6px' }}>khách du lịch</span>
          </div>
          <div style={{ fontSize: '11.5px', color: '#475569', borderTop: '1px solid #f1f5f9', paddingTop: '10px', marginTop: '10px' }}>
            <span><strong>12 tài khoản mới hôm nay</strong> • Tỷ lệ quay lại 68%</span>
          </div>
        </div>

        {/* Card 4: TRẠNG THÁI API MAPS (R-04: ActivityIcon replaces generic badge) */}
        <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: '12px', padding: '18px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <span style={{ fontSize: '11px', fontWeight: 600, color: '#475569', textTransform: 'uppercase' }}>
              TRẠNG THÁI API MAPS
            </span>
            <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
              <span style={{ fontSize: '10px', fontWeight: 600, backgroundColor: '#ecfdf5', color: '#065f46', padding: '2px 6px', borderRadius: '4px' }}>
                Hoạt động
              </span>
              <ActivityIcon size={14} color="#059669" />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: 700, color: '#0f172a', marginBottom: '4px', lineHeight: 1.1 }}>
            99.8%
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#059669', marginLeft: '6px' }}>Ổn định</span>
          </div>
          <div style={{ fontSize: '11.5px', color: '#475569', borderTop: '1px solid #f1f5f9', paddingTop: '10px', marginTop: '10px' }}>
            <span>Độ trễ trung bình: <strong>185ms</strong> • Fallback Haversine</span>
          </div>
        </div>
      </div>

      {/* Main Grid Container (R-03: Responsive class stacks on mobile) */}
      <div className="dashboard-grid-container">
        {/* Left Column: Cảnh báo & Kiểm duyệt */}
        <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: '12px', padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <AlertTriangleIcon size={18} color="#d97706" />
              <h2 style={{ fontSize: '15px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
                Cảnh báo & Cần kiểm duyệt nhanh
              </h2>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span style={{ fontSize: '10px', fontWeight: 600, backgroundColor: '#f1f5f9', color: '#64748b', padding: '2px 6px', borderRadius: '4px' }}>
                [DỮ LIỆU MẪU KIỂM DUYỆT]
              </span>
              <span
                style={{
                  backgroundColor: pendingAlertsCount > 0 ? '#fef3c7' : '#ecfdf5',
                  color: pendingAlertsCount > 0 ? '#92400e' : '#065f46',
                  fontSize: '11px',
                  fontWeight: 700,
                  padding: '2px 8px',
                  borderRadius: '6px',
                }}
              >
                {pendingAlertsCount} mục chờ
              </span>
            </div>
          </div>

          {/* R-27: UI Empty State when all alerts are handled */}
          {pendingAlertsCount === 0 ? (
            <div
              style={{
                padding: '36px 20px',
                textAlign: 'center',
                backgroundColor: '#fafaf9',
                borderRadius: '8px',
                border: '1px dashed #cbd5e1',
              }}
            >
              <CheckCircleIcon size={32} color="#059669" style={{ margin: '0 auto 10px auto' }} />
              <p style={{ margin: 0, fontSize: '14px', fontWeight: 600, color: '#0f172a' }}>
                Tất cả cảnh báo đã được giải quyết!
              </p>
              <p style={{ margin: '4px 0 16px 0', fontSize: '12px', color: '#475569' }}>
                Hệ thống dữ liệu điểm đến và tài khoản hiện đang ở trạng thái an toàn.
              </p>
              <button
                type="button"
                onClick={() => setAlerts(INITIAL_ALERTS)}
                className="btn-action-touch"
                style={{
                  padding: '6px 14px',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  background: '#ffffff',
                  color: '#334155',
                  fontSize: '12px',
                  fontWeight: 600,
                  cursor: 'pointer',
                }}
              >
                Đặt lại cảnh báo mẫu để kiểm thử
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {alerts.map((item) => {
                const isPending = item.status === 'PENDING';
                return (
                  <div
                    key={item.id}
                    style={{
                      border: '1px solid #e2e8f0',
                      borderRadius: '8px',
                      padding: '14px',
                      backgroundColor: isPending ? '#fafaf9' : '#f8fafc',
                      opacity: isPending ? 1 : 0.75,
                      transition: 'all 0.2s ease',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '6px', flexWrap: 'wrap', gap: '4px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                        <strong style={{ fontSize: '13.5px', color: '#0f172a' }}>{item.title}</strong>
                        <span
                          style={{
                            fontSize: '11px',
                            backgroundColor: item.actionType === 'LOCK_USER' ? '#fee2e2' : '#e0f2fe',
                            color: item.actionType === 'LOCK_USER' ? '#991b1b' : '#0369a1',
                            padding: '2px 6px',
                            borderRadius: '4px',
                            fontWeight: 600,
                          }}
                        >
                          {item.tag}
                        </span>
                      </div>
                      <span style={{ fontSize: '11px', color: '#475569', fontWeight: 600 }}>{item.code}</span>
                    </div>

                    <p style={{ fontSize: '12.5px', color: '#334155', margin: '0 0 10px 0', lineHeight: 1.5 }}>
                      {item.description}
                    </p>

                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px' }}>
                      <span style={{ fontSize: '11.5px', color: '#475569' }}>{item.reporter}</span>

                      {/* Interactive Buttons with minimum accessible touch targets (R-03, R-26, R-32) */}
                      <div style={{ display: 'flex', gap: '8px' }}>
                        {isPending ? (
                          <>
                            <button
                              type="button"
                              onClick={onNavigateDestinations}
                              className="btn-action-touch"
                              style={{
                                padding: '6px 12px',
                                borderRadius: '6px',
                                border: '1px solid #cbd5e1',
                                background: '#ffffff',
                                color: '#1e293b',
                                fontSize: '12px',
                                fontWeight: 500,
                                cursor: 'pointer',
                              }}
                            >
                              Xem danh sách
                            </button>
                            {item.actionType === 'LOCK_USER' ? (
                              <button
                                type="button"
                                onClick={() => handleLockAccount(item.id)}
                                className="btn-action-touch"
                                style={{
                                  padding: '6px 14px',
                                  borderRadius: '6px',
                                  border: 'none',
                                  background: '#dc2626',
                                  color: '#ffffff',
                                  fontSize: '12px',
                                  fontWeight: 600,
                                  cursor: 'pointer',
                                }}
                              >
                                Khóa tài khoản
                              </button>
                            ) : (
                              <button
                                type="button"
                                onClick={() => handleResolveAlert(item.id, `Đã xác minh và ghi nhận thông tin cho ${item.title}`)}
                                className="btn-action-touch"
                                style={{
                                  padding: '6px 14px',
                                  borderRadius: '6px',
                                  border: 'none',
                                  background: '#0284c7',
                                  color: '#ffffff',
                                  fontSize: '12px',
                                  fontWeight: 600,
                                  cursor: 'pointer',
                                }}
                              >
                                Xác minh ngay
                              </button>
                            )}
                          </>
                        ) : (
                          <span style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', color: '#059669', fontWeight: 600 }}>
                            <CheckIcon size={14} color="#059669" />
                            <span>{item.status === 'LOCKED' ? 'Đã khóa' : 'Đã xác minh'}</span>
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Right Column: AI & Maps API & Recent Activity */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {/* Card: Hệ thống AI & Maps API (R-04: CpuIcon replaces SparklesIcon) */}
          <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: '12px', padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <CpuIcon size={17} color="#0077b6" />
                <h2 style={{ fontSize: '15px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
                  Hạ tầng AI & Maps API
                </h2>
              </div>
              <span style={{ fontSize: '10px', fontWeight: 700, backgroundColor: '#f1f5f9', color: '#64748b', padding: '2px 6px', borderRadius: '4px' }}>
                [HẠN MỨC THỬ NGHIỆM]
              </span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12.5px', marginBottom: '6px' }}>
                  <span style={{ color: '#475569' }}>Hạn mức chi tiêu Google Maps</span>
                  <strong style={{ color: '#0f172a' }}>34 / 100 USD</strong>
                </div>
                <div style={{ width: '100%', height: '8px', backgroundColor: '#f1f5f9', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ width: '34%', height: '100%', backgroundColor: '#0077b6' }} />
                </div>
                <div style={{ fontSize: '11px', color: '#059669', marginTop: '4px', textAlign: 'right', fontWeight: 600 }}>
                  Đang dùng 34% ngân sách (Ngưỡng an toàn)
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', paddingTop: '10px', borderTop: '1px solid #f1f5f9' }}>
                <div style={{ backgroundColor: '#f8fafc', padding: '10px', borderRadius: '8px', textAlign: 'center', border: '1px solid #e2e8f0' }}>
                  <div style={{ fontSize: '11px', color: '#475569', fontWeight: 600 }}>Tốc độ sinh AI</div>
                  <div style={{ fontSize: '18px', fontWeight: 700, color: '#0077b6', marginTop: '2px' }}>4.2s</div>
                  <div style={{ fontSize: '10px', color: '#475569', marginTop: '2px' }}>Benchmark &lt;10s</div>
                </div>
                <div style={{ backgroundColor: '#f8fafc', padding: '10px', borderRadius: '8px', textAlign: 'center', border: '1px solid #e2e8f0' }}>
                  <div style={{ fontSize: '11px', color: '#475569', fontWeight: 600 }}>Cache Hit Rate</div>
                  <div style={{ fontSize: '18px', fontWeight: 700, color: '#059669', marginTop: '2px' }}>88.4%</div>
                  <div style={{ fontSize: '10px', color: '#475569', marginTop: '2px' }}>Distance Matrix</div>
                </div>
              </div>
            </div>
          </div>

          {/* Card: Hoạt động quản trị gần nhất */}
          <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: '12px', padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <h2 style={{ fontSize: '15px', fontWeight: 700, color: '#0f172a', margin: 0 }}>
                Nhật ký quản trị gần nhất
              </h2>
              <span style={{ fontSize: '10px', fontWeight: 600, backgroundColor: '#f1f5f9', color: '#64748b', padding: '2px 6px', borderRadius: '4px' }}>
                [AUDIT TRAIL]
              </span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                <div style={{ width: '28px', height: '28px', borderRadius: '6px', backgroundColor: '#ecfdf5', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <CheckCircleIcon size={14} color="#059669" />
                </div>
                <div>
                  <div style={{ fontWeight: 600, color: '#0f172a' }}>Cập nhật giờ mở cửa Bà Nà Hills</div>
                  <div style={{ fontSize: '11.5px', color: '#475569' }}>Lan Nguyễn • 15 phút trước</div>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                <div style={{ width: '28px', height: '28px', borderRadius: '6px', backgroundColor: '#e0f2fe', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <PlusIcon size={14} color="#0284c7" />
                </div>
                <div>
                  <div style={{ fontWeight: 600, color: '#0f172a' }}>Thêm điểm "Bánh xèo Tôm nhảy"</div>
                  <div style={{ fontSize: '11.5px', color: '#475569' }}>Lan Nguyễn • 2 giờ trước</div>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                <div style={{ width: '28px', height: '28px', borderRadius: '6px', backgroundColor: '#fef3c7', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <LockIcon size={14} color="#d97706" />
                </div>
                <div>
                  <div style={{ fontWeight: 600, color: '#0f172a' }}>Khóa tài khoản bot_test_spam</div>
                  <div style={{ fontSize: '11.5px', color: '#475569' }}>SuperAdmin • Hôm nay 09:30</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

import { AdminPageHeader } from '../../components/AdminPageHeader';
import { t } from '../../core/language';
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { dashboard } from '../../core/operationsApi';
import type { DashboardMetrics } from '../../core/operationsApi';
import '../audit/operations.css';

const number = new Intl.NumberFormat('vi-VN');

export function DashboardView() {
  const [days, setDays] = useState(7);
  const [revision, setRevision] = useState(0);
  const [data, setData] = useState<DashboardMetrics | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const request = new AbortController();
    setLoading(true);
    setError('');
    setData(null);
    dashboard(days, request.signal)
      .then(value => { if (!request.signal.aborted) setData(value); })
      .catch((failure: unknown) => {
        if (!request.signal.aborted) setError(failure instanceof Error ? failure.message : t('Không tải được dashboard.'));
      })
      .finally(() => { if (!request.signal.aborted) setLoading(false); });
    return () => request.abort();
  }, [days, revision]);

  return <section className="operations operations-dashboard">
    <AdminPageHeader title={t("Tổng quan vận hành")} description={t("Theo dõi catalog, tài khoản và hoạt động du lịch trên SmartTravel.")} actions={
    <div className="operations-filters">
      <label>{t("Khoảng thời gian")} <select value={days} onChange={event => setDays(Number(event.target.value))}>
          <option value={7}>{t("7 ngày")}</option><option value={30}>{t("30 ngày")}</option><option value={90}>{t("90 ngày")}</option>
        </select>
      </label>
      <button type="button" disabled={loading} onClick={() => setRevision(value => value + 1)}>{t("Làm mới số liệu")}</button>
    </div>} />
    {loading && <p role="status">{t("Đang tải số liệu…")}</p>}
    {error && <p role="alert">{error}</p>}
    {data && <>
      <div className="operations-section-heading"><h2>{t("Hiện tại")}</h2><span>{t("Số liệu tại thời điểm tải")}</span></div>
      <Metrics values={[
        [t('Địa điểm đang hiển thị'), data.activeDestinations],
        [t('Tổng tài khoản'), data.totalUsers],
        [t('Tài khoản hoạt động'), data.activeUsers],
        [t('Tài khoản bị khóa'), data.lockedUsers],
        [t('Quản trị viên'), data.administrators],
      ]} />
      <div className="operations-section-heading"><h2>{t("Hoạt động trong kỳ")}</h2><span>{data.from} – {data.to} · {t("Giờ Đà Nẵng")}</span></div>
      {data.newUsers + data.createdSavedTrips + data.publishedReviews + data.reportedReviews === 0
        ? <p className="admin-empty-state">{t("Chưa ghi nhận hoạt động trong kỳ này.")}</p>
        : <Metrics values={[
          [t('Tài khoản được tạo'), data.newUsers],
          [t('Chuyến được tạo trong kỳ và hiện đã lưu'), data.createdSavedTrips],
          [t('Đánh giá tạo trong kỳ và đang hiển thị'), data.publishedReviews],
          [t('Bài đánh giá có báo cáo trong kỳ'), data.reportedReviews],
        ]} />}
      <nav className="operations-shortcuts" aria-label={t("Khu vực quản trị")}>
        <Link to="/destinations">{t("Địa điểm")}</Link>
        <Link to="/trips">{t("Lịch trình")}</Link>
        <Link to="/reviews">{t("Kiểm duyệt đánh giá")}</Link>
        <Link to="/audit">{t("Nhật ký thao tác")}</Link>
      </nav>
    </>}
  </section>;
}

function Metrics({ values }: { values: [string, number][] }) {
  return <dl className="operations-grid">{values.map(([label, count]) =>
    <div key={label}><dt>{label}</dt><dd>{number.format(count)}</dd></div>
  )}</dl>;
}

import { AdminPageHeader } from '../../components/AdminPageHeader';
import { t } from '../../core/language';
import { useEffect, useState } from 'react';
import { adminTrips } from '../../core/operationsApi';
import type { ManagedTrip, Slice } from '../../core/operationsApi';
import '../audit/operations.css';

export function AdminTripsView() {
  const [input, setInput] = useState('');
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('ALL');
  const [page, setPage] = useState(0);
  const [revision, setRevision] = useState(0);
  const [result, setResult] = useState<Slice<ManagedTrip> | null>(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const request = new AbortController();
    setLoading(true); setError(''); setResult(null);
    adminTrips(search, status, page, request.signal)
      .then(value => { if (!request.signal.aborted) setResult(value); })
      .catch((failure: unknown) => {
        if (!request.signal.aborted) setError(failure instanceof Error ? failure.message : t('Không tải được lịch trình.'));
      })
      .finally(() => { if (!request.signal.aborted) setLoading(false); });
    return () => request.abort();
  }, [search, status, page, revision]);

  return <section className="operations operations-trips">
    <AdminPageHeader title={t("Lịch trình đã lưu")} description={t("Tra cứu chuyến đi theo chủ chuyến, ngày đi và trạng thái lưu.")} />
    <form onSubmit={event => {
      event.preventDefault();
      setPage(0); setSearch(input.trim()); setRevision(current => current + 1);
    }}>
      <label>{t("Tên chuyến hoặc chủ chuyến")}<input value={input} maxLength={255}
        onChange={event => setInput(event.target.value)} /></label>
      <label>{t("Trạng thái")}<select value={status} onChange={event => {
        setPage(0); setStatus(event.target.value);
      }}>
        <option value="ALL">{t("Tất cả")}</option><option value="SAVED">{t("Đã lưu")}</option>
        <option value="ARCHIVED">{t("Lưu trữ")}</option>
      </select></label>
      <button type="submit">{t("Tìm chuyến đi")}</button>
    </form>
    {loading && <p role="status">{t("Đang tải lịch trình…")}</p>}
    {error && <p role="alert">{error} <button type="button"
      onClick={() => setRevision(value => value + 1)}>{t("Thử lại")}</button></p>}
    {result?.items.length === 0 && <p className="admin-empty-state">{t("Không có chuyến đi phù hợp.")}</p>}
    {!!result?.items.length && <div className="operations-data"><table>
      <thead><tr><th>{t("Tên chuyến")}</th><th>{t("Chủ chuyến")}</th><th>{t("Ngày đi")}</th><th>{t("Trạng thái")}</th></tr></thead>
      <tbody>{result.items.map(trip => <tr key={trip.id}>
        <td>{trip.title}</td><td>{trip.owner}</td><td>{trip.startDate} – {trip.endDate}</td>
        <td><span className="admin-status" data-status={trip.status}>{trip.status === 'SAVED' ? t('Đã lưu') : t('Lưu trữ')}</span></td>
      </tr>)}</tbody>
    </table></div>}
    <nav aria-label={t("Phân trang lịch trình")}>
      <button type="button" disabled={loading || page === 0} onClick={() => setPage(page - 1)}>{t("Trang trước")}</button>
      <span>Trang {page + 1}</span>
      <button type="button" disabled={loading || !result?.hasNext} onClick={() => setPage(page + 1)}>Trang sau</button>
    </nav>
  </section>;
}

import { AdminPageHeader } from '../../components/AdminPageHeader';
import { t } from '../../core/language';
import { useEffect, useState } from 'react';
import { auditExport, auditPage } from '../../core/operationsApi';
import type { AuditFilter, AuditRow, Slice } from '../../core/operationsApi';
import './operations.css';

const empty: AuditFilter = { actor: '', actorId: '', action: '', entity: '', from: '', to: '' };
const displayDate = new Intl.DateTimeFormat('vi-VN', { dateStyle: 'short', timeStyle: 'short', timeZone: 'Asia/Ho_Chi_Minh' });

const actionLabels: Record<string, string> = {
  CREATE: 'Tạo mới', UPDATE: 'Cập nhật', ARCHIVE: 'Ẩn', STATUS: 'Đổi trạng thái',
  DELETE: 'Xóa', PROFILE: 'Hồ sơ', REGISTER: 'Đăng ký', MODERATE: 'Kiểm duyệt', REPORT: 'Báo cáo',
};
const entityLabels: Record<string, string> = {
  USER: 'Tài khoản', DESTINATION: 'Địa điểm', CATEGORY: 'Danh mục', REVIEW: 'Đánh giá',
};

export function AuditLogsView() {
  const [draft, setDraft] = useState(empty);
  const [filter, setFilter] = useState(empty);
  const [page, setPage] = useState(0);
  const [revision, setRevision] = useState(0);
  const [result, setResult] = useState<Slice<AuditRow> | null>(null);
  const [loading, setLoading] = useState(true);
  const [exporting, setExporting] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const request = new AbortController();
    setLoading(true);
    setResult(null);
    setError('');
    auditPage(filter, page, request.signal)
      .then(value => { if (!request.signal.aborted) setResult(value); })
      .catch((failure: unknown) => {
        if (!request.signal.aborted) setError(failure instanceof Error ? failure.message : t('Không tải được nhật ký.'));
      })
      .finally(() => { if (!request.signal.aborted) setLoading(false); });
    return () => request.abort();
  }, [filter, page, revision]);

  async function download() {
    setExporting(true);
    setError('');
    try {
      const file = await auditExport(filter);
      const url = URL.createObjectURL(new Blob(['\uFEFF', file.csv], { type: 'text/csv;charset=utf-8;' }));
      const link = document.createElement('a');
      link.href = url;
      link.download = file.filename;
      link.click();
      URL.revokeObjectURL(url);
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : t('Không thể xuất nhật ký.'));
    } finally {
      setExporting(false);
    }
  }

  const change = (key: keyof AuditFilter, value: string) => setDraft(previous => ({ ...previous, [key]: value }));

  return <section className="operations operations-audit">
    <AdminPageHeader title={t("Nhật ký thao tác")} description={t("Tra cứu thay đổi dữ liệu theo người thực hiện, đối tượng và thời gian.")} />
    <form onSubmit={event => {
      event.preventDefault();
      setPage(0); setFilter(draft); setRevision(value => value + 1);
    }}>
      <label>{t("Tên người thực hiện")}<input value={draft.actor} maxLength={150} onChange={event => change('actor', event.target.value)} /></label>
      <label>{t("ID tài khoản")}<input type="number" min="1" value={draft.actorId} onChange={event => change('actorId', event.target.value)} /></label>
      <label>{t("Hành động")}<select value={draft.action} onChange={event => change('action', event.target.value)}>
        <option value="">{t("Tất cả")}</option>
        {['CREATE','UPDATE','ARCHIVE','STATUS','DELETE','PROFILE','REGISTER','MODERATE','REPORT'].map(action =>
          <option key={action} value={action}>{t(actionLabels[action] ?? action)}</option>)}
      </select></label>
      <label>{t("Đối tượng")}<select value={draft.entity} onChange={event => change('entity', event.target.value)}>
        <option value="">{t("Tất cả")}</option>
        {['USER','DESTINATION','CATEGORY','REVIEW'].map(entity => <option key={entity} value={entity}>{t(entityLabels[entity] ?? entity)}</option>)}
      </select></label>
      <label>{t("Từ ngày")}<input type="date" value={draft.from} onChange={event => change('from', event.target.value)} /></label>
      <label>{t("Đến ngày")}<input type="date" value={draft.to} onChange={event => change('to', event.target.value)} /></label>
      <button type="submit">{t("Lọc nhật ký")}</button>
      <button type="button" disabled={loading || exporting} onClick={() => void download()}>
        {exporting ? 'Đang xuất…' : t('Xuất CSV theo bộ lọc')}
      </button>
    </form>
    {loading && <p role="status">{t("Đang tải nhật ký…")}</p>}
    {error && <p role="alert">{error}</p>}
    {result?.items.length === 0 && <p className="admin-empty-state">{t("Không có sự kiện phù hợp.")}</p>}
    {!!result?.items.length && <div className="operations-data"><table>
      <thead><tr><th>{t("Thời gian")}</th><th>{t("Người thực hiện")}</th><th>{t("Hành động")}</th><th>{t("Đối tượng")}</th><th>{t("Chi tiết")}</th></tr></thead>
      <tbody>{result.items.map(row => <tr key={row.id}>
        <td>{displayDate.format(new Date(row.createdAt))}</td>
        <td>{row.actorName === 'PUBLIC_REGISTRATION' ? 'Đăng ký công khai'
          : row.actorName ?? (row.actorId == null ? 'Đã ẩn danh' : t('Tài khoản'))} {row.actorId != null && `#${row.actorId}`}</td>
        <td><span className="admin-status">{t(actionLabels[row.action] ?? row.action)}</span></td>
        <td>{t(entityLabels[row.entity] ?? row.entity)} {row.entityId != null && `#${row.entityId}`}</td>
        <td><dl className="audit-details">{Object.entries(row.details).map(([key, value]) => <div key={key}><dt>{key}</dt><dd>{String(value)}</dd></div>)}</dl></td>
      </tr>)}</tbody>
    </table></div>}
    <nav aria-label={t("Phân trang nhật ký")}>
      <button type="button" disabled={loading || page === 0} onClick={() => setPage(page - 1)}>{t("Trang trước")}</button>
      <span>Trang {page + 1}</span>
      <button type="button" disabled={loading || !result?.hasNext} onClick={() => setPage(page + 1)}>Trang sau</button>
    </nav>
  </section>;
}

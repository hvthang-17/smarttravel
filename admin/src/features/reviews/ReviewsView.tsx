import { AdminPageHeader } from '../../components/AdminPageHeader';
import { t } from '../../core/language';
import { useEffect, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { fetchReviewPage, updateReviewStatus } from '../../core/reviewApi';
import type { ModerationPage, ModerationReview, ReportReason, ReviewStatus } from '../../core/reviewApi';
import './reviews.css';

const reasonLabels: Record<ReportReason, string> = {
  SPAM: t('Quảng cáo hoặc spam'),
  ABUSE: t('Nội dung xúc phạm'),
  IRRELEVANT: t('Không liên quan'),
  OTHER: t('Lý do khác'),
};

const dateFormat = new Intl.DateTimeFormat('vi-VN', {
  dateStyle: 'medium',
  timeZone: 'Asia/Ho_Chi_Minh',
});

export function ReviewsView() {
  const [params] = useSearchParams();
  const rawId = params.get('destinationId');
  const destinationId = rawId && /^\d+$/.test(rawId) && Number(rawId) > 0 ? rawId : null;
  return <ReviewQueue key={destinationId ?? 'all'} destinationId={destinationId} />;
}

function ReviewQueue({ destinationId }: { destinationId: string | null }) {
  const [reportedOnly, setReportedOnly] = useState(!destinationId);
  const [status, setStatus] = useState<ReviewStatus | 'ALL'>('ALL');
  const [page, setPage] = useState(0);
  const [revision, setRevision] = useState(0);
  const [result, setResult] = useState<ModerationPage | null>(null);
  const [loading, setLoading] = useState(true);
  const [pending, setPending] = useState<number | null>(null);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');

  useEffect(() => {
    const request = new AbortController();
    setLoading(true);
    setError('');
    fetchReviewPage(status, reportedOnly, page, destinationId, request.signal)
      .then(data => { if (!request.signal.aborted) setResult(data); })
      .catch((failure: unknown) => {
        if (!request.signal.aborted) {
          setResult(null);
          setError(failure instanceof Error ? failure.message : t('Không tải được đánh giá.'));
        }
      })
      .finally(() => { if (!request.signal.aborted) setLoading(false); });
    return () => request.abort();
  }, [status, reportedOnly, page, destinationId, revision]);

  async function moderate(review: ModerationReview) {
    const next = review.status === 'PUBLISHED' ? 'HIDDEN' : 'PUBLISHED';
    setError('');
    setMessage('');
    setPending(review.id);
    try {
      await updateReviewStatus(review.id, next);
      setMessage(next === 'HIDDEN' ? 'Đã ẩn đánh giá.' : t('Đã hiện đánh giá.'));
      setRevision(value => value + 1);
    } catch (failure) {
      setError(failure instanceof Error ? failure.message : t('Không thể cập nhật đánh giá.'));
    } finally {
      setPending(null);
    }
  }

  return (
    <section className="review-queue">
      <AdminPageHeader title={t('Kiểm duyệt đánh giá')}
        description={t('Xem báo cáo của người dùng và quản lý bài đánh giá hiển thị trên SmartTravel.')} />
      <div className="review-queue-filters">
        <label>{t("Trạng thái")} <select value={status} onChange={event => {
            setPage(0);
            setStatus(event.target.value as ReviewStatus | 'ALL');
          }}>
            <option value="ALL">{t("Tất cả")}</option>
            <option value="PUBLISHED">{t("Đang hiển thị")}</option>
            <option value="HIDDEN">{t("Đã ẩn")}</option>
          </select>
        </label>
        <label className="review-report-filter">
          <input type="checkbox" checked={reportedOnly} onChange={event => {
            setPage(0);
            setReportedOnly(event.target.checked);
          }} />{t("Chỉ bài có báo cáo")} </label>
        {destinationId && <Link to="/reviews">{t("Xóa lọc theo địa điểm")}</Link>}
      </div>
      {message && <p role="status" className="review-feedback">{message}</p>}
      {error && <p role="alert">{error} {!result && <button type="button"
        onClick={() => setRevision(value => value + 1)}>{t("Thử lại")}</button>}</p>}
      {loading && <p role="status">{t("Đang tải đánh giá…")}</p>}
      {!loading && result?.items.length === 0 && <p className="admin-empty-state">{t("Không có đánh giá phù hợp.")}</p>}
      {!loading && result?.items.map(review => (
        <article className="review-queue-row" data-status={review.status} key={review.id}>
          <div>
            <h2>{review.destinationName}</h2>
            <div className="review-meta"><span className="review-score">{review.rating}/5</span>
              <time dateTime={review.createdAt}>{dateFormat.format(new Date(review.createdAt))}</time>
              <span className="admin-status" data-status={review.status}>{review.status === 'PUBLISHED' ? t('Đang hiển thị') : t('Đã ẩn')}</span>
            </div>
            {review.comment && <p className="review-queue-comment">{review.comment}</p>}
            {Object.keys(review.reports).length > 0 && (
              <p className="review-report-reasons">{t("Báo cáo ·")} {
                (Object.entries(review.reports) as [ReportReason, number][])
                  .map(([reason, count]) => `${t(reasonLabels[reason] ?? reason)} (${count})`).join(' · ')
              }</p>
            )}
          </div>
          <button type="button" disabled={pending !== null || loading} onClick={() => void moderate(review)}>
            {pending === review.id ? 'Đang cập nhật…' : review.status === 'PUBLISHED' ? 'Ẩn đánh giá' : t('Hiện đánh giá')}
          </button>
        </article>
      ))}
      {result && (page > 0 || result.hasNext) && (
        <nav aria-label={t("Phân trang đánh giá")} className="review-queue-pagination">
          <button type="button" disabled={page === 0 || loading} onClick={() => setPage(page - 1)}>{t("Trang trước")}</button>
          <span>Trang {page + 1}</span>
          <button type="button" disabled={!result.hasNext || loading} onClick={() => setPage(page + 1)}>Trang sau</button>
        </nav>
      )}
    </section>
  );
}

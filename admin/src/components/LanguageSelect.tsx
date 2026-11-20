import { useState } from 'react';
import { API_BASE_URL, apiFetch, getStoredToken } from '../core/session';
import { setUiLanguage, useUiLanguage } from '../core/language';
import type { Language } from '../core/language';
import type { AuthUser } from '../types/auth';

export function LanguageSelect({ user }: { user: AuthUser | null | undefined }) {
  const language = useUiLanguage();
  const [pending, setPending] = useState(false);
  const [error, setError] = useState('');

  async function change(value: Language) {
    if (!user) { setUiLanguage(value); return; }
    const token = getStoredToken();
    setPending(true);
    setError('');
    try {
      const response = await apiFetch(`${API_BASE_URL}/auth/profile`, {
        method: 'PUT', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fullName: user.fullName, language: value }),
      });
      const body = await response.json();
      if (!response.ok || body.success !== true || body.data?.travelerProfile?.language !== value) {
        throw new Error('Language was not saved');
      }
      if (getStoredToken() === token) setUiLanguage(value);
    } catch {
      setError(language === 'en' ? 'Could not save language. Retry.' : 'Không lưu được ngôn ngữ. Hãy thử lại.');
    } finally {
      setPending(false);
    }
  }

  return <div>
    <label>
      <span className="sr-only">Language / Ngôn ngữ</span>
      <select aria-label="Language / Ngôn ngữ" value={language} disabled={pending}
        onChange={event => void change(event.target.value as Language)}
        style={{ minHeight: 44, maxWidth: 130, border: '1px solid #94a3b8', borderRadius: 8, padding: 6 }}>
        <option value="vi">Tiếng Việt</option><option value="en">English</option>
      </select>
    </label>
    {error && <p role="alert">{error}</p>}
  </div>;
}

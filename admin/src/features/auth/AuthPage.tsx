import { t } from '../../core/language';
import React, { useState } from 'react';
import {
  WavesIcon,
  MailIcon,
  LockIcon,
  UserIcon,
  EyeIcon,
  EyeOffIcon,
  AlertTriangleIcon,
  ShieldIcon,
  CheckCircleIcon,
  MapPinIcon,
  InfoIcon,
} from '../../components/Icons';
import { loginApi, registerApi } from '../../core/authApi';
import { AuthUser } from '../../types/auth';

interface AuthPageProps {
  initialView?: 'login' | 'register';
  onLoginSuccess: (user: AuthUser) => void;
  onRegisterSuccess?: (user: AuthUser) => void;
}

export const AuthPage: React.FC<AuthPageProps> = ({
  initialView = 'login',
  onLoginSuccess,
  onRegisterSuccess,
}) => {
  const [currentView, setCurrentView] = useState<'login' | 'register'>(initialView);
  const [slideDirection, setSlideDirection] = useState<'left' | 'right'>('right');

  // Login Form States
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [showLoginPassword, setShowLoginPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loginLoading, setLoginLoading] = useState(false);
  const [loginError, setLoginError] = useState<string | null>(null);

  // Register Form States
  const [regFullName, setRegFullName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regConfirmPassword, setRegConfirmPassword] = useState('');
  const [showRegPassword, setShowRegPassword] = useState(false);
  const [regLoading, setRegLoading] = useState(false);
  const [regError, setRegError] = useState<string | null>(null);

  const switchView = (view: 'login' | 'register') => {
    if (view === currentView) return;
    setSlideDirection(view === 'register' ? 'right' : 'left');
    setCurrentView(view);
    setLoginError(null);
    setRegError(null);
  };

  const handleLoginSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoginError(null);

    if (!loginEmail.trim() || !loginPassword) {
      setLoginError(t('Vui lòng nhập đầy đủ địa chỉ email và mật khẩu.'));
      return;
    }

    setLoginLoading(true);
    try {
      const user = await loginApi({
        email: loginEmail.trim(),
        password: loginPassword,
        remember: rememberMe,
      });
      onLoginSuccess(user);
    } catch (err: unknown) {
      setLoginError(err instanceof Error ? err.message : t('Đăng nhập không thành công. Vui lòng kiểm tra lại thông tin.'));
    } finally {
      setLoginLoading(false);
    }
  };

  const handleRegisterSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setRegError(null);

    if (!regFullName.trim()) {
      setRegError(t('Vui lòng nhập họ và tên.'));
      return;
    }
    if (!regEmail.trim()) {
      setRegError(t('Vui lòng nhập địa chỉ email hợp lệ.'));
      return;
    }
    if (regPassword.length < 8 || regPassword.length > 72) {
      setRegError(t('Mật khẩu phải có độ dài từ 8 đến 72 ký tự.'));
      return;
    }
    if (regPassword !== regConfirmPassword) {
      setRegError(t('Mật khẩu nhập lại không trùng khớp.'));
      return;
    }

    setRegLoading(true);
    try {
      const user = await registerApi({
        fullName: regFullName.trim(),
        email: regEmail.trim(),
        password: regPassword,
      });
      if (onRegisterSuccess) {
        onRegisterSuccess(user);
      } else {
        onLoginSuccess(user);
      }
    } catch (err: unknown) {
      setRegError(err instanceof Error ? err.message : t('Đăng ký không thành công. Vui lòng thử lại.'));
    } finally {
      setRegLoading(false);
    }
  };

  const isRegister = currentView === 'register';

  return (
    <div className="auth-layout-container">
      {/* 1. Hero Scenic Banner (Left in Login mode, Slides to Right in Register mode) */}
      <div className={`auth-hero-banner ${isRegister ? 'is-register' : ''}`}>
        {/* Scenic Background 1: Golden Bridge (Bà Nà Hills) - Login Mode */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            backgroundImage: `linear-gradient(145deg, rgba(3, 4, 94, 0.90) 0%, rgba(0, 119, 182, 0.82) 100%), url("https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=1600&q=80")`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
            opacity: isRegister ? 0 : 1,
            transition: 'opacity 0.7s cubic-bezier(0.4, 0, 0.2, 1)',
            zIndex: 0,
            backgroundColor: '#03045e',
          }}
        />

        {/* Scenic Background 2: Dragon Bridge (Cầu Rồng Sông Hàn) - Register Mode */}
        <div
          style={{
            position: 'absolute',
            inset: 0,
            backgroundImage: `linear-gradient(145deg, rgba(10, 25, 47, 0.92) 0%, rgba(2, 132, 199, 0.84) 100%), url("https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=1600&q=80")`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
            opacity: isRegister ? 1 : 0,
            transition: 'opacity 0.7s cubic-bezier(0.4, 0, 0.2, 1)',
            zIndex: 0,
            backgroundColor: '#0a192f',
          }}
        />

        {/* Hero Banner Foreground Content */}
        <div style={{ position: 'relative', zIndex: 1, height: '100%', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <div>
            {/* Brand Header */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '28px' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '10px',
                  backgroundColor: 'rgba(255, 255, 255, 0.16)',
                  border: '1px solid rgba(255, 255, 255, 0.28)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}
              >
                <WavesIcon size={22} color="#ffffff" strokeWidth={2.2} />
              </div>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', letterSpacing: '-0.3px' }}>
                    SmartTravel
                  </span>
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      backgroundColor: 'rgba(255, 255, 255, 0.2)',
                      color: '#ffffff',
                      padding: '2px 6px',
                      borderRadius: '4px',
                      border: '1px solid rgba(255, 255, 255, 0.3)',
                      textTransform: 'uppercase',
                    }}
                  >
                    ADMIN PORTAL
                  </span>
                </div>
                <div style={{ fontSize: '12px', color: '#cbd5e1' }}>{t("Dữ liệu Du lịch Thông minh Đà Nẵng")} </div>
              </div>
            </div>

            {/* Dynamic Landmark Details Synchronized with Mode */}
            <div key={currentView} className="animate-fade-in">
              <div className="auth-hero-badge">
                <MapPinIcon size={14} color="#38bdf8" />
                <span>{isRegister ? 'Cầu Rồng Sông Hàn, Đà Nẵng' : t('Cầu Vàng Bà Nà Hills, Đà Nẵng')}</span>
              </div>

              <h2 style={{ fontSize: '26px', fontWeight: 700, lineHeight: 1.35, color: '#ffffff', margin: '0 0 16px 0', letterSpacing: '-0.4px' }}>
                {isRegister
                  ? 'Biểu tượng Cầu Rồng và nhịp sống đêm bên dòng sông Hàn'
                  : t('Hệ thống điều hành và phân tích dữ liệu du lịch Đà Nẵng')}
              </h2>

              <p style={{ fontSize: '14.5px', color: '#e2e8f0', lineHeight: 1.6, margin: '0 0 28px 0' }}>
                {isRegister
                  ? 'Cầu Rồng bắc qua sông Hàn là kiệt tác kiến trúc biểu trưng cho khát vọng phát triển, với màn trình diễn phun lửa, phun nước sống động và chuỗi lễ hội du lịch quốc tế kết nối đôi bờ sông Hàn.'
                  : t('Nền tảng kiểm soát cơ sở dữ liệu điểm đến, đồng bộ lịch trình khám phá di sản và điều phối phân quyền nhân sự nội bộ.')}
              </p>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                <div className="auth-hero-feature">
                  <div className="auth-hero-feature-icon">
                    <CheckCircleIcon size={14} color="#ffffff" />
                  </div>
                  <span style={{ fontSize: '13.5px', color: '#f1f5f9' }}>
                    {isRegister
                      ? 'Màn trình diễn phun lửa, phun nước sống động vào các tối cuối tuần bên bờ sông Hàn'
                      : t('Quản lý điểm đến di sản, biển đảo và ẩm thực địa phương')}
                  </span>
                </div>
                <div className="auth-hero-feature">
                  <div className="auth-hero-feature-icon">
                    <CheckCircleIcon size={14} color="#ffffff" />
                  </div>
                  <span style={{ fontSize: '13.5px', color: '#f1f5f9' }}>
                    {isRegister
                      ? 'Đăng ký tài khoản tham gia đóng góp dữ liệu và trải nghiệm hệ thống SmartTravel'
                      : t('Chỉ tài khoản quản trị viên được thay đổi dữ liệu và quản lý người dùng')}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Bottom Location Credit */}
          <div style={{ fontSize: '12px', color: '#e2e8f0', borderTop: '1px solid rgba(255, 255, 255, 0.2)', paddingTop: '16px' }}>
            {isRegister
              ? 'Cầu Rồng Đà Nẵng & Sông Hàn lung linh về đêm • SmartTravel Portal © 2026'
              : t('Cầu Vàng Bà Nà Hills & Bãi biển Mỹ Khê • SmartTravel Portal © 2026')}
          </div>
        </div>
      </div>

      {/* 2. Form Panel (Right in Login mode, Slides to Left in Register mode) */}
      <div className={`auth-form-panel ${isRegister ? 'is-register' : ''}`}>
        <div className="auth-form-wrapper">

          {/* Dynamic Animated View Area */}
          <div key={currentView} className={slideDirection === 'right' ? 'auth-slide-in-right' : 'auth-slide-in-left'}>
            {currentView === 'login' ? (
              /* LOGIN FORM */
              <div>
                <div style={{ marginBottom: '22px' }}>
                  <h1 style={{ margin: '0 0 6px 0', fontSize: '22px', fontWeight: 700, color: '#0f172a' }}>{t("Chào mừng trở lại")} </h1>
                  <p style={{ margin: 0, fontSize: '13.5px', color: '#475569' }}>{t("Đăng nhập tài khoản để vào bàn làm việc quản trị.")} </p>
                </div>

                {loginError && (
                  <div role="alert" style={{ backgroundColor: '#fef2f2', border: '1px solid #fecaca', borderRadius: '8px', padding: '10px 14px', marginBottom: '18px', display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
                    <AlertTriangleIcon size={16} color="#dc2626" style={{ marginTop: '2px', flexShrink: 0 }} />
                    <span style={{ fontSize: '13px', color: '#b91c1c', lineHeight: 1.4 }}>{loginError}</span>
                  </div>
                )}

                <form onSubmit={handleLoginSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <div className="auth-input-group">
                    <label className="auth-label">{t("Địa chỉ email")}</label>
                    <div className="auth-input-wrapper">
                      <div className="auth-input-icon"><MailIcon size={16} /></div>
                      <input
                        type="email"
                        required
                        id="login-email" aria-label={t("Địa chỉ email")} autoComplete="email" value={loginEmail}
                        onChange={(e) => setLoginEmail(e.target.value)}
                        placeholder="admin@smarttravel.vn"
                        className="auth-input"
                      />
                    </div>
                  </div>

                  <div className="auth-input-group">
                    <label className="auth-label">{t("Mật khẩu")}</label>
                    <div className="auth-input-wrapper">
                      <div className="auth-input-icon"><LockIcon size={16} /></div>
                      <input
                        type={showLoginPassword ? 'text' : 'password'}
                        required
                        id="login-password" aria-label={t("Mật khẩu")} autoComplete="current-password" value={loginPassword}
                        onChange={(e) => setLoginPassword(e.target.value)}
                        placeholder="••••••••"
                        className="auth-input"
                        style={{ paddingRight: '42px' }}
                      />
                      <button
                        type="button"
                        onClick={() => setShowLoginPassword(!showLoginPassword)}
                        aria-label={showLoginPassword ? t('Ẩn mật khẩu') : t('Hiện mật khẩu')}
                        className="auth-password-toggle"
                      >
                        {showLoginPassword ? <EyeOffIcon size={16} /> : <EyeIcon size={16} />}
                      </button>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', fontSize: '13px', color: '#475569' }}>
                      <input
                        type="checkbox"
                        checked={rememberMe}
                        onChange={(e) => setRememberMe(e.target.checked)}
                        style={{ cursor: 'pointer', accentColor: '#0077b6' }}
                      />
                      <span>{t("Ghi nhớ phiên đăng nhập")}</span>
                    </label>
                    <span style={{ fontSize: '12px', color: '#0077b6', fontWeight: 600 }}>{t("RBAC Bảo mật")}</span>
                  </div>

                  <button
                    type="submit"
                    disabled={loginLoading}
                    className="auth-btn-primary btn-action-touch"
                  >
                    {loginLoading ? (
                      <span>{t("Đang xác thực...")}</span>
                    ) : (
                      <>
                        <ShieldIcon size={17} color="#ffffff" />
                        <span>{t("Đăng nhập vào hệ thống")}</span>
                      </>
                    )}
                  </button>

                  {/* 1.3 Action Link below Login Button to Switch to Register */}
                  <div className="auth-switch-link-wrapper">{t("Chưa có tài khoản?")}{' '}
                    <button
                      type="button"
                      onClick={() => switchView('register')}
                      className="auth-switch-link-btn"
                    >{t("Đăng ký tài khoản ngay")} </button>
                  </div>
                </form>
              </div>
            ) : (
              /* REGISTER FORM */
              <div>
                <div style={{ marginBottom: '22px' }}>
                  <h1 style={{ margin: '0 0 6px 0', fontSize: '22px', fontWeight: 700, color: '#0f172a' }}>{t("Tạo tài khoản mới")} </h1>
                  <p style={{ margin: 0, fontSize: '13.5px', color: '#475569' }}>{t("Đăng ký tài khoản tham gia hệ thống SmartTravel.")} </p>
                </div>

                {regError && (
                  <div role="alert" style={{ backgroundColor: '#fef2f2', border: '1px solid #fecaca', borderRadius: '8px', padding: '10px 14px', marginBottom: '18px', display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
                    <AlertTriangleIcon size={16} color="#dc2626" style={{ marginTop: '2px', flexShrink: 0 }} />
                    <span style={{ fontSize: '13px', color: '#b91c1c', lineHeight: 1.4 }}>{regError}</span>
                  </div>
                )}

                <form onSubmit={handleRegisterSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
                  <div className="auth-input-group">
                    <label className="auth-label">{t("Họ và tên")}</label>
                    <div className="auth-input-wrapper">
                      <div className="auth-input-icon"><UserIcon size={16} /></div>
                      <input
                        type="text"
                        required
                        id="register-name" aria-label={t("Họ và tên")} autoComplete="name" value={regFullName}
                        onChange={(e) => setRegFullName(e.target.value)}
                        placeholder={t("Nguyễn Văn A")}
                        className="auth-input"
                      />
                    </div>
                  </div>

                  <div className="auth-input-group">
                    <label className="auth-label">{t("Địa chỉ email")}</label>
                    <div className="auth-input-wrapper">
                      <div className="auth-input-icon"><MailIcon size={16} /></div>
                      <input
                        type="email"
                        required
                        id="register-email" aria-label={t("Địa chỉ email")} autoComplete="email" value={regEmail}
                        onChange={(e) => setRegEmail(e.target.value)}
                        placeholder="nguyenvana@gmail.com"
                        className="auth-input"
                      />
                    </div>
                  </div>

                  <div className="auth-input-group">
                    <label className="auth-label">{t("Mật khẩu (8–72 ký tự)")}</label>
                    <div className="auth-input-wrapper">
                      <div className="auth-input-icon"><LockIcon size={16} /></div>
                      <input
                        type={showRegPassword ? 'text' : 'password'}
                        required
                        id="register-password" aria-label={t("Mật khẩu")} autoComplete="new-password" value={regPassword}
                        onChange={(e) => setRegPassword(e.target.value)}
                        placeholder="••••••••"
                        className="auth-input"
                        style={{ paddingRight: '42px' }}
                      />
                      <button
                        type="button"
                        onClick={() => setShowRegPassword(!showRegPassword)}
                        aria-label={showRegPassword ? t('Ẩn mật khẩu') : t('Hiện mật khẩu')}
                        className="auth-password-toggle"
                      >
                        {showRegPassword ? <EyeOffIcon size={16} /> : <EyeIcon size={16} />}
                      </button>
                    </div>
                  </div>

                  <div className="auth-input-group">
                    <label className="auth-label">{t("Nhập lại mật khẩu")}</label>
                    <div className="auth-input-wrapper">
                      <div className="auth-input-icon"><LockIcon size={16} /></div>
                      <input
                        type={showRegPassword ? 'text' : 'password'}
                        required
                        id="register-confirm" aria-label={t("Nhập lại mật khẩu")} autoComplete="new-password" value={regConfirmPassword}
                        onChange={(e) => setRegConfirmPassword(e.target.value)}
                        placeholder="••••••••"
                        className="auth-input"
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    disabled={regLoading}
                    className="auth-btn-primary btn-action-touch"
                  >
                    {regLoading ? (
                      <span>{t("Đang đăng ký tài khoản...")}</span>
                    ) : (
                      <>
                        <CheckCircleIcon size={17} color="#ffffff" />
                        <span>{t("Đăng ký tài khoản")}</span>
                      </>
                    )}
                  </button>

                  {/* 1.3 Action Link below Register Button to Switch to Login */}
                  <div className="auth-switch-link-wrapper">{t("Đã có tài khoản quản trị?")}{' '}
                    <button
                      type="button"
                      onClick={() => switchView('login')}
                      className="auth-switch-link-btn"
                    >{t("Đăng nhập tại đây")} </button>
                  </div>
                </form>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

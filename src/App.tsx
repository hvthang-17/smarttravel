import { useMemo, useState } from 'react'
import {
  ArrowRight, CalendarDays, Check, ChevronDown, Clock3, Compass, Heart,
  MapPin, Menu, Search, Sparkles, Star, Users, X,
} from 'lucide-react'
import { places } from './data'

const interests = ['Thiên nhiên', 'Ẩm thực', 'Văn hóa', 'Biển', 'Giải trí']

function App() {
  const [destination, setDestination] = useState('Đà Nẵng')
  const [days, setDays] = useState(3)
  const [activeInterest, setActiveInterest] = useState('Tất cả')
  const [menuOpen, setMenuOpen] = useState(false)
  const [generated, setGenerated] = useState(false)

  const recommended = useMemo(
    () => activeInterest === 'Tất cả' ? places : places.filter((place) => place.category === activeInterest),
    [activeInterest],
  )

  const generatePlan = () => {
    setGenerated(true)
    document.getElementById('recommendations')?.scrollIntoView({ behavior: 'smooth' })
  }

  return (
    <div className="app-shell">
      <header className="navbar">
        <a className="brand" href="#">
          <span className="brand-mark"><Compass size={20} /></span>
          <span>smart<span>travel</span></span>
        </a>
        <nav className={menuOpen ? 'nav-links open' : 'nav-links'}>
          <a className="active" href="#planner" onClick={() => setMenuOpen(false)}>Lập kế hoạch</a>
          <a href="#recommendations" onClick={() => setMenuOpen(false)}>Khám phá</a>
          <a href="#how-it-works" onClick={() => setMenuOpen(false)}>Cách hoạt động</a>
        </nav>
        <div className="nav-actions">
          <button className="login-button">Đăng nhập</button>
          <button className="primary-button small">Bắt đầu ngay <ArrowRight size={16} /></button>
        </div>
        <button className="menu-button" onClick={() => setMenuOpen(!menuOpen)} aria-label="Mở menu">
          {menuOpen ? <X /> : <Menu />}
        </button>
      </header>

      <main>
        <section className="hero" id="planner">
          <div className="hero-copy">
            <div className="eyebrow"><Sparkles size={15} /> Trợ lý du lịch cá nhân của bạn</div>
            <h1>Mỗi chuyến đi,<br /><em>một câu chuyện riêng.</em></h1>
            <p>SmartTravel giúp bạn tạo lịch trình vừa vặn với sở thích, ngân sách và nhịp sống của riêng mình.</p>
            <div className="hero-stats">
              <div><strong>10k+</strong><span>địa điểm thú vị</span></div>
              <div><strong>4.9/5</strong><span>đánh giá người dùng</span></div>
              <div><strong>30s</strong><span>để có lịch trình</span></div>
            </div>
          </div>
          <div className="planner-card">
            <div className="card-heading">
              <div><span className="step">01</span><div><h2>Bạn muốn đi đâu?</h2><p>Hãy để chúng tôi lo phần còn lại.</p></div></div>
              <Sparkles className="heading-sparkle" size={22} />
            </div>
            <label className="input-label">Điểm đến</label>
            <div className="input-wrap"><MapPin size={18} /><input value={destination} onChange={(e) => setDestination(e.target.value)} placeholder="Ví dụ: Đà Nẵng, Hội An..." /><Search size={18} /></div>
            <label className="input-label">Bạn có bao nhiêu ngày?</label>
            <div className="day-options">{[2, 3, 4, 5].map((value) => <button key={value} className={days === value ? 'selected' : ''} onClick={() => setDays(value)}>{value} ngày</button>)}</div>
            <label className="input-label">Bạn yêu thích điều gì?</label>
            <div className="interest-options">{interests.map((interest) => <button key={interest} className={activeInterest === interest ? 'selected' : ''} onClick={() => setActiveInterest(interest)}>{interest}</button>)}</div>
            <button className="generate-button" onClick={generatePlan}>Tạo lịch trình cho tôi <ArrowRight size={18} /></button>
            <p className="privacy-note">✦ Miễn phí · Không cần thẻ tín dụng</p>
          </div>
        </section>

        <section className="recommendations section" id="recommendations">
          <div className="section-topline"><div><p className="section-kicker">{generated ? 'Lịch trình dành cho bạn' : 'Gợi ý nổi bật'}</p><h2>{generated ? `${days} ngày tuyệt vời tại ${destination}` : 'Những nơi đang được yêu thích'}</h2></div><button className="text-button">Xem tất cả <ArrowRight size={16} /></button></div>
          <div className="filter-row"><button className={activeInterest === 'Tất cả' ? 'filter active' : 'filter'} onClick={() => setActiveInterest('Tất cả')}>Tất cả</button>{interests.map((interest) => <button className={activeInterest === interest ? 'filter active' : 'filter'} key={interest} onClick={() => setActiveInterest(interest)}>{interest}</button>)}<button className="filter more">Bộ lọc <ChevronDown size={15} /></button></div>
          <div className="place-grid">{recommended.map((place) => <article className="place-card" key={place.id}><div className="place-image"><img src={place.image} alt={place.name} /><button className="heart-button" aria-label={`Lưu ${place.name}`}><Heart size={17} /></button><span className="place-category">{place.category}</span></div><div className="place-content"><div className="place-title"><h3>{place.name}</h3><span><Star size={14} fill="currentColor" /> {place.rating}</span></div><p><MapPin size={14} /> {place.area}</p><div className="place-meta"><span><Clock3 size={14} /> {place.duration}</span><b>{place.price}</b></div></div></article>)}</div>
        </section>

        <section className="how-section section" id="how-it-works">
          <div className="how-intro"><p className="section-kicker">Đơn giản như một cuộc trò chuyện</p><h2>Đi từ cảm hứng<br />đến hành trình.</h2><p>Không còn hàng giờ mở hàng chục tab. Chỉ cần cho SmartTravel biết bạn muốn gì.</p><button className="outline-button">Khám phá thêm <ArrowRight size={16} /></button></div>
          <div className="steps"><div className="step-item"><span>01</span><div><h3>Chia sẻ mong muốn</h3><p>Điểm đến, thời gian, sở thích và ngân sách của bạn.</p></div><Check size={19} /></div><div className="step-item"><span>02</span><div><h3>Nhận lịch trình riêng</h3><p>Gợi ý thông minh, cân bằng giữa khám phá và nghỉ ngơi.</p></div><Check size={19} /></div><div className="step-item"><span>03</span><div><h3>Tận hưởng trọn vẹn</h3><p>Lưu, chia sẻ và điều chỉnh chuyến đi bất cứ lúc nào.</p></div><Check size={19} /></div></div>
        </section>
      </main>
      <footer><a className="brand" href="#"><span className="brand-mark"><Compass size={18} /></span><span>smart<span>travel</span></span></a><p>Đi xa hơn, theo cách của bạn.</p><span>© 2025 SmartTravel</span></footer>
    </div>
  )
}

export default App

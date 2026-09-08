import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './style.css';

function App() {
  return <main className="shell"><h1>SmartTravel Admin</h1><p>Quản lý địa điểm và dữ liệu gợi ý của Đà Nẵng.</p><button>Thêm địa điểm</button></main>;
}

createRoot(document.getElementById('root')!).render(<StrictMode><App /></StrictMode>);


import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { Layout } from './components/Layout';
import { DestinationList } from './features/destinations/DestinationList';
import './style.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Layout>
      <DestinationList />
    </Layout>
  </StrictMode>
);



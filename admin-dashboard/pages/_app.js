import { useRouter } from 'next/router';
import '../styles/globals.css';
import { AdminAlertsProvider } from '../context/AdminAlertsContext';

const PUBLIC_PATHS = ['/login', '/register', '/diagnostic', '/network-solution'];

export default function App({ Component, pageProps }) {
  const router = useRouter();
  const isPublic = PUBLIC_PATHS.includes(router.pathname);

  if (isPublic) {
    return <Component {...pageProps} />;
  }

  return (
    <AdminAlertsProvider>
      <Component {...pageProps} />
    </AdminAlertsProvider>
  );
}

import { useEffect } from 'react';

export default function Home() {
  useEffect(() => {
    // Navigation pleine page : fiable avec export statique / hydratation (router.push peut rester bloqué).
    try {
      const token = localStorage.getItem('token');
      window.location.replace(token ? '/dashboard' : '/login');
    } catch {
      window.location.replace('/login');
    }
  }, []);

  return (
    <div style={{ 
      display: 'flex', 
      justifyContent: 'center', 
      alignItems: 'center', 
      height: '100vh' 
    }}>
      <p>Chargement...</p>
    </div>
  );
}


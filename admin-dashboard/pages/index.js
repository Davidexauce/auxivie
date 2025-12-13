import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';

export default function Home() {
  const router = useRouter();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // S'assurer que le composant est monté côté client
    setMounted(true);
  }, []);

  useEffect(() => {
    // Vérifier si l'utilisateur est connecté (uniquement côté client et après montage)
    if (!mounted || typeof window === 'undefined') return;
    
    try {
      const token = localStorage.getItem('token');
      if (token) {
        router.push('/dashboard');
      } else {
        router.push('/login');
      }
    } catch (error) {
      console.error('Erreur lors de la redirection:', error);
      router.push('/login');
    }
  }, [mounted, router]);

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


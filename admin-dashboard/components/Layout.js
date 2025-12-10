import { useRouter } from 'next/router';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import NotificationCenter from './NotificationCenter';
import styles from '../styles/Layout.module.css';

export default function Layout({ children }) {
  const router = useRouter();
  const [user, setUser] = useState(null);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const u = localStorage.getItem('user');
      if (u) setUser(JSON.parse(u));
    }
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    router.push('/login');
  };

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div className={styles.headerContent}>
          <h1 className={styles.logo}>Auxivie Admin</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
            <NotificationCenter />
            <button onClick={handleLogout} className={styles.logoutButton}>
              Déconnexion
            </button>
          </div>
        </div>
        <nav className={styles.nav}>
          <Link 
            href="/dashboard" 
            className={router.pathname === '/dashboard' ? styles.active : ''}
          >
            Tableau de bord
          </Link>
          <Link 
            href="/users" 
            className={router.pathname === '/users' ? styles.active : ''}
          >
            Utilisateurs
          </Link>
          <Link 
            href="/documents" 
            className={router.pathname === '/documents' ? styles.active : ''}
          >
            Documents
          </Link>
          <Link 
            href="/payments" 
            className={router.pathname === '/payments' ? styles.active : ''}
          >
            Paiements
          </Link>
          <Link 
            href="/reviews" 
            className={router.pathname === '/reviews' ? styles.active : ''}
          >
            Avis
          </Link>
          <Link 
            href="/reservations" 
            className={router.pathname === '/reservations' ? styles.active : ''}
          >
            Réservations
          </Link>
          <Link 
            href="/messages" 
            className={router.pathname === '/messages' ? styles.active : ''}
          >
            Messages
          </Link>
          <Link 
            href="/settings" 
            className={router.pathname === '/settings' ? styles.active : ''}
          >
            Paramètres
          </Link>
          <Link 
            href="/profile" 
            className={router.pathname === '/profile' ? styles.active : ''}
          >
            Mon Profil
          </Link>
        </nav>
      </header>
      
      <main className={styles.main}>
        {children}
      </main>
    </div>
  );
}


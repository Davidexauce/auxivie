import { useRouter } from 'next/router';
import styles from '../styles/Layout.module.css';

export default function Layout({ children }) {
  const router = useRouter();

  const handleLogout = () => {
    localStorage.removeItem('token');
    router.push('/login');
  };

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div className={styles.headerContent}>
          <h1 className={styles.logo}>Auxivie Admin</h1>
          <nav className={styles.nav}>
            <a 
              href="/dashboard" 
              className={router.pathname === '/dashboard' ? styles.active : ''}
            >
              Tableau de bord
            </a>
            <a 
              href="/users" 
              className={router.pathname === '/users' ? styles.active : ''}
            >
              Utilisateurs
            </a>
            <button onClick={handleLogout} className={styles.logoutButton}>
              Déconnexion
            </button>
          </nav>
        </div>
      </header>
      
      <main className={styles.main}>
        {children}
      </main>
    </div>
  );
}


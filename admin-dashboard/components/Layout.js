import { useRouter } from 'next/router';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import NotificationCenter from './NotificationCenter';
import { useAdminAlerts } from '../context/AdminAlertsContext';
import styles from '../styles/Layout.module.css';

const NAV_ITEMS = [
  { href: '/dashboard', label: 'Tableau de bord', icon: '◈' },
  { href: '/users', label: 'Utilisateurs', icon: '◎' },
  { href: '/documents', label: 'Documents', icon: '▤' },
  { href: '/payments', label: 'Paiements', icon: '◆' },
  { href: '/reviews', label: 'Avis', icon: '★' },
  { href: '/reports', label: 'Signalements', icon: '⚠' },
  { href: '/reservations', label: 'Réservations', icon: '▣' },
  { href: '/messages', label: 'Messages', icon: '✉' },
  { href: '/settings', label: 'Paramètres', icon: '⚙' },
  { href: '/profile', label: 'Mon profil', icon: '○' },
];

export default function Layout({ children }) {
  const router = useRouter();
  const [user, setUser] = useState(null);
  const { navBadges, totalCount } = useAdminAlerts();

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const u = localStorage.getItem('user');
    if (!u) return;
    try {
      setUser(JSON.parse(u));
    } catch {
      localStorage.removeItem('user');
    }
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    router.push('/login');
  };

  const isActive = (href) => {
    if (href === '/dashboard') return router.pathname === '/dashboard';
    return router.pathname === href || router.pathname.startsWith(`${href}/`);
  };

  return (
    <div className={styles.app}>
      <aside className={styles.sidebar}>
        <div className={styles.sidebarBrand}>
          <span className={styles.brandMark}>A</span>
          <div>
            <p className={styles.brandTitle}>Aidalya</p>
            <p className={styles.brandSubtitle}>Administration</p>
          </div>
        </div>

        <nav className={styles.sidebarNav}>
          {NAV_ITEMS.map((item, index) => (
            <Link
              key={item.href}
              href={item.href}
              className={`${styles.navLink} ${isActive(item.href) ? styles.navLinkActive : ''}`}
              style={{ animationDelay: `${0.04 + index * 0.04}s` }}
            >
              <span className={styles.navIcon} aria-hidden>
                {item.icon}
              </span>
              <span className={styles.navLabel}>{item.label}</span>
              {navBadges[item.href] > 0 && (
                <span className={styles.navBadge} title="Actions requises">
                  {navBadges[item.href] > 9 ? '9+' : navBadges[item.href]}
                </span>
              )}
            </Link>
          ))}
        </nav>

        <div className={styles.sidebarFooter}>
          {user && (
            <div className={styles.sidebarUser}>
              <span className={styles.userAvatar}>
                {(user.name?.[0] || user.email?.[0] || 'A').toUpperCase()}
              </span>
              <div className={styles.userMeta}>
                <span className={styles.userName}>{user.name || 'Administrateur'}</span>
                <span className={styles.userEmail}>{user.email}</span>
              </div>
            </div>
          )}
          <button type="button" onClick={handleLogout} className={styles.logoutButton}>
            Déconnexion
          </button>
        </div>
      </aside>

      <div className={styles.mainShell}>
        <header className={styles.topbar}>
          <p className={styles.topbarHint}>
            {totalCount > 0 ? (
              <span className={styles.topbarAlert}>
                <span className={styles.topbarAlertDot} />
                {totalCount} action{totalCount > 1 ? 's' : ''} requise
                {totalCount > 1 ? 's' : ''}
              </span>
            ) : (
              'Espace administrateur privé'
            )}
          </p>
          <div className={styles.topbarActions}>
            <NotificationCenter />
          </div>
        </header>
        <main key={router.asPath} className={styles.main}>
          {children}
        </main>
      </div>
    </div>
  );
}

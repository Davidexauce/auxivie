import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI, documentsAPI, reservationsAPI, paymentsAPI } from '../lib/api';
import SimpleChart from '../components/SimpleChart';
import AlertsPanel from '../components/AlertsPanel';
import styles from '../styles/Dashboard.module.css';

const QUICK_LINKS = [
  { href: '/users', label: 'Utilisateurs', desc: 'Comptes pro & familles', accent: 'blue' },
  { href: '/documents', label: 'Documents', desc: 'Vérifications en attente', accent: 'amber' },
  { href: '/reservations', label: 'Réservations', desc: 'Planning & statuts', accent: 'indigo' },
  { href: '/payments', label: 'Paiements', desc: 'Transactions Stripe', accent: 'green' },
  { href: '/messages', label: 'Messages', desc: 'Conversations', accent: 'slate' },
  { href: '/reviews', label: 'Avis', desc: 'Modération', accent: 'rose' },
  { href: '/reports', label: 'Signalements', desc: 'Signalements utilisateurs', accent: 'amber' },
  { href: '/settings', label: 'Paramètres', desc: 'Plateforme & Stripe', accent: 'green' },
];

export default function Dashboard() {
  const router = useRouter();
  const [admin, setAdmin] = useState(null);
  const [stats, setStats] = useState({
    totalUsers: 0,
    professionals: 0,
    families: 0,
    pendingDocuments: 0,
    activeReservations: 0,
    totalPayments: 0,
    recentPayments: 0,
  });
  const [chartData, setChartData] = useState({
    usersByType: [],
    reservationsByStatus: [],
    paymentsByStatus: [],
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      window.location.replace('/login');
      return;
    }

    const u = localStorage.getItem('user');
    if (u) {
      try {
        setAdmin(JSON.parse(u));
      } catch {
        localStorage.removeItem('user');
      }
    }

    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const [users, documents, reservations, payments] = await Promise.all([
        usersAPI.getAll().catch(() => []),
        documentsAPI.getAll().catch(() => []),
        reservationsAPI.getAll().catch(() => []),
        paymentsAPI.getAll().catch(() => []),
      ]);

      const professionals = users.filter((u) => u.userType === 'professionnel').length;
      const families = users.filter((u) => u.userType === 'famille').length;
      const pendingDocuments = documents.filter((d) => d.status === 'pending').length;
      const activeReservations = reservations.filter(
        (r) => r.status === 'pending' || r.status === 'confirmed'
      ).length;
      const recentPayments = payments.filter((p) => {
        const paymentDate = new Date(p.createdAt);
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        return paymentDate > weekAgo;
      }).length;

      setStats({
        totalUsers: users.length,
        professionals,
        families,
        pendingDocuments,
        activeReservations,
        totalPayments: payments.length,
        recentPayments,
      });

      setChartData({
        usersByType: [
          { label: 'Professionnels', value: professionals, color: '#3b82f6' },
          { label: 'Familles', value: families, color: '#10b981' },
        ],
        reservationsByStatus: [
          {
            label: 'En attente',
            value: reservations.filter((r) => r.status === 'pending').length,
            color: '#f59e0b',
          },
          {
            label: 'Confirmées',
            value: reservations.filter((r) => r.status === 'confirmed').length,
            color: '#3b82f6',
          },
          {
            label: 'Terminées',
            value: reservations.filter((r) => r.status === 'completed').length,
            color: '#10b981',
          },
          {
            label: 'Annulées',
            value: reservations.filter((r) => r.status === 'cancelled').length,
            color: '#ef4444',
          },
        ],
        paymentsByStatus: [
          {
            label: 'En attente',
            value: payments.filter((p) => p.status === 'pending').length,
            color: '#f59e0b',
          },
          {
            label: 'Complétés',
            value: payments.filter((p) => p.status === 'completed').length,
            color: '#10b981',
          },
          {
            label: 'Échoués',
            value: payments.filter((p) => p.status === 'failed').length,
            color: '#ef4444',
          },
        ],
      });
    } catch (error) {
      console.error('Erreur lors du chargement des statistiques:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement du tableau de bord...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.dashboard}>
        <header className={styles.hero}>
          <div>
            <p className={styles.heroEyebrow}>Aidalya · Administration</p>
            <h1 className={styles.heroTitle}>Tableau de bord</h1>
            <p className={styles.heroSubtitle}>
              Vue d&apos;ensemble de la plateforme en temps réel
            </p>
          </div>
          {admin && (
            <div className={styles.adminPill}>
              <span className={styles.adminAvatar}>
                {(admin.name?.[0] || admin.email?.[0] || 'A').toUpperCase()}
              </span>
              <div>
                <span className={styles.adminName}>{admin.name || 'Administrateur'}</span>
                <span className={styles.adminEmail}>{admin.email}</span>
              </div>
            </div>
          )}
        </header>

        <AlertsPanel />

        <section className={styles.statsGrid}>
          <article className={`${styles.statCard} ${styles.statPrimary}`}>
            <span className={styles.statLabel}>Utilisateurs</span>
            <p className={styles.statValue}>{stats.totalUsers}</p>
            <span className={styles.statMeta}>
              {stats.professionals} pro · {stats.families} familles
            </span>
          </article>
          <article
            className={`${styles.statCard} ${styles.statWarning} ${
              stats.pendingDocuments > 0 ? styles.statHighlight : ''
            }`}
          >
            <span className={styles.statLabel}>Documents en attente</span>
            <p className={styles.statValue}>{stats.pendingDocuments}</p>
            {stats.pendingDocuments > 0 && (
              <span className={styles.statAlertTag}>À traiter</span>
            )}
            <button
              type="button"
              className={styles.statLink}
              onClick={() => router.push('/documents')}
            >
              Voir les documents →
            </button>
          </article>
          <article className={`${styles.statCard} ${styles.statInfo}`}>
            <span className={styles.statLabel}>Réservations actives</span>
            <p className={styles.statValue}>{stats.activeReservations}</p>
            <button
              type="button"
              className={styles.statLink}
              onClick={() => router.push('/reservations')}
            >
              Voir les réservations →
            </button>
          </article>
          <article className={`${styles.statCard} ${styles.statSuccess}`}>
            <span className={styles.statLabel}>Paiements (7 jours)</span>
            <p className={styles.statValue}>{stats.recentPayments}</p>
            <span className={styles.statMeta}>Total : {stats.totalPayments}</span>
            <button
              type="button"
              className={styles.statLink}
              onClick={() => router.push('/payments')}
            >
              Voir les paiements →
            </button>
          </article>
        </section>

        <section className={styles.quickSection}>
          <h2 className={styles.sectionTitle}>Accès rapide</h2>
          <div className={styles.quickGrid}>
            {QUICK_LINKS.map((link) => (
              <button
                key={link.href}
                type="button"
                className={`${styles.quickCard} ${styles[`quick_${link.accent}`]}`}
                onClick={() => router.push(link.href)}
              >
                <span className={styles.quickLabel}>{link.label}</span>
                <span className={styles.quickDesc}>{link.desc}</span>
              </button>
            ))}
          </div>
        </section>

        <section className={styles.chartsSection}>
          <h2 className={styles.sectionTitle}>Statistiques</h2>
          <div className={styles.chartsGrid}>
            <SimpleChart
              title="Répartition des utilisateurs"
              data={chartData.usersByType}
              maxValue={stats.totalUsers || 1}
            />
            <SimpleChart
              title="Réservations par statut"
              data={chartData.reservationsByStatus}
            />
            <SimpleChart
              title="Paiements par statut"
              data={chartData.paymentsByStatus}
            />
          </div>
        </section>
      </div>
    </Layout>
  );
}

import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI, documentsAPI, reservationsAPI, paymentsAPI } from '../lib/api';
import SimpleChart from '../components/SimpleChart';
import styles from '../styles/Dashboard.module.css';

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
    // Vérifier l'authentification
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    // Charger les infos de l'admin connecté
    const u = localStorage.getItem('user');
    if (u) setAdmin(JSON.parse(u));

    loadStats();
  }, [router]);

  const loadStats = async () => {
    try {
      const [users, documents, reservations, payments] = await Promise.all([
        usersAPI.getAll().catch(() => []),
        documentsAPI.getAll().catch(() => []),
        reservationsAPI.getAll().catch(() => []),
        paymentsAPI.getAll().catch(() => []),
      ]);

      const professionals = users.filter(u => u.userType === 'professionnel').length;
      const families = users.filter(u => u.userType === 'famille').length;
      const pendingDocuments = documents.filter(d => d.status === 'pending').length;
      const activeReservations = reservations.filter(r => 
        r.status === 'pending' || r.status === 'confirmed'
      ).length;
      const recentPayments = payments.filter(p => {
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

      // Préparer les données pour les graphiques
      setChartData({
        usersByType: [
          { label: 'Professionnels', value: professionals, color: '#3b82f6' },
          { label: 'Familles', value: families, color: '#10b981' },
        ],
        reservationsByStatus: [
          { label: 'En attente', value: reservations.filter(r => r.status === 'pending').length, color: '#f59e0b' },
          { label: 'Confirmées', value: reservations.filter(r => r.status === 'confirmed').length, color: '#3b82f6' },
          { label: 'Terminées', value: reservations.filter(r => r.status === 'completed').length, color: '#10b981' },
          { label: 'Annulées', value: reservations.filter(r => r.status === 'cancelled').length, color: '#ef4444' },
        ],
        paymentsByStatus: [
          { label: 'En attente', value: payments.filter(p => p.status === 'pending').length, color: '#f59e0b' },
          { label: 'Complétés', value: payments.filter(p => p.status === 'completed').length, color: '#10b981' },
          { label: 'Échoués', value: payments.filter(p => p.status === 'failed').length, color: '#ef4444' },
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
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.dashboard}>
        <h1 className={styles.title}>Tableau de bord</h1>
        
        {admin && (
          <div className={styles.adminCard}>
            <div className={styles.adminCardHeader}>
              <h2 className={styles.adminCardTitle}>Admin connecté</h2>
            </div>
            <div className={styles.adminCardContent}>
              <div className={styles.adminField}>
                <span className={styles.adminLabel}>Nom:</span>
                <span className={styles.adminValue}>{admin.name}</span>
              </div>
              <div className={styles.adminField}>
                <span className={styles.adminLabel}>Email:</span>
                <span className={styles.adminValue}>{admin.email}</span>
              </div>
              <div className={styles.adminField}>
                <span className={styles.adminLabel}>Type:</span>
                <span className={styles.adminBadge}>{admin.userType}</span>
              </div>
              <div className={styles.adminField}>
                <span className={styles.adminLabel}>ID:</span>
                <span className={styles.adminValue}>{admin.id}</span>
              </div>
            </div>
          </div>
        )}
        
        <div className={styles.statsGrid}>
          <div className={styles.statCard}>
            <h3 className={styles.statTitle}>Total Utilisateurs</h3>
            <p className={styles.statValue}>{stats.totalUsers}</p>
          </div>
          
          <div className={styles.statCard}>
            <h3 className={styles.statTitle}>Professionnels</h3>
            <p className={styles.statValue}>{stats.professionals}</p>
          </div>
          
          <div className={styles.statCard}>
            <h3 className={styles.statTitle}>Familles</h3>
            <p className={styles.statValue}>{stats.families}</p>
          </div>

          <div className={styles.statCard} style={{ borderLeft: '4px solid #f59e0b' }}>
            <h3 className={styles.statTitle}>Documents en attente</h3>
            <p className={styles.statValue}>{stats.pendingDocuments}</p>
            <button 
              className={styles.actionButton}
              onClick={() => router.push('/documents')}
              style={{ marginTop: '10px', fontSize: '12px', padding: '6px 12px' }}
            >
              Voir les documents
            </button>
          </div>

          <div className={styles.statCard} style={{ borderLeft: '4px solid #3b82f6' }}>
            <h3 className={styles.statTitle}>Réservations actives</h3>
            <p className={styles.statValue}>{stats.activeReservations}</p>
            <button 
              className={styles.actionButton}
              onClick={() => router.push('/reservations')}
              style={{ marginTop: '10px', fontSize: '12px', padding: '6px 12px' }}
            >
              Voir les réservations
            </button>
          </div>

          <div className={styles.statCard} style={{ borderLeft: '4px solid #10b981' }}>
            <h3 className={styles.statTitle}>Paiements (7 jours)</h3>
            <p className={styles.statValue}>{stats.recentPayments}</p>
            <small style={{ color: '#666' }}>Total: {stats.totalPayments}</small>
            <button 
              className={styles.actionButton}
              onClick={() => router.push('/payments')}
              style={{ marginTop: '10px', fontSize: '12px', padding: '6px 12px' }}
            >
              Voir les paiements
            </button>
          </div>
        </div>

        <div className={styles.actions}>
          <button 
            className={styles.actionButton}
            onClick={() => router.push('/users')}
          >
            Gérer les utilisateurs
          </button>
        </div>

        {/* Graphiques */}
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', 
          gap: '20px', 
          marginTop: '40px' 
        }}>
          <SimpleChart
            title="Répartition des utilisateurs"
            data={chartData.usersByType}
            maxValue={stats.totalUsers}
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
      </div>
    </Layout>
  );
}


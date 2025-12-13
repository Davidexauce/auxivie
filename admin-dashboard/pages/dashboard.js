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
    reservationsLast30Days: [],
    revenueLast30Days: [],
  });
  const [recentActivity, setRecentActivity] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [period, setPeriod] = useState('30'); // 7, 30, 90 jours
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Vérifier l'authentification (uniquement côté client)
    if (typeof window === 'undefined') return;
    
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

      // Analytics temporelles - Réservations sur 30 jours
      const reservationsLast30Days = generateTimeSeriesData(reservations, 30);
      const revenueLast30Days = generateRevenueData(payments, 30);

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
        reservationsLast30Days,
        revenueLast30Days,
      });

      // Activité récente
      const recent = getRecentActivity(reservations, payments, documents);
      setRecentActivity(recent);

      // Alertes urgentes
      const urgentAlerts = getAlerts(documents, payments, reservations);
      setAlerts(urgentAlerts);
    } catch (error) {
      console.error('Erreur lors du chargement des statistiques:', error);
    } finally {
      setLoading(false);
    }
  };

  // Générer données temporelles pour réservations
  const generateTimeSeriesData = (reservations, days) => {
    const data = [];
    const now = new Date();
    
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      
      const count = reservations.filter(r => {
        const resDate = new Date(r.createdAt);
        return resDate.toISOString().split('T')[0] === dateStr;
      }).length;
      
      data.push({
        date: date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' }),
        count,
      });
    }
    
    return data;
  };

  // Générer données de revenu
  const generateRevenueData = (payments, days) => {
    const data = [];
    const now = new Date();
    
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      
      const dayPayments = payments.filter(p => {
        const payDate = new Date(p.createdAt);
        return payDate.toISOString().split('T')[0] === dateStr && p.status === 'completed';
      });
      
      const revenue = dayPayments.reduce((sum, p) => sum + (Number(p.amount) || 0), 0);
      
      data.push({
        date: date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' }),
        revenue,
      });
    }
    
    return data;
  };

  // Activité récente
  const getRecentActivity = (reservations, payments, documents) => {
    const activities = [];
    
    // Dernières réservations (3 max)
    const recentReservations = [...reservations]
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(0, 3);
    
    recentReservations.forEach(r => {
      activities.push({
        type: 'reservation',
        icon: '📅',
        message: `Nouvelle réservation #${r.id} par ${r.familleName || 'Client'}`,
        time: formatTimeAgo(r.createdAt),
        link: `/reservations/${r.id}`,
      });
    });
    
    // Derniers paiements (2 max)
    const recentPayments = [...payments]
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(0, 2);
    
    recentPayments.forEach(p => {
      activities.push({
        type: 'payment',
        icon: p.status === 'completed' ? '💰' : '⏳',
        message: `Paiement ${p.status === 'completed' ? 'complété' : 'en attente'} #${p.id} (${formatAmount(p.amount)})`,
        time: formatTimeAgo(p.createdAt),
        link: `/reservations/${p.reservationId}`,
      });
    });
    
    return activities.slice(0, 8);
  };

  // Alertes urgentes
  const getAlerts = (documents, payments, reservations) => {
    const alerts = [];
    
    const pendingDocs = documents.filter(d => d.status === 'pending').length;
    if (pendingDocs > 0) {
      alerts.push({
        type: 'warning',
        icon: '⚠️',
        message: `${pendingDocs} document${pendingDocs > 1 ? 's' : ''} en attente de validation`,
        link: '/documents',
      });
    }
    
    const failedPayments = payments.filter(p => {
      const payDate = new Date(p.createdAt);
      const today = new Date();
      return p.status === 'failed' && payDate.toDateString() === today.toDateString();
    }).length;
    
    if (failedPayments > 0) {
      alerts.push({
        type: 'danger',
        icon: '🔴',
        message: `${failedPayments} paiement${failedPayments > 1 ? 's échoués' : ' échoué'} aujourd'hui`,
        link: '/payments',
      });
    }
    
    const pendingReservations = reservations.filter(r => r.status === 'pending').length;
    if (pendingReservations > 5) {
      alerts.push({
        type: 'info',
        icon: '💬',
        message: `${pendingReservations} réservations en attente de confirmation`,
        link: '/reservations',
      });
    }
    
    return alerts;
  };

  const formatTimeAgo = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now - date) / 1000);
    
    if (seconds < 60) return 'Il y a quelques secondes';
    if (seconds < 3600) return `Il y a ${Math.floor(seconds / 60)} min`;
    if (seconds < 86400) return `Il y a ${Math.floor(seconds / 3600)}h`;
    if (seconds < 604800) return `Il y a ${Math.floor(seconds / 86400)}j`;
    return date.toLocaleDateString('fr-FR');
  };

  const formatAmount = (amount) => {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR',
    }).format(amount);
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

        {/* Alertes urgentes */}
        {alerts.length > 0 && (
          <div className={styles.alertsContainer}>
            {alerts.map((alert, index) => (
              <div 
                key={index} 
                className={`${styles.alert} ${styles[alert.type]}`}
                onClick={() => router.push(alert.link)}
                style={{ cursor: 'pointer' }}
              >
                <span className={styles.alertIcon}>{alert.icon}</span>
                <span className={styles.alertMessage}>{alert.message}</span>
              </div>
            ))}
          </div>
        )}
        
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
            <small style={{ color: '#666', display: 'block', marginBottom: '10px' }}>Total: {stats.totalPayments}</small>
            <button 
              className={styles.actionButton}
              onClick={() => router.push('/payments')}
              style={{ fontSize: '12px', padding: '6px 12px' }}
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
        <div className={styles.chartsSection}>
          <h2 className={styles.sectionTitle}>Analytics</h2>
          
          <div className={styles.chartsGrid}>
            {/* Graphique réservations temporelles */}
            <div className={styles.chartCard}>
              <h3 className={styles.chartTitle}>Réservations (30 derniers jours)</h3>
              <div className={styles.lineChart}>
                {chartData.reservationsLast30Days.map((item, index) => {
                  const maxCount = Math.max(...chartData.reservationsLast30Days.map(d => d.count), 1);
                  const height = (item.count / maxCount) * 100;
                  return (
                    <div key={index} className={styles.barContainer} title={`${item.date}: ${item.count}`}>
                      <div 
                        className={styles.bar}
                        style={{ height: `${height}%`, background: '#10b981' }}
                      ></div>
                      <div className={styles.barLabel}>{item.date}</div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Graphique revenus */}
            <div className={styles.chartCard}>
              <h3 className={styles.chartTitle}>Revenus (30 derniers jours)</h3>
              <div className={styles.lineChart}>
                {chartData.revenueLast30Days.map((item, index) => {
                  const maxRevenue = Math.max(...chartData.revenueLast30Days.map(d => d.revenue), 1);
                  const height = (item.revenue / maxRevenue) * 100;
                  return (
                    <div key={index} className={styles.barContainer} title={`${item.date}: ${formatAmount(item.revenue)}`}>
                      <div 
                        className={styles.bar}
                        style={{ height: `${height}%`, background: '#3b82f6' }}
                      ></div>
                      <div className={styles.barLabel}>{item.date}</div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </div>

        {/* Activité récente */}
        {recentActivity.length > 0 && (
          <div className={styles.activitySection}>
            <h2 className={styles.sectionTitle}>Activité récente</h2>
            <div className={styles.activityList}>
              {recentActivity.map((activity, index) => (
                <div 
                  key={index} 
                  className={styles.activityItem}
                  onClick={() => router.push(activity.link)}
                  style={{ cursor: 'pointer' }}
                >
                  <span className={styles.activityIcon}>{activity.icon}</span>
                  <div className={styles.activityContent}>
                    <div className={styles.activityMessage}>{activity.message}</div>
                    <div className={styles.activityTime}>{activity.time}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Graphiques existants */}
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


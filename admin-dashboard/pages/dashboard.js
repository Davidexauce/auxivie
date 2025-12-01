import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI } from '../lib/api';
import styles from '../styles/Dashboard.module.css';

export default function Dashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({
    totalUsers: 0,
    professionals: 0,
    families: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Vérifier l'authentification
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadStats();
  }, [router]);

  const loadStats = async () => {
    try {
      const users = await usersAPI.getAll();
      const professionals = users.filter(u => u.userType === 'professionnel').length;
      const families = users.filter(u => u.userType === 'famille').length;

      setStats({
        totalUsers: users.length,
        professionals,
        families,
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
        </div>

        <div className={styles.actions}>
          <button 
            className={styles.actionButton}
            onClick={() => router.push('/users')}
          >
            Gérer les utilisateurs
          </button>
        </div>
      </div>
    </Layout>
  );
}


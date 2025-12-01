import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { paymentsAPI } from '../lib/api';
import styles from '../styles/Payments.module.css';

export default function Payments() {
  const router = useRouter();
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, pending, completed, failed

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadPayments();
  }, [router, filter]);

  const loadPayments = async () => {
    try {
      const data = await paymentsAPI.getAll();
      let filtered = data;
      
      if (filter !== 'all') {
        filtered = data.filter(p => p.status === filter);
      }
      
      setPayments(filtered);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
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
      <div className={styles.container}>
        <h1 className={styles.title}>Gestion des paiements</h1>

        <div className={styles.filters}>
          <button
            className={filter === 'all' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('all')}
          >
            Tous
          </button>
          <button
            className={filter === 'pending' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('pending')}
          >
            En attente
          </button>
          <button
            className={filter === 'completed' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('completed')}
          >
            Complétés
          </button>
          <button
            className={filter === 'failed' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('failed')}
          >
            Échoués
          </button>
        </div>

        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>ID</th>
                <th>Réservation</th>
                <th>Utilisateur</th>
                <th>Montant</th>
                <th>Méthode</th>
                <th>Date</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              {payments.length === 0 ? (
                <tr>
                  <td colSpan="7" className={styles.noData}>
                    Aucun paiement trouvé
                  </td>
                </tr>
              ) : (
                payments.map((payment) => (
                  <tr key={payment.id}>
                    <td>{payment.id}</td>
                    <td>#{payment.reservationId}</td>
                    <td>{payment.userName || `User ${payment.userId}`}</td>
                    <td className={styles.amount}>{formatAmount(payment.amount)}</td>
                    <td>{payment.method || '-'}</td>
                    <td>{formatDate(payment.createdAt)}</td>
                    <td>
                      <span className={`${styles.status} ${styles[payment.status]}`}>
                        {payment.status === 'pending' && 'En attente'}
                        {payment.status === 'completed' && 'Complété'}
                        {payment.status === 'failed' && 'Échoué'}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
}


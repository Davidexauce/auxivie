import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { paymentsAPI } from '../lib/api';
import { exportPaymentsToCSV } from '../lib/export';
import Pagination from '../components/Pagination';
import styles from '../styles/Payments.module.css';

export default function Payments() {
  const router = useRouter();
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, pending, completed, failed
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(25);

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

  // Pagination
  const totalPages = Math.ceil(payments.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedPayments = payments.slice(startIndex, endIndex);

  // Réinitialiser la page si nécessaire
  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage]);

  return (
    <Layout>
      <div className={styles.container}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <h1 className={styles.title}>Gestion des paiements</h1>
          <button
            onClick={() => exportPaymentsToCSV(payments)}
            style={{
              padding: '10px 20px',
              backgroundColor: '#059669',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '14px',
              fontWeight: '600',
              display: 'flex',
              alignItems: 'center',
              gap: '8px'
            }}
          >
            📥 Exporter CSV
          </button>
        </div>

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
                paginatedPayments.map((payment) => (
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

        {payments.length > 0 && (
          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            onPageChange={setCurrentPage}
            itemsPerPage={itemsPerPage}
            totalItems={payments.length}
            onItemsPerPageChange={(value) => {
              setItemsPerPage(value);
              setCurrentPage(1);
            }}
          />
        )}
      </div>
    </Layout>
  );
}


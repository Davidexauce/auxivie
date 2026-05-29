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
      const list = Array.isArray(data) ? data : [];
      let filtered = list;

      if (filter !== 'all') {
        filtered = list.filter((p) => p.status === filter);
      }

      setPayments(filtered);
    } catch (error) {
      console.error('Erreur:', error);
      setPayments([]);
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    if (dateString == null || dateString === '') return '—';
    const date = new Date(dateString);
    if (Number.isNaN(date.getTime())) return '—';
    return date.toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const formatAmount = (amount) => {
    const n = Number(amount);
    if (Number.isNaN(n)) return '—';
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR',
    }).format(n);
  };

  // Pagination (hooks toujours avant tout return conditionnel — règles de React)
  const totalPages = Math.max(1, Math.ceil(payments.length / itemsPerPage) || 1);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedPayments = payments.slice(startIndex, endIndex);

  useEffect(() => {
    if (payments.length === 0) return;
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage, payments.length]);

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
                paginatedPayments.map((payment, idx) => (
                  <tr key={payment.id != null ? String(payment.id) : `row-${idx}`}>
                    <td>{payment.id}</td>
                    <td>#{payment.reservationId}</td>
                    <td>{payment.userName || `User ${payment.userId}`}</td>
                    <td className={styles.amount}>{formatAmount(payment.amount)}</td>
                    <td>{payment.method || payment.paymentMethod || '-'}</td>
                    <td>{formatDate(payment.createdAt)}</td>
                    <td>
                      <span
                        className={`${styles.status} ${payment.status && styles[payment.status] ? styles[payment.status] : ''}`}
                      >
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


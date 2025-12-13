import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { paymentsAPI } from '../lib/api';
import { exportPaymentsToCSV, exportPaymentsToExcel } from '../lib/export';
import Pagination from '../components/Pagination';
import styles from '../styles/Payments.module.css';

export default function Payments() {
  const router = useRouter();
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, pending, completed, failed
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(25);
  const [searchTerm, setSearchTerm] = useState('');
  const [dateFilter, setDateFilter] = useState('all'); // all, today, week, month
  const [processing, setProcessing] = useState(false);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadPayments();
  }, [router, filter]);

  const loadPayments = async () => {
    try {
      setLoading(true);
      const data = await paymentsAPI.getAll();
      setPayments(data);
    } catch (error) {
      console.error('Erreur:', error);
      setPayments([]);
    } finally {
      setLoading(false);
    }
  };

  const handleRetry = async (paymentId) => {
    if (!confirm('Voulez-vous vraiment réessayer ce paiement ?')) return;
    
    setProcessing(true);
    try {
      const response = await fetch('https://auxivie.org/api/stripe/create-payment-intent', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          paymentId: paymentId,
          retry: true
        })
      });

      if (response.ok) {
        alert('Paiement relancé avec succès');
        loadPayments();
      } else {
        const error = await response.json();
        alert(`Erreur: ${error.message}`);
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la relance du paiement');
    } finally {
      setProcessing(false);
    }
  };

  const handleRefund = async (paymentId, amount) => {
    const reason = prompt('Raison du remboursement :');
    if (!reason) return;
    
    setProcessing(true);
    try {
      const response = await fetch('https://auxivie.org/api/stripe/refund', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          paymentId: paymentId,
          amount: amount,
          reason: reason
        })
      });

      if (response.ok) {
        alert('Remboursement effectué avec succès');
        loadPayments();
      } else {
        const error = await response.json();
        alert(`Erreur: ${error.message}`);
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors du remboursement');
    } finally {
      setProcessing(false);
    }
  };

  // Filtrage par statut
  const filteredByStatus = filter === 'all' 
    ? payments 
    : payments.filter(p => p.status === filter);

  // Filtrage par date
  const filteredByDate = dateFilter === 'all'
    ? filteredByStatus
    : filteredByStatus.filter(p => {
        const paymentDate = new Date(p.createdAt);
        const now = new Date();
        
        if (dateFilter === 'today') {
          return paymentDate.toDateString() === now.toDateString();
        } else if (dateFilter === 'week') {
          const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
          return paymentDate >= weekAgo;
        } else if (dateFilter === 'month') {
          const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
          return paymentDate >= monthAgo;
        }
        return true;
      });

  // Recherche
  const searchedPayments = searchTerm.trim() === ''
    ? filteredByDate
    : filteredByDate.filter(p => {
        const search = searchTerm.toLowerCase();
        return (
          p.id?.toString().includes(search) ||
          p.reservationId?.toString().includes(search) ||
          p.userName?.toLowerCase().includes(search) ||
          p.userId?.toString().includes(search) ||
          p.amount?.toString().includes(search) ||
          p.method?.toLowerCase().includes(search)
        );
      });

  // Pagination
  const totalPages = Math.ceil(searchedPayments.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedPayments = searchedPayments.slice(startIndex, endIndex);

  // Statistiques
  const stats = {
    total: payments.length,
    totalAmount: payments.reduce((sum, p) => sum + (Number(p.amount) || 0), 0),
    completed: payments.filter(p => p.status === 'completed').length,
    completedAmount: payments.filter(p => p.status === 'completed').reduce((sum, p) => sum + (Number(p.amount) || 0), 0),
    pending: payments.filter(p => p.status === 'pending').length,
    pendingAmount: payments.filter(p => p.status === 'pending').reduce((sum, p) => sum + (Number(p.amount) || 0), 0),
    failed: payments.filter(p => p.status === 'failed').length,
    failedAmount: payments.filter(p => p.status === 'failed').reduce((sum, p) => sum + (Number(p.amount) || 0), 0),
  };

  // Réinitialiser la page si nécessaire
  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage]);

  useEffect(() => {
    setCurrentPage(1);
  }, [filter, searchTerm, dateFilter]);

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
        <div className={styles.header}>
          <h1 className={styles.title}>Gestion des paiements</h1>
          <div style={{ display: 'flex', gap: '12px' }}>
            <button
              onClick={() => exportPaymentsToCSV(searchedPayments)}
              className={styles.exportButton}
              style={{ background: '#10b981' }}
            >
              📄 CSV
            </button>
            <button
              onClick={() => exportPaymentsToExcel(searchedPayments)}
              className={styles.exportButton}
              style={{ background: '#059669' }}
            >
              📊 Excel
            </button>
          </div>
        </div>

        {/* Statistiques */}
        <div className={styles.statsGrid}>
          <div className={styles.statCard}>
            <div className={styles.statIcon}>💰</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>Total complété</div>
              <div className={styles.statValue}>{formatAmount(stats.completedAmount)}</div>
              <div className={styles.statSubtext}>{stats.completed} paiements</div>
            </div>
          </div>
          <div className={styles.statCard}>
            <div className={styles.statIcon}>⏳</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>En attente</div>
              <div className={styles.statValue}>{formatAmount(stats.pendingAmount)}</div>
              <div className={styles.statSubtext}>{stats.pending} paiements</div>
            </div>
          </div>
          <div className={styles.statCard}>
            <div className={styles.statIcon}>❌</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>Échoués</div>
              <div className={styles.statValue}>{formatAmount(stats.failedAmount)}</div>
              <div className={styles.statSubtext}>{stats.failed} paiements</div>
            </div>
          </div>
          <div className={styles.statCard}>
            <div className={styles.statIcon}>📊</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>Total général</div>
              <div className={styles.statValue}>{formatAmount(stats.totalAmount)}</div>
              <div className={styles.statSubtext}>{stats.total} paiements</div>
            </div>
          </div>
        </div>

        {/* Barre de recherche */}
        <div className={styles.searchContainer}>
          <input
            type="text"
            placeholder="🔍 Rechercher par ID, réservation, utilisateur, montant..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className={styles.searchInput}
          />
          {searchTerm && (
            <button
              onClick={() => setSearchTerm('')}
              className={styles.clearSearch}
              title="Effacer la recherche"
            >
              ✕
            </button>
          )}
        </div>

        {/* Filtres */}
        <div className={styles.filtersContainer}>
          <div className={styles.filters}>
            <span className={styles.filterLabel}>Statut:</span>
            <button
              className={filter === 'all' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('all')}
            >
              Tous ({payments.length})
            </button>
            <button
              className={filter === 'completed' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('completed')}
            >
              Complétés ({stats.completed})
            </button>
            <button
              className={filter === 'pending' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('pending')}
            >
              En attente ({stats.pending})
            </button>
            <button
              className={filter === 'failed' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('failed')}
            >
              Échoués ({stats.failed})
            </button>
          </div>

          <div className={styles.filters}>
            <span className={styles.filterLabel}>Période:</span>
            <button
              className={dateFilter === 'all' ? styles.activeFilter : styles.filter}
              onClick={() => setDateFilter('all')}
            >
              Tous
            </button>
            <button
              className={dateFilter === 'today' ? styles.activeFilter : styles.filter}
              onClick={() => setDateFilter('today')}
            >
              Aujourd'hui
            </button>
            <button
              className={dateFilter === 'week' ? styles.activeFilter : styles.filter}
              onClick={() => setDateFilter('week')}
            >
              7 jours
            </button>
            <button
              className={dateFilter === 'month' ? styles.activeFilter : styles.filter}
              onClick={() => setDateFilter('month')}
            >
              30 jours
            </button>
          </div>
        </div>

        <div className={styles.tableContainer}>
          {searchedPayments.length === 0 ? (
            <div className={styles.empty}>
              <p>Aucun paiement trouvé {filter !== 'all' ? `avec le statut "${filter}"` : ''} {searchTerm ? `correspondant à "${searchTerm}"` : ''}</p>
            </div>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Réservation</th>
                  <th>Client</th>
                  <th>Montant</th>
                  <th>Méthode</th>
                  <th>Date</th>
                  <th>Statut</th>
                  <th className={styles.stickyActions}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {paginatedPayments.map((payment) => (
                  <tr 
                    key={payment.id}
                    onClick={() => router.push(`/reservations/${payment.reservationId}`)}
                    style={{ cursor: 'pointer' }}
                    className={styles.clickableRow}
                  >
                    <td>
                      <strong style={{ color: '#3b82f6' }}>#{payment.id}</strong>
                    </td>
                    <td>
                      <strong style={{ color: '#16a34a' }}>#{payment.reservationId}</strong>
                    </td>
                    <td>
                      <div className={styles.userInfo}>
                        <strong>{payment.userName || `User ${payment.userId}`}</strong>
                        <span className={styles.userId}>ID: {payment.userId}</span>
                      </div>
                    </td>
                    <td>
                      <div className={styles.amount}>{formatAmount(payment.amount)}</div>
                    </td>
                    <td>
                      <span className={styles.method}>{payment.method || 'Carte'}</span>
                    </td>
                    <td>
                      <div style={{ fontSize: '13px' }}>{formatDate(payment.createdAt)}</div>
                    </td>
                    <td>
                      <span className={`${styles.badge} ${styles[payment.status]}`}>
                        {payment.status === 'pending' && '⏳ En attente'}
                        {payment.status === 'completed' && '✓ Complété'}
                        {payment.status === 'failed' && '✗ Échoué'}
                      </span>
                    </td>
                    <td onClick={(e) => e.stopPropagation()} className={styles.stickyActions}>
                      <div className={styles.actions}>
                        {payment.status === 'failed' && (
                          <button
                            onClick={() => handleRetry(payment.id)}
                            className={styles.retryButton}
                            title="Relancer le paiement"
                            disabled={processing}
                          >
                            🔄 Retry
                          </button>
                        )}
                        {payment.status === 'completed' && (
                          <button
                            onClick={() => handleRefund(payment.id, payment.amount)}
                            className={styles.refundButton}
                            title="Rembourser"
                            disabled={processing}
                          >
                            💰 Refund
                          </button>
                        )}
                        <button
                          onClick={() => router.push(`/reservations/${payment.reservationId}`)}
                          className={styles.viewButton}
                          title="Voir la réservation"
                        >
                          👁️ View
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        {totalPages > 1 && (
          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            onPageChange={setCurrentPage}
          />
        )}

        <div className={styles.stats}>
          <p>
            Affichage {startIndex + 1} - {Math.min(endIndex, searchedPayments.length)} sur {searchedPayments.length}
            {searchTerm && ` (${filteredByDate.length} au total)`}
          </p>
        </div>
      </div>
    </Layout>
  );
}


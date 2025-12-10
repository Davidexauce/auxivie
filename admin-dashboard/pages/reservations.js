import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { reservationsAPI } from '../lib/api';
import { exportReservationsToCSV } from '../lib/export';
import Pagination from '../components/Pagination';
import styles from '../styles/Reservations.module.css';

export default function Reservations() {
  const router = useRouter();
  const [reservations, setReservations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, pending, confirmed, completed, cancelled
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(25);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReservations();
  }, [router]);

  useEffect(() => {
    setCurrentPage(1); // Réinitialiser la page lors du changement de filtre
  }, [filter]);

  const loadReservations = async () => {
    try {
      setLoading(true);
      const data = await reservationsAPI.getAll();
      setReservations(data);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async (reservationId, newStatus) => {
    try {
      await reservationsAPI.updateStatus(reservationId, newStatus);
      loadReservations();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la mise à jour du statut');
    }
  };

  const filteredReservations = filter === 'all' 
    ? reservations 
    : reservations.filter(r => r.status === filter);

  // Pagination
  const totalPages = Math.ceil(filteredReservations.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedReservations = filteredReservations.slice(startIndex, endIndex);

  // Réinitialiser la page si nécessaire
  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage]);

  const getStatusBadge = (status) => {
    const statusMap = {
      pending: { label: 'En attente', class: styles.pending },
      confirmed: { label: 'Confirmée', class: styles.confirmed },
      completed: { label: 'Terminée', class: styles.completed },
      cancelled: { label: 'Annulée', class: styles.cancelled },
    };
    const statusInfo = statusMap[status] || { label: status, class: styles.pending };
    return <span className={`${styles.badge} ${statusInfo.class}`}>{statusInfo.label}</span>;
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric' 
    });
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
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%', marginBottom: '20px' }}>
            <h1 className={styles.title}>Réservations</h1>
            <button
              onClick={() => exportReservationsToCSV(filteredReservations)}
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
              Toutes ({reservations.length})
            </button>
            <button
              className={filter === 'pending' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('pending')}
            >
              En attente ({reservations.filter(r => r.status === 'pending').length})
            </button>
            <button
              className={filter === 'confirmed' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('confirmed')}
            >
              Confirmées ({reservations.filter(r => r.status === 'confirmed').length})
            </button>
            <button
              className={filter === 'completed' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('completed')}
            >
              Terminées ({reservations.filter(r => r.status === 'completed').length})
            </button>
            <button
              className={filter === 'cancelled' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('cancelled')}
            >
              Annulées ({reservations.filter(r => r.status === 'cancelled').length})
            </button>
          </div>
        </div>

        <div className={styles.tableContainer}>
          {filteredReservations.length === 0 ? (
            <div className={styles.empty}>
              <p>Aucune réservation {filter !== 'all' ? `avec le statut "${filter}"` : ''}</p>
            </div>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Famille</th>
                  <th>Professionnel</th>
                  <th>Date</th>
                  <th>Heure</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {paginatedReservations.map((reservation) => (
                  <tr key={reservation.id}>
                    <td>#{reservation.id}</td>
                    <td>
                      <div className={styles.userInfo}>
                        <strong>{reservation.familleName || `User ${reservation.userId}`}</strong>
                        <span className={styles.userId}>ID: {reservation.userId}</span>
                      </div>
                    </td>
                    <td>
                      <div className={styles.userInfo}>
                        <strong>{reservation.professionalName || `Pro ${reservation.professionnelId}`}</strong>
                        <span className={styles.userId}>ID: {reservation.professionnelId}</span>
                      </div>
                    </td>
                    <td>{formatDate(reservation.date)}</td>
                    <td>{reservation.heure || '-'}</td>
                    <td>{getStatusBadge(reservation.status)}</td>
                    <td>
                      <div className={styles.actions}>
                        {reservation.status === 'pending' && (
                          <>
                            <button
                              className={styles.confirmButton}
                              onClick={() => handleUpdateStatus(reservation.id, 'confirmed')}
                            >
                              Confirmer
                            </button>
                            <button
                              className={styles.cancelButton}
                              onClick={() => handleUpdateStatus(reservation.id, 'cancelled')}
                            >
                              Annuler
                            </button>
                          </>
                        )}
                        {reservation.status === 'confirmed' && (
                          <button
                            className={styles.completeButton}
                            onClick={() => handleUpdateStatus(reservation.id, 'completed')}
                          >
                            Terminer
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}

          {filteredReservations.length > 0 && (
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              onPageChange={setCurrentPage}
              itemsPerPage={itemsPerPage}
              totalItems={filteredReservations.length}
              onItemsPerPageChange={(value) => {
                setItemsPerPage(value);
                setCurrentPage(1);
              }}
            />
          )}
        </div>
      </div>
    </Layout>
  );
}


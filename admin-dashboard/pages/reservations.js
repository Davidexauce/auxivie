import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Layout from '../components/Layout';
import { reservationsAPI } from '../lib/api';
import { exportReservationsToCSV, exportReservationsToExcel } from '../lib/export';
import Pagination from '../components/Pagination';
import styles from '../styles/Reservations.module.css';

export default function Reservations() {
  const router = useRouter();
  const [reservations, setReservations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(25);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReservations();
  }, [router]);

  useEffect(() => {
    setCurrentPage(1);
  }, [filter, searchTerm]);

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

  const handleDeleteReservation = async (reservationId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette réservation ? Cette action est irréversible.')) {
      return;
    }

    try {
      const response = await fetch(`https://auxivie.org/api/reservations/${reservationId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      if (response.ok) {
        alert('Réservation supprimée avec succès');
        loadReservations();
      } else {
        alert('Erreur lors de la suppression de la réservation');
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la suppression de la réservation');
    }
  };

  const filteredReservations = filter === 'all' 
    ? reservations 
    : reservations.filter(r => r.status === filter);

  // Recherche
  const searchedReservations = searchTerm.trim() === ''
    ? filteredReservations
    : filteredReservations.filter(r => {
        const search = searchTerm.toLowerCase();
        return (
          r.id?.toString().includes(search) ||
          r.familleName?.toLowerCase().includes(search) ||
          r.professionalName?.toLowerCase().includes(search) ||
          r.userId?.toString().includes(search) ||
          r.professionnelId?.toString().includes(search) ||
          r.date?.includes(search)
        );
      });

  const totalPages = Math.ceil(searchedReservations.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedReservations = searchedReservations.slice(startIndex, endIndex);

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

  const getBooleanBadge = (value) => {
    return value ? (
      <span className={`${styles.badge} ${styles.confirmed}`}>✓</span>
    ) : (
      <span className={`${styles.badge} ${styles.pending}`}>✗</span>
    );
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

  const formatPrice = (price) => {
    if (!price && price !== 0) return '-';
    return `${parseFloat(price).toFixed(2)} €`;
  };

  const formatHours = (hours) => {
    if (!hours && hours !== 0) return '-';
    return `${parseFloat(hours).toFixed(1)}h`;
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
          <h1 className={styles.title}>Réservations</h1>
          <div style={{ display: 'flex', gap: '12px' }}>
            <button
              onClick={() => exportReservationsToCSV(filteredReservations)}
              className={styles.exportButton}
              style={{
                padding: '10px 20px',
                background: '#10b981',
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                cursor: 'pointer',
                fontWeight: '600',
                display: 'flex',
                alignItems: 'center',
                gap: '8px'
              }}
            >
              📥 Exporter CSV
            </button>
          </div>
        </div>

        {/* Barre de recherche */}
        <div className={styles.searchContainer}>
          <input
            type="text"
            placeholder="🔍 Rechercher par ID, nom famille, nom pro, date..."
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

        {/* Filtres par statut */}
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

        <div className={styles.tableContainer}>
          {searchedReservations.length === 0 ? (
            <div className={styles.empty}>
              <p>Aucune réservation {filter !== 'all' ? `avec le statut "${filter}"` : ''} {searchTerm ? `correspondant à "${searchTerm}"` : ''}</p>
            </div>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Client</th>
                  <th>Professionnel</th>
                  <th>Date & Heure</th>
                  <th>Prix Total</th>
                  <th>Statut</th>
                  <th className={styles.stickyActions}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {paginatedReservations.map((reservation) => (
                  <tr 
                    key={reservation.id}
                    onClick={() => router.push(`/reservations/${reservation.id}`)}
                    style={{ cursor: 'pointer' }}
                    className={styles.clickableRow}
                  >
                    <td>
                      <strong style={{ color: '#3b82f6' }}>#{reservation.id}</strong>
                    </td>
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
                    <td>
                      <div>
                        <div style={{ fontWeight: '600' }}>{formatDate(reservation.date)}</div>
                        <div style={{ fontSize: '12px', color: '#64748b' }}>{reservation.heure || '-'}</div>
                      </div>
                    </td>
                    <td>
                      <div>
                        <div style={{ fontWeight: '700', color: '#10b981', fontSize: '15px' }}>{formatPrice(reservation.total_prix)}</div>
                        <div style={{ fontSize: '11px', color: '#64748b' }}>{formatHours(reservation.total_heures)}</div>
                      </div>
                    </td>
                    <td>{getStatusBadge(reservation.status)}</td>
                    <td onClick={(e) => e.stopPropagation()} className={styles.stickyActions}>
                      <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', alignItems: 'center' }}>
                        <select
                          value={reservation.status}
                          onChange={(e) => {
                            if (e.target.value !== reservation.status) {
                              handleUpdateStatus(reservation.id, e.target.value);
                            }
                          }}
                          style={{
                            padding: '6px 12px',
                            background: 'white',
                            border: '2px solid #dcfce7',
                            borderRadius: '6px',
                            cursor: 'pointer',
                            fontSize: '12px',
                            fontWeight: '600',
                            color: '#0b1220'
                          }}
                        >
                          <option value="pending">En attente</option>
                          <option value="confirmed">Confirmée</option>
                          <option value="completed">Terminée</option>
                          <option value="cancelled">Annulée</option>
                        </select>
                        <button
                          onClick={() => handleDeleteReservation(reservation.id)}
                          style={{
                            padding: '6px 12px',
                            background: '#dc2626',
                            color: 'white',
                            border: 'none',
                            borderRadius: '6px',
                            cursor: 'pointer',
                            fontSize: '12px',
                            fontWeight: '600',
                            transition: 'all 0.2s'
                          }}
                          onMouseOver={(e) => e.target.style.background = '#991b1b'}
                          onMouseOut={(e) => e.target.style.background = '#dc2626'}
                          title="Supprimer définitivement cette réservation"
                        >
                          🗑️
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
            Affichage {startIndex + 1} - {Math.min(endIndex, searchedReservations.length)} sur {searchedReservations.length}
            {searchTerm && ` (${filteredReservations.length} au total)`}
          </p>
        </div>
      </div>
    </Layout>
  );
}

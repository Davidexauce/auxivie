import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import Link from 'next/link';
import styles from '../styles/Reports.module.css';

export default function Reports() {
  const router = useRouter();
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, open, resolved

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReports();
  }, [router]);

  const loadReports = async () => {
    try {
      setLoading(true);
      // TODO: Remplacer par l'API réelle quand disponible
      const response = await fetch('https://auxivie.org/api/reports', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setReports(data);
      } else {
        // Données de démonstration si l'API n'existe pas encore
        setReports([]);
      }
    } catch (error) {
      console.error('Erreur chargement signalements:', error);
      setReports([]);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async (reportId, newStatus) => {
    try {
      const response = await fetch(`https://auxivie.org/api/reports/${reportId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ status: newStatus })
      });

      if (response.ok) {
        loadReports();
      } else {
        alert('Erreur lors de la mise à jour du statut');
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la mise à jour du statut');
    }
  };

  const filteredReports = filter === 'all' 
    ? reports 
    : reports.filter(r => r.status === filter);

  const getStatusBadge = (status) => {
    const statusMap = {
      open: { label: 'Ouvert', class: styles.open },
      resolved: { label: 'Résolu', class: styles.resolved },
    };
    const statusInfo = statusMap[status] || { label: status, class: styles.open };
    return <span className={`${styles.badge} ${statusInfo.class}`}>{statusInfo.label}</span>;
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
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
          <h1 className={styles.title}>⚠️ Signalements</h1>
          
          <div className={styles.filters}>
            <button
              className={filter === 'all' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('all')}
            >
              Tous ({reports.length})
            </button>
            <button
              className={filter === 'open' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('open')}
            >
              Ouverts ({reports.filter(r => r.status === 'open').length})
            </button>
            <button
              className={filter === 'resolved' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('resolved')}
            >
              Résolus ({reports.filter(r => r.status === 'resolved').length})
            </button>
          </div>
        </div>

        <div className={styles.tableContainer}>
          {filteredReports.length === 0 ? (
            <div className={styles.empty}>
              <p>Aucun signalement {filter !== 'all' ? `avec le statut "${filter}"` : ''}</p>
              <p className={styles.emptyHint}>Les signalements des utilisateurs apparaîtront ici</p>
            </div>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Utilisateur</th>
                  <th>Réservation</th>
                  <th>Type</th>
                  <th>Message</th>
                  <th>Date</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredReports.map((report) => (
                  <tr key={report.id}>
                    <td>#{report.id}</td>
                    <td>
                      <div className={styles.userInfo}>
                        <strong>{report.userName || `User ${report.userId}`}</strong>
                        <span className={styles.userId}>ID: {report.userId}</span>
                      </div>
                    </td>
                    <td>
                      {report.reservationId ? (
                        <Link href={`/reservations/${report.reservationId}`} className={styles.link}>
                          Réservation #{report.reservationId}
                        </Link>
                      ) : '-'}
                    </td>
                    <td>{report.type || 'Général'}</td>
                    <td>
                      <div className={styles.message}>
                        {report.message && report.message.length > 50
                          ? `${report.message.substring(0, 50)}...`
                          : report.message || '-'}
                      </div>
                    </td>
                    <td>{formatDate(report.createdAt)}</td>
                    <td>{getStatusBadge(report.status)}</td>
                    <td>
                      <div className={styles.actions}>
                        <Link href={`/reports/${report.id}`} className={styles.viewButton}>
                          Voir
                        </Link>
                        {report.status === 'open' && (
                          <button
                            className={styles.resolveButton}
                            onClick={() => handleUpdateStatus(report.id, 'resolved')}
                          >
                            Résoudre
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </Layout>
  );
}

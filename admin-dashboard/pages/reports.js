import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Layout from '../components/Layout';
import { reportsAPI } from '../lib/api';
import { useAdminAlerts } from '../context/AdminAlertsContext';
import styles from '../styles/Reports.module.css';

const OPEN_STATUSES = new Set(['open', 'pending', '']);

function isOpenReport(r) {
  const s = (r.status || 'open').toLowerCase();
  return OPEN_STATUSES.has(s);
}

function statusLabel(status) {
  const s = (status || 'open').toLowerCase();
  if (s === 'resolved') return 'Traité';
  if (s === 'dismissed') return 'Classé sans suite';
  if (s === 'pending') return 'En attente';
  return 'Ouvert';
}

export default function Reports() {
  const router = useRouter();
  const { refresh: refreshAlerts } = useAdminAlerts();
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('open');

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }
    loadReports();
  }, [router]);

  const loadReports = async () => {
    try {
      const data = await reportsAPI.getAll();
      setReports(Array.isArray(data) ? data : []);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (id, status) => {
    try {
      await reportsAPI.updateStatus(id, status);
      await loadReports();
      refreshAlerts();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Impossible de mettre à jour le signalement');
    }
  };

  const filtered = reports.filter((r) => {
    if (filter === 'open') return isOpenReport(r);
    if (filter === 'closed') return !isOpenReport(r);
    return true;
  });

  const openCount = reports.filter(isOpenReport).length;

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement des signalements…</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.container}>
        <h1 className={styles.title}>Signalements utilisateurs</h1>
        <p className={styles.subtitle}>
          Signalements envoyés depuis l&apos;application mobile — {openCount} ouvert
          {openCount > 1 ? 's' : ''} sur {reports.length}
        </p>

        <div className={styles.filters}>
          <button
            type="button"
            className={filter === 'open' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('open')}
          >
            Ouverts ({openCount})
          </button>
          <button
            type="button"
            className={filter === 'closed' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('closed')}
          >
            Traités ({reports.length - openCount})
          </button>
          <button
            type="button"
            className={filter === 'all' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('all')}
          >
            Tous ({reports.length})
          </button>
        </div>

        <div className={styles.tableContainer}>
          {filtered.length === 0 ? (
            <p className={styles.empty}>Aucun signalement dans cette catégorie.</p>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Date</th>
                  <th>Signalé par</th>
                  <th>Utilisateur signalé</th>
                  <th>Motif</th>
                  <th>Message</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((report) => {
                  const open = isOpenReport(report);
                  const status = (report.status || 'open').toLowerCase();
                  return (
                    <tr key={report.id}>
                      <td>{report.id}</td>
                      <td>
                        {report.createdAt
                          ? new Date(report.createdAt).toLocaleString('fr-FR')
                          : '—'}
                      </td>
                      <td>
                        {report.reporterId ? (
                          <Link href={`/users/${report.reporterId}`} className={styles.userLink}>
                            {report.reporterName || `User #${report.reporterId}`}
                          </Link>
                        ) : (
                          '—'
                        )}
                        {report.reporterEmail && (
                          <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
                            {report.reporterEmail}
                          </div>
                        )}
                      </td>
                      <td>
                        {report.reportedUserId ? (
                          <Link
                            href={`/users/${report.reportedUserId}`}
                            className={styles.userLink}
                          >
                            {report.reportedName || `User #${report.reportedUserId}`}
                          </Link>
                        ) : (
                          '—'
                        )}
                        {report.reportedEmail && (
                          <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
                            {report.reportedEmail}
                          </div>
                        )}
                      </td>
                      <td>{report.type || report.reason || '—'}</td>
                      <td className={styles.messageCell}>
                        {report.message || report.description || '—'}
                      </td>
                      <td>
                        <span
                          className={
                            status === 'resolved'
                              ? styles.badgeResolved
                              : status === 'dismissed'
                                ? styles.badgeDismissed
                                : styles.badgeOpen
                          }
                        >
                          {statusLabel(report.status)}
                        </span>
                      </td>
                      <td>
                        <div className={styles.actions}>
                          {open ? (
                            <>
                              <button
                                type="button"
                                className={styles.btnResolve}
                                onClick={() => updateStatus(report.id, 'resolved')}
                              >
                                Traiter
                              </button>
                              <button
                                type="button"
                                className={styles.btnDismiss}
                                onClick={() => updateStatus(report.id, 'dismissed')}
                              >
                                Classer
                              </button>
                            </>
                          ) : (
                            <button
                              type="button"
                              className={styles.btnReopen}
                              onClick={() => updateStatus(report.id, 'open')}
                            >
                              Rouvrir
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </Layout>
  );
}

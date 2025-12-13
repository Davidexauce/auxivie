import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../../components/Layout';
import Link from 'next/link';
import styles from '../../styles/ReportDetail.module.css';

export default function ReportDetail() {
  const router = useRouter();
  const { id } = router.query;
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReport();
  }, [id]);

  const loadReport = async () => {
    try {
      setLoading(true);
      const response = await fetch(`https://auxivie.org/api/reports/${id}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setReport(data);
      }
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async (newStatus) => {
    try {
      const response = await fetch(`https://auxivie.org/api/reports/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ status: newStatus })
      });

      if (response.ok) {
        loadReport();
      } else {
        alert('Erreur lors de la mise à jour');
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la mise à jour');
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  if (!report) {
    return (
      <Layout>
        <div className={styles.notFound}>
          <h2>Signalement introuvable</h2>
          <Link href="/reports" className={styles.backButton}>← Retour aux signalements</Link>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.container}>
        <div className={styles.header}>
          <Link href="/reports" className={styles.backLink}>← Retour</Link>
          <h1 className={styles.title}>⚠️ Signalement #{report.id}</h1>
        </div>

        <div className={styles.content}>
          <div className={styles.card}>
            <h2 className={styles.cardTitle}>Informations</h2>
            <div className={styles.infoGrid}>
              <div className={styles.infoItem}>
                <label>Statut</label>
                <span className={`${styles.badge} ${report.status === 'open' ? styles.open : styles.resolved}`}>
                  {report.status === 'open' ? 'Ouvert' : 'Résolu'}
                </span>
              </div>
              <div className={styles.infoItem}>
                <label>Type</label>
                <span>{report.type || 'Général'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Date de création</label>
                <span>{new Date(report.createdAt).toLocaleString('fr-FR')}</span>
              </div>
              {report.resolvedAt && (
                <div className={styles.infoItem}>
                  <label>Résolu le</label>
                  <span>{new Date(report.resolvedAt).toLocaleString('fr-FR')}</span>
                </div>
              )}
            </div>
          </div>

          <div className={styles.card}>
            <h2 className={styles.cardTitle}>Utilisateur</h2>
            <div className={styles.userInfo}>
              <p><strong>Nom:</strong> {report.userName || '-'}</p>
              <p><strong>Email:</strong> {report.userEmail || '-'}</p>
              <p><strong>ID:</strong> #{report.userId}</p>
              <Link href={`/users/${report.userId}`} className={styles.link}>
                Voir le profil →
              </Link>
            </div>
          </div>

          {report.reservationId && (
            <div className={styles.card}>
              <h2 className={styles.cardTitle}>Réservation concernée</h2>
              <p><strong>ID:</strong> #{report.reservationId}</p>
              <Link href={`/reservations/${report.reservationId}`} className={styles.link}>
                Voir la réservation →
              </Link>
            </div>
          )}

          <div className={styles.card}>
            <h2 className={styles.cardTitle}>Message</h2>
            <div className={styles.message}>
              {report.message || 'Aucun message'}
            </div>
          </div>

          <div className={styles.actions}>
            {report.status === 'open' ? (
              <button
                className={styles.resolveButton}
                onClick={() => handleUpdateStatus('resolved')}
              >
                ✓ Marquer comme résolu
              </button>
            ) : (
              <button
                className={styles.reopenButton}
                onClick={() => handleUpdateStatus('open')}
              >
                ↻ Rouvrir le signalement
              </button>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}

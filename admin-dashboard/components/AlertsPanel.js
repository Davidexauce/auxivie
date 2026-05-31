import { useRouter } from 'next/router';
import { useAdminAlerts } from '../context/AdminAlertsContext';
import styles from '../styles/AlertsPanel.module.css';

export default function AlertsPanel({ compact = false }) {
  const router = useRouter();
  const { alerts, loading, totalCount } = useAdminAlerts();

  if (loading) {
    return (
      <section className={styles.panel}>
        <p className={styles.loadingText}>Chargement des signalements…</p>
      </section>
    );
  }

  if (totalCount === 0) {
    return (
      <section className={`${styles.panel} ${styles.panelOk}`}>
        <div className={styles.okRow}>
          <span className={styles.okIcon}>✓</span>
          <div>
            <p className={styles.okTitle}>Rien en attente</p>
            <p className={styles.okDesc}>Aucune action urgente pour le moment.</p>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className={styles.panel}>
      <div className={styles.panelHeader}>
        <div>
          <h2 className={styles.panelTitle}>
            {compact ? 'À traiter' : 'Signalements & actions requises'}
          </h2>
          <p className={styles.panelSubtitle}>
            {totalCount} élément{totalCount > 1 ? 's' : ''} nécessite
            {totalCount > 1 ? 'nt' : ''} votre attention
          </p>
        </div>
        <span className={styles.panelBadge}>{totalCount}</span>
      </div>
      <ul className={styles.alertList}>
        {alerts.map((alert) => (
          <li key={alert.id}>
            <button
              type="button"
              className={`${styles.alertItem} ${styles[`priority_${alert.priority}`]}`}
              onClick={() => router.push(alert.link)}
            >
              <span className={styles.alertIcon} aria-hidden>
                {alert.icon}
              </span>
              <span className={styles.alertBody}>
                <span className={styles.alertTitle}>{alert.title}</span>
                <span className={styles.alertMessage}>{alert.message}</span>
              </span>
              {alert.count > 0 && (
                <span className={styles.alertCount}>{alert.count}</span>
              )}
              <span className={styles.alertArrow} aria-hidden>
                →
              </span>
            </button>
          </li>
        ))}
      </ul>
    </section>
  );
}

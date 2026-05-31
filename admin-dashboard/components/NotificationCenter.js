import { useState } from 'react';
import { useRouter } from 'next/router';
import { useAdminAlerts } from '../context/AdminAlertsContext';
import styles from '../styles/NotificationCenter.module.css';

export default function NotificationCenter() {
  const router = useRouter();
  const { alerts, totalCount, refresh } = useAdminAlerts();
  const [isOpen, setIsOpen] = useState(false);

  const handleNotificationClick = (link) => {
    setIsOpen(false);
    router.push(link);
  };

  return (
    <div className={styles.notificationCenter}>
      <button
        type="button"
        className={styles.notificationButton}
        onClick={() => {
          setIsOpen(!isOpen);
          if (!isOpen) refresh();
        }}
        title="Signalements et notifications"
        aria-label={`${totalCount} signalement${totalCount > 1 ? 's' : ''}`}
      >
        🔔
        {totalCount > 0 && (
          <span className={styles.badge}>{totalCount > 9 ? '9+' : totalCount}</span>
        )}
      </button>

      {isOpen && (
        <>
          <div className={styles.overlay} onClick={() => setIsOpen(false)} />
          <div className={styles.notificationPanel}>
            <div className={styles.panelHeader}>
              <h3>Signalements</h3>
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className={styles.closeButton}
              >
                ×
              </button>
            </div>
            <div className={styles.panelContent}>
              {alerts.length === 0 ? (
                <div className={styles.empty}>
                  <p>Aucun signalement en cours</p>
                </div>
              ) : (
                alerts.map((notification) => (
                  <div
                    key={notification.id}
                    role="button"
                    tabIndex={0}
                    className={`${styles.notificationItem} ${styles[notification.priority]}`}
                    onClick={() => handleNotificationClick(notification.link)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') handleNotificationClick(notification.link);
                    }}
                  >
                    <div className={styles.notificationIcon}>
                      {notification.icon || (notification.type === 'document' ? '📄' : '💬')}
                    </div>
                    <div className={styles.notificationContent}>
                      <h4>{notification.title}</h4>
                      <p>{notification.message}</p>
                    </div>
                    {notification.count > 1 && (
                      <div className={styles.notificationCount}>{notification.count}</div>
                    )}
                  </div>
                ))
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}

import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import { documentsAPI, messagesAPI } from '../lib/api';
import styles from '../styles/NotificationCenter.module.css';

export default function NotificationCenter() {
  const router = useRouter();
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    loadNotifications();
    // Recharger toutes les 30 secondes
    const interval = setInterval(loadNotifications, 30000);
    return () => clearInterval(interval);
  }, []);

  const loadNotifications = async () => {
    try {
      const [documents, messages] = await Promise.all([
        documentsAPI.getAll().catch(() => []),
        messagesAPI.getAll().catch(() => []),
      ]);

      const newNotifications = [];

      // Documents en attente
      const pendingDocs = documents.filter(d => d.status === 'pending' && !d.verified);
      if (pendingDocs.length > 0) {
        newNotifications.push({
          id: 'pending-docs',
          type: 'document',
          title: `${pendingDocs.length} document(s) en attente`,
          message: `${pendingDocs.length} document(s) nécessitent une vérification`,
          count: pendingDocs.length,
          link: '/documents',
          priority: 'high',
        });
      }

      // Nouveaux messages (non lus par l'admin)
      const recentMessages = messages.filter(m => {
        const messageDate = new Date(m.timestamp);
        const dayAgo = new Date();
        dayAgo.setDate(dayAgo.getDate() - 1);
        return messageDate > dayAgo && m.senderId !== 0; // Messages des utilisateurs (pas de l'admin)
      });

      if (recentMessages.length > 0) {
        newNotifications.push({
          id: 'new-messages',
          type: 'message',
          title: `${recentMessages.length} nouveau(x) message(s)`,
          message: 'Vous avez de nouveaux messages à lire',
          count: recentMessages.length,
          link: '/messages',
          priority: 'medium',
        });
      }

      setNotifications(newNotifications);
      setUnreadCount(newNotifications.length);
    } catch (error) {
      console.error('Erreur lors du chargement des notifications:', error);
    }
  };

  const handleNotificationClick = (link) => {
    setIsOpen(false);
    router.push(link);
  };

  return (
    <div className={styles.notificationCenter}>
      <button
        className={styles.notificationButton}
        onClick={() => setIsOpen(!isOpen)}
        title="Notifications"
      >
        🔔
        {unreadCount > 0 && (
          <span className={styles.badge}>{unreadCount}</span>
        )}
      </button>

      {isOpen && (
        <>
          <div className={styles.overlay} onClick={() => setIsOpen(false)} />
          <div className={styles.notificationPanel}>
            <div className={styles.panelHeader}>
              <h3>Notifications</h3>
              <button onClick={() => setIsOpen(false)} className={styles.closeButton}>
                ×
              </button>
            </div>
            <div className={styles.panelContent}>
              {notifications.length === 0 ? (
                <div className={styles.empty}>
                  <p>Aucune notification</p>
                </div>
              ) : (
                notifications.map(notification => (
                  <div
                    key={notification.id}
                    className={`${styles.notificationItem} ${styles[notification.priority]}`}
                    onClick={() => handleNotificationClick(notification.link)}
                  >
                    <div className={styles.notificationIcon}>
                      {notification.type === 'document' ? '📄' : '💬'}
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


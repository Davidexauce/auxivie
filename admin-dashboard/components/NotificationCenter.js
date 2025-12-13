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
    if (typeof window === 'undefined') return;
    
    loadNotifications();
    // Recharger toutes les 30 secondes
    const interval = setInterval(loadNotifications, 30000);
    
    // Écouter les événements de rechargement des notifications
    const handleRefresh = () => {
      loadNotifications();
    };
    
    // Écouter les changements de route pour recharger les notifications
    const handleRouteChange = () => {
      loadNotifications();
    };
    
    window.addEventListener('refreshNotifications', handleRefresh);
    router.events?.on('routeChangeComplete', handleRouteChange);
    
    return () => {
      clearInterval(interval);
      window.removeEventListener('refreshNotifications', handleRefresh);
      router.events?.off('routeChangeComplete', handleRouteChange);
    };
  }, [router]);

  const loadNotifications = async () => {
    try {
      // Récupérer l'ID de l'admin connecté
      const userJson = typeof window !== 'undefined' ? localStorage.getItem('user') : null;
      const currentUser = userJson ? JSON.parse(userJson) : null;
      const adminId = currentUser?.id;
      
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
      // Un message est non lu si :
      // 1. L'admin est le receiver (receiverId = adminId ou receiverId = 0 pour compatibilité)
      // 2. Le message n'a pas été lu (isRead = 0)
      // 3. Le sender n'est pas l'admin (senderId !== adminId et senderId !== 0)
      const unreadMessages = messages.filter(m => {
        const isAdminReceiver = m.receiverId === adminId || m.receiverId === 0;
        const isAdminSender = m.senderId === adminId || m.senderId === 0;
        const isUnread = m.isRead === 0 || m.isRead === false;
        
        // Message non lu = l'admin est le destinataire ET le message n'a pas été lu ET ce n'est pas l'admin qui l'a envoyé
        return isAdminReceiver && !isAdminSender && isUnread;
      });

      if (unreadMessages.length > 0) {
        newNotifications.push({
          id: 'new-messages',
          type: 'message',
          title: `${unreadMessages.length} nouveau(x) message(s)`,
          message: 'Vous avez de nouveaux messages à lire',
          count: unreadMessages.length,
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


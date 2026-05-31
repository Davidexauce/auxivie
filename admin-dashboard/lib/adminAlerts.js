import {
  documentsAPI,
  messagesAPI,
  reservationsAPI,
  paymentsAPI,
  usersAPI,
  reportsAPI,
} from './api';

/**
 * Construit les alertes admin et les badges de navigation.
 */
export function computeAdminAlerts({
  documents = [],
  messages = [],
  reservations = [],
  payments = [],
  users = [],
  reports = [],
}) {
  const alerts = [];
  const navBadges = {};

  const pendingDocs = documents.filter(
    (d) => d.status === 'pending' || (!d.verified && d.status !== 'rejected')
  );
  if (pendingDocs.length > 0) {
    alerts.push({
      id: 'pending-docs',
      type: 'document',
      priority: 'high',
      title: `${pendingDocs.length} document${pendingDocs.length > 1 ? 's' : ''} à vérifier`,
      message: 'Des pièces jointes attendent votre validation.',
      count: pendingDocs.length,
      link: '/documents',
      icon: '📄',
    });
    navBadges['/documents'] = pendingDocs.length;
  }

  const pendingReservations = reservations.filter((r) => r.status === 'pending');
  if (pendingReservations.length > 0) {
    alerts.push({
      id: 'pending-reservations',
      type: 'reservation',
      priority: 'high',
      title: `${pendingReservations.length} réservation${pendingReservations.length > 1 ? 's' : ''} en attente`,
      message: 'À confirmer ou refuser depuis la page Réservations.',
      count: pendingReservations.length,
      link: '/reservations',
      icon: '▣',
    });
    navBadges['/reservations'] = pendingReservations.length;
  }

  const pendingPayments = payments.filter((p) => p.status === 'pending');
  if (pendingPayments.length > 0) {
    alerts.push({
      id: 'pending-payments',
      type: 'payment',
      priority: 'medium',
      title: `${pendingPayments.length} paiement${pendingPayments.length > 1 ? 's' : ''} en attente`,
      message: 'Transactions à suivre dans Paiements.',
      count: pendingPayments.length,
      link: '/payments',
      icon: '◆',
    });
    navBadges['/payments'] = pendingPayments.length;
  }

  const dayAgo = new Date();
  dayAgo.setDate(dayAgo.getDate() - 1);
  const recentMessages = messages.filter((m) => {
    const ts = new Date(m.timestamp || m.createdAt);
    return ts > dayAgo && m.senderId !== 0 && m.senderId != null;
  });
  if (recentMessages.length > 0) {
    alerts.push({
      id: 'new-messages',
      type: 'message',
      priority: 'medium',
      title: `${recentMessages.length} message${recentMessages.length > 1 ? 's' : ''} récent${recentMessages.length > 1 ? 's' : ''}`,
      message: 'Répondez aux utilisateurs depuis Messages.',
      count: recentMessages.length,
      link: '/messages',
      icon: '✉',
    });
    navBadges['/messages'] = recentMessages.length;
  }

  const suspendedUsers = users.filter((u) => Boolean(u.suspended));
  if (suspendedUsers.length > 0) {
    alerts.push({
      id: 'suspended-users',
      type: 'user',
      priority: 'low',
      title: `${suspendedUsers.length} compte${suspendedUsers.length > 1 ? 's' : ''} suspendu${suspendedUsers.length > 1 ? 's' : ''}`,
      message: 'Comptes désactivés — réactivation possible.',
      count: suspendedUsers.length,
      link: '/users',
      icon: '◎',
    });
  }

  const openReports = reports.filter(
    (r) => !r.status || r.status === 'pending' || r.status === 'open'
  );
  if (openReports.length > 0) {
    alerts.push({
      id: 'open-reports',
      type: 'report',
      priority: 'high',
      title: `${openReports.length} signalement${openReports.length > 1 ? 's' : ''}`,
      message: 'Signalements utilisateurs à examiner.',
      count: openReports.length,
      link: '/reports',
      icon: '⚠',
    });
    navBadges['/reports'] = openReports.length;
  }

  const priorityOrder = { high: 0, medium: 1, low: 2 };
  alerts.sort((a, b) => priorityOrder[a.priority] - priorityOrder[b.priority]);

  return {
    alerts,
    navBadges,
    totalCount: alerts.length,
  };
}

export async function fetchAdminAlerts() {
  const [documents, messages, reservations, payments, users, reports] =
    await Promise.all([
      documentsAPI.getAll().catch(() => []),
      messagesAPI.getAll().catch(() => []),
      reservationsAPI.getAll().catch(() => []),
      paymentsAPI.getAll().catch(() => []),
      usersAPI.getAll().catch(() => []),
      reportsAPI.getAll().catch(() => []),
    ]);

  return computeAdminAlerts({
    documents,
    messages,
    reservations,
    payments,
    users,
    reports,
  });
}

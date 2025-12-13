// Utilitaires pour l'export de données en CSV et Excel
import * as XLSX from 'xlsx';

export const exportToCSV = (data, filename, headers = null) => {
  if (typeof window === 'undefined') {
    console.error('exportToCSV ne peut être utilisé que côté client');
    return;
  }
  
  if (!data || data.length === 0) {
    alert('Aucune donnée à exporter');
    return;
  }

  // Déterminer les en-têtes
  let csvHeaders = headers;
  if (!csvHeaders) {
    // Utiliser les clés du premier objet comme en-têtes
    csvHeaders = Object.keys(data[0]);
  }

  // Créer la ligne d'en-tête
  const headerRow = csvHeaders.map(h => `"${h}"`).join(',');

  // Créer les lignes de données
  const dataRows = data.map(row => {
    return csvHeaders.map(header => {
      const value = row[header];
      // Échapper les guillemets et gérer les valeurs nulles
      if (value === null || value === undefined) return '""';
      const stringValue = String(value).replace(/"/g, '""');
      return `"${stringValue}"`;
    }).join(',');
  });

  // Combiner tout
  const csvContent = [headerRow, ...dataRows].join('\n');

  // Ajouter BOM pour Excel (UTF-8)
  const BOM = '\uFEFF';
  const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);

  link.setAttribute('href', url);
  link.setAttribute('download', `${filename}_${new Date().toISOString().split('T')[0]}.csv`);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
};

// Export spécifique pour les utilisateurs
export const exportUsersToCSV = (users) => {
  const headers = ['ID', 'Nom', 'Email', 'Téléphone', 'Type', 'Catégorie', 'Ville', 'Tarif', 'Statut'];
  const data = users.map(user => ({
    'ID': user.id,
    'Nom': user.name || '',
    'Email': user.email || '',
    'Téléphone': user.phone || '',
    'Type': user.userType === 'professionnel' ? 'Professionnel' : 'Famille',
    'Catégorie': user.categorie || '',
    'Ville': user.ville || '',
    'Tarif': user.tarif || '',
    'Statut': user.suspended ? 'Suspendu' : 'Actif',
  }));
  exportToCSV(data, 'utilisateurs', headers);
};

// Export spécifique pour les paiements
export const exportPaymentsToCSV = (payments) => {
  const headers = ['ID', 'Réservation ID', 'Utilisateur', 'Montant', 'Méthode', 'Statut', 'Date'];
  const data = payments.map(payment => ({
    'ID': payment.id,
    'Réservation ID': payment.reservationId || '',
    'Utilisateur': payment.userName || `User ${payment.userId}`,
    'Montant': `${payment.amount} €`,
    'Méthode': payment.method || '',
    'Statut': payment.status === 'pending' ? 'En attente' : 
              payment.status === 'completed' ? 'Complété' : 
              payment.status === 'failed' ? 'Échoué' : payment.status,
    'Date': new Date(payment.createdAt).toLocaleDateString('fr-FR'),
  }));
  exportToCSV(data, 'paiements', headers);
};

// Export spécifique pour les réservations
export const exportReservationsToCSV = (reservations) => {
  const headers = ['ID', 'Famille', 'Professionnel', 'Date', 'Heure', 'Statut', 'Créée le'];
  const data = reservations.map(reservation => ({
    'ID': reservation.id,
    'Famille': reservation.familleName || `User ${reservation.userId}`,
    'Professionnel': reservation.professionalName || `Pro ${reservation.professionnelId}`,
    'Date': reservation.date ? new Date(reservation.date).toLocaleDateString('fr-FR') : '',
    'Heure': reservation.heure || '',
    'Statut': reservation.status === 'pending' ? 'En attente' :
              reservation.status === 'confirmed' ? 'Confirmée' :
              reservation.status === 'completed' ? 'Terminée' :
              reservation.status === 'cancelled' ? 'Annulée' : reservation.status,
    'Créée le': reservation.createdAt ? new Date(reservation.createdAt).toLocaleDateString('fr-FR') : '',
  }));
  exportToCSV(data, 'reservations', headers);
};

// Export Excel générique
export const exportToExcel = (data, filename, headers = null) => {
  if (typeof window === 'undefined') {
    console.error('exportToExcel ne peut être utilisé que côté client');
    return;
  }
  
  if (!data || data.length === 0) {
    alert('Aucune donnée à exporter');
    return;
  }

  // Créer une feuille de calcul
  const worksheet = XLSX.utils.json_to_sheet(data, { header: headers });
  
  // Créer un classeur
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, 'Données');
  
  // Générer et télécharger
  const fileName = `${filename}_${new Date().toISOString().split('T')[0]}.xlsx`;
  XLSX.writeFile(workbook, fileName);
};

// Export Excel spécifique pour les utilisateurs
export const exportUsersToExcel = (users) => {
  const data = users.map(user => ({
    'ID': user.id,
    'Nom': user.name || '',
    'Email': user.email || '',
    'Téléphone': user.phone || '',
    'Type': user.userType === 'professionnel' ? 'Professionnel' : 'Famille',
    'Catégorie': user.categorie || '',
    'Ville': user.ville || '',
    'Tarif': user.tarif || '',
    'Statut': user.suspended ? 'Suspendu' : 'Actif',
  }));
  exportToExcel(data, 'utilisateurs');
};

// Export Excel spécifique pour les paiements
export const exportPaymentsToExcel = (payments) => {
  const data = payments.map(payment => ({
    'ID': payment.id,
    'Réservation ID': payment.reservationId || '',
    'Utilisateur': payment.userName || `User ${payment.userId}`,
    'Montant': payment.amount,
    'Méthode': payment.method || '',
    'Statut': payment.status === 'pending' ? 'En attente' : 
              payment.status === 'completed' ? 'Complété' : 
              payment.status === 'failed' ? 'Échoué' : payment.status,
    'Date': new Date(payment.createdAt).toLocaleDateString('fr-FR'),
  }));
  exportToExcel(data, 'paiements');
};

// Export Excel spécifique pour les réservations
export const exportReservationsToExcel = (reservations) => {
  const data = reservations.map(reservation => ({
    'ID': reservation.id,
    'Famille': reservation.familleName || `User ${reservation.userId}`,
    'Professionnel': reservation.professionalName || `Pro ${reservation.professionnelId}`,
    'Date': reservation.date ? new Date(reservation.date).toLocaleDateString('fr-FR') : '',
    'Heure': reservation.heure || '',
    'Total heures': reservation.total_heures || 0,
    'Total prix': reservation.total_prix || 0,
    'Statut': reservation.status === 'pending' ? 'En attente' :
              reservation.status === 'confirmed' ? 'Confirmée' :
              reservation.status === 'completed' ? 'Terminée' :
              reservation.status === 'cancelled' ? 'Annulée' : reservation.status,
    'Créée le': reservation.createdAt ? new Date(reservation.createdAt).toLocaleDateString('fr-FR') : '',
  }));
  exportToExcel(data, 'reservations');
};

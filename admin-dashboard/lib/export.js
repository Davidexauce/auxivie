// Utilitaires pour l'export de données en CSV

export const exportToCSV = (data, filename, headers = null) => {
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


class ReviewConstants {
  // Messages d'erreur
  static const String errorLoadReviews = 'Erreur lors du chargement des avis';
  static const String errorCreateReview = 'Erreur lors de la création de l\'avis';
  static const String errorDeleteReview = 'Erreur lors de la suppression de l\'avis';
  static const String errorInvalidRating = 'Veuillez sélectionner une note';
  
  // Messages de succès
  static const String successCreateReview = 'Avis publié avec succès';
  static const String successDeleteReview = 'Avis supprimé';
  
  // Labels
  static const String labelRating = 'Note';
  static const String labelComment = 'Commentaire (optionnel)';
  static const String labelProfessional = 'Professionnel';
  static const String labelDate = 'Date';
  
  // Placeholders
  static const String placeholderComment = 'Partagez votre expérience...';
  
  // Notes et descriptions
  static const Map<int, String> ratingLabels = {
    1: 'Très mauvais',
    2: 'Mauvais',
    3: 'Moyen',
    4: 'Bon',
    5: 'Excellent',
  };
  
  // Limites
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int maxCommentLength = 500;
}


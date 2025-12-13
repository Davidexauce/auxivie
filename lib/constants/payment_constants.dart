class PaymentConstants {
  // Clé publique Stripe (PRODUCTION/LIVE)
  static const String stripePublishableKey =
      'pk_live_51SaaqvQ3cUJNrEfLs5aS95Uc8B78vALVgmcqgKqfQioqyL7PMOtlVrdaymJI99GwWhMDEDcbgGg9N5m4XFH11mvM00SYO12EBh';

  // Messages d'erreur
  static const String errorPaymentFailed = 'Le paiement a échoué';
  static const String errorPaymentCanceled = 'Paiement annulé';
  static const String errorCreateIntent = 'Erreur lors de la création du paiement';
  static const String errorConfirmPayment = 'Erreur lors de la confirmation du paiement';

  // Messages de succès
  static const String successPaymentCompleted = 'Paiement effectué avec succès';

  // Labels
  static const String labelCardNumber = 'Numéro de carte';
  static const String labelExpiry = 'MM/AA';
  static const String labelCvc = 'CVC';
  static const String labelCardHolder = 'Titulaire de la carte';

  // Cartes de test (MODE TEST uniquement)
  static const String testCardNumber = '4242 4242 4242 4242';
  static const String testCardExpiry = '12/34';
  static const String testCardCvc = '123';

  // Statuts de paiement
  static const String statusPending = 'pending';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusCanceled = 'canceled';

  // Devise
  static const String defaultCurrency = 'eur';
  static const String currencySymbol = '€';
}


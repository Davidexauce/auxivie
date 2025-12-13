import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/app_config.dart';
import '../services/backend_api_service.dart';
import '../constants/payment_constants.dart';

/// Service pour gérer les paiements Stripe
class PaymentService {
  static bool _initialized = false;

  /// Initialise Stripe avec la clé publique (depuis PaymentConstants)
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      Stripe.publishableKey = PaymentConstants.stripePublishableKey;
      await Stripe.instance.applySettings();
      _initialized = true;
      if (AppConfig.enableLogging) {
        print('✅ Stripe initialisé avec succès (mode PRODUCTION)');
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur lors de l\'initialisation de Stripe: $e');
      }
      rethrow;
    }
  }

  /// Calcule le montant total d'une réservation
  /// 
  /// [tarifHoraire] : Tarif horaire du professionnel en euros
  /// [dateDebut] : Date de début de la réservation
  /// [dateFin] : Date de fin (optionnel, si null = 1 jour)
  /// [heure] : Heure de début (format HH:mm)
  /// 
  /// Retourne le montant total en centimes (Stripe utilise les centimes)
  static int calculateAmount({
    required double tarifHoraire,
    required DateTime dateDebut,
    DateTime? dateFin,
    required String heure,
  }) {
    // Calculer le nombre de jours
    final dateDebutNormalized = DateTime(dateDebut.year, dateDebut.month, dateDebut.day);
    final dateFinNormalized = dateFin != null 
        ? DateTime(dateFin.year, dateFin.month, dateFin.day)
        : dateDebutNormalized;
    
    final nombreJours = dateFinNormalized.difference(dateDebutNormalized).inDays + 1;
    
    // Pour simplifier, on considère une journée complète (8 heures)
    // Vous pouvez ajuster selon vos besoins
    const heuresParJour = 8.0;
    final totalHeures = nombreJours * heuresParJour;
    final montantTotal = tarifHoraire * totalHeures;
    
    // Convertir en centimes (Stripe utilise les centimes)
    return (montantTotal * 100).round();
  }

  /// Processus de paiement complet (utilise processPaymentWithSheet)
  /// 
  /// Cette méthode est un alias pour processPaymentWithSheet
  static Future<bool> processPayment({
    required int reservationId,
    required int userId,
    required double amount,
    String currency = 'eur',
  }) async {
    return await processPaymentWithSheet(
      reservationId: reservationId,
      userId: userId,
      amount: amount,
      currency: currency,
    );
  }

  /// Processus de paiement avec carte (méthode alternative)
  /// Utilise le PaymentSheet de Stripe pour une meilleure UX
  static Future<bool> processPaymentWithSheet({
    required int reservationId,
    required int userId,
    required double amount,
    String currency = 'eur',
  }) async {
    try {
      // 1. Créer le PaymentIntent via l'API backend
      final intentData = await BackendApiService.createPaymentIntent(
        reservationId: reservationId,
        userId: userId,
        amount: amount,
        currency: currency,
      );

      if (intentData == null || intentData['clientSecret'] == null) {
        if (AppConfig.enableLogging) {
          print('❌ Erreur: Impossible de créer le PaymentIntent');
        }
        return false;
      }

      final clientSecret = intentData['clientSecret'] as String;
      final paymentIntentId = intentData['paymentIntentId'] as String;

      // 2. Initialiser le PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Auxivie',
        ),
      );

      // 3. Afficher le PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirmer le paiement côté serveur
      final confirmResult = await BackendApiService.confirmPayment(
        paymentIntentId: paymentIntentId,
        reservationId: reservationId,
        userId: userId,
        amount: amount,
      );

      if (confirmResult != null) {
        // 5. Mettre à jour la réservation pour la confirmer (status: confirmed)
        // La réservation est automatiquement confirmée côté serveur lors du confirmPayment
        // Mais on peut aussi le faire explicitement ici si nécessaire
        if (AppConfig.enableLogging) {
          print('✅ Paiement confirmé avec succès');
        }
        return true;
      }

      return false;
    } on StripeException catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur Stripe: ${e.error.message}');
      }
      return false;
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Erreur lors du paiement: $e');
      }
      return false;
    }
  }
}


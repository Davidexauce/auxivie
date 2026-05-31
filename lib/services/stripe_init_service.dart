import 'package:flutter_stripe/flutter_stripe.dart';
import '../constants/payment_constants.dart';
import '../utils/app_logger.dart';

/// Initialise Stripe avec une clé publishable valide (`pk_test_` / `pk_live_`).
class StripeInitService {
  static String? _lastAppliedKey;

  /// Retourne true si la clé ressemble à une clé Stripe publishable.
  static bool isValidPublishableKey(String? key) {
    if (key == null) return false;
    final k = key.trim();
    if (k.isEmpty || k == '0') return false;
    return k.startsWith('pk_test_') || k.startsWith('pk_live_');
  }

  /// Priorité : paramètres API → --dart-define=STRIPE_PUBLISHABLE_KEY
  static String? resolvePublishableKey({String? fromSettings}) {
    if (isValidPublishableKey(fromSettings)) {
      return fromSettings!.trim();
    }
    final fromEnv = PaymentConstants.stripePublishableKey.trim();
    if (isValidPublishableKey(fromEnv)) {
      return fromEnv;
    }
    return null;
  }

  /// Applique la clé et `applySettings`. Idempotent si la clé est inchangée.
  static Future<bool> ensureInitialized({String? fromSettings}) async {
    final key = resolvePublishableKey(fromSettings: fromSettings);
    if (key == null) {
      AppLogger.error(
        'Stripe: aucune clé publishable valide (paramètres admin ou STRIPE_PUBLISHABLE_KEY)',
      );
      return false;
    }

    try {
      if (_lastAppliedKey != key) {
        Stripe.publishableKey = key;
        _lastAppliedKey = key;
      }
      await Stripe.instance
          .applySettings()
          .timeout(const Duration(seconds: 12));
      AppLogger.log('Stripe initialisé');
      return true;
    } catch (e) {
      AppLogger.error('Erreur initialisation Stripe', error: e);
      return false;
    }
  }

  static String userFacingConfigError() =>
      'Paiement indisponible : la clé Stripe n’est pas configurée. '
      'Contactez le support ou réessayez plus tard.';
}

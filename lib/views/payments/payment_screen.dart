import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../../services/backend_api_service.dart';
import '../../constants/payment_constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/price_breakdown_widget.dart';

class PaymentScreen extends StatefulWidget {
  final int reservationId;
  final int userId;
  final double amount;
  final String professionalName;

  const PaymentScreen({
    super.key,
    required this.reservationId,
    required this.userId,
    required this.amount,
    required this.professionalName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  CardFieldInputDetails? _cardDetails;

  Future<void> _handlePayment() async {
    if (_cardDetails == null || !_cardDetails!.complete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir toutes les informations de la carte'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Créer le PaymentIntent côté backend
      print('💳 [PAYMENT] Création PaymentIntent...');
      final paymentIntentData = await BackendApiService.createPaymentIntent(
        reservationId: widget.reservationId,
        userId: widget.userId,
        amount: widget.amount,
        currency: PaymentConstants.defaultCurrency,
      );

      if (paymentIntentData == null) {
        throw Exception(PaymentConstants.errorCreateIntent);
      }

      final clientSecret = paymentIntentData['clientSecret'] as String;
      final paymentIntentId = paymentIntentData['paymentIntentId'] as String;

      print('✅ [PAYMENT] PaymentIntent créé: $paymentIntentId');
      print('💳 [PAYMENT] Client Secret: ${clientSecret.substring(0, 20)}...');

      // 2. Confirmer le paiement avec Stripe
      print('💳 [PAYMENT] Confirmation du paiement avec Stripe...');
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      print('✅ [PAYMENT] Paiement confirmé par Stripe');

      // 3. Confirmer côté backend
      print('💳 [PAYMENT] Confirmation côté backend...');
      final confirmed = await BackendApiService.confirmPayment(
        paymentIntentId: paymentIntentId,
        reservationId: widget.reservationId,
        userId: widget.userId,
        amount: widget.amount,
      );

      if (confirmed == null) {
        throw Exception('Erreur lors de la confirmation backend');
      }

      print('✅ [PAYMENT] Paiement confirmé côté backend');

      // 4. Succès !
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(PaymentConstants.successPaymentCompleted),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner true pour indiquer le succès
      Navigator.of(context).pop(true);

    } on StripeException catch (e) {
      print('❌ [PAYMENT] Erreur Stripe: ${e.error.message}');
      if (!mounted) return;

      String errorMessage = PaymentConstants.errorPaymentFailed;
     
      if (e.error.code == FailureCode.Canceled) {
        errorMessage = PaymentConstants.errorPaymentCanceled;
      } else if (e.error.message != null) {
        errorMessage = e.error.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('❌ [PAYMENT] Erreur générale: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Récapitulatif
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Récapitulatif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Professionnel:'),
                        Text(
                          widget.professionalName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Réservation:'),
                        Text(
                          '#${widget.reservationId}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Répartition des prix avec frais de plateforme
            PriceBreakdownWidget(
              basePrice: widget.amount,
              label: 'Détail du montant',
            ),

            const SizedBox(height: 24),

            // Note: Le montant affiché dans PriceBreakdownWidget inclut déjà les frais
            // Le bouton de paiement utilise widget.amount qui doit être le montant total avec frais
            // Si vous passez le montant de base, utilisez PriceBreakdownWidget pour calculer le total

            // Formulaire de carte
            const Text(
              'Informations de paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            CardField(
              onCardChanged: (card) {
                setState(() {
                  _cardDetails = card;
                });
              },
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info sécurité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé par Stripe',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de paiement
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Payer ${widget.amount.toStringAsFixed(2)} ${PaymentConstants.currencySymbol}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

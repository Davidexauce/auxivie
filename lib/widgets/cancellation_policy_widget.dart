import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

/// Widget pour afficher la politique d'annulation
class CancellationPolicyWidget extends StatelessWidget {
  final DateTime reservationStart;

  const CancellationPolicyWidget({
    super.key,
    required this.reservationStart,
  });

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    final settings = settingsViewModel.settings;

    if (settings == null) {
      return const SizedBox.shrink();
    }

    final canCancel = settings.canCancelFree(reservationStart);
    final now = DateTime.now();
    final hoursUntilStart = reservationStart.difference(now).inHours;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canCancel ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canCancel ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            canCancel ? Icons.check_circle : Icons.warning_amber,
            color: canCancel ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canCancel
                      ? 'Annulation gratuite possible'
                      : 'Annulation sous conditions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canCancel ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.getCancellationPolicyText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: canCancel ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                if (!canCancel && hoursUntilStart >= 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Il reste ${hoursUntilStart}h avant le début de la réservation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


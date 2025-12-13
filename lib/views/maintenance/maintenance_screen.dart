import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Écran affiché lorsque l'application est en mode maintenance
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 120,
                color: Colors.orange,
              ),
              const SizedBox(height: 32),
              const Text(
                'Maintenance en cours',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nous effectuons actuellement une maintenance. '
                'L\'application sera de nouveau disponible très bientôt.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Recharger l'app pour vérifier si la maintenance est terminée
                  // Note: Pour un vrai rechargement, vous pourriez utiliser un package comme flutter_restart
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../theme/app_theme.dart';

/// Écran de support avec informations de contact
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchEmail(String email, BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Support Aidalia'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir l\'application email')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _launchPhone(String phone, BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de passer un appel')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    final settings = settingsViewModel.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // En-tête
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.support_agent,
                          size: 64,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Besoin d\'aide ?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Notre équipe est là pour vous accompagner',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                Card(
                  child: ListTile(
                    leading: Icon(Icons.email, color: Colors.blue),
                    title: const Text('Email'),
                    subtitle: Text(settings.contactEmail),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _launchEmail(settings.contactEmail, context),
                  ),
                ),
                const SizedBox(height: 12),

                // Téléphone
                Card(
                  child: ListTile(
                    leading: Icon(Icons.phone, color: Colors.green),
                    title: const Text('Téléphone'),
                    subtitle: Text(settings.supportPhone),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _launchPhone(settings.supportPhone, context),
                  ),
                ),
                const SizedBox(height: 24),

                // Informations supplémentaires
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nos horaires d\'ouverture: Lundi - Vendredi, 9h - 18h',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}


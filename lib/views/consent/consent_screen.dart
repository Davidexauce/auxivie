import 'package:flutter/material.dart';

import '../../services/consent_service.dart';
import '../profile/legal_info_screen.dart';

class ConsentScreen extends StatefulWidget {
  final VoidCallback? onDecided;

  const ConsentScreen({super.key, this.onDecided});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _analytics = false;
  bool _marketing = false;
  bool _showCustomize = false;
  bool _saving = false;

  Future<void> _save({required bool analytics, required bool marketing}) async {
    setState(() => _saving = true);
    try {
      await ConsentService.setConsent(analytics: analytics, marketing: marketing);
      if (!mounted) return;
      widget.onDecided?.call();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LegalInfoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité & consentement'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Votre choix, votre contrôle',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Nous utilisons des données nécessaires au fonctionnement et à la sécurité de l’application. '
              'Vous pouvez aussi choisir d’autoriser (ou non) des usages supplémentaires.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Toujours actif', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _bullet(
                      title: 'Fonctionnement & sécurité',
                      description:
                          'Connexion, paiements, prévention de fraude, et sécurité technique.',
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _openPrivacyPolicy,
                      icon: const Icon(Icons.privacy_tip_rounded),
                      label: const Text('Lire la politique de confidentialité'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Personnaliser',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Switch(
                          value: _showCustomize,
                          onChanged: _saving ? null : (v) => setState(() => _showCustomize = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Activez cette option pour choisir précisément.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                    if (_showCustomize) ...[
                      const SizedBox(height: 12),
                      _toggle(
                        title: 'Mesure d’audience (analytics)',
                        description:
                            'Nous aide à améliorer l’app (statistiques d’usage, stabilité).',
                        value: _analytics,
                        onChanged: _saving ? null : (v) => setState(() => _analytics = v),
                      ),
                      const Divider(height: 24),
                      _toggle(
                        title: 'Marketing',
                        description:
                            'Communications et recommandations (si activées dans l’app).',
                        value: _marketing,
                        onChanged: _saving ? null : (v) => setState(() => _marketing = v),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Conseil: évitez de partager des documents médicaux ou des données de santé via l’app.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_saving) const Center(child: CircularProgressIndicator()),
            if (!_saving) ...[
              FilledButton(
                onPressed: () => _save(analytics: true, marketing: true),
                child: const Text('Tout accepter'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _save(analytics: false, marketing: false),
                child: const Text('Tout refuser'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _showCustomize
                    ? () => _save(analytics: _analytics, marketing: _marketing)
                    : null,
                child: const Text('Enregistrer mes choix'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _toggle({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _bullet({required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_rounded, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}


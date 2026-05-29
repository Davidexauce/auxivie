import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations légales'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _docTile(
            context,
            title: 'Mentions légales',
            subtitle: 'Informations éditeur, hébergeur, contact',
            assetPath: 'assets/legal/mentions_legales.txt',
            icon: Icons.gavel_rounded,
          ),
          const SizedBox(height: 12),
          _docTile(
            context,
            title: 'CGV',
            subtitle: 'Conditions Générales de Vente',
            assetPath: 'assets/legal/cgv.txt',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 12),
          _docTile(
            context,
            title: 'Politique de confidentialité',
            subtitle: 'RGPD, données collectées, droits',
            assetPath: 'assets/legal/politique_confidentialite.txt',
            icon: Icons.privacy_tip_rounded,
          ),
          const SizedBox(height: 12),
          _docTile(
            context,
            title: 'Checklist confidentialité (sprints)',
            subtitle: 'Plan interne RGPD (Aidalya)',
            assetPath: 'assets/legal/checklist_confidentialite_sprints.txt',
            icon: Icons.checklist_rounded,
          ),
        ],
      ),
    );
  }

  Widget _docTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String assetPath,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _LegalDocViewerScreen(
                title: title,
                assetPath: assetPath,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LegalDocViewerScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const _LegalDocViewerScreen({
    required this.title,
    required this.assetPath,
  });

  Future<String> _load() async {
    final raw = await rootBundle.loadString(assetPath);
    return raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Impossible de charger le document.\n\nErreur: ${snapshot.error}',
              ),
            );
          }
          final text = snapshot.data ?? '';
          if (text.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Document vide.'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              text,
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
          );
        },
      ),
    );
  }
}


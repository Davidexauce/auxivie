import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../messages/chat_screen.dart';

/// Écran de détails d'une famille (pour les professionnels)
class FamilyDetailScreen extends StatelessWidget {
  final UserModel family;

  const FamilyDetailScreen({
    super.key,
    required this.family,
  });

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;
    final isProfessional = currentUser?.userType == 'professionnel';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil de la famille'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec photo/avatar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      family.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    family.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (family.ville != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          family.ville!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Informations principales
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de contact
                  _SectionCard(
                    title: 'Informations de contact',
                    children: [
                      if (family.email.isNotEmpty)
                        _InfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: family.email,
                        ),
                      if (family.phone != null && family.phone!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.phone,
                          label: 'Téléphone',
                          value: family.phone!,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Besoins
                  if (family.besoin != null && family.besoin!.isNotEmpty)
                    _SectionCard(
                      title: 'Besoins',
                      children: [
                        Text(
                          family.besoin!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),

                  if (family.besoin != null && family.besoin!.isNotEmpty)
                    const SizedBox(height: 16),

                  // Préférences
                  if (family.preference != null && family.preference!.isNotEmpty)
                    _SectionCard(
                      title: 'Préférences',
                      children: [
                        Text(
                          family.preference!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),

                  if (family.preference != null && family.preference!.isNotEmpty)
                    const SizedBox(height: 16),

                  // Mission demandée
                  if (family.mission != null && family.mission!.isNotEmpty)
                    _SectionCard(
                      title: 'Mission demandée',
                      children: [
                        Text(
                          family.mission!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),

                  if (family.mission != null && family.mission!.isNotEmpty)
                    const SizedBox(height: 16),

                  // Particularités
                  if (family.particularite != null && family.particularite!.isNotEmpty)
                    _SectionCard(
                      title: 'Particularités',
                      children: [
                        Text(
                          family.particularite!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Boutons d'action (uniquement pour les professionnels)
                  if (isProfessional && currentUser != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                currentUserId: currentUser.id!,
                                otherUserId: family.id!,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message_outlined, size: 22),
                        label: const Text(
                          'Envoyer un message',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour une section avec titre
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Widget pour afficher une ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


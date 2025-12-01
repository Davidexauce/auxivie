import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../messages/chat_screen.dart';
import '../reservations/create_reservation_screen.dart';

/// Écran de détails d'un professionnel
class ProfessionalDetailScreen extends StatefulWidget {
  final UserModel professional;

  const ProfessionalDetailScreen({
    super.key,
    required this.professional,
  });

  @override
  State<ProfessionalDetailScreen> createState() => _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;
    final isFamily = currentUser?.userType == 'famille';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du professionnel'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec photo/avatar - Style Doctolib
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.professional.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.professional.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.professional.categorie,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Informations
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ville
                  if (widget.professional.ville != null) ...[
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Ville',
                      value: widget.professional.ville!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Téléphone
                  if (widget.professional.phone != null) ...[
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Téléphone',
                      value: widget.professional.phone!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _InfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: widget.professional.email,
                  ),
                  const SizedBox(height: 16),

                  // Tarif horaire
                  if (widget.professional.tarif != null) ...[
                    _InfoRow(
                      icon: Icons.euro,
                      label: 'Tarif horaire',
                      value: '${widget.professional.tarif!.toStringAsFixed(2)} €/h',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Expérience
                  if (widget.professional.experience != null) ...[
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Expérience',
                      value: '${widget.professional.experience} ${widget.professional.experience! > 1 ? 'années' : 'année'}',
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 24),

                    // Boutons d'action (uniquement pour les familles) - Style Doctolib
                    if (isFamily && currentUser != null) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CreateReservationScreen(
                                  professional: widget.professional,
                                  userId: currentUser.id!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today, size: 22),
                          label: const Text(
                            'Prendre rendez-vous',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  currentUserId: currentUser.id!,
                                  otherUserId: widget.professional.id!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message_outlined, size: 22),
                          label: const Text(
                            'Envoyer un message',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
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
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
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


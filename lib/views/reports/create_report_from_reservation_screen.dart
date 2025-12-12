import 'package:flutter/material.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../services/backend_api_service.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Écran pour créer un signalement depuis une réservation
class CreateReportFromReservationScreen extends StatefulWidget {
  final int currentUserId;
  final ReservationModel? reservation;
  final UserModel? reportedUser; // L'utilisateur à signaler (famille ou professionnel)

  const CreateReportFromReservationScreen({
    super.key,
    required this.currentUserId,
    this.reservation,
    this.reportedUser,
  });

  @override
  State<CreateReportFromReservationScreen> createState() => _CreateReportFromReservationScreenState();
}

class _CreateReportFromReservationScreenState extends State<CreateReportFromReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _selectedReason;
  bool _isLoading = false;

  final Map<String, String> _reasons = {
    'spam': '🚫 Spam ou publicité',
    'harassment': '😡 Harcèlement ou insultes',
    'fake_profile': '🎭 Faux profil',
    'inappropriate_content': '📵 Contenu inapproprié',
    'other': '❓ Autre raison',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Veuillez sélectionner une raison'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (widget.reportedUser?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Utilisateur à signaler non trouvé'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Le reporterId est extrait automatiquement du token JWT côté backend
      final report = await BackendApiService.createReport(
        reportedUserId: widget.reportedUser!.id!,
        reason: _selectedReason!,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (report != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Signalement envoyé avec succès'),
            backgroundColor: AppTheme.emerald,
          ),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer le succès
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Erreur lors de l\'envoi du signalement'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Signaler un problème'),
        backgroundColor: AppTheme.cardBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info réservation si disponible
              if (widget.reservation != null) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppTheme.primary),
                    title: const Text('Réservation concernée'),
                    subtitle: Text(
                      'Réservation #${widget.reservation!.id}\n'
                      'Date: ${_formatDate(widget.reservation!.date)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Utilisateur signalé
              if (widget.reportedUser != null) ...[
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        widget.reportedUser!.name[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(widget.reportedUser!.name),
                    subtitle: Text(widget.reportedUser!.email),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Type de signalement
              const Text(
                'Raison du signalement *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._reasons.entries.map((entry) {
                return RadioListTile<String>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() => _selectedReason = value);
                  },
                );
              }),
              const SizedBox(height: 20),

              // Message
              const Text(
                'Description détaillée * (min. 20 caractères)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 8,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Décrivez en détail le problème rencontré...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez décrire le problème';
                  }
                  if (value.trim().length < 20) {
                    return 'La description doit faire au moins 20 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bouton d'envoi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Envoyer le signalement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Note d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.green50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.green200, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.textGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Votre signalement sera traité dans les plus brefs délais par notre équipe.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}


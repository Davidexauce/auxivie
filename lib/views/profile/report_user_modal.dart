import 'package:flutter/material.dart';
import '../../services/backend_api_service.dart';
import '../../config/app_config.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

/// Modal pour signaler un utilisateur
class ReportUserModal extends StatefulWidget {
  final UserModel reportedUser;
  final int currentUserId;

  const ReportUserModal({
    super.key,
    required this.reportedUser,
    required this.currentUserId,
  });

  @override
  State<ReportUserModal> createState() => _ReportUserModalState();
}

class _ReportUserModalState extends State<ReportUserModal> {
  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

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
    // Validation
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Veuillez sélectionner une raison'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ La description doit contenir au moins 20 caractères'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Le reporterId est extrait automatiquement du token JWT côté backend
      final report = await BackendApiService.createReport(
        reportedUserId: widget.reportedUser.id!,
        reason: _selectedReason!,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (report != null) {
        Navigator.of(context).pop(true); // Retour avec succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Signalement envoyé avec succès'),
            backgroundColor: AppTheme.emerald,
          ),
        );
      } else {
        // Le message d'erreur détaillé est déjà loggé dans BackendApiService
        // Afficher un message utilisateur plus explicite
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Erreur lors de l\'envoi du signalement. Veuillez réessayer plus tard.'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
        // Ne pas fermer le modal en cas d'erreur pour que l'utilisateur puisse réessayer
        setState(() => _isSubmitting = false);
        return;
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      if (AppConfig.enableLogging) {
        print('❌ Erreur exception dans report_user_modal: $e');
        print('Stack trace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur inattendue: ${e.toString()}'),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const Text(
                    '⚠️ Signaler un utilisateur',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Utilisateur signalé
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.green50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Text(
                      widget.reportedUser.name[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reportedUser.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (widget.reportedUser.email.isNotEmpty)
                          Text(
                            widget.reportedUser.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sélection de la raison
            const Text(
              'Raison du signalement *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
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

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description détaillée * (min. 20 caractères)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Décrivez précisément le problème rencontré...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppTheme.green50,
              ),
            ),

            const SizedBox(height: 24),

            // Avertissement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.green50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.green200, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.textGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Les signalements abusifs peuvent entraîner la suspension de votre compte.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Envoyer',
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


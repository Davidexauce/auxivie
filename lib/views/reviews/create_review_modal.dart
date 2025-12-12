import 'package:flutter/material.dart';
import '../../services/backend_api_service.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';

/// Modal pour créer un avis
class CreateReviewModal extends StatefulWidget {
  final UserModel reviewedUser; // L'utilisateur qui est noté (professionnel ou famille)
  final int? reservationId; // ID de la réservation associée (optionnel)
  final bool isProfessionalReviewingFamily; // true si c'est un professionnel qui note une famille

  const CreateReviewModal({
    super.key,
    required this.reviewedUser,
    this.reservationId,
    this.isProfessionalReviewingFamily = false,
  });

  @override
  State<CreateReviewModal> createState() => _CreateReviewModalState();
}

class _CreateReviewModalState extends State<CreateReviewModal> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Le userId sera extrait automatiquement du token JWT côté backend
      // On envoie uniquement professionalId (qui peut être le professionnel OU la famille selon le contexte)
      if (widget.reviewedUser.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Erreur: ID utilisateur manquant'),
          backgroundColor: AppTheme.error,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final reviewedUserId = widget.reviewedUser.id!;
    final commentText = _commentController.text.trim();
    final result = await BackendApiService.createReview(
        professionalId: reviewedUserId,
        rating: _selectedRating,
        comment: commentText.isEmpty ? null : commentText,
        reservationId: widget.reservationId,
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.of(context).pop(true); // Retourner true pour indiquer le succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Avis envoyé avec succès'),
            backgroundColor: AppTheme.emerald,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Erreur lors de l\'envoi de l\'avis'),
            backgroundColor: AppTheme.error,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: ${e.toString()}'),
          backgroundColor: AppTheme.error,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isProfessionalReviewingFamily
        ? 'Noter la famille'
        : 'Noter le professionnel';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
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
              
              // Utilisateur noté
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
                        widget.reviewedUser.name[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.reviewedUser.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (widget.reviewedUser.userType == 'professionnel' && widget.reviewedUser.categorie != null)
                            Text(
                              widget.reviewedUser.categorie!,
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

              // Note (étoiles)
              const Text(
                'Note *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Flexible(
                    child: IconButton(
                      icon: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        size: 36,
                        color: Colors.amber,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Commentaire
              const Text(
                'Commentaire (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppTheme.green50,
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
                      onPressed: _isSubmitting ? null : _submitReview,
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
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../services/backend_api_service.dart';
import '../../constants/review_constants.dart';
import '../../theme/app_theme.dart';

class CreateReviewScreen extends StatefulWidget {
  final int reservationId;
  final int professionalId;
  final String professionalName;

  const CreateReviewScreen({
    super.key,
    required this.reservationId,
    required this.professionalId,
    required this.professionalName,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  int _selectedRating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(ReviewConstants.errorInvalidRating),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await BackendApiService.createReview(
          reservationId: widget.reservationId,
          professionalId: widget.professionalId,
          rating: _selectedRating,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
        );

        if (result != null) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(ReviewConstants.successCreateReview),
              backgroundColor: AppTheme.emerald,
            ),
          );
          
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(ReviewConstants.errorCreateReview),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre note *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return Flexible(
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  starValue <= _selectedRating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: starValue <= _selectedRating 
                      ? Colors.amber 
                      : AppTheme.textTertiary,
                ),
                onPressed: () => setState(() => _selectedRating = starValue),
              ),
            );
          }),
        ),
        if (_selectedRating > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              ReviewConstants.ratingLabels[_selectedRating] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Laisser un avis'),
        backgroundColor: AppTheme.cardBackground,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info professionnel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.green50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.green200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        widget.professionalName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Professionnel',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          Text(
                            widget.professionalName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Note par étoiles
              _buildStarRating(),
              
              const SizedBox(height: 24),
              
              // Commentaire
              TextFormField(
                controller: _commentController,
                maxLines: 5,
                maxLength: ReviewConstants.maxCommentLength,
                decoration: InputDecoration(
                  labelText: ReviewConstants.labelComment,
                  hintText: ReviewConstants.placeholderComment,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderSlate),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderSlate),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  hintStyle: const TextStyle(color: AppTheme.textTertiary),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton soumettre
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                        ),
                      )
                    : const Text(
                        'Publier l\'avis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


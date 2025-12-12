import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/backend_api_service.dart';
import '../../theme/app_theme.dart';
import '../messages/chat_screen.dart';
import '../reservations/create_reservation_screen.dart';
import '../profile/report_user_modal.dart';

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
  List<Map<String, dynamic>> _badges = [];
  Map<String, dynamic>? _rating;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadgesRatingAndReviews();
  }

  Future<void> _loadBadgesRatingAndReviews() async {
    if (widget.professional.id == null) {
      print('⚠️ Professional ID est null');
      return;
    }

    print('🔄 Chargement badges/rating/reviews pour professionnel ID: ${widget.professional.id}');

    setState(() {
      _isLoading = true;
    });

    try {
      // Charger directement depuis le backend (base de données unique)
      print('📡 Chargement depuis le backend (base unique)...');
      final badges = await BackendApiService.getBadges(widget.professional.id!);
      final rating = await BackendApiService.getRating(widget.professional.id!);
      final reviews = await BackendApiService.getReviews(widget.professional.id!);

      print('📊 Données reçues:');
      print('  - Badges: ${badges.length}');
      print('  - Rating: ${rating != null ? "Oui" : "Non"}');
      print('  - Reviews: ${reviews.length}');

      // Utiliser directement les données du backend
      setState(() {
        _badges = badges.map((b) => b.toMap()).toList();
        _rating = rating?.toMap();
        _reviews = reviews.map((r) => r.toMap()).toList();
        _isLoading = false;
      });
      
      print('✅ État mis à jour avec ${_badges.length} badges, ${_reviews.length} avis');
      if (_badges.isNotEmpty) {
        print('📋 Badges à afficher:');
        for (final badge in _badges) {
          print('   - ${badge['badgeName']} (${badge['badgeIcon']})');
        }
      } else {
        print('⚠️ Aucun badge à afficher pour userId ${widget.professional.id}');
      }
    } catch (e, stackTrace) {
      print('❌ Erreur chargement badges/rating/reviews: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;
    final isFamily = currentUser?.userType == 'famille';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du professionnel'),
        actions: [
          if (currentUser != null && currentUser.id != widget.professional.id)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Signaler',
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => ReportUserModal(
                    reportedUser: widget.professional,
                    currentUserId: currentUser.id!,
                  ),
                );
                // Le modal gère déjà l'affichage du message de succès
              },
            ),
        ],
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

                  // Badges - Affichés pour tous (familles et professionnels)
                  if (_isLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 24),
                  ] else if (_badges.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Badges',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _badges.map((badge) {
                        return Chip(
                          avatar: badge['badgeIcon'] != null && badge['badgeIcon'].toString().isNotEmpty
                              ? Text(
                                  badge['badgeIcon'].toString(),
                                  style: const TextStyle(fontSize: 16),
                                )
                              : null,
                          label: Text(
                            badge['badgeName']?.toString() ?? 'Badge',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppTheme.green50,
                          labelStyle: const TextStyle(color: AppTheme.textGreen),
                          side: const BorderSide(color: AppTheme.borderLight),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Note moyenne
                  if (!_isLoading && _rating != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '${(_rating!['averageRating'] as num?)?.toStringAsFixed(1) ?? '0.0'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_rating!['totalRatings'] ?? 0} avis)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Avis et Note moyenne
                  if (!_isLoading && (_rating != null || _reviews.isNotEmpty)) ...[
                    Text(
                      'Avis et notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Note moyenne
                    if (_rating != null && _rating!['totalRatings'] > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.green50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.green200),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (_rating!['averageRating'] as num).toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textGreen,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (index) {
                                    final avgRating = (_rating!['averageRating'] as num).toDouble();
                                    return Icon(
                                      index < avgRating.round()
                                          ? Icons.star
                                          : (index < avgRating ? Icons.star_half : Icons.star_border),
                                      size: 20,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_rating!['totalRatings']} ${(_rating!['totalRatings'] as int) > 1 ? 'avis' : 'avis'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Basé sur les avis des utilisateurs',
                                    style: TextStyle(
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
                      const SizedBox(height: 16),
                    ],
                    
                    // Liste des avis
                    if (_reviews.isNotEmpty) ...[
                      ..._reviews.take(10).map((review) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      review['userName'] ?? 'Utilisateur anonyme',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ...List.generate(5, (index) {
                                        return Icon(
                                          index < (review['rating'] as int? ?? 0)
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 18,
                                          color: Colors.amber,
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  review['comment'].toString(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                              if (review['createdAt'] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(review['createdAt'].toString()),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      if (_reviews.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Et ${_reviews.length - 10} autre${_reviews.length - 10 > 1 ? 's' : ''} avis...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ] else if (_rating == null || (_rating!['totalRatings'] as int) == 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.green50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.textTertiary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Aucun avis pour le moment',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],

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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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


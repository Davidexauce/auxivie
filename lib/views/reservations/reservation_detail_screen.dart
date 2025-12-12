import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reservation_model.dart';
import '../../viewmodels/reservation_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/backend_api_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../reports/create_report_from_reservation_screen.dart';
import '../reviews/create_review_modal.dart';

/// Écran de détails d'une réservation
class ReservationDetailScreen extends StatefulWidget {
  final ReservationModel reservation;

  const ReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  UserModel? _user;
  UserModel? _professional;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // Charger depuis le backend (base de données unique)
    final user = await BackendApiService.getUserById(widget.reservation.userId);
    final professional = await BackendApiService.getUserById(widget.reservation.professionnelId);

    setState(() {
      _user = user;
      _professional = professional;
      _isLoading = false;
    });
  }

  Future<void> _confirmReservation() async {
    final reservationViewModel = Provider.of<ReservationViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final isProfessional = currentUser.userType == 'professionnel';
    final currentUserId = currentUser.id!;
    
    final success = await reservationViewModel.confirmReservation(
      widget.reservation,
      currentUserId: currentUserId,
      isProfessional: isProfessional,
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reservationViewModel.errorMessage ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToCreateReport() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Déterminer quel utilisateur signaler
    UserModel? reportedUser;
    if (currentUser.userType == 'professionnel') {
      // Si le professionnel signale, c'est la famille qui est signalée
      reportedUser = _user;
    } else {
      // Si la famille signale, c'est le professionnel qui est signalé
      reportedUser = _professional;
    }
    
    if (reportedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de déterminer l\'utilisateur à signaler'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateReportFromReservationScreen(
          currentUserId: currentUser.id!,
          reservation: widget.reservation,
          reportedUser: reportedUser,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Signalement envoyé'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _cancelReservation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final reservationViewModel = Provider.of<ReservationViewModel>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final currentUser = authViewModel.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur non connecté'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final isProfessional = currentUser.userType == 'professionnel';
      final currentUserId = currentUser.id!;
      
      final success = await reservationViewModel.cancelReservation(
        widget.reservation,
        currentUserId: currentUserId,
        isProfessional: isProfessional,
      );
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation annulée'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reservationViewModel.errorMessage ?? 'Erreur'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _hasReviewedUser() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    
    if (currentUser == null) return false;
    
    // Déterminer quel utilisateur a été noté
    UserModel? reviewedUser;
    if (currentUser.userType == 'professionnel') {
      reviewedUser = _user; // Le professionnel note la famille
    } else {
      reviewedUser = _professional; // La famille note le professionnel
    }
    
    if (reviewedUser == null) return false;
    
    // Vérifier si un avis existe déjà pour cette réservation et cet utilisateur
    try {
      final reviews = await BackendApiService.getReviews(reviewedUser.id);
      return reviews.any((review) => review.reservationId == widget.reservation.id);
    } catch (e) {
      return false;
    }
  }

  Future<void> _navigateToCreateReview() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    
    // Déterminer quel utilisateur noter
    UserModel? reviewedUser;
    bool isProfessionalReviewingFamily = false;
    
    if (currentUser.userType == 'professionnel') {
      reviewedUser = _user; // Le professionnel note la famille
      isProfessionalReviewingFamily = true;
    } else {
      reviewedUser = _professional; // La famille note le professionnel
    }
    
    if (reviewedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de déterminer l\'utilisateur à noter'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateReviewModal(
        reviewedUser: reviewedUser!,
        reservationId: widget.reservation.id,
        isProfessionalReviewingFamily: isProfessionalReviewingFamily,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Avis envoyé avec succès'),
          backgroundColor: AppTheme.emerald,
        ),
      );
      // Recharger pour mettre à jour l'affichage
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    final statusColors = {
      'pending': Colors.orange,
      'confirmed': Colors.green,
      'completed': Colors.blue,
      'cancelled': Colors.red,
    };

    final statusLabels = {
      'pending': 'En attente',
      'confirmed': 'Confirmée',
      'completed': 'Terminée',
      'cancelled': 'Annulée',
    };

    final color = statusColors[widget.reservation.status] ?? Colors.grey;
    final label = statusLabels[widget.reservation.status] ?? widget.reservation.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la réservation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Statut
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date et heure
                  _InfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: '${widget.reservation.date.day}/${widget.reservation.date.month}/${widget.reservation.date.year}',
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.access_time,
                    title: widget.reservation.heureFin != null && widget.reservation.heureFin!.isNotEmpty
                        ? 'Heures'
                        : 'Heure',
                    value: widget.reservation.heureFin != null && widget.reservation.heureFin!.isNotEmpty
                        ? '${widget.reservation.heure} - ${widget.reservation.heureFin}'
                        : widget.reservation.heure,
                  ),
                  // Afficher les besoins si présents
                  if (widget.reservation.besoins != null && widget.reservation.besoins!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: Colors.blue.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Besoins spécifiques',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.reservation.besoins!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Informations du professionnel
                  if (_professional != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Professionnel',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    _professional!.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _professional!.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        _professional!.categorie,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Informations de la famille
                  if (_user != null && _user!.userType == 'famille')
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Famille',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    _user!.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _user!.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Bouton pour créer un avis (si réservation terminée ou confirmée)
                  if ((widget.reservation.status == 'completed' || widget.reservation.status == 'confirmed') && currentUser != null) ...[
                    FutureBuilder<bool>(
                      future: _hasReviewedUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        
                        final hasReviewed = snapshot.data ?? false;
                        if (hasReviewed) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.green50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.green200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.emerald, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Vous avez déjà donné un avis pour cette réservation',
                                    style: TextStyle(color: AppTheme.textGreen),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _navigateToCreateReview,
                            icon: const Icon(Icons.star_outline),
                            label: Text(
                              currentUser.userType == 'professionnel'
                                  ? 'Noter la famille'
                                  : 'Noter le professionnel',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Actions
                  if (widget.reservation.status == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Confirmer la réservation'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _cancelReservation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Annuler la réservation'),
                    ),
                  ),
                  
                  // Bouton signaler un problème
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _navigateToCreateReport,
                      icon: const Icon(Icons.report_problem),
                      label: const Text('Signaler un problème'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Widget pour afficher une information
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
        ),
      ),
    );
  }
}


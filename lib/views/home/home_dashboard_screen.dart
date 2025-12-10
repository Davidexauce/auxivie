import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/reservation_viewmodel.dart';
import '../../viewmodels/message_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/reservation_model.dart';

/// Écran d'accueil avec statistiques et informations
class HomeDashboardScreen extends StatefulWidget {
  final UserModel currentUser;
  final Function(int) onNavigate;

  const HomeDashboardScreen({
    super.key,
    required this.currentUser,
    required this.onNavigate,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (!mounted) return;
    final reservationViewModel = Provider.of<ReservationViewModel>(context, listen: false);
    final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
    
    reservationViewModel.loadUserReservations(widget.currentUser.id!);
    messageViewModel.loadConversations(widget.currentUser.id!);
  }

  @override
  Widget build(BuildContext context) {
    final isProfessional = widget.currentUser.userType == 'professionnel';

    // HomeDashboardScreen est dans un IndexedStack, donc il n'est pas dans la pile de navigation
    // Le bouton retour système ne devrait rien faire ici
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Ne rien faire - on est dans un IndexedStack, le retour est géré par le HomeScreen
      },
      child: SafeArea(
        child: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              _WelcomeHeader(
                userName: widget.currentUser.name,
                isProfessional: isProfessional,
              ),
              const SizedBox(height: 24),

              // Statistiques rapides
              Consumer<ReservationViewModel>(
                builder: (context, reservationViewModel, child) {
                  return Consumer<MessageViewModel>(
                    builder: (context, messageViewModel, child) {
                      return _StatsGrid(
                        reservationsCount: reservationViewModel.reservations.length,
                        unreadMessagesCount: messageViewModel.unreadCount,
                        isProfessional: isProfessional,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Réservations à venir
              Consumer<ReservationViewModel>(
                builder: (context, reservationViewModel, child) {
                  final upcomingReservations = reservationViewModel.reservations
                      .where((r) => r.status == 'pending' || r.status == 'confirmed')
                      .where((r) => r.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));

                  if (upcomingReservations.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return _UpcomingReservationsSection(
                    reservations: upcomingReservations.take(3).toList(),
                    onViewAll: () => widget.onNavigate(3),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Conseils pratiques personnalisés
              _PracticalTipsSection(isProfessional: isProfessional),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// En-tête de bienvenue
class _WelcomeHeader extends StatelessWidget {
  final String userName;
  final bool isProfessional;

  const _WelcomeHeader({
    required this.userName,
    required this.isProfessional,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isProfessional
                ? 'Gérez vos réservations et votre activité'
                : 'Trouvez le professionnel qu\'il vous faut',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grille de statistiques
class _StatsGrid extends StatelessWidget {
  final int reservationsCount;
  final int unreadMessagesCount;
  final bool isProfessional;

  const _StatsGrid({
    required this.reservationsCount,
    required this.unreadMessagesCount,
    required this.isProfessional,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_rounded,
            label: 'Réservations',
            value: reservationsCount.toString(),
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.message_rounded,
            label: 'Messages',
            value: unreadMessagesCount > 0 ? '$unreadMessagesCount' : '0',
            color: unreadMessagesCount > 0 ? AppTheme.error : AppTheme.textTertiary,
            badge: unreadMessagesCount > 0 ? unreadMessagesCount : null,
          ),
        ),
      ],
    );
  }
}

/// Carte de statistique
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int? badge;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (badge != null && badge! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section des réservations à venir
class _UpcomingReservationsSection extends StatelessWidget {
  final List<ReservationModel> reservations;
  final VoidCallback onViewAll;

  const _UpcomingReservationsSection({
    required this.reservations,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Réservations à venir',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...reservations.map((reservation) => _ReservationCard(reservation: reservation)),
      ],
    );
  }
}

/// Carte de réservation
class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'pending': Colors.orange,
      'confirmed': Colors.green,
      'cancelled': Colors.red,
    };

    final statusLabels = {
      'pending': 'En attente',
      'confirmed': 'Confirmée',
      'cancelled': 'Annulée',
    };

    final color = statusColors[reservation.status] ?? Colors.grey;
    final label = statusLabels[reservation.status] ?? reservation.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reservation.date.day}/${reservation.date.month}/${reservation.date.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      reservation.heureFin != null && reservation.heureFin!.isNotEmpty
                          ? '${reservation.heure} - ${reservation.heureFin}'
                          : reservation.heure,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section des conseils pratiques personnalisés
class _PracticalTipsSection extends StatelessWidget {
  final bool isProfessional;

  const _PracticalTipsSection({required this.isProfessional});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: AppTheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isProfessional ? 'Conseils pour professionnels' : 'Conseils pratiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isProfessional) _ProfessionalTips() else _FamilyTips(),
      ],
    );
  }
}

/// Conseils pour les professionnels
class _ProfessionalTips extends StatelessWidget {
  final List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.calendar_today_rounded,
      'title': 'Optimisez votre planning',
      'description': 'Remplissez vos disponibilités régulièrement pour maximiser vos réservations.',
      'color': AppTheme.primary,
    },
    {
      'icon': Icons.star_outline_rounded,
      'title': 'Améliorez votre profil',
      'description': 'Ajoutez votre photo et détaillez votre expérience pour attirer plus de familles.',
      'color': AppTheme.emerald,
    },
    {
      'icon': Icons.message_outlined,
      'title': 'Répondez rapidement',
      'description': 'Les familles apprécient les réponses rapides. Vérifiez vos messages régulièrement.',
      'color': AppTheme.primaryLight,
    },
    {
      'icon': Icons.verified_outlined,
      'title': 'Confirmez les réservations',
      'description': 'Confirmez rapidement les demandes pour rassurer les familles et sécuriser votre planning.',
      'color': Colors.orange,
    },
    {
      'icon': Icons.trending_up_rounded,
      'title': 'Augmentez votre visibilité',
      'description': 'Mettez à jour votre tarif selon votre expérience et la demande dans votre région.',
      'color': AppTheme.error,
    },
    {
      'icon': Icons.favorite_outline_rounded,
      'title': 'Cultivez la relation',
      'description': 'Faites preuve d\'écoute et de bienveillance. La qualité de service amène les meilleures recommandations.',
      'color': Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _tips.map((tip) => _TipCard(
        icon: tip['icon'] as IconData,
        title: tip['title'] as String,
        description: tip['description'] as String,
        color: tip['color'] as Color,
      )).toList(),
    );
  }
}

/// Conseils pour les familles
class _FamilyTips extends StatelessWidget {
  final List<Map<String, dynamic>> _tips = [
    {
      'icon': Icons.search_rounded,
      'title': 'Choisissez avec soin',
      'description': 'Lisez les avis et le profil complet des professionnels pour faire le bon choix.',
      'color': AppTheme.primary,
    },
    {
      'icon': Icons.calendar_today_rounded,
      'title': 'Planifiez à l\'avance',
      'description': 'Réservez plusieurs jours à l\'avance pour garantir la disponibilité du professionnel.',
      'color': AppTheme.emerald,
    },
    {
      'icon': Icons.message_outlined,
      'title': 'Communiquez vos besoins',
      'description': 'Décrivez clairement vos besoins et attentes lors de la réservation pour un service optimal.',
      'color': AppTheme.primaryLight,
    },
    {
      'icon': Icons.family_restroom_rounded,
      'title': 'Préparez votre domicile',
      'description': 'Préparez l\'espace de travail et communiquez les informations importantes au professionnel.',
      'color': Colors.orange,
    },
    {
      'icon': Icons.star_rate_rounded,
      'title': 'Laissez un avis',
      'description': 'Partagez votre expérience après le service pour aider les autres familles.',
      'color': AppTheme.error,
    },
    {
      'icon': Icons.lock_outline_rounded,
      'title': 'Sécurisez vos paiements',
      'description': 'Utilisez notre système de paiement sécurisé Stripe pour toutes vos transactions.',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _tips.map((tip) => _TipCard(
        icon: tip['icon'] as IconData,
        title: tip['title'] as String,
        description: tip['description'] as String,
        color: tip['color'] as Color,
      )).toList(),
    );
  }
}

/// Carte de conseil
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

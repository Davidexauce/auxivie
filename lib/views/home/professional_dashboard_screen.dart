import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/reservation_viewmodel.dart';
import '../../viewmodels/message_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/reservation_model.dart';

/// Tableau de bord professionnel avec statistiques
class ProfessionalDashboardScreen extends StatefulWidget {
  final UserModel currentUser;
  final Function(int) onNavigate;

  const ProfessionalDashboardScreen({
    super.key,
    required this.currentUser,
    required this.onNavigate,
  });

  @override
  State<ProfessionalDashboardScreen> createState() => _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState extends State<ProfessionalDashboardScreen> {
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
    
    reservationViewModel.loadProfessionalReservations(widget.currentUser.id!);
    messageViewModel.loadConversations(widget.currentUser.id!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              // En-tête professionnel
              _ProfessionalHeader(
                userName: widget.currentUser.name,
                category: widget.currentUser.categorie,
                city: widget.currentUser.ville,
              ),
              const SizedBox(height: 24),

              // Statistiques principales
              Consumer<ReservationViewModel>(
                builder: (context, reservationViewModel, child) {
                  return Consumer<MessageViewModel>(
                    builder: (context, messageViewModel, child) {
                      final stats = _calculateStats(reservationViewModel.reservations);
                      return _ProfessionalStatsGrid(
                        totalReservations: reservationViewModel.reservations.length,
                        pendingReservations: stats['pending'] ?? 0,
                        confirmedReservations: stats['confirmed'] ?? 0,
                        completedReservations: stats['completed'] ?? 0,
                        unreadMessages: messageViewModel.unreadCount,
                        estimatedRevenue: stats['revenue'] ?? 0.0,
                        hourlyRate: widget.currentUser.tarif ?? 0.0,
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
                    return _EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: 'Aucune réservation à venir',
                      subtitle: 'Vos prochaines réservations apparaîtront ici',
                    );
                  }

                  return _UpcomingReservationsSection(
                    reservations: upcomingReservations.take(5).toList(),
                    onViewAll: () => widget.onNavigate(3),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Actions rapides
              _ProfessionalQuickActions(
                onNavigate: widget.onNavigate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<ReservationModel> reservations) {
    int pending = 0;
    int confirmed = 0;
    int completed = 0;
    double revenue = 0.0;

    for (final reservation in reservations) {
      if (reservation.status == 'pending') pending++;
      if (reservation.status == 'confirmed') confirmed++;
      if (reservation.status == 'completed') {
        completed++;
        // Estimation basée sur le tarif horaire (supposons 1h par réservation)
        revenue += widget.currentUser.tarif ?? 0.0;
      }
    }

    return {
      'pending': pending,
      'confirmed': confirmed,
      'completed': completed,
      'revenue': revenue,
    };
  }
}

/// En-tête professionnel
class _ProfessionalHeader extends StatelessWidget {
  final String userName;
  final String category;
  final String? city;

  const _ProfessionalHeader({
    required this.userName,
    required this.category,
    this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tableau de bord',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (city != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.location_on_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    city!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grille de statistiques professionnelles
class _ProfessionalStatsGrid extends StatelessWidget {
  final int totalReservations;
  final int pendingReservations;
  final int confirmedReservations;
  final int completedReservations;
  final int unreadMessages;
  final double estimatedRevenue;
  final double hourlyRate;

  const _ProfessionalStatsGrid({
    required this.totalReservations,
    required this.pendingReservations,
    required this.confirmedReservations,
    required this.completedReservations,
    required this.unreadMessages,
    required this.estimatedRevenue,
    required this.hourlyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProfessionalStatCard(
                icon: Icons.calendar_today_rounded,
                label: 'Total',
                value: totalReservations.toString(),
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfessionalStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'En attente',
                value: pendingReservations.toString(),
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProfessionalStatCard(
                icon: Icons.check_circle_rounded,
                label: 'Confirmées',
                value: confirmedReservations.toString(),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfessionalStatCard(
                icon: Icons.done_all_rounded,
                label: 'Terminées',
                value: completedReservations.toString(),
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ProfessionalStatCard(
                icon: Icons.message_rounded,
                label: 'Messages',
                value: unreadMessages > 0 ? '$unreadMessages' : '0',
                color: unreadMessages > 0 ? AppTheme.error : AppTheme.textTertiary,
                badge: unreadMessages > 0 ? unreadMessages : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfessionalStatCard(
                icon: Icons.euro_rounded,
                label: 'Revenus estimés',
                value: '${estimatedRevenue.toStringAsFixed(0)} €',
                color: AppTheme.emerald,
                subtitle: hourlyRate > 0 ? '${hourlyRate.toStringAsFixed(0)} €/h' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Carte de statistique professionnelle
class _ProfessionalStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int? badge;
  final String? subtitle;

  const _ProfessionalStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badge,
    this.subtitle,
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
              fontSize: 24,
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
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
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
              'Prochaines réservations',
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
        ...reservations.map((reservation) => _ProfessionalReservationCard(reservation: reservation)),
      ],
    );
  }
}

/// Carte de réservation professionnelle
class _ProfessionalReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ProfessionalReservationCard({required this.reservation});

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${reservation.date.day}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  _getMonthName(reservation.date.month),
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      reservation.heure,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }
}

/// État vide
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Actions rapides professionnelles
class _ProfessionalQuickActions extends StatelessWidget {
  final Function(int) onNavigate;

  const _ProfessionalQuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.calendar_today_rounded,
          title: 'Mon planning',
          subtitle: 'Gérer mes réservations',
          color: AppTheme.primary,
          onTap: () => onNavigate(3),
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.message_rounded,
          title: 'Mes messages',
          subtitle: 'Consulter mes conversations',
          color: AppTheme.emerald,
          onTap: () => onNavigate(2),
        ),
      ],
    );
  }
}

/// Carte d'action rapide
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}


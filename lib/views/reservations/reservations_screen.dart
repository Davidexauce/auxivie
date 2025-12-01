import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../viewmodels/reservation_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/reservation_model.dart';
import 'reservation_detail_screen.dart';

/// Écran de planning/réservations
class ReservationsScreen extends StatefulWidget {
  final int userId;

  const ReservationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadReservations() async {
    if (!mounted || _hasLoaded) return;
    
    _hasLoaded = true;
    final reservationViewModel = Provider.of<ReservationViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    if (user != null) {
      if (user.userType == 'professionnel') {
        await reservationViewModel.loadProfessionalReservations(widget.userId);
      } else {
        await reservationViewModel.loadUserReservations(widget.userId);
      }
    }
  }

  Map<DateTime, List<ReservationModel>> _getReservationsByDate(ReservationViewModel reservationViewModel) {
    final Map<DateTime, List<ReservationModel>> reservationsByDate = {};

    for (final reservation in reservationViewModel.reservations) {
      final date = DateTime(
        reservation.date.year,
        reservation.date.month,
        reservation.date.day,
      );
      if (reservationsByDate[date] == null) {
        reservationsByDate[date] = [];
      }
      reservationsByDate[date]!.add(reservation);
    }

    return reservationsByDate;
  }

  List<ReservationModel> _getReservationsForSelectedDay(ReservationViewModel reservationViewModel) {
    final reservationsByDate = _getReservationsByDate(reservationViewModel);
    final selectedDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    return reservationsByDate[selectedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;
    final isFamily = currentUser?.userType == 'famille';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning'),
        actions: [
          if (isFamily)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // L'écran de création de réservation sera créé séparément
                // Pour l'instant, on affiche juste un message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Créez une réservation depuis la page d\'un professionnel'),
                  ),
                );
              },
              tooltip: 'Nouvelle réservation',
            ),
        ],
      ),
      body: Consumer<ReservationViewModel>(
        builder: (context, reservationViewModel, child) {
          // Charger les réservations après le premier frame
          if (!_hasLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadReservations();
            });
          }

          if (reservationViewModel.isLoading && reservationViewModel.reservations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservationsByDate = _getReservationsByDate(reservationViewModel);

          return Column(
            children: [
              // Calendrier
              Card(
                margin: const EdgeInsets.all(16),
                child: TableCalendar<ReservationModel>(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) {
                    final date = DateTime(day.year, day.month, day.day);
                    return reservationsByDate[date] ?? [];
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),

              // Réservations du jour sélectionné
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Réservations du ${_formatDate(_selectedDay)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _getReservationsForSelectedDay(reservationViewModel).isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucune réservation',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _getReservationsForSelectedDay(reservationViewModel).length,
                              itemBuilder: (context, index) {
                                final reservation = _getReservationsForSelectedDay(reservationViewModel)[index];
                                return _ReservationCard(reservation: reservation);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Carte pour une réservation
class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
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

    final color = statusColors[reservation.status] ?? Colors.grey;
    final label = statusLabels[reservation.status] ?? reservation.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            Icons.calendar_today,
            color: color,
          ),
        ),
        title: Text(
          '${reservation.heure}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReservationDetailScreen(reservation: reservation),
            ),
          );
        },
      ),
    );
  }
}


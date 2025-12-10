import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/reservation_model.dart';
import '../../viewmodels/reservation_viewmodel.dart';
import '../../services/backend_api_service.dart';
import '../payments/payment_screen.dart';
import '../../theme/app_theme.dart';

/// Modèle pour une journée de réservation
class _ReservationDay {
  final DateTime date;
  String heureDebut;
  String? heureFin;

  _ReservationDay({
    required this.date,
    required this.heureDebut,
    this.heureFin,
  });
}

/// Écran de création d'une réservation
class CreateReservationScreen extends StatefulWidget {
  final UserModel professional;
  final int userId;

  const CreateReservationScreen({
    super.key,
    required this.professional,
    required this.userId,
  });

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Set<DateTime> _selectedDays = {};
  List<_ReservationDay> _reservationDays = [];
  String _defaultHeureDebut = '09:00';
  String _defaultHeureFin = '17:00';
  final TextEditingController _besoinsController = TextEditingController();
  
  final List<String> _timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser avec le jour sélectionné
    _selectedDays.add(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));
    _updateReservationDays();
  }

  @override
  void dispose() {
    _besoinsController.dispose();
    super.dispose();
  }

  void _updateReservationDays() {
    final List<_ReservationDay> days = [];
    final sortedDays = _selectedDays.toList()..sort();
    
    for (final date in sortedDays) {
      // Chercher si ce jour existe déjà dans la liste
      final existing = _reservationDays.firstWhere(
        (d) => isSameDay(d.date, date),
        orElse: () => _ReservationDay(
          date: date,
          heureDebut: _defaultHeureDebut,
          heureFin: _defaultHeureFin,
        ),
      );
      days.add(_ReservationDay(
        date: date,
        heureDebut: existing.heureDebut,
        heureFin: existing.heureFin,
      ));
    }
    
    setState(() {
      _reservationDays = days;
    });
  }

  /// Calcule le montant total basé sur les heures réelles de chaque jour
  double _calculateTotalAmount() {
    if (widget.professional.tarif == null || widget.professional.tarif == 0) {
      return 0.0;
    }

    double totalHours = 0.0;
    
    for (final day in _reservationDays) {
      if (day.heureFin != null && day.heureFin!.isNotEmpty) {
        try {
          final debutParts = day.heureDebut.split(':');
          final finParts = day.heureFin!.split(':');
          if (debutParts.length == 2 && finParts.length == 2) {
            final debut = int.parse(debutParts[0]) * 60 + int.parse(debutParts[1]);
            final fin = int.parse(finParts[0]) * 60 + int.parse(finParts[1]);
            if (fin > debut) {
              totalHours += (fin - debut) / 60.0;
            }
          }
        } catch (e) {
          // Ignorer les erreurs de parsing
        }
      }
    }
    
    return widget.professional.tarif! * totalHours;
  }

  Future<void> _handleCreateReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un jour'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Vérifier que toutes les heures sont valides
    for (final day in _reservationDays) {
      if (day.heureFin == null || day.heureFin!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez définir une heure de fin pour ${DateFormat('dd/MM/yyyy').format(day.date)}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      try {
        final debutParts = day.heureDebut.split(':');
        final finParts = day.heureFin!.split(':');
        if (debutParts.length != 2 || finParts.length != 2) {
          throw Exception('Format invalide');
        }
        final debut = int.parse(debutParts[0]) * 60 + int.parse(debutParts[1]);
        final fin = int.parse(finParts[0]) * 60 + int.parse(finParts[1]);
        if (fin <= debut) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('L\'heure de fin doit être après l\'heure de début pour ${DateFormat('dd/MM/yyyy').format(day.date)}'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Format d\'heure invalide pour ${DateFormat('dd/MM/yyyy').format(day.date)}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Vérifier que le professionnel a un tarif
    if (widget.professional.tarif == null || widget.professional.tarif == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce professionnel n\'a pas de tarif défini'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = _calculateTotalAmount();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le montant total doit être supérieur à 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Afficher un dialogue de confirmation avec le récapitulatif
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réservation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_reservationDays.length} jour(s) sélectionné(s):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._reservationDays.map((day) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${DateFormat('dd/MM/yyyy').format(day.date)}: ${day.heureDebut} - ${day.heureFin}',
                  style: const TextStyle(fontSize: 14),
                ),
              )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous serez redirigé vers le paiement après la création des réservations.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Afficher un indicateur de chargement
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Créer toutes les réservations
    final List<ReservationModel> reservations = [];
    final besoinsText = _besoinsController.text.trim();
    
    for (final day in _reservationDays) {
      reservations.add(ReservationModel(
        userId: widget.userId,
        professionnelId: widget.professional.id!,
        date: day.date,
        heure: day.heureDebut,
        heureFin: day.heureFin,
        besoins: besoinsText.isNotEmpty ? besoinsText : null,
        status: 'pending',
      ));
    }

    // Créer toutes les réservations et récupérer les IDs
    final reservationIds = await BackendApiService.createMultipleReservations(reservations);

    if (!mounted) return;
    Navigator.of(context).pop(); // Fermer le dialog de chargement

    if (reservationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création des réservations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (reservationIds.length < reservations.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reservationIds.length}/${reservations.length} réservations créées avec succès'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // Recharger les réservations
    final reservationViewModel = Provider.of<ReservationViewModel>(context, listen: false);
    await reservationViewModel.loadUserReservations(widget.userId);

    // Afficher l'écran de paiement avec le montant cumulé
    if (mounted) {
      final paymentSuccess = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            reservationId: reservationIds.first, // Utiliser le premier ID pour le paiement
            userId: widget.userId,
            amount: amount, // Montant total cumulé
            professionalName: widget.professional.name,
          ),
        ),
      );

      if (paymentSuccess == true) {
        // Paiement réussi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${reservationIds.length} réservation(s) créée(s) et payée(s) avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Retour à l'écran précédent
        }
      } else {
        // Paiement échoué ou annulé
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${reservationIds.length} réservation(s) créée(s) mais le paiement n\'a pas été effectué. Vous pouvez payer plus tard.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop(); // Retour à l'écran précédent
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réservation'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Informations du professionnel
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.cardBackground,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        widget.professional.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
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
                          Text(
                            widget.professional.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.professional.categorie,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          if (widget.professional.tarif != null)
                            Text(
                              '${widget.professional.tarif!.toStringAsFixed(2)} €/h',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Calendrier avec sélection multiple
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionnez les jours',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous pouvez sélectionner plusieurs jours (consécutifs ou non)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 90)),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            final normalized = DateTime(day.year, day.month, day.day);
                            return _selectedDays.contains(normalized);
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: AppTheme.emerald,
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
                              _focusedDay = focusedDay;
                              _selectedDay = selectedDay;
                              final normalized = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                              
                              if (_selectedDays.contains(normalized)) {
                                _selectedDays.remove(normalized);
                              } else {
                                _selectedDays.add(normalized);
                              }
                              _updateReservationDays();
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Paramètres par défaut
                      Text(
                        'Heures par défaut',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _TimePickerField(
                              label: 'Heure début',
                              value: _defaultHeureDebut,
                              onChanged: (value) {
                                setState(() {
                                  _defaultHeureDebut = value;
                                  // Mettre à jour tous les jours avec les valeurs par défaut
                                  for (final day in _reservationDays) {
                                    if (day.heureDebut == _defaultHeureDebut) {
                                      day.heureDebut = value;
                                    }
                                  }
                                });
                                _updateReservationDays();
                              },
                              timeSlots: _timeSlots,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TimePickerField(
                              label: 'Heure fin',
                              value: _defaultHeureFin,
                              onChanged: (value) {
                                setState(() {
                                  _defaultHeureFin = value;
                                  // Mettre à jour tous les jours avec les valeurs par défaut
                                  for (final day in _reservationDays) {
                                    if (day.heureFin == _defaultHeureFin || day.heureFin == null) {
                                      day.heureFin = value;
                                    }
                                  }
                                });
                                _updateReservationDays();
                              },
                              timeSlots: _timeSlots,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Détails par jour
                      if (_reservationDays.isNotEmpty) ...[
                        Text(
                          'Détails par jour (${_reservationDays.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ..._reservationDays.map((day) => _DayReservationCard(
                          day: day,
                          timeSlots: _timeSlots,
                          onChanged: () {
                            setState(() {
                              // La carte a été modifiée, on met à jour la liste
                              _updateReservationDays();
                            });
                          },
                        )),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Section Besoins spécifiques
                      Text(
                        'Vos besoins spécifiques',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Décrivez vos besoins, préférences ou informations importantes pour cette réservation (optionnel)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: TextField(
                          controller: _besoinsController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Ex: Personne à mobilité réduite, préférence pour les repas végétariens, présence d\'un animal de compagnie, tâches spécifiques à effectuer...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Montant total
                      if (widget.professional.tarif != null && widget.professional.tarif! > 0)
                        Card(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Montant total',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '${_reservationDays.length} jour(s)',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(_calculateTotalAmount()),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bouton de création
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Consumer<ReservationViewModel>(
                    builder: (context, reservationViewModel, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: reservationViewModel.isLoading || _selectedDays.isEmpty
                              ? null
                              : _handleCreateReservation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: reservationViewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Réserver et payer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
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

/// Widget pour sélectionner une heure
class _TimePickerField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final List<String> timeSlots;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.timeSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: timeSlots.map((time) {
              return DropdownMenuItem(
                value: time,
                child: Text(time),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Carte pour configurer une journée de réservation
class _DayReservationCard extends StatefulWidget {
  final _ReservationDay day;
  final List<String> timeSlots;
  final VoidCallback onChanged;

  const _DayReservationCard({
    required this.day,
    required this.timeSlots,
    required this.onChanged,
  });

  @override
  State<_DayReservationCard> createState() => _DayReservationCardState();
}

class _DayReservationCardState extends State<_DayReservationCard> {
  late String _heureDebut;
  late String? _heureFin;

  @override
  void initState() {
    super.initState();
    _heureDebut = widget.day.heureDebut;
    _heureFin = widget.day.heureFin;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(widget.day.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimePickerField(
                    label: 'Heure début',
                    value: _heureDebut,
                    onChanged: (value) {
                      setState(() {
                        _heureDebut = value;
                        widget.day.heureDebut = value;
                      });
                      widget.onChanged();
                    },
                    timeSlots: widget.timeSlots,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimePickerField(
                    label: 'Heure fin',
                    value: _heureFin ?? '',
                    onChanged: (value) {
                      setState(() {
                        _heureFin = value;
                        widget.day.heureFin = value;
                      });
                      widget.onChanged();
                    },
                    timeSlots: widget.timeSlots.where((slot) {
                      // Filtrer pour que l'heure de fin soit après l'heure de début
                      try {
                        final debutParts = _heureDebut.split(':');
                        final slotParts = slot.split(':');
                        final debut = int.parse(debutParts[0]) * 60 + int.parse(debutParts[1]);
                        final slotTime = int.parse(slotParts[0]) * 60 + int.parse(slotParts[1]);
                        return slotTime > debut;
                      } catch (e) {
                        return true;
                      }
                    }).toList(),
                  ),
                ),
              ],
            ),
            if (_heureFin != null && _heureFin!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppTheme.emerald),
                    const SizedBox(width: 8),
                    Text(
                      _calculateHours(_heureDebut, _heureFin!),
                      style: TextStyle(
                        color: AppTheme.emerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _calculateHours(String debut, String fin) {
    try {
      final debutParts = debut.split(':');
      final finParts = fin.split(':');
      final debutMinutes = int.parse(debutParts[0]) * 60 + int.parse(debutParts[1]);
      final finMinutes = int.parse(finParts[0]) * 60 + int.parse(finParts[1]);
      final hours = (finMinutes - debutMinutes) / 60.0;
      return '${hours.toStringAsFixed(1)} heure(s)';
    } catch (e) {
      return '0 heure';
    }
  }
}

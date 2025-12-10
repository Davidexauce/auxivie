import 'package:flutter/material.dart';
import '../../models/availability_model.dart';
import '../../services/backend_api_service.dart';

/// Écran de gestion des disponibilités pour les professionnels
class AvailabilityScreen extends StatefulWidget {
  final int professionnelId;

  const AvailabilityScreen({
    super.key,
    required this.professionnelId,
  });

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  Map<int, AvailabilityModel> _availabilities = {};
  bool _isLoading = true;
  final List<String> _timeSlots = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'
  ];

  final List<Map<String, dynamic>> _jours = [
    {'id': 1, 'nom': 'Lundi'},
    {'id': 2, 'nom': 'Mardi'},
    {'id': 3, 'nom': 'Mercredi'},
    {'id': 4, 'nom': 'Jeudi'},
    {'id': 5, 'nom': 'Vendredi'},
    {'id': 6, 'nom': 'Samedi'},
    {'id': 0, 'nom': 'Dimanche'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailabilities();
  }

  Future<void> _loadAvailabilities() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await BackendApiService.getAvailabilities(widget.professionnelId);
      final Map<int, AvailabilityModel> availabilities = {};
      
      for (final item in data) {
        final availability = AvailabilityModel.fromMap(item);
        availabilities[availability.jourSemaine] = availability;
      }
      
      setState(() {
        _availabilities = availabilities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _saveAvailability(int jourSemaine, String heureDebut, String heureFin) async {
    try {
      final success = await BackendApiService.saveAvailability(
        professionnelId: widget.professionnelId,
        jourSemaine: jourSemaine,
        heureDebut: heureDebut,
        heureFin: heureFin,
      );

      if (success) {
        await _loadAvailabilities();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disponibilité enregistrée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'enregistrement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteAvailability(int availabilityId) async {
    try {
      final success = await BackendApiService.deleteAvailability(availabilityId);
      if (success) {
        await _loadAvailabilities();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disponibilité supprimée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes disponibilités'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Définissez vos heures de disponibilité',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Les familles pourront réserver uniquement pendant ces créneaux',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._jours.map((jour) => _buildDayAvailability(jour['id'] as int, jour['nom'] as String)),
                ],
              ),
            ),
    );
  }

  Widget _buildDayAvailability(int jourSemaine, String jourNom) {
    final availability = _availabilities[jourSemaine];
    String heureDebut = availability?.heureDebut ?? '09:00';
    String heureFin = availability?.heureFin ?? '17:00';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  jourNom,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (availability != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer la disponibilité'),
                          content: Text('Voulez-vous supprimer la disponibilité du $jourNom ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deleteAvailability(availability.id!);
                              },
                              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heure de début',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: heureDebut,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _timeSlots.map((time) {
                          return DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              heureDebut = value;
                            });
                            _saveAvailability(jourSemaine, heureDebut, heureFin);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heure de fin',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: heureFin,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _timeSlots.map((time) {
                          // Ne permettre que les heures après l'heure de début
                          final heureDebutIndex = _timeSlots.indexOf(heureDebut);
                          final timeIndex = _timeSlots.indexOf(time);
                          if (timeIndex <= heureDebutIndex) {
                            return null;
                          }
                          return DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          );
                        }).whereType<DropdownMenuItem<String>>().toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              heureFin = value;
                            });
                            _saveAvailability(jourSemaine, heureDebut, heureFin);
                          }
                        },
                      ),
                    ],
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


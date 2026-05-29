import 'package:flutter/material.dart';
import '../../services/backend_api_service.dart';
import '../../models/user_model.dart';
import '../../utils/user_display_name.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  final UserModel user;

  const EditPersonalInfoScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _villeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _dateController = TextEditingController(); // Controller pour afficher la date
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime? _selectedDateNaissance;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      _nameController.text = widget.user.name.isNotEmpty ? widget.user.name : '';
      
      // Récupérer firstName et lastName depuis le modèle
      String? firstName = widget.user.firstName;
      String? lastName = widget.user.lastName;
      
      // Si firstName ou lastName sont vides, essayer de les extraire depuis name
      if ((firstName == null || firstName.isEmpty) && 
          (lastName == null || lastName.isEmpty) && 
          widget.user.name.isNotEmpty) {
        final nameParts = widget.user.name.trim().split(' ');
        if (nameParts.length >= 2) {
          firstName = nameParts[0];
          lastName = nameParts.sublist(1).join(' ');
        } else if (nameParts.length == 1) {
          firstName = nameParts[0];
        }
      }
      
      _firstNameController.text = firstName ?? '';
      _lastNameController.text = lastName ?? '';
      _addressController.text = widget.user.address ?? '';
      _villeController.text = widget.user.ville ?? '';
      _experienceController.text = widget.user.experience?.toString() ?? '';
      
      // Debug pour voir ce qui est chargé
      debugPrint('📝 [EDIT PROFILE] Initialisation:');
      debugPrint('   name: ${widget.user.name}');
      debugPrint('   firstName (from model): ${widget.user.firstName}');
      debugPrint('   lastName (from model): ${widget.user.lastName}');
      debugPrint('   firstName (final): $firstName');
      debugPrint('   lastName (final): $lastName');
      debugPrint('   address: ${widget.user.address}');
      debugPrint('   ville: ${widget.user.ville}');
      debugPrint('   experience: ${widget.user.experience}');
      
      // Initialiser la date
      _initializeDate();
    } catch (e) {
      debugPrint('❌ Erreur initialisation: $e');
    }
  }

  void _initializeDate() {
    try {
      DateTime? userDate;
      
      // Priorité à dateOfBirth (string)
      if (widget.user.dateOfBirth != null && widget.user.dateOfBirth!.isNotEmpty) {
        userDate = DateTime.tryParse(widget.user.dateOfBirth!);
      }
      
      // Fallback sur dateNaissance (DateTime)
      if (userDate == null && widget.user.dateNaissance != null) {
        userDate = widget.user.dateNaissance;
      }
      
      if (userDate != null && userDate.year >= 1900 && userDate.year <= 2100) {
        _selectedDateNaissance = DateTime(userDate.year, userDate.month, userDate.day);
        _dateController.text = _formatDate(_selectedDateNaissance);
      } else {
        _selectedDateNaissance = null;
        _dateController.text = '';
      }
    } catch (e) {
      print('❌ Erreur initialisation date: $e');
      _selectedDateNaissance = null;
      _dateController.text = '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _villeController.dispose();
    _experienceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
    } catch (e) {
      return '';
    }
  }

  /// SOLUTION ULTIME : Date picker avec protections maximales
  /// Utilise rootNavigator pour éviter les problèmes de context
  Future<void> _selectDate(BuildContext context) async {
    // Vérifier que le widget est toujours monté
    if (!mounted) return;
    
    // Capturer le messenger AVANT les opérations async
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Date initiale par défaut (25 ans en arrière)
      final now = DateTime.now();
      final defaultInitialDate = DateTime(now.year - 25, now.month, now.day);
      
      DateTime initialDate;
      if (_selectedDateNaissance != null) {
        try {
          final date = _selectedDateNaissance!;
          // Valider la date
          if (date.year >= 1900 && 
              date.year <= now.year && 
              (date.isBefore(now) || date.isAtSameMomentAs(now))) {
            initialDate = date;
          } else {
            initialDate = defaultInitialDate;
          }
        } catch (e) {
          initialDate = defaultInitialDate;
        }
      } else {
        initialDate = defaultInitialDate;
      }

      // Dates limites
      final firstDate = DateTime(1900, 1, 1);
      final lastDate = now;
      
      // S'assurer que initialDate est dans les limites
      if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      } else if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      }

      if (!mounted) return;

      // Afficher le date picker SANS locale et SANS builder personnalisé pour éviter les plantages
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        // Ne pas utiliser locale pour éviter les problèmes
        // Ne pas utiliser builder pour éviter les problèmes de theme
        helpText: 'Sélectionner une date de naissance',
        cancelText: 'Annuler',
        confirmText: 'Valider',
      );

      if (!mounted) return;

      if (picked != null) {
        setState(() {
          _selectedDateNaissance = picked;
          _dateController.text = _formatDate(picked);
        });
      }
    } catch (e, stackTrace) {
      // Log détaillé de l'erreur
      debugPrint('❌ [DATE PICKER] Erreur: $e');
      debugPrint('❌ [DATE PICKER] Stack trace: $stackTrace');
      
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de la date: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final experience = int.tryParse(_experienceController.text);
      
      // Formater la date
      String? dateOfBirthString;
      if (_selectedDateNaissance != null) {
        try {
          final date = _selectedDateNaissance!;
          dateOfBirthString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        } catch (e) {
          throw Exception('Date de naissance invalide');
        }
      }
      
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final nameToUse = buildUserDisplayName(
        name: _nameController.text.trim(),
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        experience: experience,
      );
      
      final updates = <String, dynamic>{
        'name': nameToUse,
        'firstName': _firstNameController.text.trim().isNotEmpty ? _firstNameController.text.trim() : null,
        'lastName': _lastNameController.text.trim().isNotEmpty ? _lastNameController.text.trim() : null,
        'email': widget.user.email,
        if (widget.user.phone != null) 'phone': widget.user.phone,
        'categorie': widget.user.categorie,
        if (dateOfBirthString != null) 'dateOfBirth': dateOfBirthString,
        if (_addressController.text.trim().isNotEmpty) 'address': _addressController.text.trim(),
        if (_villeController.text.trim().isNotEmpty) 'ville': _villeController.text.trim(),
        if (experience != null) 'experience': experience,
        if (widget.user.tarif != null) 'tarif': widget.user.tarif,
        if (widget.user.photo != null) 'photo': widget.user.photo,
      };

      final success = await BackendApiService.updateUser(widget.user.id!, updates);
      
      if (!success) {
        throw Exception('Erreur lors de la mise à jour');
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations mises à jour')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.id == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: Text('Utilisateur invalide')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier les informations personnelles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prénom
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Nom
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // SOLUTION RADICALE : TextFormField readOnly avec onTap
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: const OutlineInputBorder(),
                  hintText: 'Sélectionner une date',
                ),
                onTap: () {
                  if (mounted) {
                    _selectDate(context);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Adresse
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Numéro, rue, ville, code postal',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Ville
              TextFormField(
                controller: _villeController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Expérience
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Années d\'expérience',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final exp = int.tryParse(value);
                    if (exp == null || exp < 0) {
                      return 'Expérience invalide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Bouton sauvegarder
              ElevatedButton(
                onPressed: _isLoading ? null : _saveInfo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/backend_api_service.dart';
import '../../models/user_model.dart';

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
  final _villeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _villeController.text = widget.user.ville ?? '';
    _experienceController.text = widget.user.experience?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final experience = int.tryParse(_experienceController.text);
      
      // Préparer les mises à jour
      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': widget.user.email,
        if (widget.user.phone != null) 'phone': widget.user.phone,
        'categorie': widget.user.categorie,
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
        Navigator.of(context).pop(true); // Retourner true pour indiquer une mise à jour réussie
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier les informations personnelles'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _villeController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Années d\'expérience',
                  prefixIcon: Icon(Icons.calendar_today),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _saveInfo,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


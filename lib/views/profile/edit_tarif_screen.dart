import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class EditTarifScreen extends StatefulWidget {
  final double? currentTarif;
  final int? userId;

  const EditTarifScreen({
    super.key,
    this.currentTarif,
    this.userId,
  });

  @override
  State<EditTarifScreen> createState() => _EditTarifScreenState();
}

class _EditTarifScreenState extends State<EditTarifScreen> {
  final _tarifController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentTarif != null) {
      _tarifController.text = widget.currentTarif!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _tarifController.dispose();
    super.dispose();
  }

  Future<void> _saveTarif() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.userId != null) {
        final user = await DatabaseService.instance.getUserById(widget.userId!);
        if (user != null) {
          final tarif = double.tryParse(_tarifController.text);
          final updatedUser = user.copyWith(tarif: tarif);
          await DatabaseService.instance.updateUser(updatedUser);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarif mis à jour')),
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
        title: const Text('Modifier le tarif horaire'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tarifController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tarif horaire (€)',
                  hintText: '25.0',
                  prefixIcon: Icon(Icons.euro),
                  helperText: 'Entre 0 et 100 €',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final tarif = double.tryParse(value);
                    if (tarif == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    if (tarif < 0) {
                      return 'Le tarif ne peut pas être négatif';
                    }
                    if (tarif > 100) {
                      return 'Le tarif ne peut pas dépasser 100 €';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTarif,
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


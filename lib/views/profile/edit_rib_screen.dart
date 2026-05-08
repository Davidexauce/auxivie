import 'package:flutter/material.dart';

import '../../services/backend_api_service.dart';

/// Normalise un IBAN : espaces retirés, majuscules.
String normalizeIbanInput(String raw) {
  return raw.replaceAll(RegExp(r'\s'), '').toUpperCase();
}

/// Validation minimale : IBAN français (27 caractères, préfixe FR) ou identifiant bancaire strictement numérique (ex. RIB 23 chiffres).
bool isAcceptedBankIdentifier(String normalized) {
  if (normalized.isEmpty) return false;
  if (RegExp(r'^FR\d{25}$').hasMatch(normalized)) return true;
  if (RegExp(r'^\d{23}$').hasMatch(normalized)) return true;
  return false;
}

class EditRibScreen extends StatefulWidget {
  final int userId;
  final String? initialRib;

  const EditRibScreen({
    super.key,
    required this.userId,
    this.initialRib,
  });

  @override
  State<EditRibScreen> createState() => _EditRibScreenState();
}

class _EditRibScreenState extends State<EditRibScreen> {
  final _ribController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRib?.trim();
    if (initial != null && initial.isNotEmpty) {
      _ribController.text = initial;
    }
  }

  @override
  void dispose() {
    _ribController.dispose();
    super.dispose();
  }

  Future<void> _saveRib() async {
    if (!_formKey.currentState!.validate()) return;

    final normalized = normalizeIbanInput(_ribController.text);
    if (!isAcceptedBankIdentifier(normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Format invalide : utilisez un IBAN français (FR + 25 caractères) ou 23 chiffres (RIB).'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ok =
        await BackendApiService.updateUser(widget.userId, {'rib': normalized});

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RIB / IBAN enregistré')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Enregistrement impossible. Vérifiez la connexion ou que le serveur accepte le champ « rib ».'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le RIB'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _ribController,
                decoration: const InputDecoration(
                  labelText: 'IBAN ou RIB',
                  hintText: 'FR76 XXXX XXXX XXXX XXXX XXXX XXX',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre IBAN ou RIB';
                  }
                  final n = normalizeIbanInput(value);
                  if (!isAcceptedBankIdentifier(n)) {
                    return 'IBAN FR (27 caractères) ou RIB (23 chiffres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRib,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
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

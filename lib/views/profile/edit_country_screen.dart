import 'package:flutter/material.dart';

class EditCountryScreen extends StatefulWidget {
  final String? currentCountry;

  const EditCountryScreen({
    super.key,
    this.currentCountry,
  });

  @override
  State<EditCountryScreen> createState() => _EditCountryScreenState();
}

class _EditCountryScreenState extends State<EditCountryScreen> {
  String? _selectedCountry;
  final List<String> _countries = [
    'France',
    'Belgique',
    'Suisse',
    'Canada',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.currentCountry ?? 'France';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le pays'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Pays',
                prefixIcon: Icon(Icons.flag),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedCountry);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pays mis à jour')),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}


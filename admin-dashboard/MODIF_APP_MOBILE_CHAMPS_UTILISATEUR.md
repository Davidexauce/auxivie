# Modifications Application Mobile - Champs Utilisateur

**Date:** 13 Décembre 2025  
**Projet:** Auxivie - Application mobile Flutter  
**Objectif:** Ajouter les champs firstName, lastName, dateOfBirth et address

---

## 📋 Nouveaux champs disponibles dans l'API

L'API `/api/users/:id` retourne maintenant ces champs supplémentaires :

```json
{
  "id": 1,
  "name": "LOLO jean",
  "firstName": null,          // ✅ NOUVEAU
  "lastName": null,           // ✅ NOUVEAU
  "email": "lolo@gmail.com",
  "phone": "0765566776",
  "dateOfBirth": null,        // ✅ NOUVEAU (format: "YYYY-MM-DD")
  "address": null,            // ✅ NOUVEAU
  "categorie": "Auxiliaire de vie",
  "ville": "Melun",
  "tarif": "12.00",
  "experience": 8,
  "photo": null,
  "userType": "professionnel",
  "besoin": null,
  "preference": null,
  "mission": null,
  "particularite": null
}
```

---

## 1. 📦 Modèle User

**Fichier:** `lib/models/user.dart` ou `lib/models/user_model.dart`

### Modifications à apporter :

```dart
class User {
  final int id;
  final String name;
  final String? firstName;      // ✅ AJOUTER
  final String? lastName;       // ✅ AJOUTER
  final String email;
  final String? phone;
  final String? dateOfBirth;    // ✅ AJOUTER (format: "YYYY-MM-DD" ou "DD/MM/YYYY")
  final String? address;        // ✅ AJOUTER
  final String? categorie;
  final String? ville;
  final double? tarif;
  final int? experience;
  final String? photo;
  final String userType;
  final String? besoin;
  final String? preference;
  final String? mission;
  final String? particularite;

  User({
    required this.id,
    required this.name,
    this.firstName,              // ✅ AJOUTER
    this.lastName,               // ✅ AJOUTER
    required this.email,
    this.phone,
    this.dateOfBirth,            // ✅ AJOUTER
    this.address,                // ✅ AJOUTER
    this.categorie,
    this.ville,
    this.tarif,
    this.experience,
    this.photo,
    required this.userType,
    this.besoin,
    this.preference,
    this.mission,
    this.particularite,
  });

  // ✅ AJOUTER : Getter pour calculer l'âge depuis dateOfBirth
  int? get age {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return null;
    
    try {
      // Supporter les formats YYYY-MM-DD ou DD/MM/YYYY
      DateTime birth;
      if (dateOfBirth!.contains('-')) {
        birth = DateTime.parse(dateOfBirth!);
      } else if (dateOfBirth!.contains('/')) {
        final parts = dateOfBirth!.split('/');
        birth = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return null;
      }
      
      final now = DateTime.now();
      int age = now.year - birth.year;
      
      if (now.month < birth.month || 
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      print('Erreur parsing dateOfBirth: $e');
      return null;
    }
  }

  // ✅ AJOUTER : Getter pour le nom complet
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return name;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      firstName: json['firstName'] as String?,              // ✅ AJOUTER
      lastName: json['lastName'] as String?,                // ✅ AJOUTER
      email: json['email'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,          // ✅ AJOUTER
      address: json['address'] as String?,                  // ✅ AJOUTER
      categorie: json['categorie'] as String?,
      ville: json['ville'] as String?,
      tarif: json['tarif'] != null 
          ? double.tryParse(json['tarif'].toString())
          : null,
      experience: json['experience'] as int?,
      photo: json['photo'] as String?,
      userType: json['userType'] as String? ?? 'client',
      besoin: json['besoin'] as String?,
      preference: json['preference'] as String?,
      mission: json['mission'] as String?,
      particularite: json['particularite'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,                  // ✅ AJOUTER
      'lastName': lastName,                    // ✅ AJOUTER
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,              // ✅ AJOUTER
      'address': address,                      // ✅ AJOUTER
      'categorie': categorie,
      'ville': ville,
      'tarif': tarif,
      'experience': experience,
      'photo': photo,
      'userType': userType,
      'besoin': besoin,
      'preference': preference,
      'mission': mission,
      'particularite': particularite,
    };
  }

  // Copier avec modifications
  User copyWith({
    int? id,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? categorie,
    String? ville,
    double? tarif,
    int? experience,
    String? photo,
    String? userType,
    String? besoin,
    String? preference,
    String? mission,
    String? particularite,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      categorie: categorie ?? this.categorie,
      ville: ville ?? this.ville,
      tarif: tarif ?? this.tarif,
      experience: experience ?? this.experience,
      photo: photo ?? this.photo,
      userType: userType ?? this.userType,
      besoin: besoin ?? this.besoin,
      preference: preference ?? this.preference,
      mission: mission ?? this.mission,
      particularite: particularite ?? this.particularite,
    );
  }
}
```

---

## 2. 👤 Écran Profil Utilisateur

**Fichier:** `lib/screens/profile_screen.dart` ou `lib/screens/user_profile_screen.dart`

### Affichage des nouvelles informations :

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: user),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo de profil
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: user.photo != null
                    ? NetworkImage(user.photo!)
                    : null,
                child: user.photo == null
                    ? Text(
                        user.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            SizedBox(height: 24),

            // Nom complet
            Center(
              child: Text(
                user.fullName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                user.userType,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 32),

            // Section Informations personnelles
            _buildSectionTitle('Informations personnelles'),
            SizedBox(height: 16),
            
            // ✅ AJOUTER : Prénom
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Prénom',
              value: user.firstName ?? 'Non renseigné',
            ),
            
            // ✅ AJOUTER : Nom
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Nom',
              value: user.lastName ?? 'Non renseigné',
            ),
            
            // ✅ AJOUTER : Âge (calculé)
            if (user.age != null)
              _buildInfoRow(
                icon: Icons.cake_outlined,
                label: 'Âge',
                value: '${user.age} ans',
              ),
            
            // ✅ AJOUTER : Date de naissance
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date de naissance',
              value: user.dateOfBirth != null
                  ? _formatDate(user.dateOfBirth!)
                  : 'Non renseignée',
            ),
            
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
            ),
            
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: user.phone ?? 'Non renseigné',
            ),
            
            // ✅ AJOUTER : Adresse
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Adresse',
              value: user.address ?? 'Non renseignée',
              maxLines: 3,
            ),
            
            _buildInfoRow(
              icon: Icons.location_city_outlined,
              label: 'Ville',
              value: user.ville ?? 'Non renseignée',
            ),

            // Section professionnelle (si professionnel)
            if (user.userType == 'professionnel') ...[
              SizedBox(height: 32),
              _buildSectionTitle('Informations professionnelles'),
              SizedBox(height: 16),
              
              _buildInfoRow(
                icon: Icons.work_outline,
                label: 'Catégorie',
                value: user.categorie ?? '-',
              ),
              
              _buildInfoRow(
                icon: Icons.euro_outlined,
                label: 'Tarif horaire',
                value: user.tarif != null ? '${user.tarif}€/h' : '-',
              ),
              
              _buildInfoRow(
                icon: Icons.stars_outlined,
                label: 'Expérience',
                value: user.experience != null ? '${user.experience} ans' : '-',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      DateTime dateTime;
      if (date.contains('-')) {
        dateTime = DateTime.parse(date);
      } else if (date.contains('/')) {
        final parts = date.split('/');
        dateTime = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return date;
      }
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}
```

---

## 3. ✏️ Écran d'Inscription

**Fichier:** `lib/screens/register_screen.dart`

### Ajouter les champs dans le formulaire :

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // ✅ AJOUTER : Nouveaux contrôleurs
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  
  final _phoneController = TextEditingController();
  final _villeController = TextEditingController();
  
  // ✅ AJOUTER : Variable pour la date de naissance
  DateTime? _dateOfBirth;
  
  String _userType = 'client';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Créer un compte',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),

              // Type d'utilisateur
              DropdownButtonFormField<String>(
                value: _userType,
                decoration: InputDecoration(
                  labelText: 'Type de compte *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                  DropdownMenuItem(value: 'professionnel', child: Text('Professionnel')),
                ],
                onChanged: (value) => setState(() => _userType = value!),
              ),
              SizedBox(height: 16),

              // ✅ AJOUTER : Prénom
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre prénom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // ✅ AJOUTER : Nom
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // ✅ AJOUTER : Date de naissance
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                    locale: Locale('fr', 'FR'),
                  );
                  if (date != null) {
                    setState(() => _dateOfBirth = date);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date de naissance *',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'JJ/MM/AAAA',
                    ),
                    controller: TextEditingController(
                      text: _dateOfBirth != null
                          ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                          : '',
                    ),
                    validator: (value) {
                      if (_dateOfBirth == null) {
                        return 'Veuillez sélectionner votre date de naissance';
                      }
                      
                      // Vérifier l'âge minimum (18 ans)
                      final now = DateTime.now();
                      int age = now.year - _dateOfBirth!.year;
                      if (now.month < _dateOfBirth!.month || 
                          (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
                        age--;
                      }
                      
                      if (age < 18) {
                        return 'Vous devez avoir au moins 18 ans';
                      }
                      
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // ✅ AJOUTER : Adresse
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'Numéro, rue, ville, code postal',
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),

              // Ville
              TextFormField(
                controller: _villeController,
                decoration: InputDecoration(
                  labelText: 'Ville *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre ville';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Confirmation mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Bouton d'inscription
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('S\'inscrire', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ Formater la date au format YYYY-MM-DD pour l'API
      final dateOfBirthFormatted = _dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
          : null;

      // Appel au service d'authentification
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: '${_firstNameController.text} ${_lastNameController.text}',
        firstName: _firstNameController.text.trim(),        // ✅ AJOUTER
        lastName: _lastNameController.text.trim(),          // ✅ AJOUTER
        dateOfBirth: dateOfBirthFormatted,                  // ✅ AJOUTER
        address: _addressController.text.trim(),            // ✅ AJOUTER
        phone: _phoneController.text.trim(),
        ville: _villeController.text.trim(),
        userType: _userType,
      );

      // Navigation vers l'écran principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _firstNameController.dispose();       // ✅ AJOUTER
    _lastNameController.dispose();        // ✅ AJOUTER
    _addressController.dispose();         // ✅ AJOUTER
    _phoneController.dispose();
    _villeController.dispose();
    super.dispose();
  }
}
```

---

## 4. 📝 Écran de Modification du Profil

**Fichier:** `lib/screens/edit_profile_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _villeController;
  
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _villeController = TextEditingController(text: widget.user.ville ?? '');
    
    // Parser la date de naissance
    if (widget.user.dateOfBirth != null && widget.user.dateOfBirth!.isNotEmpty) {
      try {
        if (widget.user.dateOfBirth!.contains('-')) {
          _dateOfBirth = DateTime.parse(widget.user.dateOfBirth!);
        } else if (widget.user.dateOfBirth!.contains('/')) {
          final parts = widget.user.dateOfBirth!.split('/');
          _dateOfBirth = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        print('Erreur parsing date: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier mon profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isLoading ? null : _handleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo de profil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.user.photo != null
                          ? NetworkImage(widget.user.photo!)
                          : null,
                      child: widget.user.photo == null
                          ? Text(
                              widget.user.fullName.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontSize: 40),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 20,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                          onPressed: () {
                            // Gérer le changement de photo
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Prénom
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Nom
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date de naissance
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateOfBirth ?? DateTime.now().subtract(Duration(days: 365 * 25)),
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                    locale: Locale('fr', 'FR'),
                  );
                  if (date != null) {
                    setState(() => _dateOfBirth = date);
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'JJ/MM/AAAA',
                    ),
                    controller: TextEditingController(
                      text: _dateOfBirth != null
                          ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                          : '',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              // Adresse
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'Numéro, rue, ville, code postal',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),

              // Ville
              TextFormField(
                controller: _villeController,
                decoration: InputDecoration(
                  labelText: 'Ville',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Enregistrer', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Formater la date au format YYYY-MM-DD
      final dateOfBirthFormatted = _dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(_dateOfBirth!)
          : null;

      final userService = Provider.of<UserService>(context, listen: false);
      await userService.updateProfile(
        userId: widget.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: dateOfBirthFormatted,
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        ville: _villeController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Profil mis à jour')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _villeController.dispose();
    super.dispose();
  }
}
```

---

## 5. 🔌 Service d'Authentification

**Fichier:** `lib/services/auth_service.dart`

### Mettre à jour la méthode d'inscription :

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://auxivie.org/api';

  Future<User> register({
    required String email,
    required String password,
    required String name,
    String? firstName,          // ✅ AJOUTER
    String? lastName,           // ✅ AJOUTER
    String? dateOfBirth,        // ✅ AJOUTER (format: "YYYY-MM-DD")
    String? address,            // ✅ AJOUTER
    String? phone,
    String? ville,
    String? categorie,
    String? userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'firstName': firstName,          // ✅ AJOUTER
          'lastName': lastName,            // ✅ AJOUTER
          'dateOfBirth': dateOfBirth,      // ✅ AJOUTER
          'address': address,              // ✅ AJOUTER
          'phone': phone,
          'ville': ville,
          'categorie': categorie,
          'userType': userType ?? 'client',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Email ou mot de passe incorrect');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    
    return null;
  }
}
```

---

## 6. 🔄 Service Utilisateur

**Fichier:** `lib/services/user_service.dart`

### Méthode de mise à jour du profil :

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'https://auxivie.org/api';

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<User> getUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  Future<User> updateProfile({
    required int userId,
    String? name,
    String? firstName,          // ✅ AJOUTER
    String? lastName,           // ✅ AJOUTER
    String? dateOfBirth,        // ✅ AJOUTER
    String? address,            // ✅ AJOUTER
    String? email,
    String? phone,
    String? ville,
    String? categorie,
    double? tarif,
    int? experience,
    String? photo,
    String? besoin,
    String? preference,
    String? mission,
    String? particularite,
  }) async {
    try {
      final token = await _getToken();
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (firstName != null) 'firstName': firstName,          // ✅ AJOUTER
          if (lastName != null) 'lastName': lastName,            // ✅ AJOUTER
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,  // ✅ AJOUTER
          if (address != null) 'address': address,              // ✅ AJOUTER
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (ville != null) 'ville': ville,
          if (categorie != null) 'categorie': categorie,
          if (tarif != null) 'tarif': tarif,
          if (experience != null) 'experience': experience,
          if (photo != null) 'photo': photo,
          if (besoin != null) 'besoin': besoin,
          if (preference != null) 'preference': preference,
          if (mission != null) 'mission': mission,
          if (particularite != null) 'particularite': particularite,
        }),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(jsonDecode(response.body));
        
        // Mettre à jour l'utilisateur en cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));
        
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
}
```

---

## 7. ✅ Validation

**Fichier:** `lib/utils/validators.dart`

### Fonction de validation de l'âge :

```dart
class Validators {
  // Validation de l'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  // Validation du téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone requis';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Téléphone invalide (10 chiffres)';
    }
    return null;
  }

  // ✅ AJOUTER : Validation de l'âge minimum
  static String? validateAge(DateTime? dateOfBirth, {int minAge = 18}) {
    if (dateOfBirth == null) {
      return 'Date de naissance requise';
    }

    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    if (age < minAge) {
      return 'Vous devez avoir au moins $minAge ans';
    }

    return null;
  }

  // ✅ AJOUTER : Validation du champ requis
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requis';
    }
    return null;
  }

  // Validation du mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Au moins 6 caractères';
    }
    return null;
  }

  // Validation de confirmation de mot de passe
  static String? validatePasswordConfirm(String? value, String password) {
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
```

---

## 8. 🎨 Widget Réutilisable - Champ de profil

**Fichier:** `lib/widgets/profile_field.dart`

```dart
import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final int maxLines;
  final VoidCallback? onTap;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.maxLines = 1,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.blue, size: 24),
              SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value == 'Non renseigné' || value == '-' 
                          ? Colors.grey[400]
                          : Colors.black87,
                    ),
                    maxLines: maxLines,
                    overflow: maxLines > 1 
                        ? TextOverflow.ellipsis 
                        : TextOverflow.clip,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
```

---

## 9. 📦 Dépendances requises

**Fichier:** `pubspec.yaml`

Ajouter si manquant :

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP requests
  http: ^1.1.0
  
  # Stockage local
  shared_preferences: ^2.2.2
  
  # Formatage de dates
  intl: ^0.18.1
  
  # State management
  provider: ^6.1.1
```

---

## 10. 🔧 Backend - Vérifications

### Route d'inscription - `/api/register`

**Fichier backend:** `/root/auxivie/backend/server.js`

Vérifier que la route accepte les nouveaux champs :

```javascript
app.post('/api/register', async (req, res) => {
  try {
    const {
      email,
      password,
      name,
      firstName,      // ✅ Doit être accepté
      lastName,       // ✅ Doit être accepté
      dateOfBirth,    // ✅ Doit être accepté
      address,        // ✅ Doit être accepté
      phone,
      ville,
      categorie,
      userType,
    } = req.body;

    // Validation
    if (!email || !password || !name) {
      return res.status(400).json({ message: 'Champs requis manquants' });
    }

    // Vérifier si l'email existe déjà
    const existingUser = await db.get('SELECT id FROM users WHERE email = ?', [email]);
    if (existingUser) {
      return res.status(400).json({ message: 'Cet email est déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insérer l'utilisateur
    const result = await db.run(
      `INSERT INTO users (
        name, firstName, lastName, email, password, phone, 
        dateOfBirth, address, ville, categorie, userType, createdAt
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        name,
        firstName || null,
        lastName || null,
        email,
        hashedPassword,
        phone || null,
        dateOfBirth || null,
        address || null,
        ville || null,
        categorie || null,
        userType || 'client',
      ]
    );

    // Générer le token JWT
    const token = jwt.sign(
      { id: result.lastID, email, userType: userType || 'client' },
      process.env.JWT_SECRET || 'secret_key',
      { expiresIn: '30d' }
    );

    // Récupérer l'utilisateur créé
    const newUser = await db.get('SELECT * FROM users WHERE id = ?', [result.lastID]);

    res.status(201).json({
      message: 'Inscription réussie',
      token,
      user: newUser,
    });
  } catch (error) {
    console.error('Erreur inscription:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});
```

### Route de mise à jour - `PUT /api/users/:id`

```javascript
app.put('/api/users/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      firstName,      // ✅ Accepter
      lastName,       // ✅ Accepter
      dateOfBirth,    // ✅ Accepter
      address,        // ✅ Accepter
      email,
      phone,
      ville,
      categorie,
      tarif,
      experience,
      photo,
      besoin,
      preference,
      mission,
      particularite,
    } = req.body;

    // Construire la requête UPDATE dynamiquement
    const updates = [];
    const params = [];

    if (name !== undefined) { updates.push('name = ?'); params.push(name); }
    if (firstName !== undefined) { updates.push('firstName = ?'); params.push(firstName); }
    if (lastName !== undefined) { updates.push('lastName = ?'); params.push(lastName); }
    if (dateOfBirth !== undefined) { updates.push('dateOfBirth = ?'); params.push(dateOfBirth); }
    if (address !== undefined) { updates.push('address = ?'); params.push(address); }
    if (email !== undefined) { updates.push('email = ?'); params.push(email); }
    if (phone !== undefined) { updates.push('phone = ?'); params.push(phone); }
    if (ville !== undefined) { updates.push('ville = ?'); params.push(ville); }
    if (categorie !== undefined) { updates.push('categorie = ?'); params.push(categorie); }
    if (tarif !== undefined) { updates.push('tarif = ?'); params.push(tarif); }
    if (experience !== undefined) { updates.push('experience = ?'); params.push(experience); }
    if (photo !== undefined) { updates.push('photo = ?'); params.push(photo); }
    if (besoin !== undefined) { updates.push('besoin = ?'); params.push(besoin); }
    if (preference !== undefined) { updates.push('preference = ?'); params.push(preference); }
    if (mission !== undefined) { updates.push('mission = ?'); params.push(mission); }
    if (particularite !== undefined) { updates.push('particularite = ?'); params.push(particularite); }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'Aucune donnée à mettre à jour' });
    }

    updates.push('updatedAt = NOW()');
    params.push(id);

    await db.run(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      params
    );

    // Retourner l'utilisateur mis à jour
    const updatedUser = await db.get('SELECT * FROM users WHERE id = ?', [id]);

    res.json(updatedUser);
  } catch (error) {
    console.error('Erreur mise à jour:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});
```

---

## ✅ Checklist d'implémentation

### Phase 1: Modèle et services (Priorité haute)
- [ ] Mettre à jour `User` model avec `firstName`, `lastName`, `dateOfBirth`, `address`
- [ ] Ajouter le getter `age` dans le modèle
- [ ] Ajouter le getter `fullName` dans le modèle
- [ ] Mettre à jour `User.fromJson()` et `User.toJson()`
- [ ] Mettre à jour `AuthService.register()` avec les nouveaux paramètres
- [ ] Mettre à jour `UserService.updateProfile()` avec les nouveaux paramètres

### Phase 2: UI - Affichage (Priorité haute)
- [ ] Afficher l'âge calculé dans l'écran de profil
- [ ] Afficher l'adresse dans l'écran de profil
- [ ] Afficher prénom et nom séparément
- [ ] Utiliser le formatter de date pour afficher la date de naissance

### Phase 3: UI - Formulaires (Priorité moyenne)
- [ ] Ajouter les champs dans `RegisterScreen`
- [ ] Ajouter le sélecteur de date de naissance
- [ ] Ajouter la validation de l'âge minimum (18 ans)
- [ ] Créer/mettre à jour `EditProfileScreen`
- [ ] Ajouter les champs d'édition pour tous les nouveaux champs

### Phase 4: Validation (Priorité moyenne)
- [ ] Créer la fonction `validateAge()`
- [ ] Créer la fonction `validateRequired()`
- [ ] Appliquer les validations dans les formulaires

### Phase 5: Backend (Vérification)
- [ ] Vérifier que `POST /api/register` accepte les nouveaux champs
- [ ] Vérifier que `PUT /api/users/:id` accepte les nouveaux champs
- [ ] Vérifier que `GET /api/users/:id` retourne les nouveaux champs ✅ (déjà fait)

### Phase 6: Tests
- [ ] Tester l'inscription avec tous les champs
- [ ] Tester l'affichage du profil
- [ ] Tester la modification du profil
- [ ] Tester le calcul de l'âge avec différentes dates
- [ ] Tester la validation de l'âge minimum

---

## 📝 Notes importantes

### Format de date
- **API attend:** `"YYYY-MM-DD"` (ex: `"1990-05-15"`)
- **Affichage utilisateur:** `"DD/MM/YYYY"` (ex: `"15/05/1990"`)
- **Utiliser:** `DateFormat` de `intl` pour la conversion

### Validation de l'âge
- **Minimum requis:** 18 ans
- **Calcul:** Tenir compte du mois et du jour pour un calcul précis

### Champs optionnels vs requis
**Requis à l'inscription:**
- `firstName` ✅
- `lastName` ✅
- `email` ✅
- `password` ✅
- `phone` ✅
- `dateOfBirth` ✅

**Optionnels:**
- `address`
- `ville` (peut être requis selon votre logique métier)

---

## 🔍 Exemple complet de flux utilisateur

1. **Inscription:**
   - Utilisateur remplit prénom, nom, date de naissance, adresse
   - Validation de l'âge (18+ ans)
   - Format date converti en YYYY-MM-DD
   - Envoi à l'API
   - Token JWT retourné et stocké

2. **Affichage profil:**
   - Chargement depuis API ou cache local
   - Calcul automatique de l'âge depuis dateOfBirth
   - Affichage formaté de la date (DD/MM/YYYY)
   - Affichage du nom complet (firstName + lastName)

3. **Modification profil:**
   - Pré-remplissage avec données existantes
   - Sélecteur de date pour dateOfBirth
   - Validation des modifications
   - Mise à jour via API
   - Rafraîchissement du cache local

---

**Dernière mise à jour:** 13 Décembre 2025

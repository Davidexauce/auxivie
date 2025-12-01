import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'login_screen.dart';

/// Écran d'inscription moderne et épuré
class RegisterScreen extends StatefulWidget {
  final String? initialUserType;
  
  const RegisterScreen({
    super.key,
    this.initialUserType,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villeController = TextEditingController();
  final _tarifController = TextEditingController();
  final _experienceController = TextEditingController();
  
  late String _selectedUserType;
  String _selectedCategorie = 'Auxiliaire de vie';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _categories = ['Auxiliaire de vie', 'Aide-soignant'];

  @override
  void initState() {
    super.initState();
    // Initialiser avec le type passé en paramètre ou 'professionnel' par défaut
    _selectedUserType = widget.initialUserType ?? 'professionnel';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _villeController.dispose();
    _tarifController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    double? tarif;
    if (_tarifController.text.isNotEmpty) {
      tarif = double.tryParse(_tarifController.text);
    }

    int? experience;
    if (_experienceController.text.isNotEmpty) {
      experience = int.tryParse(_experienceController.text);
    }

    final success = await authViewModel.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      categorie: _selectedUserType == 'professionnel' 
          ? _selectedCategorie 
          : 'Famille',
      ville: _villeController.text.trim().isEmpty 
          ? null 
          : _villeController.text.trim(),
      tarif: tarif,
      experience: experience,
      userType: _selectedUserType,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Erreur lors de l\'inscription'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Inscription',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Titre
                Text(
                  'Créer un compte',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    height: 1.2,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 40),

                // Type d'utilisateur - Sélection moderne
                Text(
                  'Je suis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _UserTypeSelector(
                        label: 'Professionnel',
                        icon: Icons.person_outline_rounded,
                        isSelected: _selectedUserType == 'professionnel',
                        onTap: () {
                          setState(() {
                            _selectedUserType = 'professionnel';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UserTypeSelector(
                        label: 'Famille',
                        icon: Icons.family_restroom_rounded,
                        isSelected: _selectedUserType == 'famille',
                        onTap: () {
                          setState(() {
                            _selectedUserType = 'famille';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Catégorie (uniquement pour professionnels)
                if (_selectedUserType == 'professionnel') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedCategorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: const Icon(Icons.work_outline, color: AppTheme.textTertiary),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategorie = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Jean Dupont',
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textTertiary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'votre@email.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textTertiary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textTertiary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textTertiary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Téléphone (optionnel)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    hintText: '0612345678',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 20),

                // Ville (optionnel pour professionnels)
                if (_selectedUserType == 'professionnel') ...[
                  TextFormField(
                    controller: _villeController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Paris',
                      prefixIcon: const Icon(Icons.location_city_outlined, color: AppTheme.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tarif horaire (optionnel)
                  TextFormField(
                    controller: _tarifController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tarif horaire (€) (optionnel)',
                      hintText: '25.0',
                      prefixIcon: const Icon(Icons.euro_outlined, color: AppTheme.textTertiary),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final tarif = double.tryParse(value);
                        if (tarif == null || tarif <= 0) {
                          return 'Tarif invalide';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Expérience (optionnel)
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Années d\'expérience (optionnel)',
                      hintText: '5',
                      prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppTheme.textTertiary),
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
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 32),

                // Bouton d'inscription
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: authViewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'S\'inscrire',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(userType: _selectedUserType),
                          ),
                        );
                      },
                      child: Text(
                        'Connectez-vous',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sélecteur de type d'utilisateur moderne
class _UserTypeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeSelector({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : AppTheme.green50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : AppTheme.borderSlate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.primaryColor
                  : AppTheme.textTertiary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.primaryColor
                    : AppTheme.textSecondary,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

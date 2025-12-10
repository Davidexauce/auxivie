import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/auxivie_logo.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'auth/choice_screen.dart';
import 'home_screen.dart';

/// Écran de démarrage (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialiser le AuthViewModel pour restaurer l'utilisateur connecté
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.init();

    // Attendre 2 secondes pour l'affichage du splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Rediriger selon l'état d'authentification
    if (authViewModel.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChoiceScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.heroGradient,
        ),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Auxivie (texte uniquement avec dégradé)
            const AuxivieLogo(
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 24),
            Text(
              'Aide à domicile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}


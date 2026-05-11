import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../widgets/aidalya_logo.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'auth/choice_screen.dart';
import 'home_screen.dart';

/// Écran de démarrage (Splash Screen)
class SplashScreen extends StatefulWidget {
  final bool disableAutoNavigation;

  const SplashScreen({
    super.key,
    this.disableAutoNavigation = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.disableAutoNavigation) return;
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialiser le AuthViewModel pour restaurer l'utilisateur connecté
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final minDisplay = Future<void>.delayed(const Duration(milliseconds: 220));
    try {
      // Borne de sécurité courte: priorité à l'affichage rapide de l'écran suivant.
      await authViewModel
          .init()
          .timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // Préférences / stockage anormalement lent : on affiche quand même la suite
    } catch (_) {
      // Erreur silencieuse au démarrage : l’utilisateur pourra se reconnecter
    }
    await minDisplay;

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
            // Logo Aidalya
            const AidalyaLogo(
              width: 320,
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


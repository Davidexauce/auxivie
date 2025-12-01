import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import 'auth/choice_screen.dart';

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
    // Rediriger après 2 secondes
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChoiceScreen()),
      );
    });
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
            // Logo ou icône
            Icon(
              Icons.medical_services,
              size: 100,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            // Nom de l'application avec dégradé texte
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.textGradient.createShader(bounds),
              child: Text(
                'Auxivie',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aide à domicile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}


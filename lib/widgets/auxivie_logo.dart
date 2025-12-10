import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget réutilisable pour afficher le logo Auxivie (texte uniquement)
class AuxivieLogo extends StatelessWidget {
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const AuxivieLogo({
    super.key,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.textGradient.createShader(bounds),
      child: Text(
        'AUXIVIE',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize ?? 48,
              letterSpacing: 1.5,
            ),
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }
}

/// Version compacte du logo pour l'AppBar (texte uniquement)
class AuxivieLogoCompact extends StatelessWidget {
  final double? fontSize;
  final FontWeight? fontWeight;

  const AuxivieLogoCompact({
    super.key,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.textGradient.createShader(bounds),
      child: Text(
        'AUXIVIE',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: fontWeight ?? FontWeight.bold,
              fontSize: fontSize ?? 20,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}


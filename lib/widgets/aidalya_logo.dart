import 'package:flutter/material.dart';

/// Logo officiel Aidalya (feuille + nom + baseline).
const String kAidalyaLogoAsset = 'assets/images/aidalya_logo_official.png';

/// Logo Aidalya pour splash, accueil et barres d’outils.
class AidalyaLogo extends StatelessWidget {
  /// Largeur du logo (hauteur proportionnelle ~0,6× largeur).
  final double width;

  /// Variante compacte pour en-tête horizontal.
  final bool horizontal;

  const AidalyaLogo({
    super.key,
    this.width = 300,
    this.horizontal = false,
  });

  /// Grand logo centré (splash).
  factory AidalyaLogo.splash({Key? key}) {
    return AidalyaLogo(key: key, width: 320, horizontal: false);
  }

  /// En-tête accueil / connexion.
  factory AidalyaLogo.homeHeader({Key? key}) {
    return AidalyaLogo(key: key, width: 220, horizontal: true);
  }

  @override
  Widget build(BuildContext context) {
    final w = horizontal ? width.clamp(160.0, 260.0) : width;
    return Image.asset(
      kAidalyaLogoAsset,
      width: w,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

/// Petite marque (chargement initial, barres d’outils).
class AidalyaLogoCompact extends StatelessWidget {
  final double width;

  const AidalyaLogoCompact({
    super.key,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kAidalyaLogoAsset,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

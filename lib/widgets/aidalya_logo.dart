import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher le logo de l'app (PNG fiable iOS/Android)
class AidalyaLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final TextAlign? textAlign;

  const AidalyaLogo({
    super.key,
    this.width,
    this.height,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _toAlignment(textAlign ?? TextAlign.center),
      child: Image.asset(
        'assets/images/app_icon_1024.png',
        width: width ?? 260,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }

  Alignment _toAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
      case TextAlign.justify:
        return Alignment.center;
    }
  }
}

/// Version compacte du logo pour l'AppBar
class AidalyaLogoCompact extends StatelessWidget {
  final double? size;

  const AidalyaLogoCompact({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_icon_1024.png',
      width: size ?? 120,
      height: size != null ? (size! * 120 / 260) : null,
      fit: BoxFit.contain,
    );
  }
}

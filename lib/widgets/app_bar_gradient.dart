import 'package:flutter/material.dart';

/// Gradient pour l'AppBar
LinearGradient getAppBarGradient() {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black.withOpacity(0.9),
      Colors.black.withOpacity(0.7),
      Colors.black.withOpacity(0.5),
      Colors.transparent,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );
}

/// Style de texte pour l'AppBar
TextStyle getAppBarTextStyle() {
  return const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    shadows: [
      Shadow(
        offset: Offset(0, 1),
        blurRadius: 3,
        color: Colors.black26,
      ),
    ],
  );
}

/// AppBar avec gradient réutilisable
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: getAppBarTextStyle()),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: getAppBarGradient(),
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


# AuxiLink

Application mobile Flutter de mise en relation entre professionnels de l'aide à domicile et familles.

## Fonctionnalités

- ✅ Authentification locale (inscription/connexion)
- ✅ Gestion de profils professionnels
- ✅ Messagerie interne
- ✅ Planning/réservations
- ✅ Recherche de professionnels avec filtres
- ✅ Support iOS et Android
- ✅ Fonctionnement 100% hors-ligne

## Architecture

- **MVVM** (Model-View-ViewModel)
- **Provider** pour la gestion d'état
- **SQLite** pour le stockage local

## Installation

```bash
flutter pub get
flutter run
```

## Structure du projet

```
lib/
├── main.dart
├── models/          # Modèles de données
├── services/        # Services (SQLite, etc.)
├── viewmodels/     # ViewModels (logique métier)
├── views/          # Vues/Écrans
├── widgets/        # Widgets réutilisables
└── theme/          # Configuration du thème
```



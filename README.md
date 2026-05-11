# Aidalya — Application mobile Flutter

Plateforme de mise en relation entre professionnels de l'aide à domicile et familles (marque **Aidalya**).

## 📱 Plateformes supportées

- ✅ iOS
- ✅ Android

## 🚀 Fonctionnalités

### Pour les Familles
- Recherche et sélection de professionnels
- Création de réservations multi-jours
- Communication avec les professionnels via messagerie
- Paiement sécurisé via Stripe
- Gestion des besoins spécifiques lors des réservations
- Consultation des avis et notes des professionnels

### Pour les Professionnels
- Gestion du profil et disponibilités
- Visualisation des réservations
- Communication avec les familles
- Gestion des badges et certifications
- Consultation des avis reçus

## 🛠 Technologies

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Base de données**: Backend API (https://auxivie.org/api)
- **Paiements**: Stripe
- **Langage**: Dart 3.x

## 📦 Installation

```bash
# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 🔧 Configuration

### API Backend
L'application est configurée pour utiliser l'API à l'adresse:
- Staging/Production: `https://auxivie.org/api`

Configuration dans `lib/config/app_config.dart`

### Stripe
Clés Stripe configurées dans `lib/services/payment_service.dart`
En fallback, la clé publishable peut être injectée au build:

```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_xxx
```

## 📝 Structure du projet

```
lib/
├── config/          # Configuration de l'application
├── models/          # Modèles de données
├── services/        # Services API et business logic
├── views/           # Écrans de l'application
├── viewmodels/      # ViewModels (state management)
├── widgets/         # Widgets réutilisables
└── theme/           # Thème et styles
```

## 📄 Licence

Propriétaire - Tous droits réservés

## 👥 Équipe

Équipe Aidalya

# Analyse de l'intégration API Mobile

## 📋 Résumé

Cette analyse compare le backend en production (Hostinger) avec l'application mobile Flutter pour identifier les ajustements nécessaires.

## 🔗 Configuration des URLs

### Backend (Production)
- **URL principale**: `https://api.auxivie.org` (selon app_config.dart)
- **URL alternative**: `https://auxivie.org` (utilisée par admin-dashboard)
- **Port**: 3001

### Admin Dashboard
- Utilise: `https://auxivie.org` (même domaine, pas de sous-domaine)
- Fonctionne correctement en production

### Application Mobile
- Configuration actuelle: `https://api.auxivie.org` (Environment.production)
- ✅ **Recommandation**: Utiliser `https://api.auxivie.org` (domaine direct du backend)
- **Alternative**: Si `api.auxivie.org` ne fonctionne pas, utiliser `https://auxivie.org` (comme l'admin-dashboard)

## 🔐 Authentification

### Endpoint: `POST /api/auth/login`
- **Headers requis**: `x-request-type: mobile` (pour permettre connexion non-admin)
- **Réponse**: `{ token, user: { id, name, email, userType } }`
- ✅ **Statut**: Implémenté correctement dans l'app mobile

## 👤 Gestion des Utilisateurs

### Endpoints publics (pour mobile):
1. `GET /api/users?userType=professionnel` - Liste des professionnels
2. `GET /api/users/:id` - Détails d'un utilisateur
3. `POST /api/users/sync` - Créer/mettre à jour un utilisateur

### ⚠️ Problème identifié dans `createUser`:
L'application mobile n'envoie **PAS** les champs suivants requis par le backend:
- `besoin`
- `preference`
- `mission`
- `particularite`

**Impact**: Ces champs sont nécessaires pour les familles et sont requis par le backend.

## 📅 Réservations

### Endpoints disponibles:
- `GET /api/reservations?userId=X` - Réservations d'un utilisateur
- `GET /api/reservations?professionnelId=X` - Réservations d'un professionnel
- `POST /api/reservations/sync` - Créer/mettre à jour une réservation
- `PUT /api/reservations/:id` - Mettre à jour le statut (nécessite auth)

✅ **Statut**: Implémenté correctement

## 💬 Messages

### Endpoints disponibles:
- `GET /api/messages?userId=X&partnerId=Y` - Conversation entre deux utilisateurs
- `GET /api/messages/partners?userId=X` - Liste des partenaires de conversation
- `POST /api/messages` - Envoyer un message

✅ **Statut**: Implémenté correctement

## 📊 Disponibilités

### Endpoints disponibles:
- `GET /api/availabilities?professionnelId=X` - Disponibilités d'un professionnel
- `POST /api/availabilities` - Créer/mettre à jour (nécessite auth)
- `DELETE /api/availabilities/:id` - Supprimer (nécessite auth)

⚠️ **Note**: La création nécessite un token, mais l'app mobile peut lire les disponibilités

## 🏆 Badges, Notes, Avis

### Endpoints publics:
- `GET /api/badges?userId=X` - Badges d'un utilisateur
- `GET /api/ratings?userId=X` - Note d'un utilisateur
- `GET /api/reviews` - Tous les avis (filtrés par professionalId côté client)

✅ **Statut**: Implémenté correctement

## 📁 Documents et Photos

### Endpoints:
- `POST /api/documents/upload` - Upload de document (multipart/form-data)
- `POST /api/users/:id/photo` - Upload de photo de profil (multipart/form-data)

✅ **Statut**: Implémenté correctement

## 💳 Paiements

### Endpoints:
- `POST /api/payments/create-intent` - Créer un PaymentIntent Stripe
- `POST /api/payments/confirm` - Confirmer un paiement

✅ **Statut**: Implémenté correctement

## 🌐 Configuration CORS

### Configuration actuelle:
```javascript
origin: ['https://www.auxivie.org', 'https://auxivie.org', 'https://api.auxivie.org', 'http://178.16.131.24:3001']
```

⚠️ **Problème potentiel**: Les applications mobiles n'ont pas d'origine HTTP spécifique. Le CORS ne s'applique qu'aux requêtes depuis un navigateur web. Les applications mobiles utilisent directement HTTP/HTTPS et ne sont pas affectées par CORS.

✅ **Conclusion**: Pas de problème CORS pour l'application mobile

## ✅ Actions à effectuer

### 1. Corriger `createUser` dans `backend_api_service.dart`
Ajouter les champs manquants: `besoin`, `preference`, `mission`, `particularite`

### 2. Vérifier l'URL de l'API
Tester si `https://api.auxivie.org` est accessible depuis l'application mobile, sinon utiliser `https://auxivie.org`

### 3. Vérifier la gestion des erreurs
S'assurer que toutes les erreurs réseau sont bien gérées avec des messages clairs

## 📝 Endpoints complets disponibles

### Authentification
- `POST /api/auth/login` - Connexion (header `x-request-type: mobile` requis)

### Utilisateurs
- `GET /api/users?userType=professionnel` - Liste professionnels (public)
- `GET /api/users?email=X` - Recherche par email (nécessite auth)
- `GET /api/users/:id` - Détails utilisateur (public)
- `POST /api/users/sync` - Créer/mettre à jour (public)
- `PUT /api/users/:id` - Mettre à jour (nécessite auth)

### Réservations
- `GET /api/reservations?userId=X` - Réservations utilisateur (public)
- `GET /api/reservations?professionnelId=X` - Réservations professionnel (public)
- `POST /api/reservations/sync` - Créer/mettre à jour (public)
- `PUT /api/reservations/:id` - Mettre à jour statut (nécessite auth)

### Messages
- `GET /api/messages?userId=X&partnerId=Y` - Conversation (public)
- `GET /api/messages/partners?userId=X` - Partenaires (public)
- `POST /api/messages` - Envoyer message (public)

### Disponibilités
- `GET /api/availabilities?professionnelId=X` - Disponibilités (public)
- `POST /api/availabilities` - Créer/mettre à jour (nécessite auth)
- `DELETE /api/availabilities/:id` - Supprimer (nécessite auth)

### Badges, Notes, Avis
- `GET /api/badges?userId=X` - Badges (public)
- `GET /api/ratings?userId=X` - Note (public)
- `GET /api/reviews` - Tous les avis (public)

### Uploads
- `POST /api/documents/upload` - Upload document (multipart)
- `POST /api/users/:id/photo` - Upload photo (multipart)

### Paiements
- `POST /api/payments/create-intent` - Créer PaymentIntent (public)
- `POST /api/payments/confirm` - Confirmer paiement (public)

## 🔍 Comparaison Admin Dashboard vs Mobile App

| Fonctionnalité | Admin Dashboard | Mobile App | Statut |
|---------------|-----------------|------------|--------|
| Login | ✅ | ✅ | OK |
| Liste utilisateurs | ✅ (admin) | ✅ (professionnels) | OK |
| Créer utilisateur | ❌ | ✅ | OK |
| Messages | ✅ (admin) | ✅ (utilisateurs) | OK |
| Réservations | ✅ (admin) | ✅ (utilisateurs) | OK |
| Documents | ✅ (admin) | ✅ (upload) | OK |
| Paiements | ✅ (admin) | ✅ (créer) | OK |

## 🎯 Conclusion

L'application mobile est globalement bien configurée pour se connecter au backend de production. Le seul problème identifié est l'absence des champs `besoin`, `preference`, `mission`, `particularite` lors de la création d'utilisateur.

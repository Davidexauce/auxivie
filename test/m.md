# 📱 Modifications Nécessaires - Application Mobile Auxivie
**Date:** 11 Décembre 2025  
**Version Dashboard:** 2.0  
**Objectif:** Mise en adéquation de l'app mobile avec le dashboard admin

---

## 🎯 Vue d'Ensemble

Le dashboard admin a été amélioré avec de nouvelles fonctionnalités, API et flux de données. L'application mobile doit être mise à jour pour :
1. Supporter les nouvelles API backend
2. Intégrer les nouveaux statuts et workflows
3. Améliorer l'expérience utilisateur en cohérence avec le dashboard
4. Ajouter les fonctionnalités manquantes

---

## 📋 Table des Matières

1. [Système de Signalements (Reports)](#1-système-de-signalements-reports)
2. [Gestion des Documents](#2-gestion-des-documents)
3. [Paiements Stripe](#3-paiements-stripe)
4. [Avis et Notations](#4-avis-et-notations)
5. [Réservations](#5-réservations)
6. [Paramètres Système](#6-paramètres-système)
7. [Messagerie](#7-messagerie)
8. [Profils Utilisateurs](#8-profils-utilisateurs)

---

## 1. Système de Signalements (Reports)

### 🆕 Nouvelle Fonctionnalité
Le dashboard dispose maintenant d'un système complet de signalements. L'app mobile doit permettre aux utilisateurs de signaler des comportements inappropriés.

### 📡 Nouvelles API à Intégrer

#### **POST /api/reports** - Créer un signalement
```javascript
// Payload
{
  "reportedUserId": 123,
  "reason": "spam" | "harassment" | "fake_profile" | "inappropriate_content" | "other",
  "description": "Description détaillée du problème"
}

// Response
{
  "id": 456,
  "reporterId": 789,
  "reportedUserId": 123,
  "reason": "spam",
  "description": "...",
  "status": "open",
  "createdAt": "2025-12-11T10:30:00.000Z"
}
```

#### **GET /api/reports** - Mes signalements (utilisateur)
```javascript
// Response
[
  {
    "id": 456,
    "reportedName": "John Doe",
    "reason": "spam",
    "status": "open" | "resolved" | "dismissed",
    "createdAt": "2025-12-11T10:30:00.000Z"
  }
]
```

### 🎨 UI/UX à Implémenter

1. **Bouton "Signaler" sur les profils**
   - Position: Menu contextuel (3 points) en haut à droite du profil
   - Icône: ⚠️ ou 🚩

2. **Modal de signalement**
   - Liste déroulante des raisons:
     - 🚫 Spam ou publicité
     - 😡 Harcèlement ou insultes
     - 🎭 Faux profil
     - 📵 Contenu inapproprié
     - ❓ Autre raison
   - Zone de texte obligatoire (min 20 caractères)
   - Boutons: "Annuler" | "Envoyer le signalement"

3. **Page "Mes signalements"** (dans Paramètres/Mon compte)
   - Liste chronologique des signalements envoyés
   - Badge de statut: 🟡 En cours | ✅ Résolu | ❌ Rejeté
   - Détails: raison, date, statut, notes admin (si résolu)

### ✅ Checklist Développement

- [ ] Créer service API `ReportsService.js`
- [ ] Ajouter bouton "Signaler" sur `ProfileScreen.js`
- [ ] Créer `ReportUserModal.js` avec formulaire
- [ ] Créer `MyReportsScreen.js` pour l'historique
- [ ] Ajouter navigation vers "Mes signalements" dans Settings
- [ ] Gérer les erreurs (déjà signalé, auto-signalement interdit)
- [ ] Ajouter confirmation après envoi réussi

---

## 2. Gestion des Documents

### 🔄 Modifications Requises

Le dashboard a amélioré la gestion des documents avec de nouveaux statuts et raisons de rejet.

### 📡 API Modifiées

#### **GET /api/documents** - Récupérer mes documents
```javascript
// Response
[
  {
    "id": 123,
    "userId": 456,
    "documentType": "kbis" | "insurance" | "diploma" | "identity",
    "documentUrl": "https://...",
    "status": "pending" | "verified" | "rejected",
    "rejectReason": "Document illisible, veuillez soumettre une meilleure qualité",
    "uploadedAt": "2025-12-11T10:30:00.000Z",
    "verifiedAt": null
  }
]
```

#### **POST /api/documents/upload** - Upload document
```javascript
// FormData
{
  "file": File,
  "documentType": "kbis" | "insurance" | "diploma" | "identity",
  "userId": 456
}
```

### 🎨 UI/UX à Améliorer

1. **Affichage du statut de vérification**
   - 🟡 En attente de vérification (badge jaune)
   - ✅ Vérifié (badge vert)
   - ❌ Rejeté (badge rouge)

2. **Message de rejet détaillé**
   - Afficher `rejectReason` dans une card rouge
   - Bouton "Téléverser à nouveau" bien visible
   - Exemples de documents valides (icône ℹ️)

3. **Types de documents supportés**
   - **Pour Professionnels:**
     - 📄 KBIS (obligatoire)
     - 🛡️ Assurance responsabilité civile (obligatoire)
     - 🎓 Diplômes/certifications (optionnel)
     - 🆔 Pièce d'identité (obligatoire)
   - **Pour Familles:**
     - 🆔 Pièce d'identité (obligatoire)

4. **Indicateur de progression**
   - Barre de progression: "2/3 documents validés"
   - Badge de profil complet: ✅ Profil vérifié

### ✅ Checklist Développement

- [ ] Mettre à jour `DocumentsService.js` pour gérer `rejectReason`
- [ ] Améliorer `DocumentsScreen.js` avec badges de statut
- [ ] Ajouter `DocumentRejectCard.js` pour afficher les raisons de rejet
- [ ] Implémenter "Téléverser à nouveau" sur documents rejetés
- [ ] Ajouter indicateur de progression de vérification
- [ ] Notification push quand document vérifié/rejeté
- [ ] Bloquer certaines actions si documents non vérifiés

---

## 3. Paiements Stripe

### 🔄 Améliorations Backend

Le dashboard peut maintenant réessayer les paiements échoués et effectuer des remboursements via Stripe.

### 📡 Nouvelles API Stripe

#### **POST /api/stripe/create-payment-intent** - Créer un paiement
```javascript
// Payload
{
  "amount": 5000, // en centimes (50€)
  "currency": "eur",
  "reservationId": 123,
  "customerId": "cus_xxxxx" // Stripe customer ID
}

// Response
{
  "clientSecret": "pi_xxxxx_secret_xxxxx",
  "paymentIntentId": "pi_xxxxx"
}
```

#### **POST /api/stripe/refund** - Demander un remboursement
```javascript
// Payload
{
  "paymentIntentId": "pi_xxxxx",
  "amount": 5000, // optionnel, remboursement partiel
  "reason": "requested_by_customer" | "duplicate" | "fraudulent"
}

// Response
{
  "refundId": "re_xxxxx",
  "status": "succeeded",
  "amount": 5000
}
```

### 🎨 UI/UX à Implémenter

1. **Historique des paiements**
   - Liste de tous les paiements (réservations)
   - Statut: 💳 En attente | ✅ Payé | ❌ Échoué | 💰 Remboursé
   - Montant, date, professionnel/famille

2. **Gestion des paiements échoués**
   - Message d'erreur clair: "Paiement refusé par votre banque"
   - Bouton "Réessayer le paiement" bien visible
   - Suggestion: "Vérifiez vos informations bancaires"

3. **Demande de remboursement**
   - Bouton "Demander un remboursement" sur réservations annulées
   - Conditions: annulation > 24h avant, statut "cancelled"
   - Modal de confirmation avec raison (optionnel)
   - Délai de traitement: "Remboursement sous 5-10 jours ouvrés"

4. **Statuts de remboursement**
   - 🟡 Remboursement demandé
   - ⏳ En cours de traitement
   - ✅ Remboursé (avec date)

### ✅ Checklist Développement

- [ ] Mettre à jour `StripeService.js` avec nouvelles routes
- [ ] Créer `PaymentHistoryScreen.js` pour historique
- [ ] Implémenter "Réessayer le paiement" sur échoués
- [ ] Ajouter bouton "Demander remboursement" sur réservations
- [ ] Créer `RefundRequestModal.js`
- [ ] Gérer les webhooks Stripe (payment_intent.succeeded, etc.)
- [ ] Notifications push: paiement réussi/échoué, remboursement effectué
- [ ] Sauvegarder `paymentIntentId` dans la BDD locale

---

## 4. Avis et Notations

### 🔄 Fonctionnalités Dashboard

Le dashboard affiche des statistiques avancées sur les avis (moyenne, distribution, tendances).

### 📡 API à Utiliser

#### **GET /api/reviews** - Récupérer les avis
```javascript
// Query params
?userId=123 // Avis reçus par cet utilisateur
?reviewerId=456 // Avis laissés par cet utilisateur

// Response
[
  {
    "id": 789,
    "reviewerId": 456,
    "reviewedUserId": 123,
    "reservationId": 321,
    "rating": 5,
    "comment": "Excellent service !",
    "userName": "Marie D.",
    "professionalName": "Jean P.",
    "createdAt": "2025-12-11T10:30:00.000Z"
  }
]
```

#### **POST /api/reviews** - Laisser un avis
```javascript
// Payload
{
  "reviewedUserId": 123,
  "reservationId": 321,
  "rating": 5, // 1 à 5
  "comment": "Excellent service, très professionnel !"
}
```

#### **DELETE /api/reviews/:id** - Supprimer mon avis
```javascript
// Nécessite authentification
// Seulement l'auteur peut supprimer
```

### 🎨 UI/UX à Améliorer

1. **Obligation d'avis après réservation**
   - Popup automatique 2h après fin de réservation
   - Notification: "Laissez un avis sur votre expérience"
   - Bouton "Plus tard" (relance J+1, J+3)

2. **Affichage de la note moyenne**
   - ⭐ 4.8/5 (124 avis) - bien visible sur profils
   - Distribution des étoiles (graphique à barres)
   - Filtres: Tous | ⭐⭐⭐⭐⭐ 5 étoiles | ⭐⭐⭐⭐ 4 étoiles, etc.

3. **Formulaire d'avis amélioré**
   - Étoiles cliquables (1 à 5)
   - Zone de commentaire (optionnel, 10-500 caractères)
   - Critères spécifiques:
     - **Pour professionnels:** Ponctualité, Compétence, Relation enfants
     - **Pour familles:** Communication, Respect, Environnement
   - Photo de profil du destinataire visible

4. **Gestion des avis reçus**
   - Section "Mes avis reçus" dans Profil
   - Possibilité de signaler un avis inapproprié (via système de reports)
   - Pas de réponse possible (éviter les conflits)

### ✅ Checklist Développement

- [ ] Créer `ReviewsService.js`
- [ ] Ajouter popup post-réservation `LeaveReviewModal.js`
- [ ] Créer `ReviewFormScreen.js` avec critères détaillés
- [ ] Améliorer affichage note moyenne sur `ProfileScreen.js`
- [ ] Créer `MyReviewsScreen.js` (donnés et reçus)
- [ ] Implémenter filtres par nombre d'étoiles
- [ ] Ajouter graphique de distribution (react-native-chart-kit)
- [ ] Notification push: "Vous avez reçu un nouvel avis"
- [ ] Bloquer avis multiples pour même réservation

---

## 5. Réservations

### 🔄 Flux Améliorés

Le dashboard gère maintenant des statuts de réservation plus précis et des règles d'annulation.

### 📡 API Complètes

#### **GET /api/reservations** - Mes réservations
```javascript
// Response
[
  {
    "id": 123,
    "userId": 456,
    "professionalId": 789,
    "startTime": "2025-12-15T14:00:00.000Z",
    "endTime": "2025-12-15T18:00:00.000Z",
    "status": "pending" | "confirmed" | "cancelled" | "completed",
    "totalPrice": 50.00,
    "cancellationReason": null,
    "familyName": "Marie D.",
    "professionalName": "Jean P.",
    "createdAt": "2025-12-11T10:30:00.000Z"
  }
]
```

#### **PUT /api/reservations/:id** - Mettre à jour une réservation
```javascript
// Payload
{
  "status": "confirmed" | "cancelled",
  "cancellationReason": "Empêchement de dernière minute"
}
```

### 🎨 UI/UX à Implémenter

1. **Statuts clairs**
   - 🕐 En attente de confirmation (pending)
   - ✅ Confirmée (confirmed)
   - ❌ Annulée (cancelled)
   - 🎉 Terminée (completed)

2. **Règles d'annulation**
   - Afficher délai d'annulation: "Annulation gratuite jusqu'à 24h avant"
   - Si < 24h: "Annulation impossible sans frais"
   - Demander confirmation + raison d'annulation

3. **Notifications push**
   - Nouvelle réservation reçue (pro)
   - Réservation confirmée (famille)
   - Réservation annulée (les deux)
   - Rappel 2h avant réservation
   - Invitation à laisser un avis (2h après)

4. **Calendrier de disponibilités**
   - Les professionnels définissent leurs créneaux
   - Les familles voient les créneaux disponibles en vert
   - Blocage automatique des créneaux réservés

### ✅ Checklist Développement

- [ ] Mettre à jour `ReservationsService.js`
- [ ] Améliorer `ReservationDetailScreen.js` avec statuts
- [ ] Implémenter règles d'annulation (24h)
- [ ] Ajouter `CancellationModal.js` avec raison
- [ ] Créer `CalendarScreen.js` pour professionnels
- [ ] Gérer disponibilités via `/api/availabilities`
- [ ] Notifications push pour tous les événements
- [ ] Badge de statut sur liste réservations
- [ ] Auto-passage à "completed" après `endTime`

---

## 6. Paramètres Système

### 🆕 Configuration Centralisée

Le dashboard permet de configurer 11 paramètres système. L'app doit les récupérer dynamiquement.

### 📡 API Settings

#### **GET /api/settings** - Récupérer les paramètres
```javascript
// Response
{
  "platformFee": 15, // Commission en %
  "cancellationDelay": 24, // Heures avant réservation
  "contactEmail": "contact@auxivie.org",
  "supportPhone": "+33 1 23 45 67 89",
  "paymentMethods": ["card", "stripe"],
  "minReservationHours": 2,
  "maxReservationHours": 24,
  "autoApproveDocuments": false,
  "sendEmailNotifications": true,
  "sendSMSNotifications": false,
  "maintenanceMode": false
}
```

### 🎨 Impacts sur l'App Mobile

1. **Commission affichée**
   - Lors de la création de réservation, afficher: "Prix: 50€ + frais de service (15%): 7,50€"
   - Total: 57,50€
   - Récupérer `platformFee` depuis API

2. **Délai d'annulation dynamique**
   - Utiliser `cancellationDelay` pour calculer si annulation possible
   - Message: "Annulation gratuite jusqu'à 24h avant"

3. **Durée de réservation**
   - Bloquer réservations < `minReservationHours` (2h)
   - Bloquer réservations > `maxReservationHours` (24h)
   - Validation côté client et serveur

4. **Contact support**
   - Page "Aide & Support" avec email et téléphone dynamiques
   - Boutons: 📧 Email | 📞 Appeler

5. **Mode maintenance**
   - Si `maintenanceMode: true`, afficher:
     - ⚠️ "Application en maintenance"
     - "Nous revenons bientôt !"
     - Bloquer toutes les actions sauf lecture

### ✅ Checklist Développement

- [ ] Créer `SettingsService.js`
- [ ] Charger settings au démarrage (dans `App.js`)
- [ ] Stocker settings dans Context/Redux
- [ ] Utiliser `platformFee` dans calcul prix
- [ ] Utiliser `cancellationDelay` dans validation annulation
- [ ] Utiliser `min/maxReservationHours` dans formulaire réservation
- [ ] Créer `SupportScreen.js` avec contact dynamique
- [ ] Implémenter détection mode maintenance
- [ ] Refresh settings toutes les 24h

---

## 7. Messagerie

### 📡 API Messages

#### **GET /api/messages/partners** - Liste des conversations
```javascript
// Response
[
  {
    "partnerId": 123,
    "partnerName": "Jean P.",
    "lastMessage": "D'accord, à demain !",
    "lastMessageTime": "2025-12-11T15:30:00.000Z",
    "unreadCount": 2
  }
]
```

#### **GET /api/messages?userId1=456&userId2=789** - Conversation
```javascript
// Response
[
  {
    "id": 1,
    "senderId": 456,
    "receiverId": 789,
    "message": "Bonjour, êtes-vous disponible demain ?",
    "createdAt": "2025-12-11T14:00:00.000Z",
    "isRead": true
  }
]
```

#### **POST /api/messages** - Envoyer un message
```javascript
// Payload
{
  "receiverId": 789,
  "message": "Oui, je suis disponible de 14h à 18h"
}
```

### 🎨 UI/UX à Améliorer

1. **Badge de messages non lus**
   - Icône messagerie avec badge rouge: 🔴 3
   - Refresh automatique toutes les 30 secondes

2. **Horodatage intelligent**
   - Aujourd'hui: "14:30"
   - Hier: "Hier 14:30"
   - Cette semaine: "Lundi 14:30"
   - Ancien: "11 déc. 14:30"

3. **Notifications push**
   - Nouveau message reçu
   - Son/vibration si app en arrière-plan

### ✅ Checklist Développement

- [ ] Améliorer `MessagesScreen.js` avec badge non lus
- [ ] Polling automatique (toutes les 30s)
- [ ] Notification push nouveaux messages
- [ ] Marquer comme lu automatiquement
- [ ] Horodatage relatif

---

## 8. Profils Utilisateurs

### 📡 API Profil

#### **GET /api/users/:id** - Profil public
```javascript
// Response
{
  "id": 123,
  "name": "Jean P.",
  "email": "jean@example.com", // Caché pour autres utilisateurs
  "userType": "professionnel",
  "phone": "+33 6 12 34 56 78",
  "city": "Paris",
  "photoUrl": "https://...",
  "bio": "Auxiliaire de puériculture depuis 10 ans",
  "averageRating": 4.8,
  "reviewCount": 124,
  "badges": ["verified", "top_rated"],
  "documentsVerified": true
}
```

#### **PUT /api/users/:id** - Mettre à jour mon profil
```javascript
// Payload
{
  "name": "Jean Dupont",
  "phone": "+33 6 12 34 56 78",
  "city": "Lyon",
  "bio": "..."
}
```

### 🎨 UI/UX à Améliorer

1. **Badge "Profil vérifié"**
   - ✅ Badge vert si `documentsVerified: true`
   - Visible sur carte profil et profil complet

2. **Badges de distinction**
   - 🏆 Top Rated (rating > 4.5 et > 50 avis)
   - ⭐ Nouveau (inscrit < 3 mois)
   - 👍 Recommandé (> 100 avis positifs)

3. **Visibilité email/téléphone**
   - Email caché sauf si réservation en cours
   - Téléphone visible seulement après confirmation réservation

### ✅ Checklist Développement

- [ ] Afficher badge "Vérifié" conditionnel
- [ ] Implémenter système de badges
- [ ] Masquer email selon contexte
- [ ] Afficher téléphone seulement si réservation confirmée

---

## 🚀 Priorités de Développement

### Phase 1 - Critique (2 semaines)
1. ✅ Système de signalements (Reports)
2. ✅ Gestion améliorée des documents (rejectReason)
3. ✅ Paiements Stripe (retry, refund)
4. ✅ Paramètres dynamiques (settings API)

### Phase 2 - Important (2 semaines)
5. ✅ Avis obligatoires post-réservation
6. ✅ Statuts de réservation avancés
7. ✅ Notifications push complètes
8. ✅ Calendrier de disponibilités

### Phase 3 - Amélioration (1 semaine)
9. ✅ Statistiques avis (distribution)
10. ✅ Badges de profil
11. ✅ Messagerie améliorée
12. ✅ Mode maintenance

---

## 📊 Tableau Récapitulatif des API

| Endpoint | Méthode | Authentification | Priorité | Implémenté App? |
|----------|---------|------------------|----------|-----------------|
| `/api/reports` | GET/POST | ✅ | 🔴 Haute | ❌ |
| `/api/reports/:id` | PUT/DELETE | ✅ | 🔴 Haute | ❌ |
| `/api/documents` | GET | ✅ | 🔴 Haute | ⚠️ Partiel |
| `/api/documents/:id/reject` | POST | ✅ Admin | 🔴 Haute | ❌ |
| `/api/stripe/create-payment-intent` | POST | ✅ | 🔴 Haute | ⚠️ Partiel |
| `/api/stripe/refund` | POST | ✅ | 🟡 Moyenne | ❌ |
| `/api/settings` | GET | ❌ | 🔴 Haute | ❌ |
| `/api/reviews` | GET/POST | ✅ | 🟡 Moyenne | ⚠️ Partiel |
| `/api/reviews/:id` | DELETE | ✅ | 🟢 Basse | ❌ |
| `/api/reservations` | GET/PUT | ✅ | 🔴 Haute | ✅ |
| `/api/messages` | GET/POST | ✅ | 🟡 Moyenne | ✅ |
| `/api/users/:id` | GET/PUT | ⚠️ | 🔴 Haute | ✅ |
| `/api/availabilities` | GET/POST | ✅ | 🟡 Moyenne | ❌ |

**Légende:**
- 🔴 Haute = Fonctionnalité essentielle
- 🟡 Moyenne = Amélioration importante
- 🟢 Basse = Confort utilisateur
- ✅ Implémenté | ⚠️ Partiel | ❌ Manquant

---

## 🔧 Recommandations Techniques

### Architecture
- Créer des **services API** séparés pour chaque module
- Utiliser **React Context** ou **Redux** pour les settings globaux
- Implémenter **React Query** pour le caching des données

### Notifications
- Configurer **Firebase Cloud Messaging (FCM)**
- Créer endpoint webhook: `POST /api/notifications/register-device`
- Stocker `deviceToken` côté backend

### Sécurité
- Toujours envoyer le **JWT token** dans headers: `Authorization: Bearer <token>`
- Valider les permissions côté client ET serveur
- Ne jamais stocker de données sensibles en clair

### Performance
- Implémenter **lazy loading** pour les listes longues
- Utiliser **pagination** sur les avis et réservations
- **Caching** des profils utilisateurs (24h)

### Tests
- Tester tous les nouveaux flux (signalements, remboursements, etc.)
- Vérifier comportement en mode hors ligne
- Tests E2E sur workflow complet: inscription → réservation → avis

---

## 📞 Support & Questions

**Contact technique:**
- Email: dev@auxivie.org
- Documentation API: https://auxivie.org/api/docs (à créer)

**Ressources:**
- Dashboard Admin: https://auxivie.org/admin
- Backend: https://auxivie.org/api
- Base de données: MySQL Hostinger

---

## ✅ Checklist Finale

- [ ] Lire et comprendre ce document complet
- [ ] Auditer l'app mobile actuelle (fonctionnalités manquantes)
- [ ] Créer un plan de développement par sprint
- [ ] Configurer les nouveaux services API
- [ ] Implémenter Phase 1 (Critique)
- [ ] Tests utilisateurs beta
- [ ] Implémenter Phase 2 (Important)
- [ ] Implémenter Phase 3 (Amélioration)
- [ ] Tests de régression complets
- [ ] Déploiement en production

---

**Document créé le:** 11 Décembre 2025  
**Dernière mise à jour:** 11 Décembre 2025  
**Version:** 1.0  
**Auteur:** Équipe Auxivie - Dashboard Admin

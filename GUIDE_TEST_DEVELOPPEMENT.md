# 🧪 Guide de Test - Mode Développement

Guide pour tester toutes les fonctionnalités de l'application Auxivie en mode développement.

## 🚀 Démarrage Rapide

### 1. Démarrer le Backend

```bash
cd backend

# Installer les dépendances si nécessaire
npm install

# Démarrer le serveur en mode développement
npm run dev

# Ou en mode normal
npm start
```

Le backend sera accessible sur `http://localhost:3001`

### 2. Vérifier la Configuration Flutter

Le fichier `lib/config/app_config.dart` est déjà configuré en mode développement :
- **iOS Simulator** : `http://localhost:3001`
- **Android Emulator** : `http://10.0.2.2:3001`
- **Détection automatique** de la plateforme

### 3. Démarrer l'Application Flutter

```bash
# Depuis la racine du projet
flutter run
```

## ✅ Checklist de Test des Fonctionnalités

### 🔐 Authentification
- [ ] **Inscription Famille**
  - Créer un compte famille
  - Vérifier la synchronisation avec le backend
  
- [ ] **Inscription Professionnel**
  - Créer un compte professionnel
  - Vérifier la synchronisation avec le backend
  
- [ ] **Connexion**
  - Se connecter avec un compte existant
  - Vérifier la redirection vers le dashboard approprié

### 👤 Profil Utilisateur
- [ ] **Photo de profil**
  - Cliquer sur l'icône caméra dans le profil
  - Prendre une photo ou choisir depuis la galerie
  - Vérifier l'upload et l'affichage de la photo
  
- [ ] **Modification des informations**
  - Modifier le nom, email, téléphone
  - Vérifier la synchronisation avec le backend

### 📄 Documents
- [ ] **Upload de documents**
  - Aller dans la section "Documents" du profil
  - Ajouter un document (photo caméra ou galerie)
  - Vérifier l'upload vers le backend
  - Vérifier l'affichage dans le dashboard admin

### 💰 Paiements
- [ ] **Création d'un PaymentIntent**
  - Créer une réservation
  - Tester la création d'un PaymentIntent Stripe
  - Vérifier la réponse avec `clientSecret`

### 📅 Réservations
- [ ] **Création de réservation**
  - Créer une nouvelle réservation
  - Vérifier l'affichage dans le calendrier
  - Vérifier la synchronisation avec le backend

- [ ] **Modification de réservation**
  - Modifier le statut d'une réservation
  - Vérifier la mise à jour

### 💬 Messagerie
- [ ] **Envoi de messages**
  - Envoyer un message à un professionnel
  - Vérifier la réception
  - Vérifier l'affichage dans la conversation

### 🔍 Recherche
- [ ] **Recherche de professionnels**
  - Utiliser les filtres (catégorie, ville, tarif)
  - Vérifier les résultats
  - Vérifier l'affichage des badges et notes

## 🐛 Dépannage

### Erreur de connexion au backend

**Problème** : `Failed host lookup` ou `Connection refused`

**Solutions** :
1. Vérifier que le backend est démarré : `curl http://localhost:3001/api/health`
2. Pour Android, vérifier que vous utilisez `10.0.2.2:3001`
3. Pour iOS, vérifier que vous utilisez `localhost:3001`
4. Si vous testez sur un appareil physique, utiliser l'IP locale de votre machine

### Erreur d'upload de fichiers

**Problème** : Les fichiers ne s'uploadent pas

**Solutions** :
1. Vérifier que le dossier `backend/uploads` existe
2. Vérifier les permissions d'écriture
3. Vérifier la taille du fichier (max 10MB pour documents, 5MB pour photos)
4. Vérifier les logs du backend pour les erreurs

### Erreur Stripe

**Problème** : Erreur lors de la création du PaymentIntent

**Solutions** :
1. Vérifier que `STRIPE_SECRET_KEY` est configuré dans `.env`
2. Utiliser une clé de test Stripe (commence par `sk_test_`)
3. Vérifier les logs du backend

## 📝 Notes Importantes

### Variables d'Environnement Backend

Créez un fichier `backend/.env` avec :

```env
PORT=3001
JWT_SECRET=your-secret-key-for-development
STRIPE_SECRET_KEY=sk_test_your_stripe_key
CORS_ORIGIN=http://localhost:3000,http://localhost:3001
NODE_ENV=development
```

### Base de Données

La base de données SQLite est dans `backend/data/auxivie.db`

Pour réinitialiser la base de données :
```bash
cd backend
npm run clear-all
```

### Logs

- **Backend** : Les logs s'affichent dans la console
- **Flutter** : Utilisez `flutter logs` ou la console de développement

## 🎯 Tests Recommandés par Priorité

1. **Priorité 1** : Authentification, Profil, Documents
2. **Priorité 2** : Réservations, Messagerie
3. **Priorité 3** : Paiements, Recherche avancée

## 📞 Support

En cas de problème, vérifiez :
- Les logs du backend
- Les logs Flutter
- La configuration réseau
- Les permissions des fichiers


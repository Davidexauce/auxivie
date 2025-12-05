# 🌐 Configuration du Domaine auxivie.org

## 📋 Informations du Domaine

- **Domaine principal :** `https://www.auxivie.org`
- **Dashboard Admin :** `https://www.auxivie.org` (ou sous-domaine dédié)
- **API Backend :** `https://api.auxivie.org` (à configurer)

---

## 🔧 Configuration Requise

### 1. Dashboard Admin (Hostinger)

**Variables d'environnement :**
```env
NEXT_PUBLIC_API_URL=https://api.auxivie.org
NODE_ENV=production
PORT=3000
```

**URL d'accès :** `https://www.auxivie.org`

---

### 2. API Backend (à configurer)

**Configuration CORS nécessaire :**

Dans `backend/server.js`, la configuration CORS doit autoriser :
- `https://www.auxivie.org` (dashboard)
- `https://api.auxivie.org` (si nécessaire)

**Exemple de configuration :**
```javascript
const corsOptions = {
  origin: [
    'https://www.auxivie.org',
    'https://auxivie.org',
    'https://api.auxivie.org'
  ],
  credentials: true,
  optionsSuccessStatus: 200
};
```

---

### 3. Application Mobile Flutter

**Configuration pour la production :**

Dans `lib/config/app_config.dart`, mettre à jour :
```dart
case Environment.production:
  return 'https://api.auxivie.org';
```

---

## 📝 Checklist de Configuration

### Dashboard (Hostinger)
- [ ] Domaine `auxivie.org` configuré dans Hostinger
- [ ] Variables d'environnement définies avec `https://api.auxivie.org`
- [ ] Application Node.js déployée et accessible
- [ ] HTTPS activé (certificat SSL)

### API Backend
- [ ] Sous-domaine `api.auxivie.org` configuré
- [ ] CORS configuré pour autoriser `https://www.auxivie.org`
- [ ] HTTPS activé (certificat SSL)
- [ ] Variables d'environnement de production configurées

### DNS
- [ ] Enregistrement A pour `www.auxivie.org` → IP du serveur
- [ ] Enregistrement A pour `api.auxivie.org` → IP du serveur API
- [ ] Enregistrement CNAME si nécessaire

---

## 🔐 Sécurité

### Certificats SSL
- ✅ Activer HTTPS pour tous les sous-domaines
- ✅ Utiliser Let's Encrypt (gratuit) ou certificat payant
- ✅ Configurer la redirection HTTP → HTTPS

### Headers de Sécurité
Les headers de sécurité sont déjà configurés dans :
- `admin-dashboard/next.config.js`
- `backend/server.js`

---

## 🧪 Tests

### Vérifier le Dashboard
1. Accéder à `https://www.auxivie.org`
2. Vérifier que la page de login s'affiche
3. Tester la connexion admin

### Vérifier l'API
1. Tester `https://api.auxivie.org/api/health` (si endpoint existe)
2. Vérifier les logs CORS dans le backend
3. Tester une requête depuis le dashboard

### Vérifier l'Application Mobile
1. Configurer l'environnement en production
2. Tester la connexion à l'API
3. Vérifier toutes les fonctionnalités

---

## 📞 Support

En cas de problème :
1. Vérifier les logs dans Hostinger
2. Vérifier les logs du backend
3. Vérifier la configuration DNS
4. Vérifier les certificats SSL

---

**Date de création :** 2024-12-19


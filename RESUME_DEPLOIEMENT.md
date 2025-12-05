# 📋 Résumé de Déploiement - auxivie.org

## 🌐 Domaines Configurés

- **Dashboard Admin :** `https://www.auxivie.org`
- **API Backend :** `https://api.auxivie.org` (à configurer)
- **Application Mobile :** Utilise `https://api.auxivie.org` en production

---

## ✅ Fichiers Configurés

### Dashboard (Hostinger)
- ✅ `admin-dashboard/.env.example` → `NEXT_PUBLIC_API_URL=https://api.auxivie.org`
- ✅ `admin-dashboard/GUIDE_DEPLOIEMENT_HOSTINGER.md` → Mis à jour avec auxivie.org
- ✅ `admin-dashboard/README.md` → Mis à jour avec auxivie.org
- ✅ `admin-dashboard/package.json` → Scripts de production configurés
- ✅ `admin-dashboard/next.config.js` → Mode standalone activé
- ✅ `admin-dashboard/server.js` → Serveur Node.js pour Hostinger

### Backend
- ✅ `backend/.env.example` → CORS configuré pour auxivie.org
- ✅ `backend/server.js` → CORS mis à jour pour autoriser auxivie.org

### Application Mobile
- ✅ `lib/config/app_config.dart` → URL de production mise à jour vers `https://api.auxivie.org`

---

## 🚀 Étapes de Déploiement

### 1. Dashboard sur Hostinger

**Variables d'environnement à définir dans Hostinger :**
```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
NODE_ENV=production
PORT=3000
```

**Configuration de l'application Node.js :**
- **Source Directory :** `/admin-dashboard`
- **Build Command :** `npm run build`
- **Start Command :** `npm start`
- **Node Version :** `18.x` ou supérieur

**URL d'accès :** `https://www.auxivie.org`

---

### 2. API Backend (à déployer séparément)

**Variables d'environnement :**
```
PORT=3001
JWT_SECRET=votre-secret-jwt-securise
STRIPE_SECRET_KEY=votre-cle-stripe
CORS_ORIGIN=https://www.auxivie.org,https://auxivie.org,https://api.auxivie.org
NODE_ENV=production
```

**URL d'accès :** `https://api.auxivie.org`

**⚠️ Important :** 
- Le backend doit être déployé sur un serveur accessible publiquement
- Configurer le sous-domaine `api.auxivie.org` dans les DNS
- Activer HTTPS avec un certificat SSL

---

### 3. Configuration DNS

**Enregistrements nécessaires :**
- **A Record :** `www.auxivie.org` → IP du serveur Hostinger (dashboard)
- **A Record :** `api.auxivie.org` → IP du serveur backend
- **CNAME :** `auxivie.org` → `www.auxivie.org` (redirection)

---

## 🔐 Sécurité

### Certificats SSL
- ✅ Activer HTTPS pour tous les domaines
- ✅ Utiliser Let's Encrypt (gratuit) ou certificat payant
- ✅ Configurer la redirection HTTP → HTTPS automatique

### CORS
- ✅ Backend configuré pour autoriser `https://www.auxivie.org`
- ✅ Headers de sécurité configurés dans Next.js

---

## 📝 Checklist de Déploiement

### Dashboard
- [ ] Repository GitHub poussé avec les nouvelles configurations
- [ ] Application Node.js créée dans Hostinger
- [ ] Variables d'environnement définies
- [ ] GitHub connecté et déploiement activé
- [ ] Domaine `www.auxivie.org` configuré
- [ ] HTTPS activé
- [ ] Application accessible et fonctionnelle

### Backend
- [ ] Serveur backend déployé et accessible
- [ ] Sous-domaine `api.auxivie.org` configuré
- [ ] Variables d'environnement définies
- [ ] CORS configuré pour autoriser auxivie.org
- [ ] HTTPS activé
- [ ] Base de données accessible
- [ ] Tests de connexion réussis

### DNS
- [ ] Enregistrements DNS configurés
- [ ] Propagation DNS vérifiée
- [ ] Certificats SSL installés

### Tests
- [ ] Dashboard accessible sur `https://www.auxivie.org`
- [ ] API accessible sur `https://api.auxivie.org`
- [ ] Login admin fonctionne
- [ ] Connexion entre dashboard et API fonctionne
- [ ] Application mobile connecte à l'API en production

---

## 📚 Documentation

- **Guide complet Hostinger :** `admin-dashboard/GUIDE_DEPLOIEMENT_HOSTINGER.md`
- **Configuration domaine :** `CONFIGURATION_DOMAINE.md`
- **README Dashboard :** `admin-dashboard/README.md`

---

**Date de création :** 2024-12-19


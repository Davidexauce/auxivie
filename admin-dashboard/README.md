# 🎯 Dashboard d'Administration Auxivie

Dashboard d'administration pour la plateforme Auxivie, construit avec Next.js et React.

## 🚀 Déploiement Rapide sur Hostinger

### Prérequis
- Compte Hostinger avec accès Node.js
- Repository GitHub connecté

### Étapes

1. **Configurer les variables d'environnement dans Hostinger :**
   ```
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   NODE_ENV=production
   PORT=3000
   ```

2. **Configurer l'application Node.js :**
   - **Source Directory** : `/admin-dashboard`
   - **Build Command** : `npm run build`
   - **Start Command** : `npm start`
   - **Node Version** : `18.x` ou supérieur

3. **Connecter GitHub et déployer**

📖 **Guide complet** : Voir [GUIDE_DEPLOIEMENT_HOSTINGER.md](./GUIDE_DEPLOIEMENT_HOSTINGER.md)

## 🛠️ Développement Local

```bash
# Installer les dépendances
npm install

# Démarrer en mode développement
npm run dev

# Build pour la production
npm run build

# Démarrer en mode production
npm start
```

## 📁 Structure du Projet

```
admin-dashboard/
├── components/          # Composants réutilisables
├── lib/                 # Utilitaires et API
├── pages/               # Pages Next.js
├── styles/              # Fichiers CSS
├── public/              # Assets statiques
├── next.config.js       # Configuration Next.js
├── server.js            # Serveur pour Hostinger
└── package.json         # Dépendances
```

## 🔐 Variables d'Environnement

Créez un fichier `.env` basé sur `.env.example` :

**En développement :**
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

**En production (Hostinger) :**
```env
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

## 📝 Fonctionnalités

- ✅ Gestion des utilisateurs
- ✅ Gestion des documents
- ✅ Gestion des paiements
- ✅ Gestion des avis
- ✅ Gestion des réservations
- ✅ Gestion des messages

## 🔗 Liens Utiles

- [Guide de déploiement Hostinger](./GUIDE_DEPLOIEMENT_HOSTINGER.md)
- [Documentation Next.js](https://nextjs.org/docs)


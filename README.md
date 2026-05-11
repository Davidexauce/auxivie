# Christelle Projet — Aidalya

Dépôt **serveur + dashboard web** uniquement.  
L’**application mobile Flutter Aidalya** (iOS / Android) est dans un projet séparé sur cette machine (répertoire local « App flutter Auxivie », package Dart `aidalya`).

## Contenu

| Dossier | Rôle |
|---------|------|
| **`backend/`** | API Node.js (Express, MySQL), Stripe, auth JWT — déployée derrière `auxivie.org` / Hostinger. |
| **`admin-dashboard/`** | Interface Next.js pour l’administration. |
| **`docs/`** | Notes d’intégration, déploiement et historiques de corrections. |

## Démarrage rapide

**API** (depuis `backend/`) :

```bash
npm install
# Configurer .env ou .env.production (voir backend/.env.local.example si présent)
node server.js
```

**Dashboard** (depuis `admin-dashboard/`) :

```bash
npm install
npm run dev
```

## Déploiement

Voir **`docs/DEPLOYMENT.md`** et **`docs/PRODUCTION_CHECKLIST.md`**.

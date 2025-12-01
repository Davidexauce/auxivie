# 🔧 Configuration des Variables d'Environnement

Certains fichiers `.env` ne peuvent pas être créés automatiquement pour des raisons de sécurité. Suivez ces instructions pour les créer manuellement.

## Backend

### 1. Créer `.env.example` (déjà créé)

Le fichier `backend/.env.example` contient un modèle. Copiez-le :

```bash
cd backend
cp .env.example .env
cp .env.example .env.production
```

### 2. Éditer `.env.production`

Ouvrez `backend/.env.production` et remplissez :

```env
NODE_ENV=production
PORT=3001
JWT_SECRET=GÉNÉREZ-UN-SECRET-FORT-ICI
DB_PATH=./data/auxivie.db
CORS_ORIGIN=https://votre-dashboard.com,https://api.votre-domaine.com
API_URL=https://api.votre-domaine.com
```

**Générer un JWT_SECRET fort :**
```bash
openssl rand -base64 32
```

## Dashboard

### 1. Créer les fichiers d'environnement

```bash
cd admin-dashboard
cp .env.example .env.local
cp .env.example .env.production
```

### 2. Éditer `.env.production`

Ouvrez `admin-dashboard/.env.production` et remplissez :

```env
NEXT_PUBLIC_API_URL=https://api.votre-domaine.com
NODE_ENV=production
```

## ⚠️ Important

- **NE COMMITEZ JAMAIS** les fichiers `.env` ou `.env.production` avec de vraies valeurs
- Ces fichiers sont déjà dans `.gitignore`
- Utilisez des secrets différents pour chaque environnement


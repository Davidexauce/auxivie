# 📤 Déployer .env.production sur Hostinger

## 📋 Contenu du Fichier

Le fichier `.env.production` doit contenir :

```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

---

## 🎯 Méthode 1 : Via File Manager Hostinger (Recommandé)

### Étapes :

1. **Connectez-vous à Hostinger hPanel**
2. **Ouvrez le File Manager**
3. **Naviguez vers** : `domains/auxivie.org/public_html/admin-dashboard/`
4. **Cliquez sur "Nouveau fichier"** ou **"New File"**
5. **Nommez le fichier** : `.env.production`
6. **Collez ce contenu** :
   ```
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   ```
7. **Sauvegardez**

---

## 🎯 Méthode 2 : Via SSH (si vous avez accès)

### Option A : Créer directement sur Hostinger

```bash
# Connectez-vous via SSH
ssh votre_utilisateur@votre_serveur

# Naviguez vers le dossier admin-dashboard
cd ~/domains/auxivie.org/public_html/admin-dashboard

# Créer le fichier
echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > .env.production

# Vérifier
cat .env.production
```

### Option B : Transférer depuis votre machine locale

```bash
# Depuis votre machine locale
cd "/Users/david/Christelle Projet/admin-dashboard"

# Transférer via SCP (remplacez par vos identifiants)
scp .env.production utilisateur@hostinger:/domains/auxivie.org/public_html/admin-dashboard/.env.production
```

---

## 🎯 Méthode 3 : Via FTP (FileZilla, etc.)

1. **Connectez-vous via FTP** à Hostinger
2. **Naviguez vers** : `/domains/auxivie.org/public_html/admin-dashboard/`
3. **Créez un nouveau fichier** `.env.production`
4. **Collez le contenu** :
   ```
   NEXT_PUBLIC_API_URL=https://api.auxivie.org
   ```
5. **Upload**

---

## 🎯 Méthode 4 : Via Terminal Hostinger (hPanel)

1. **Connectez-vous à Hostinger hPanel**
2. **Allez dans "Terminal"** ou **"SSH Access"**
3. **Exécutez** :
   ```bash
   cd ~/domains/auxivie.org/public_html/admin-dashboard
   echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > .env.production
   cat .env.production
   ```

---

## ✅ Vérification

Après avoir créé le fichier, vérifiez :

```bash
# Via SSH ou Terminal Hostinger
cd ~/domains/auxivie.org/public_html/admin-dashboard
cat .env.production
```

Vous devriez voir :
```
NEXT_PUBLIC_API_URL=https://api.auxivie.org
```

---

## 🔄 Rebuild Nécessaire

**⚠️ IMPORTANT** : Après avoir créé `.env.production`, vous **devez rebuilder** le Dashboard :

```bash
cd ~/domains/auxivie.org/public_html/admin-dashboard
npm run build
npm start
```

---

## 📋 Checklist

- [ ] Fichier `.env.production` créé sur Hostinger
- [ ] Contenu : `NEXT_PUBLIC_API_URL=https://api.auxivie.org`
- [ ] Fichier vérifié (`cat .env.production`)
- [ ] Dashboard rebuild (`npm run build`)
- [ ] Serveur redémarré (`npm start`)

---

## 💡 Astuce

Si vous utilisez **GitHub** pour déployer sur Hostinger, le fichier `.env.production` ne sera **pas** inclus car il est dans `.gitignore`. Vous devez le créer manuellement sur Hostinger après chaque déploiement, ou utiliser une variable d'environnement dans les paramètres Hostinger.

---

**La méthode la plus simple est via le File Manager de Hostinger !**


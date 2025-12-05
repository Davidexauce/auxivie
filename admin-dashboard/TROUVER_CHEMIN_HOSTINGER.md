# 🔍 Trouver le Chemin du Dashboard sur Hostinger

## ❌ Problème

Le chemin `~/domains/auxivie.org/public_html/` n'existe pas.

---

## 🔍 Méthode 1 : Trouver le Chemin via SSH

### Étape 1 : Lister les Dossiers Disponibles

```bash
# Voir où vous êtes
pwd

# Voir les dossiers dans votre home
ls -la

# Chercher le dossier domains
ls -la ~/

# Chercher public_html
find ~ -name "public_html" -type d 2>/dev/null

# Chercher admin-dashboard
find ~ -name "admin-dashboard" -type d 2>/dev/null
```

### Étape 2 : Chercher le Fichier package.json du Dashboard

```bash
# Chercher package.json du Dashboard
find ~ -name "package.json" -path "*/admin-dashboard/*" 2>/dev/null
```

---

## 🔍 Méthode 2 : Via File Manager Hostinger

1. **Connectez-vous à hPanel** : https://hpanel.hostinger.com/
2. **Ouvrez File Manager**
3. **Naviguez vers votre site** `auxivie.org`
4. **Regardez le chemin affiché** en haut du File Manager
5. **Notez le chemin complet** vers `admin-dashboard`

---

## 🔍 Méthode 3 : Chemins Possibles sur Hostinger

Essayez ces chemins un par un :

```bash
# Option 1 : Structure standard
cd ~/public_html/admin-dashboard
pwd

# Option 2 : Avec domains
cd ~/domains/auxivie.org/public_html/admin-dashboard
pwd

# Option 3 : Directement dans public_html
cd ~/public_html
ls -la
# Cherchez admin-dashboard dans la liste

# Option 4 : Dans le dossier du domaine
cd ~/domains/auxivie.org
ls -la
# Cherchez public_html ou admin-dashboard
```

---

## 🎯 Solution Rapide : Créer le Fichier où vous êtes

Si vous ne trouvez pas le chemin exact, créez le fichier dans votre home et déplacez-le ensuite :

```bash
# Créer le fichier dans votre home
echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > ~/.env.production.temp

# Trouver admin-dashboard
DASHBOARD_PATH=$(find ~ -name "next.config.js" -path "*/admin-dashboard/*" 2>/dev/null | head -1 | xargs dirname)

# Si trouvé, déplacer le fichier
if [ -n "$DASHBOARD_PATH" ]; then
    mv ~/.env.production.temp "$DASHBOARD_PATH/.env.production"
    echo "✅ Fichier créé dans: $DASHBOARD_PATH/.env.production"
    cat "$DASHBOARD_PATH/.env.production"
else
    echo "❌ Dossier admin-dashboard non trouvé"
    echo "💡 Utilisez le File Manager pour créer le fichier manuellement"
fi
```

---

## 🎯 Solution Alternative : Via File Manager (Plus Simple)

Si vous avez des difficultés avec SSH, utilisez le **File Manager** :

1. **Connectez-vous à hPanel** : https://hpanel.hostinger.com/
2. **Ouvrez File Manager**
3. **Naviguez vers votre site** (cherchez `auxivie.org` ou `admin-dashboard`)
4. **Créez le fichier** `.env.production` directement dans le File Manager
5. **Collez le contenu** : `NEXT_PUBLIC_API_URL=https://api.auxivie.org`

---

## 📋 Commandes de Diagnostic

Exécutez ces commandes pour trouver le bon chemin :

```bash
# 1. Voir où vous êtes
pwd

# 2. Voir votre structure de dossiers
ls -la ~/

# 3. Chercher public_html
find ~ -maxdepth 3 -name "public_html" -type d 2>/dev/null

# 4. Chercher admin-dashboard
find ~ -maxdepth 5 -name "admin-dashboard" -type d 2>/dev/null

# 5. Chercher next.config.js (fichier du Dashboard)
find ~ -name "next.config.js" 2>/dev/null

# 6. Chercher package.json avec "next" dedans
find ~ -name "package.json" -exec grep -l "next" {} \; 2>/dev/null | grep admin-dashboard
```

---

## 💡 Astuce

Une fois que vous avez trouvé le chemin, notez-le pour la prochaine fois :

```bash
# Exemple de chemin trouvé
DASHBOARD_PATH="/home/u133413376/public_html/admin-dashboard"

# Créer le fichier
echo "NEXT_PUBLIC_API_URL=https://api.auxivie.org" > "$DASHBOARD_PATH/.env.production"

# Vérifier
cat "$DASHBOARD_PATH/.env.production"
```

---

**Commencez par exécuter `pwd` et `ls -la ~/` pour voir la structure de vos dossiers !**


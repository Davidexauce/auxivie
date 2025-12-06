# 🔍 Commandes pour Trouver le Dashboard

## 📋 Commandes à Exécuter sur Hostinger

Copiez et exécutez ces commandes **une par une** :

### 1. Voir le Contenu de public_html

```bash
ls -la ~/domains/auxivie.org/public_html/
```

### 2. Chercher les Dossiers avec "admin" ou "dashboard"

```bash
find ~/domains/auxivie.org/public_html -type d \( -iname "*admin*" -o -iname "*dashboard*" \) 2>/dev/null
```

### 3. Chercher next.config.js

```bash
find ~/domains/auxivie.org/public_html -name "next.config.js" 2>/dev/null
```

### 4. Chercher package.json avec "next"

```bash
find ~/domains/auxivie.org/public_html -name "package.json" -exec grep -l "next" {} \; 2>/dev/null
```

### 5. Chercher dans Tout le Home

```bash
find ~ -maxdepth 5 -name "next.config.js" 2>/dev/null | grep -v node_modules
```

### 6. Chercher package.json avec "auxivie-admin"

```bash
find ~ -maxdepth 5 -name "package.json" -exec grep -l "auxivie-admin" {} \; 2>/dev/null | grep -v node_modules
```

### 7. Voir la Structure Complète de public_html

```bash
find ~/domains/auxivie.org/public_html -maxdepth 3 -type d 2>/dev/null
```

---

## 🎯 Script Automatique

Si vous avez téléchargé le script, exécutez :

```bash
cd ~/domains/auxivie.org/public_html
bash find-dashboard.sh
```

Ou téléchargez le script depuis GitHub :

```bash
# Si git est disponible
cd ~
git clone https://github.com/Davidexauce/auxivie.git temp-dashboard
bash temp-dashboard/admin-dashboard/scripts/find-dashboard.sh
rm -rf temp-dashboard
```

---

## 📋 Résultats Attendus

### Si le Dashboard Existe

Vous devriez voir :
- Un dossier avec `next.config.js`
- Un dossier avec `package.json` contenant `"next"`
- Un dossier avec `package.json` contenant `"auxivie-admin-dashboard"`

### Si le Dashboard N'Existe Pas

Aucun résultat → Le Dashboard n'est pas encore déployé.

---

**Commencez par exécuter la commande #1 : `ls -la ~/domains/auxivie.org/public_html/`**


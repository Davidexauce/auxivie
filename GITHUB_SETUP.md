# 🚀 Configuration GitHub pour Auxivie

## Option 1 : Créer le dépôt manuellement (Recommandé)

### Étape 1 : Créer le dépôt sur GitHub
1. Allez sur [GitHub.com](https://github.com) et connectez-vous
2. Cliquez sur le bouton **"+"** en haut à droite → **"New repository"**
3. Remplissez les informations :
   - **Repository name** : `auxivie` (ou le nom de votre choix)
   - **Description** : "Application mobile de mise en relation entre professionnels de l'aide à domicile et familles"
   - **Visibilité** : Privé ou Public (selon votre préférence)
   - ⚠️ **NE COCHEZ PAS** "Initialize this repository with a README" (le dépôt existe déjà)
4. Cliquez sur **"Create repository"**

### Étape 2 : Copier l'URL du dépôt
Après la création, GitHub vous affichera une URL comme :
- `https://github.com/VOTRE_USERNAME/auxivie.git` (HTTPS)
- `git@github.com:VOTRE_USERNAME/auxivie.git` (SSH)

### Étape 3 : Exécuter les commandes suivantes
Remplacez `VOTRE_URL` par l'URL que vous avez copiée :

```bash
cd "/Users/david/Christelle Projet"
git remote add origin VOTRE_URL
git branch -M main  # Optionnel : renommer master en main
git push -u origin main  # ou master si vous gardez master
```

## Option 2 : Utiliser GitHub CLI (si installé)

```bash
# Installer GitHub CLI (macOS)
brew install gh

# S'authentifier
gh auth login

# Créer le dépôt et pousser
cd "/Users/david/Christelle Projet"
gh repo create auxivie --private --source=. --remote=origin --push
```

## Vérification

Après avoir poussé, vérifiez que tout est bien synchronisé :

```bash
git remote -v
git log --oneline -5
```

## 🔐 Authentification GitHub

### Méthode HTTPS (Recommandée pour débutants)
- Utilisez un **Personal Access Token** au lieu du mot de passe
- Créez-en un ici : https://github.com/settings/tokens
- Scopes nécessaires : `repo` (accès complet aux dépôts)

### Méthode SSH (Plus sécurisée)
- Configurez une clé SSH : https://docs.github.com/en/authentication/connecting-to-github-with-ssh

## 📝 Notes importantes

- ⚠️ Les fichiers sensibles (`.env`, `*.db`) sont déjà dans `.gitignore`
- ✅ Tous les fichiers importants sont déjà commités localement
- 🔄 Vous pouvez pousser plusieurs fois : `git push`


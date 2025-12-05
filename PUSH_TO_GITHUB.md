# 🚀 Guide pour pousser le code vers GitHub

## ⚠️ Problème d'authentification détecté

GitHub nécessite maintenant un **Personal Access Token** au lieu d'un mot de passe pour l'authentification HTTPS.

## 📝 Étapes pour résoudre le problème

### Option 1 : Utiliser un Personal Access Token (Recommandé)

1. **Créer un token GitHub :**
   - Allez sur : https://github.com/settings/tokens
   - Cliquez sur **"Generate new token"** → **"Generate new token (classic)"**
   - Donnez un nom : `Auxivie Project`
   - Sélectionnez les scopes : ✅ **`repo`** (accès complet aux dépôts)
   - Cliquez sur **"Generate token"**
   - ⚠️ **COPIEZ LE TOKEN IMMÉDIATEMENT** (vous ne pourrez plus le voir après)

2. **Configurer Git avec le token :**
   ```bash
   cd "/Users/david/Christelle Projet"
   
   # Option A : Utiliser le token dans l'URL (temporaire)
   git remote set-url origin https://VOTRE_TOKEN@github.com/Davidexauce/auxivie.git
   git push -u origin master
   
   # Option B : Git vous demandera le token (plus sécurisé)
   git remote set-url origin https://github.com/Davidexauce/auxivie.git
   git push -u origin master
   # Username: Davidexauce
   # Password: [collez votre token ici]
   ```

3. **Sauvegarder le token dans le Keychain (macOS) :**
   ```bash
   git config --global credential.helper osxkeychain
   ```

### Option 2 : Utiliser SSH (Plus sécurisé)

1. **Vérifier si vous avez une clé SSH :**
   ```bash
   ls -la ~/.ssh
   ```

2. **Si vous n'avez pas de clé SSH, en créer une :**
   ```bash
   ssh-keygen -t ed25519 -C "votre_email@example.com"
   # Appuyez sur Entrée pour accepter l'emplacement par défaut
   # Entrez une passphrase (optionnel mais recommandé)
   ```

3. **Ajouter la clé SSH à GitHub :**
   ```bash
   # Copier la clé publique
   cat ~/.ssh/id_ed25519.pub
   # Copiez la sortie complète
   ```
   - Allez sur : https://github.com/settings/keys
   - Cliquez sur **"New SSH key"**
   - Collez votre clé publique
   - Cliquez sur **"Add SSH key"**

4. **Changer l'URL du remote en SSH :**
   ```bash
   cd "/Users/david/Christelle Projet"
   git remote set-url origin git@github.com:Davidexauce/auxivie.git
   git push -u origin master
   ```

## 🔍 Vérification

Après avoir poussé, vérifiez que tout fonctionne :

```bash
git remote -v
git log --oneline -3
```

Visitez votre dépôt : https://github.com/Davidexauce/auxivie

## 💡 Astuce : Éviter les problèmes avec node_modules

Les fichiers dans `node_modules` ne devraient pas être suivis. Si vous voyez des modifications dans `node_modules`, ignorez-les :

```bash
# Vérifier que node_modules est bien dans .gitignore
cat .gitignore | grep node_modules

# Si des fichiers node_modules sont déjà suivis, les retirer :
git rm -r --cached backend/node_modules admin-dashboard/node_modules 2>/dev/null || true
git commit -m "Remove node_modules from tracking"
```

## 🆘 En cas de problème

Si vous rencontrez toujours des erreurs :

1. **Vérifier la connexion :**
   ```bash
   git ls-remote origin
   ```

2. **Vérifier l'URL du remote :**
   ```bash
   git remote -v
   ```

3. **Réessayer avec verbose pour voir l'erreur :**
   ```bash
   GIT_CURL_VERBOSE=1 GIT_TRACE=1 git push -u origin master
   ```


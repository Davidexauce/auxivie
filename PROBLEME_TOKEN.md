# ⚠️ Problème d'authentification GitHub

## Erreur rencontrée

```
remote: Permission to Davidexauce/auxivie.git denied to Davidexauce.
fatal: unable to access 'https://github.com/Davidexauce/auxivie.git/': The requested URL returned error: 403
```

## Causes possibles

1. **Token sans les bonnes permissions**
   - Le token doit avoir la permission `repo` (accès complet au dépôt)
   - Vérifiez sur : https://github.com/settings/tokens

2. **Token expiré ou révoqué**
   - Les tokens peuvent expirer ou être révoqués
   - Créez un nouveau token si nécessaire

3. **Format du token incorrect**
   - Les tokens GitHub commencent par `ghp_` (classic) ou `github_pat_` (fine-grained)
   - Votre token semble être un fine-grained token

## Solutions

### Solution 1 : Vérifier les permissions du token

1. Allez sur https://github.com/settings/tokens
2. Vérifiez que votre token a la permission **`repo`** (Repository access)
3. Pour un fine-grained token, vérifiez les permissions dans "Repository permissions"

### Solution 2 : Créer un nouveau token Classic

1. Allez sur https://github.com/settings/tokens/new
2. Sélectionnez "Generate new token (classic)"
3. Donnez-lui le nom "Auxivie Push"
4. Cochez la permission **`repo`** (toutes les permissions repo)
5. Cliquez sur "Generate token"
6. Copiez le token (il commence par `ghp_`)

### Solution 3 : Utiliser SSH (Recommandé pour production)

```bash
# Générer une clé SSH
ssh-keygen -t ed25519 -C "votre-email@example.com"

# Afficher la clé publique
cat ~/.ssh/id_ed25519.pub

# Ajouter la clé sur GitHub
# https://github.com/settings/keys

# Configurer Git pour utiliser SSH
cd /root/auxivie
git remote set-url origin git@github.com:Davidexauce/auxivie.git
git push origin master
```

### Solution 4 : Utiliser GitHub CLI

```bash
# Installer GitHub CLI
sudo apt update && sudo apt install gh -y

# S'authentifier
gh auth login

# Pousser
cd /root/auxivie
git push origin master
```

## État actuel

- **4 commits** en attente de push
- Dépôt configuré : `https://github.com/Davidexauce/auxivie.git`
- Copie locale : `/root/auxivie-backup-20251210-194726`

## Commits en attente

1. `feat: Ajout des fonctionnalités complètes du dashboard admin`
2. `docs: Ajout des instructions pour pousser sur GitHub`
3. `chore: Ajout script pour pousser sur GitHub`
4. `docs: Ajout README GitHub avec instructions complètes`

## Recommandation

Pour une solution rapide, utilisez **GitHub CLI** (`gh auth login`) qui gère l'authentification automatiquement.


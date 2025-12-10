# 📦 Instructions pour pousser sur GitHub

## ✅ État actuel

Le projet est prêt à être poussé sur GitHub :
- **2 commits** en attente de push
- Dépôt configuré : `https://github.com/Davidexauce/auxivie.git`
- Copie locale créée : `/root/auxivie-backup-20251210-194726`

## 🚀 Méthodes pour pousser

### Méthode 1 : Script automatique (Recommandé)

```bash
cd /root/auxivie
./push-to-github.sh VOTRE_TOKEN_GITHUB
```

### Méthode 2 : Token d'accès personnel

1. Créez un token sur [GitHub Settings > Tokens](https://github.com/settings/tokens)
2. Donnez-lui la permission `repo`
3. Poussez avec le token :

```bash
cd /root/auxivie
git push https://VOTRE_TOKEN@github.com/Davidexauce/auxivie.git master
```

### Méthode 3 : Configuration SSH

1. Générez une clé SSH :
```bash
ssh-keygen -t ed25519 -C "votre-email@example.com"
cat ~/.ssh/id_ed25519.pub
```

2. Ajoutez la clé sur [GitHub Settings > SSH Keys](https://github.com/settings/keys)

3. Changez l'URL du remote :
```bash
cd /root/auxivie
git remote set-url origin git@github.com:Davidexauce/auxivie.git
git push origin master
```

### Méthode 4 : GitHub CLI

```bash
# Installer GitHub CLI
sudo apt update
sudo apt install gh

# S'authentifier
gh auth login

# Pousser
cd /root/auxivie
git push origin master
```

## 📋 Commits en attente

1. `feat: Ajout des fonctionnalités complètes du dashboard admin`
   - Export CSV, pagination, notifications, graphiques
   - Version 1.2.0

2. `docs: Ajout des instructions pour pousser sur GitHub`
   - Documentation d'authentification

3. `chore: Ajout script pour pousser sur GitHub`
   - Script d'automatisation

## 🔗 Liens utiles

- **Dépôt GitHub** : https://github.com/Davidexauce/auxivie
- **Créer un token** : https://github.com/settings/tokens
- **SSH Keys** : https://github.com/settings/keys

## 📦 Copie de sauvegarde

Une copie complète du projet est disponible dans :
```
/root/auxivie-backup-20251210-194726
```

## ⚠️ Important

- Les fichiers `.env` et `node_modules` sont exclus du dépôt (via `.gitignore`)
- Les données sensibles ne seront pas poussées
- Le projet est prêt pour la production


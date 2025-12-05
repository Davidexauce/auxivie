# 🚀 Guide d'Installation et Configuration PM2

## 📦 Installation de PM2

PM2 est un gestionnaire de processus pour Node.js qui permet de :
- Démarrer/arrêter/redémarrer votre application
- Surveiller l'application en temps réel
- Redémarrer automatiquement en cas de crash
- Démarrer au boot du système

### Installation Globale

```bash
# Installer PM2 globalement
npm install -g pm2

# Vérifier l'installation
pm2 --version
```

---

## 🎯 Utilisation de Base

### Démarrer le Serveur

```bash
cd ~/backend/backend

# Démarrer avec PM2
pm2 start server.js --name auxivie-api

# Ou avec des variables d'environnement
pm2 start server.js --name auxivie-api --env production
```

### Commandes Utiles

```bash
# Voir la liste des processus
pm2 list

# Voir les logs en temps réel
pm2 logs auxivie-api

# Voir les logs des 100 dernières lignes
pm2 logs auxivie-api --lines 100

# Arrêter le serveur
pm2 stop auxivie-api

# Redémarrer le serveur
pm2 restart auxivie-api

# Supprimer le processus de PM2
pm2 delete auxivie-api

# Voir les informations détaillées
pm2 show auxivie-api

# Surveiller (CPU, mémoire, etc.)
pm2 monit
```

---

## 🔄 Redémarrage Automatique

### Sauvegarder la Configuration

```bash
# Sauvegarder la liste actuelle des processus
pm2 save
```

### Démarrer au Boot du Système

```bash
# Générer le script de démarrage automatique
pm2 startup

# Cette commande affichera une commande à exécuter avec sudo
# Exemple : sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u apiuser --hp /home/apiuser

# Exécutez la commande affichée, puis :
pm2 save
```

---

## 📊 Monitoring

### Voir les Statistiques

```bash
# Interface de monitoring en temps réel
pm2 monit

# Voir les métriques
pm2 status
```

### Logs

```bash
# Voir tous les logs
pm2 logs

# Voir les logs d'un processus spécifique
pm2 logs auxivie-api

# Voir les logs d'erreur uniquement
pm2 logs auxivie-api --err

# Voir les logs de sortie uniquement
pm2 logs auxivie-api --out

# Nettoyer les logs
pm2 flush
```

---

## 🔧 Configuration Avancée

### Fichier de Configuration PM2 (ecosystem.config.js)

Créez un fichier `ecosystem.config.js` dans `~/backend/backend/` :

```javascript
module.exports = {
  apps: [{
    name: 'auxivie-api',
    script: 'server.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
```

Puis démarrez avec :

```bash
pm2 start ecosystem.config.js
pm2 save
```

---

## 🛠️ Dépannage

### Si PM2 ne démarre pas au boot

```bash
# Réinstaller le script de démarrage
pm2 unstartup
pm2 startup
pm2 save
```

### Si le serveur ne répond pas

```bash
# Vérifier le statut
pm2 status

# Voir les logs d'erreur
pm2 logs auxivie-api --err

# Redémarrer
pm2 restart auxivie-api
```

### Réinitialiser PM2

```bash
# Arrêter tous les processus
pm2 kill

# Redémarrer PM2
pm2 resurrect
```

---

## 📋 Checklist de Configuration

- [ ] PM2 installé globalement
- [ ] Serveur démarré avec PM2
- [ ] Configuration sauvegardée (`pm2 save`)
- [ ] Démarrage automatique configuré (`pm2 startup`)
- [ ] Logs vérifiés (`pm2 logs auxivie-api`)
- [ ] Serveur accessible (`curl http://localhost:3001`)

---

## 🎯 Commandes Rapides

```bash
# Installation
npm install -g pm2

# Démarrer
cd ~/backend/backend
pm2 start server.js --name auxivie-api

# Sauvegarder et configurer le démarrage automatique
pm2 save
pm2 startup
# (Exécutez la commande affichée avec sudo)

# Vérifier
pm2 status
pm2 logs auxivie-api
```

---

**Une fois PM2 installé et configuré, votre serveur redémarrera automatiquement en cas de crash ou de redémarrage du VPS !**


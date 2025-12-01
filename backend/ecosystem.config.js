// Configuration PM2 pour le backend
// Installation: npm install -g pm2
// Utilisation: pm2 start ecosystem.config.js

module.exports = {
  apps: [{
    name: 'auxivie-backend',
    script: 'server.js',
    instances: 1, // Pour commencer, utilisez 1 instance
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'development',
      PORT: 3001
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    // Options de redémarrage
    watch: false, // Ne pas surveiller les fichiers en production
    max_memory_restart: '500M',
    // Gestion des erreurs
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    log_file: './logs/pm2-combined.log',
    time: true,
    // Redémarrage automatique
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s',
    // Variables d'environnement depuis .env
    env_file: '.env.production'
  }]
};


# 📧 Configuration de l'envoi d'emails

## Configuration requise

Pour que les emails soient envoyés depuis le dashboard admin avec l'adresse expéditrice **contact@auxivie.org**, vous devez configurer les variables d'environnement suivantes dans votre fichier `.env` ou `.env.production` du backend :

```env
# Configuration SMTP
SMTP_HOST=smtp.votre-serveur.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe_smtp
```

## Paramètres SMTP

- **SMTP_HOST** : L'adresse du serveur SMTP (ex: `smtp.gmail.com`, `smtp.office365.com`, `mail.auxivie.org`)
- **SMTP_PORT** : Le port SMTP (généralement `587` pour TLS ou `465` pour SSL)
- **SMTP_SECURE** : `true` pour SSL (port 465), `false` pour TLS (port 587)
- **SMTP_USER** : L'adresse email utilisée pour l'authentification (doit être `contact@auxivie.org` ou une adresse autorisée)
- **SMTP_PASS** : Le mot de passe de l'adresse email

## ⚠️ Important

**L'adresse expéditrice est TOUJOURS `contact@auxivie.org`**, peu importe la configuration SMTP. C'est codé en dur dans le module `email.js` pour garantir que tous les emails envoyés depuis le dashboard admin utilisent cette adresse.

## Exemples de configuration

### Gmail (avec mot de passe d'application)
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe_application
```

### Office 365 / Outlook
```env
SMTP_HOST=smtp.office365.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe
```

### Serveur SMTP personnalisé
```env
SMTP_HOST=mail.auxivie.org
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe
```

## Fonctionnement

Lorsqu'un administrateur envoie un message depuis le dashboard admin :

1. Le message est enregistré dans la base de données
2. Un email de notification est automatiquement envoyé à l'utilisateur destinataire
3. L'email est envoyé depuis **contact@auxivie.org** (adresse expéditrice fixe)
4. L'email contient le contenu du message dans un format HTML professionnel

## Notes importantes

- L'adresse expéditrice est **toujours** `contact@auxivie.org`, peu importe la configuration SMTP
- Si les variables SMTP ne sont pas configurées, un avertissement sera affiché mais l'application continuera de fonctionner (le message sera enregistré mais l'email ne sera pas envoyé)
- Les erreurs d'envoi d'email n'empêchent pas l'enregistrement du message dans la base de données
- Les logs d'envoi d'email sont disponibles dans les logs PM2 : `pm2 logs api`

## Vérification

Pour vérifier que l'envoi d'emails fonctionne :

1. Configurez les variables SMTP dans `.env` ou `.env.production`
2. Redémarrez le serveur : `pm2 restart api`
3. Envoyez un message depuis le dashboard admin
4. Vérifiez les logs : `pm2 logs api` (vous devriez voir "✅ Email envoyé")
5. Vérifiez la boîte mail du destinataire

---

**Fichier:** `/root/auxivie/backend/email.js`  
**Module:** `email.js`  
**Expéditeur fixe:** `contact@auxivie.org`


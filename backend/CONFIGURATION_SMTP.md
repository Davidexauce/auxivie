# ⚙️ Configuration SMTP - Instructions

## ✅ Variables SMTP ajoutées

Les variables SMTP ont été ajoutées dans les fichiers suivants :
- `/root/auxivie/backend/.env`
- `/root/auxivie/backend/.env.production`

## 📝 Action requise : Remplacer les valeurs par défaut

Les variables ont été ajoutées avec des valeurs par défaut. **Vous devez les remplacer par vos vraies valeurs SMTP** :

### Fichier : `/root/auxivie/backend/.env` et `.env.production`

```env
# Configuration SMTP pour l'envoi d'emails
# L'adresse expéditrice est toujours contact@auxivie.org
SMTP_HOST=smtp.votre-serveur.com    # ⚠️ À remplacer par votre serveur SMTP
SMTP_PORT=587                        # ⚠️ À vérifier (587 pour TLS, 465 pour SSL)
SMTP_SECURE=false                    # ⚠️ true pour SSL (port 465), false pour TLS (port 587)
SMTP_USER=contact@auxivie.org        # ✅ Déjà correct
SMTP_PASS=votre_mot_de_passe_smtp    # ⚠️ À remplacer par le vrai mot de passe
```

## 🔧 Exemples de configuration

### Si vous utilisez Gmail
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe_application_gmail
```

### Si vous utilisez Office 365 / Outlook
```env
SMTP_HOST=smtp.office365.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe_outlook
```

### Si vous utilisez un serveur SMTP personnalisé (ex: Hostinger)
```env
SMTP_HOST=mail.auxivie.org
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe_email
```

## 🚀 Après modification

1. **Modifiez les valeurs** dans `.env` et `.env.production`
2. **Redémarrez le serveur** :
   ```bash
   cd /root/auxivie
   pm2 restart api --update-env
   ```
3. **Vérifiez les logs** :
   ```bash
   pm2 logs api
   ```

## ✅ Vérification

Pour tester que l'envoi d'emails fonctionne :

1. Envoyez un message depuis le dashboard admin
2. Vérifiez les logs : `pm2 logs api`
   - Vous devriez voir : `✅ Email envoyé: [messageId]`
3. Vérifiez la boîte mail du destinataire
4. Vérifiez que l'expéditeur est bien `contact@auxivie.org`

## ⚠️ Important

- **L'expéditeur est toujours `contact@auxivie.org`** (codé en dur dans `email.js`)
- Si les variables SMTP ne sont pas correctement configurées, un avertissement s'affichera dans les logs
- Les erreurs d'envoi d'email n'empêchent pas l'enregistrement du message dans la base de données

---

**Dernière mise à jour:** 10 Décembre 2025


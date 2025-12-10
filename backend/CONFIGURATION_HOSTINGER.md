# 📧 Configuration SMTP Hostinger

## ✅ Configuration appliquée

Les paramètres SMTP ont été configurés pour Hostinger dans :
- `/root/auxivie/backend/.env`
- `/root/auxivie/backend/.env.production`

### Paramètres configurés

```env
SMTP_HOST=mail.auxivie.org
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@auxivie.org
SMTP_PASS=votre_mot_de_passe_smtp
```

## ⚠️ Action requise : Ajouter le mot de passe

**Vous devez maintenant remplacer `votre_mot_de_passe_smtp` par le vrai mot de passe de l'email `contact@auxivie.org`**

### Comment faire :

1. **Ouvrez les fichiers** :
   ```bash
   nano /root/auxivie/backend/.env
   nano /root/auxivie/backend/.env.production
   ```

2. **Trouvez la ligne** :
   ```
   SMTP_PASS=votre_mot_de_passe_smtp
   ```

3. **Remplacez par** :
   ```
   SMTP_PASS=votre_vrai_mot_de_passe
   ```

4. **Sauvegardez** (Ctrl+X, puis Y, puis Entrée)

5. **Redémarrez le serveur** :
   ```bash
   cd /root/auxivie
   pm2 restart api --update-env
   ```

## 🔧 Paramètres Hostinger

### Configuration standard Hostinger :
- **SMTP Host:** `mail.auxivie.org` ou `smtp.hostinger.com`
- **SMTP Port:** `587` (TLS) ou `465` (SSL)
- **SMTP Secure:** `false` pour port 587, `true` pour port 465
- **Username:** `contact@auxivie.org`
- **Password:** Le mot de passe de votre email Hostinger

### Alternative : Si mail.auxivie.org ne fonctionne pas

Si `mail.auxivie.org` ne fonctionne pas, essayez :
```env
SMTP_HOST=smtp.hostinger.com
```

## ✅ Vérification

Après avoir ajouté le mot de passe et redémarré :

1. **Vérifiez les logs** :
   ```bash
   pm2 logs api
   ```
   - Si vous voyez `⚠️ Variables SMTP non configurées`, le mot de passe n'est pas correct
   - Si vous voyez `✅ Email envoyé`, ça fonctionne !

2. **Testez l'envoi** :
   - Envoyez un message depuis le dashboard admin
   - Vérifiez la boîte mail du destinataire
   - L'expéditeur doit être `contact@auxivie.org`

## 🔐 Sécurité

⚠️ **Important** : Ne partagez jamais le fichier `.env` qui contient le mot de passe !

---

**Dernière mise à jour:** 10 Décembre 2025


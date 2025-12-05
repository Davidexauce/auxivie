# 📦 Résumé - Upload Base de Données sur Hostinger

## ✅ Fichier Prêt

**Fichier :** `backend/data/auxivie.db`  
**Taille :** 80 KB  
**Tables :** 13 tables (users, reservations, messages, documents, payments, etc.)  
**Données :** 4 utilisateurs actuellement

---

## 🚀 Méthode la Plus Simple

### Via File Manager Hostinger

1. **Accéder au File Manager**
   - hPanel → Files → File Manager

2. **Naviguer vers le backend**
   - Aller dans `domains/auxivie.org/backend/` (ou où se trouve votre backend)

3. **Créer le dossier `data/`** (s'il n'existe pas)
   - Clic droit → New Folder → `data`

4. **Uploader `auxivie.db`**
   - Ouvrir le dossier `data/`
   - Cliquer "Upload"
   - Sélectionner `backend/data/auxivie.db` depuis votre ordinateur

5. **Configurer les permissions**
   - Clic droit sur `auxivie.db` → Change Permissions → `644` ou `666`

6. **Redémarrer le backend**
   - Dans Node.js Apps → Restart

---

## 📍 Emplacement Final sur Hostinger

```
backend/
  ├── server.js
  ├── data/
  │   └── auxivie.db  ← Ici (80 KB)
  ├── package.json
  └── ...
```

---

## ✅ Vérification

Après l'upload et le redémarrage :

1. Vérifier les logs (pas d'erreur "Cannot open database")
2. Tester : `https://api.auxivie.org/api/users?userType=professionnel`
3. Vérifier dans le dashboard que les données s'affichent

---

## 📚 Documentation Complète

- **Guide détaillé :** `GUIDE_IMPORT_BDD_HOSTINGER.md`
- **Instructions rapides :** `backend/INSTRUCTIONS_UPLOAD_BDD.md`

---

**Le fichier est prêt à être uploadé ! 🚀**


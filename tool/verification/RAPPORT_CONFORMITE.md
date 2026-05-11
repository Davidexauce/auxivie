# Rapport de vérification de conformité — Aidalya (app Flutter)

**Date indicative du rapport :** 2026-05-09  
**Périmètre :** application mobile (`App flutter Auxivie`), documents légaux embarqués, configuration iOS/Android ; rappels backend (`Christelle Projet`) lorsque pertinent.

Ce document est une **auto-évaluation** : il ne remplace pas un audit juridique ni une revue App Store officielle.

---

## 1. Identification produit & marque

| Élément | Statut |
|--------|--------|
| Nom affiché iOS (`CFBundleDisplayName`) | **Aidalya** |
| Nom Android (`android:label`) | **Aidalya** |
| Politique de confidentialité embarquée | **Aidalya** (entête du fichier) |
| ATS exception domaine `auxivie.org` | Conservé (cohérent avec l’API actuelle) |

**À suivre :** harmoniser partout le vocabulaire métier (CGU, stores, site) si la marque publique est uniquement « Aidalya ».

---

## 2. RGPD / vie privée (mobile)

| Exigence | Évaluation | Détail |
|----------|------------|--------|
| Politique accessible in-app | **Conforme** | `LegalInfoScreen`, lien depuis consentement |
| Consentement cookies / usages optionnels | **Partiel** | Écran CMP local (`ConsentService`) : analytics / marketing stockés en prefs. **Aucun SDK analytics/marketing identifié dans `pubspec.yaml`** → les interrupteurs ne pilotent pas encore un service tiers ; la politique évoque analytics possibles — rester cohérent (activer un SDK seulement si case cochée, ou ajuster le texte). |
| Données sensibles / santé | **Documenté** | Politique §4 — limitation et vigilance |
| Paiements tiers | **Documenté** | Stripe §3.2 |
| Droits utilisateurs (accès, rectification, suppression…) | **Documenté** | Politique § droits |
| Suppression de compte | **À valider côté prod** | App : flux UI + `DELETE /users/:id`. Backend Christelle : route ajoutée ; migration SQL **`rib`** et déploiement à confirmer sur serveur réel. |
| Hébergement IBAN / RIB | **À documenter** | Traitement côté profil + backend `rib`. La politique pourrait mentionner explicitement **coordonnées bancaires / IBAN** dans § données collectées (transparence RGPD). |

---

## 3. Apple App Store (références utiles)

| Sujet | Évaluation | Notes |
|-------|------------|--------|
| Guideline 5.1.1 — Purpose strings | **Corrigé dans cette passe** | Suppression de **NSContactsUsageDescription** : aucune dépendance « contacts » dans l’app → éviter une chaîne trompeuse. |
| Guideline 5.1.1 — Suppression compte | **À tester E2E** | Flux présent ; backend doit répondre 204 sur suppression. |
| Guideline 3.1.x — Paiements | **Stripe in-app** | Vérifier affichage CGU / confidentialité pour tout achat ou abonnement si vous en ajoutez. |
| ATT / IDFA | **Non applicable actuellement** | Pas de référence App Tracking Transparency dans le projet. |
| Captures & métadonnées | **Hors code** | Captures = usage réel de l’app (cf. retours Apple précédents). |

---

## 4. Google Play (Android)

| Sujet | Évaluation |
|-------|------------|
| Déclaration Data Safety (Play Console) | **Hors dépôt** — à remplir selon collecte réelle (compte, messages, paiements, crash logs si ajoutés). |
| Permissions manifest | INTERNET, caméra, stockage / médias, réseau — **alignées** usages documents & photos. Pas de READ_CONTACTS Android. |

---

## 5. Alignement technique app ↔ API (rappel)

À confirmer sur l’environnement déployé :

- `DELETE https://…/api/users/:id` (JWT) — suppression compte  
- `PUT https://…/api/users/:id` avec champ **`rib`** si besoin  
- Colonne MySQL **`users.rib`** (script `migration_add_rib_to_users.sql`)  
- `DELETE https://…/api/reservations/:id` avec contrôle famille / pro / admin  

---

## 6. Synthèse — priorités

1. **Production :** appliquer migration `rib`, déployer `server.js`, tester suppression compte et enregistrement RIB.  
2. **Politique de confidentialité :** ajouter un paragraphe sur **coordonnées bancaires (IBAN/RIB)** si vous les stockez.  
3. **Consentement analytics :** soit brancher un outil respectant le choix utilisateur, soit assouplir la formulation juridique tant qu’aucun outil n’est intégré.  
4. **Stores :** Data Safety Play ; fiche App Store Privacy Nutrition Labels cohérentes avec la réalité.

---

*Document généré pour suivi interne — mise à jour recommandée après chaque évolution majeure (paiement, tracking, nouvelle permission).*

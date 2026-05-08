-- À exécuter sur une base MySQL existante (Hostinger, etc.) si la colonne n'existe pas encore.
-- ALTER IGNORE évite l'erreur si la colonne est déjà présente (selon version MySQL / droits).

ALTER TABLE `users`
  ADD COLUMN `rib` VARCHAR(34) DEFAULT NULL COMMENT 'IBAN / RIB pour versements' AFTER `particularite`;

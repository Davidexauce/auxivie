-- Corrige les noms où un « 0 » a été concaténé par erreur (JS : name + experience avec experience = 0).
-- Exemple : « Anne Sophie0 » → « Anne Sophie »
UPDATE users
SET name = TRIM(TRAILING '0' FROM name)
WHERE experience = 0
  AND name LIKE '%0'
  AND CHAR_LENGTH(name) > 2
  AND name NOT LIKE '%00';

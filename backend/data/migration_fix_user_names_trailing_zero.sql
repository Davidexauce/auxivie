-- Corrige les noms où un « 0 » a été concaténé par erreur (JS : name + experience).
-- Exemple : « Anne Sophie0 » → « Anne Sophie » (même si experience n'est plus 0 en base)
UPDATE users
SET name = TRIM(TRAILING '0' FROM name)
WHERE name REGEXP '[[:alpha:]]0$'
  AND CHAR_LENGTH(name) > 2
  AND name NOT LIKE '%00';

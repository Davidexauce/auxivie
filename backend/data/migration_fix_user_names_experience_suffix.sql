-- Retire les chiffres d'expérience concaténés par erreur au nom (ex. "Anne Sophie9", "Zidi2019").
-- À exécuter une fois sur la base de production.

UPDATE users
SET name = TRIM(LEFT(name, CHAR_LENGTH(name) - CHAR_LENGTH(CAST(experience AS CHAR))))
WHERE experience IS NOT NULL
  AND experience > 0
  AND name REGEXP CONCAT('[0-9]+$', CAST(experience AS CHAR))
  AND name LIKE CONCAT('%', CAST(experience AS CHAR));

UPDATE users
SET name = TRIM(LEFT(name, CHAR_LENGTH(name) - 1))
WHERE name REGEXP '[A-Za-zÀ-ÿ]0$'
  AND (experience IS NULL OR experience = 0);

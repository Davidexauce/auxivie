/**
 * Construit et nettoie le nom affiché utilisateur.
 * Corrige l'ancien bug : en JS, "Prénom Nom" + 0 → "Prénom Nom0".
 */

/** Retire le « 0 » final parasite (ex. "Anne Sophie" + 0 en JS → "Anne Sophie0"). */
function stripErroneousTrailingZero(name) {
  if (!name || typeof name !== 'string') return name || '';
  const trimmed = name.trim();
  if (trimmed.length < 2 || !trimmed.endsWith('0')) return trimmed;
  const charBefore = trimmed.charAt(trimmed.length - 2);
  // Ne pas toucher aux noms qui se terminent par un chiffre (ex. "Pro10")
  if (/[0-9]/.test(charBefore)) return trimmed;
  const without = trimmed.slice(0, -1);
  if (!without || without.endsWith(' ')) return trimmed;
  return without;
}

/** Retire les années d'expérience concaténées par erreur (ex. "Zidi2019"). */
function stripExperienceSuffix(name, experience) {
  if (!name || experience === undefined || experience === null || experience === '') {
    return name;
  }
  const expStr = String(experience).trim();
  if (!expStr || !/^\d+$/.test(expStr)) return name;
  if (name.endsWith(expStr) && name.length > expStr.length) {
    const before = name.slice(0, -expStr.length).trimEnd();
    if (before.length > 0) return before;
  }
  return name;
}

/**
 * Nom à enregistrer à partir du corps d'une requête (sync / PUT).
 */
function resolveUserDisplayName(body) {
  const firstName =
    body.firstName != null && String(body.firstName).trim() !== ''
      ? String(body.firstName).trim()
      : '';
  const lastName =
    body.lastName != null && String(body.lastName).trim() !== ''
      ? String(body.lastName).trim()
      : '';

  let name =
    body.name != null && String(body.name).trim() !== ''
      ? String(body.name).trim()
      : '';

  if (!name) {
    if (firstName && lastName) name = `${firstName} ${lastName}`;
    else if (firstName) name = firstName;
    else if (lastName) name = lastName;
  }

  name = stripErroneousTrailingZero(name);
  name = stripExperienceSuffix(name, body.experience);
  return name.slice(0, 255);
}

/** Nom pour les réponses API / dashboard (données déjà en base). */
function formatUserDisplayName(row) {
  if (!row) return '';
  const exp = row.experience;
  let firstName = stripErroneousTrailingZero(
    row.firstName != null ? String(row.firstName).trim() : ''
  );
  let lastName = stripErroneousTrailingZero(
    row.lastName != null ? String(row.lastName).trim() : ''
  );
  firstName = stripExperienceSuffix(firstName, exp);
  lastName = stripExperienceSuffix(lastName, exp);
  if (firstName || lastName) {
    return [firstName, lastName].filter(Boolean).join(' ');
  }
  let name = stripErroneousTrailingZero(row.name != null ? String(row.name) : '');
  return stripExperienceSuffix(name, exp);
}

module.exports = {
  resolveUserDisplayName,
  formatUserDisplayName,
  stripErroneousTrailingZero,
};

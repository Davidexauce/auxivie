/**
 * Construit et nettoie le nom affiché utilisateur.
 * Corrige l'ancien bug : en JS, "Prénom Nom" + 0 → "Prénom Nom0".
 */

function isZeroExperience(experience) {
  if (experience === undefined || experience === null || experience === '') {
    return false;
  }
  const n = parseInt(String(experience), 10);
  return Number.isFinite(n) && n === 0;
}

/** Retire le « 0 » final ajouté par erreur (concaténation avec experience = 0). */
function stripErroneousTrailingZero(name, experience) {
  if (!name || typeof name !== 'string') return name || '';
  const trimmed = name.trim();
  if (!isZeroExperience(experience)) return trimmed;
  if (trimmed.length < 2 || !trimmed.endsWith('0')) return trimmed;
  const without = trimmed.slice(0, -1);
  if (!without || without.endsWith(' ')) return trimmed;
  return without;
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

  name = stripErroneousTrailingZero(name, body.experience);
  return name.slice(0, 255);
}

/** Nom pour les réponses API / dashboard (données déjà en base). */
function formatUserDisplayName(row) {
  if (!row) return '';
  const firstName = row.firstName != null ? String(row.firstName).trim() : '';
  const lastName = row.lastName != null ? String(row.lastName).trim() : '';
  if (firstName || lastName) {
    return [firstName, lastName].filter(Boolean).join(' ');
  }
  return stripErroneousTrailingZero(
    row.name != null ? String(row.name) : '',
    row.experience
  );
}

module.exports = {
  resolveUserDisplayName,
  formatUserDisplayName,
  stripErroneousTrailingZero,
  isZeroExperience,
};

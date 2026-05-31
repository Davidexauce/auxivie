/**
 * Affichage du nom utilisateur (corrige le « 0 » ou chiffres d'expérience collés au nom).
 */

/** Retire un « 0 » final parasite après une lettre (ex. "Sophie0"). */
export function stripErroneousTrailingZero(name) {
  if (!name || typeof name !== 'string') return name || '';
  const trimmed = name.trim();
  if (trimmed.length < 2 || !trimmed.endsWith('0')) return trimmed;
  const charBefore = trimmed.charAt(trimmed.length - 2);
  if (/[0-9]/.test(charBefore)) return trimmed;
  const without = trimmed.slice(0, -1);
  if (!without || without.endsWith(' ')) return trimmed;
  return without;
}

/** Retire l'années d'expérience si elle a été concaténée au nom (ex. "Zidi2019", "Anne Sophie9"). */
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

export function displayUserName(user) {
  if (!user) return '';
  const experience = user.experience;

  let firstName = user.firstName != null ? String(user.firstName).trim() : '';
  let lastName = user.lastName != null ? String(user.lastName).trim() : '';
  firstName = stripExperienceSuffix(stripErroneousTrailingZero(firstName), experience);
  lastName = stripExperienceSuffix(stripErroneousTrailingZero(lastName), experience);

  if (firstName || lastName) {
    return [firstName, lastName].filter(Boolean).join(' ');
  }

  let name = user.name != null ? String(user.name).trim() : '';
  name = stripErroneousTrailingZero(name);
  name = stripExperienceSuffix(name, experience);
  return name;
}

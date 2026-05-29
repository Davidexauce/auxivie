/**
 * Affichage du nom utilisateur (corrige le « 0 » final si experience = 0).
 */
export function displayUserName(user) {
  if (!user) return '';
  const firstName = user.firstName != null ? String(user.firstName).trim() : '';
  const lastName = user.lastName != null ? String(user.lastName).trim() : '';
  if (firstName || lastName) {
    return [firstName, lastName].filter(Boolean).join(' ');
  }
  let name = user.name != null ? String(user.name).trim() : '';
  const exp = user.experience;
  const expIsZero = exp === 0 || exp === '0';
  if (expIsZero && name.length > 2 && name.endsWith('0')) {
    const without = name.slice(0, -1);
    if (without && !without.endsWith(' ')) name = without;
  }
  return name;
}

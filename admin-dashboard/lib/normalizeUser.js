import { displayUserName } from './displayUserName';

/** Normalise un utilisateur API pour l'affichage (nom sans chiffre parasite). */
export function normalizeUser(user) {
  if (!user || typeof user !== 'object') return user;
  const cleanName = displayUserName(user);
  return {
    ...user,
    name: cleanName,
  };
}

export function normalizeUsers(users) {
  if (!Array.isArray(users)) return [];
  return users.map(normalizeUser);
}

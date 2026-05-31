/**
 * Paramètres plateforme Aidalya (dashboard admin + app mobile).
 */

const DEFAULT_SETTINGS = {
  platformFee: 15,
  cancellationDelay: 24,
  contactEmail: 'contact@auxivie.org',
  supportPhone: '+33 6 52 24 85 94',
  minReservationHours: 2,
  maxReservationHours: 24,
  stripePublicKey: '',
  stripeMode: 'test',
  autoApproveDocuments: false,
  sendEmailNotifications: true,
  sendSMSNotifications: false,
  maxLoginAttempts: 5,
  lockoutDuration: 30,
  sessionTimeout: 24,
  require2FA: false,
  maintenanceMode: false,
  debugMode: false,
};

const PUBLIC_KEYS = [
  'platformFee',
  'cancellationDelay',
  'contactEmail',
  'supportPhone',
  'minReservationHours',
  'maxReservationHours',
  'stripePublicKey',
  'stripeMode',
  'maintenanceMode',
  'debugMode',
];

function toBool(value, fallback) {
  if (typeof value === 'boolean') return value;
  if (value === 1 || value === '1' || value === 'true') return true;
  if (value === 0 || value === '0' || value === 'false') return false;
  return fallback;
}

function toNumber(value, fallback) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

/** Ignore les valeurs corrompues (ex. `0` en base) et les clés non Stripe. */
function normalizeStripePublicKey(value) {
  if (value == null) return '';
  const s = String(value).trim();
  if (!s || s === '0') return '';
  if (!s.startsWith('pk_test_') && !s.startsWith('pk_live_')) return '';
  return s;
}

function mergeSettings(stored) {
  const base = { ...DEFAULT_SETTINGS };
  if (!stored || typeof stored !== 'object' || Array.isArray(stored)) {
    return base;
  }
  return {
    ...base,
    platformFee: toNumber(stored.platformFee, base.platformFee),
    cancellationDelay: toNumber(stored.cancellationDelay, base.cancellationDelay),
    contactEmail:
      stored.contactEmail != null ? String(stored.contactEmail).trim() : base.contactEmail,
    supportPhone:
      stored.supportPhone != null ? String(stored.supportPhone).trim() : base.supportPhone,
    minReservationHours: toNumber(stored.minReservationHours, base.minReservationHours),
    maxReservationHours: toNumber(stored.maxReservationHours, base.maxReservationHours),
    stripePublicKey:
      normalizeStripePublicKey(stored.stripePublicKey) ||
      normalizeStripePublicKey(process.env.STRIPE_PUBLISHABLE_KEY) ||
      base.stripePublicKey,
    stripeMode: stored.stripeMode === 'production' ? 'production' : 'test',
    autoApproveDocuments: toBool(stored.autoApproveDocuments, base.autoApproveDocuments),
    sendEmailNotifications: toBool(stored.sendEmailNotifications, base.sendEmailNotifications),
    sendSMSNotifications: toBool(stored.sendSMSNotifications, base.sendSMSNotifications),
    maxLoginAttempts: toNumber(stored.maxLoginAttempts, base.maxLoginAttempts),
    lockoutDuration: toNumber(stored.lockoutDuration, base.lockoutDuration),
    sessionTimeout: toNumber(stored.sessionTimeout, base.sessionTimeout),
    require2FA: toBool(stored.require2FA, base.require2FA),
    maintenanceMode: toBool(stored.maintenanceMode, base.maintenanceMode),
    debugMode: toBool(stored.debugMode, base.debugMode),
  };
}

function sanitizePublicSettings(settings) {
  const out = {};
  for (const key of PUBLIC_KEYS) {
    if (settings[key] !== undefined) out[key] = settings[key];
  }
  return out;
}

function validateSettings(body) {
  const errors = [];
  const rawPk = body?.stripePublicKey;
  if (
    rawPk != null &&
    String(rawPk).trim() !== '' &&
    !normalizeStripePublicKey(rawPk)
  ) {
    errors.push('Clé publique Stripe invalide (attendu pk_test_... ou pk_live_...).');
  }
  const s = mergeSettings(body);

  if (s.platformFee < 0 || s.platformFee > 50) {
    errors.push('La commission doit être entre 0 et 50 %.');
  }
  if (s.cancellationDelay < 1 || s.cancellationDelay > 168) {
    errors.push('Le délai d’annulation gratuite doit être entre 1 et 168 heures.');
  }
  if (!s.contactEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s.contactEmail)) {
    errors.push('Email de contact invalide.');
  }
  if (s.minReservationHours < 1 || s.minReservationHours > 72) {
    errors.push('Durée minimale de réservation : entre 1 et 72 h.');
  }
  if (s.maxReservationHours < s.minReservationHours || s.maxReservationHours > 168) {
    errors.push('La durée maximale doit être supérieure à la minimale (max 168 h).');
  }
  if (s.maxLoginAttempts < 3 || s.maxLoginAttempts > 20) {
    errors.push('Tentatives de connexion : entre 3 et 20.');
  }
  if (s.lockoutDuration < 5 || s.lockoutDuration > 1440) {
    errors.push('Durée de verrouillage : entre 5 et 1440 minutes.');
  }
  if (s.sessionTimeout < 1 || s.sessionTimeout > 168) {
    errors.push('Durée de session : entre 1 et 168 heures.');
  }
  if (s.stripeMode !== 'test' && s.stripeMode !== 'production') {
    errors.push('Mode Stripe invalide.');
  }
  return { ok: errors.length === 0, errors, settings: s };
}

module.exports = {
  DEFAULT_SETTINGS,
  PUBLIC_KEYS,
  normalizeStripePublicKey,
  mergeSettings,
  sanitizePublicSettings,
  validateSettings,
};

/** Valeurs par défaut alignées sur l’app mobile (SettingsModel.defaults). */
export const DEFAULT_SETTINGS = {
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

export function mergeWithDefaults(data) {
  return { ...DEFAULT_SETTINGS, ...(data && typeof data === 'object' ? data : {}) };
}

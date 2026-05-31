import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { settingsAPI } from '../lib/api';
import { mergeWithDefaults } from '../lib/defaultSettings';
import styles from '../styles/Settings.module.css';

function Toggle({ id, label, description, checked, onChange }) {
  return (
    <div className={styles.toggleRow}>
      <div>
        <div className={styles.toggleLabel}>{label}</div>
        {description && <p className={styles.toggleDesc}>{description}</p>}
      </div>
      <label className={styles.switch} htmlFor={id}>
        <input
          id={id}
          type="checkbox"
          checked={checked}
          onChange={(e) => onChange(e.target.checked)}
        />
        <span className={styles.slider} />
      </label>
    </div>
  );
}

export default function Settings() {
  const router = useRouter();
  const [settings, setSettings] = useState(null);
  const [updatedAt, setUpdatedAt] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }
    loadSettings();
  }, [router]);

  const loadSettings = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await settingsAPI.get();
      const meta = data?._meta;
      const clean = { ...data };
      delete clean._meta;
      setSettings(mergeWithDefaults(clean));
      setUpdatedAt(meta?.updatedAt ?? null);
    } catch (err) {
      console.error(err);
      setError('Impossible de charger les paramètres.');
      setSettings(mergeWithDefaults({}));
    } finally {
      setLoading(false);
    }
  };

  const update = (key, value) => {
    setSettings((prev) => ({ ...prev, [key]: value }));
  };

  const handleNumber = (key) => (e) => {
    const v = e.target.value;
    update(key, v === '' ? '' : Number(v));
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess(false);
    setSaving(true);
    try {
      const payload = { ...settings };
      Object.keys(payload).forEach((k) => {
        if (payload[k] === '') payload[k] = 0;
      });
      const res = await settingsAPI.update(payload);
      if (res.settings) {
        setSettings(mergeWithDefaults(res.settings));
      }
      setSuccess(true);
      setTimeout(() => setSuccess(false), 4000);
      loadSettings();
    } catch (err) {
      setError(err.message || 'Erreur lors de la sauvegarde');
    } finally {
      setSaving(false);
    }
  };

  const handleResetDefaults = () => {
    if (confirm('Réinitialiser tous les champs aux valeurs par défaut ? (non enregistré tant que vous ne sauvegardez pas)')) {
      setSettings(mergeWithDefaults({}));
    }
  };

  if (loading || !settings) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement des paramètres...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.page}>
        <header className={styles.header}>
          <h1 className={styles.title}>Paramètres</h1>
          <p className={styles.subtitle}>
            Configuration de la plateforme Aidalya (app mobile et administration).
            {updatedAt && (
              <> Dernière mise à jour : {new Date(updatedAt).toLocaleString('fr-FR')}.</>
            )}
          </p>
        </header>

        {error && <div className={styles.alertError}>{error}</div>}
        {success && (
          <div className={styles.alertSuccess}>Paramètres enregistrés avec succès.</div>
        )}

        <form onSubmit={handleSave}>
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Général & réservations</h2>
            <p className={styles.sectionDesc}>
              Commission, contacts support et règles de durée / annulation.
            </p>
            <div className={styles.grid}>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="platformFee">
                  Commission plateforme (%)
                </label>
                <input
                  id="platformFee"
                  type="number"
                  min={0}
                  max={50}
                  step={0.5}
                  className={styles.input}
                  value={settings.platformFee}
                  onChange={handleNumber('platformFee')}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="cancellationDelay">
                  Annulation gratuite (heures avant)
                </label>
                <input
                  id="cancellationDelay"
                  type="number"
                  min={1}
                  max={168}
                  className={styles.input}
                  value={settings.cancellationDelay}
                  onChange={handleNumber('cancellationDelay')}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="minReservationHours">
                  Durée min. réservation (h)
                </label>
                <input
                  id="minReservationHours"
                  type="number"
                  min={1}
                  max={72}
                  className={styles.input}
                  value={settings.minReservationHours}
                  onChange={handleNumber('minReservationHours')}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="maxReservationHours">
                  Durée max. réservation (h)
                </label>
                <input
                  id="maxReservationHours"
                  type="number"
                  min={1}
                  max={168}
                  className={styles.input}
                  value={settings.maxReservationHours}
                  onChange={handleNumber('maxReservationHours')}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="contactEmail">
                  Email de contact
                </label>
                <input
                  id="contactEmail"
                  type="email"
                  className={styles.input}
                  value={settings.contactEmail}
                  onChange={(e) => update('contactEmail', e.target.value)}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="supportPhone">
                  Téléphone support
                </label>
                <input
                  id="supportPhone"
                  type="tel"
                  className={styles.input}
                  value={settings.supportPhone}
                  onChange={(e) => update('supportPhone', e.target.value)}
                />
              </div>
            </div>
          </section>

          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Paiements Stripe</h2>
            <p className={styles.sectionDesc}>
              Clé publique affichée dans l’app (jamais la clé secrète).
            </p>
            <div className={styles.grid}>
              <div className={`${styles.field} ${styles.fieldFull}`}>
                <label className={styles.label} htmlFor="stripePublicKey">
                  Clé publique Stripe
                </label>
                <input
                  id="stripePublicKey"
                  type="text"
                  className={styles.input}
                  placeholder="pk_live_... ou pk_test_..."
                  value={settings.stripePublicKey}
                  onChange={(e) => update('stripePublicKey', e.target.value)}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="stripeMode">
                  Mode Stripe
                </label>
                <select
                  id="stripeMode"
                  className={styles.select}
                  value={settings.stripeMode}
                  onChange={(e) => update('stripeMode', e.target.value)}
                >
                  <option value="test">Test</option>
                  <option value="production">Production</option>
                </select>
              </div>
            </div>
            {settings.stripeMode === 'production' && (
              <div className={styles.warningBox}>
                Mode production : vérifiez que la clé publique et le backend Stripe
                utilisent les clés live correspondantes.
              </div>
            )}
          </section>

          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Notifications & documents</h2>
            <Toggle
              id="autoApproveDocuments"
              label="Validation automatique des documents"
              description="Les documents uploadés sont marqués vérifiés sans action admin."
              checked={settings.autoApproveDocuments}
              onChange={(v) => update('autoApproveDocuments', v)}
            />
            <Toggle
              id="sendEmailNotifications"
              label="Notifications par email"
              description="Envois d’emails transactionnels (réservations, messages admin, etc.)."
              checked={settings.sendEmailNotifications}
              onChange={(v) => update('sendEmailNotifications', v)}
            />
            <Toggle
              id="sendSMSNotifications"
              label="Notifications SMS"
              description="À activer lorsque le fournisseur SMS sera configuré."
              checked={settings.sendSMSNotifications}
              onChange={(v) => update('sendSMSNotifications', v)}
            />
          </section>

          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Sécurité</h2>
            <div className={styles.grid}>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="maxLoginAttempts">
                  Tentatives de connexion max.
                </label>
                <input
                  id="maxLoginAttempts"
                  type="number"
                  min={3}
                  max={20}
                  className={styles.input}
                  value={settings.maxLoginAttempts}
                  onChange={handleNumber('maxLoginAttempts')}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="lockoutDuration">
                  Verrouillage (minutes)
                </label>
                <input
                  id="lockoutDuration"
                  type="number"
                  min={5}
                  max={1440}
                  className={styles.input}
                  value={settings.lockoutDuration}
                  onChange={handleNumber('lockoutDuration')}
                />
              </div>
              <div className={styles.field}>
                <label className={styles.label} htmlFor="sessionTimeout">
                  Expiration session (heures)
                </label>
                <input
                  id="sessionTimeout"
                  type="number"
                  min={1}
                  max={168}
                  className={styles.input}
                  value={settings.sessionTimeout}
                  onChange={handleNumber('sessionTimeout')}
                />
              </div>
            </div>
            <Toggle
              id="require2FA"
              label="Authentification à deux facteurs (2FA)"
              description="Exiger la 2FA pour les comptes admin (selon implémentation future)."
              checked={settings.require2FA}
              onChange={(v) => update('require2FA', v)}
            />
          </section>

          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Système</h2>
            <Toggle
              id="maintenanceMode"
              label="Mode maintenance"
              description="Affiche l’écran maintenance dans l’app mobile (bloque l’accès utilisateurs)."
              checked={settings.maintenanceMode}
              onChange={(v) => update('maintenanceMode', v)}
            />
            {settings.maintenanceMode && (
              <div className={styles.warningBox}>
                Le mode maintenance est actif : les utilisateurs de l’app verront
                l’écran de maintenance.
              </div>
            )}
            <Toggle
              id="debugMode"
              label="Mode debug (logs app)"
              description="Active les journaux détaillés côté application mobile."
              checked={settings.debugMode}
              onChange={(v) => update('debugMode', v)}
            />
          </section>

          <div className={styles.actions}>
            <button type="submit" className={styles.saveBtn} disabled={saving}>
              {saving ? 'Enregistrement…' : 'Enregistrer'}
            </button>
            <button
              type="button"
              className={styles.secondaryBtn}
              onClick={handleResetDefaults}
            >
              Réinitialiser
            </button>
            <button
              type="button"
              className={styles.secondaryBtn}
              onClick={() => router.push('/dashboard')}
            >
              Tableau de bord
            </button>
          </div>

          <p className={styles.meta}>
            API : GET/PUT <code>/api/settings</code> — lecture publique pour l’app,
            écriture réservée aux administrateurs.
          </p>
        </form>
      </div>
    </Layout>
  );
}

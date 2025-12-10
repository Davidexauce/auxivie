import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { settingsAPI } from '../lib/api';
import styles from '../styles/Dashboard.module.css';

export default function Settings() {
  const router = useRouter();
  const [settings, setSettings] = useState(null);
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
      const data = await settingsAPI.get().catch(() => ({}));
      setSettings(data || {});
    } catch (error) {
      console.error('Erreur:', error);
      setError('Erreur lors du chargement des paramètres');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess(false);
    setSaving(true);

    try {
      await settingsAPI.update(settings);
      setSuccess(true);
      setTimeout(() => setSuccess(false), 3000);
    } catch (error) {
      console.error('Erreur:', error);
      setError(error.message || 'Erreur lors de la sauvegarde');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.dashboard}>
        <h1 className={styles.title}>Paramètres</h1>

        {error && (
          <div style={{ 
            marginBottom: '20px', 
            padding: '12px', 
            backgroundColor: '#fee', 
            border: '1px solid #fcc', 
            borderRadius: '4px',
            color: '#c33'
          }}>
            {error}
          </div>
        )}

        {success && (
          <div style={{ 
            marginBottom: '20px', 
            padding: '12px', 
            backgroundColor: '#efe', 
            border: '1px solid #cfc', 
            borderRadius: '4px',
            color: '#3c3'
          }}>
            ✅ Paramètres sauvegardés avec succès !
          </div>
        )}

        <form onSubmit={handleSave}>
          <div className={styles.adminCard} style={{ marginBottom: '20px' }}>
            <h2 style={{ marginBottom: '20px' }}>Configuration générale</h2>
            <p style={{ color: '#666', marginBottom: '20px' }}>
              Les paramètres système seront disponibles ici une fois l'API configurée.
            </p>
            <div style={{ 
              padding: '15px', 
              backgroundColor: '#f5f5f5', 
              borderRadius: '8px',
              color: '#666'
            }}>
              <p>📝 Cette page permet de gérer les paramètres généraux de l'application.</p>
              <p style={{ marginTop: '10px' }}>
                L'API <code>/api/settings</code> est disponible dans le backend.
              </p>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '12px' }}>
            <button
              type="submit"
              className={styles.actionButton}
              disabled={saving}
              style={{ 
                backgroundColor: saving ? '#999' : 'var(--primary)',
                cursor: saving ? 'not-allowed' : 'pointer'
              }}
            >
              {saving ? 'Enregistrement...' : 'Enregistrer les paramètres'}
            </button>
            <button
              type="button"
              className={styles.actionButton}
              onClick={() => router.push('/dashboard')}
              style={{ backgroundColor: '#666' }}
            >
              Retour au dashboard
            </button>
          </div>
        </form>
      </div>
    </Layout>
  );
}


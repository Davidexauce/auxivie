import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI } from '../lib/api';
import styles from '../styles/Dashboard.module.css';

export default function Profile() {
  const router = useRouter();
  const [admin, setAdmin] = useState(null);
  const [loading, setLoading] = useState(true);
  const [changingPassword, setChangingPassword] = useState(false);
  const [passwordData, setPasswordData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    const u = localStorage.getItem('user');
    if (u) {
      const userData = JSON.parse(u);
      setAdmin(userData);
      loadUser(userData.id);
    }
  }, [router]);

  const loadUser = async (userId) => {
    try {
      const userData = await usersAPI.getById(userId);
      setAdmin(userData);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handlePasswordChange = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess(false);

    // Validation
    if (!passwordData.currentPassword || !passwordData.newPassword || !passwordData.confirmPassword) {
      setError('Tous les champs sont requis');
      return;
    }

    if (passwordData.newPassword !== passwordData.confirmPassword) {
      setError('Les nouveaux mots de passe ne correspondent pas');
      return;
    }

    if (passwordData.newPassword.length < 8) {
      setError('Le nouveau mot de passe doit contenir au moins 8 caractères');
      return;
    }

    setChangingPassword(true);

    try {
      // Mettre à jour le mot de passe via l'API
      await usersAPI.update(admin.id, {
        password: passwordData.newPassword,
        currentPassword: passwordData.currentPassword,
      });

      setSuccess(true);
      setPasswordData({
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
      });
      setTimeout(() => {
        setSuccess(false);
        setChangingPassword(false);
      }, 3000);
    } catch (error) {
      console.error('Erreur:', error);
      setError(error.message || 'Erreur lors du changement de mot de passe');
      setChangingPassword(false);
    }
  };

  if (loading || !admin) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.dashboard}>
        <h1 className={styles.title}>Mon Profil</h1>

        <div className={styles.adminCard} style={{ marginBottom: '30px' }}>
          <h2 style={{ marginBottom: '20px' }}>Informations personnelles</h2>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '16px' }}>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '700', color: '#059669', textTransform: 'uppercase' }}>
                Nom
              </span>
              <p style={{ fontSize: '16px', fontWeight: '600', margin: '4px 0 0 0' }}>{admin.name}</p>
            </div>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '700', color: '#059669', textTransform: 'uppercase' }}>
                Email
              </span>
              <p style={{ fontSize: '16px', fontWeight: '600', margin: '4px 0 0 0' }}>{admin.email}</p>
            </div>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '700', color: '#059669', textTransform: 'uppercase' }}>
                Âge
              </span>
              <p style={{ fontSize: '16px', fontWeight: '600', margin: '4px 0 0 0' }}>{admin.age || 'Non renseigné'} ans</p>
            </div>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '700', color: '#059669', textTransform: 'uppercase' }}>
                Téléphone
              </span>
              <p style={{ fontSize: '16px', fontWeight: '600', margin: '4px 0 0 0' }}>{admin.phone || 'Non renseigné'}</p>
            </div>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '700', color: '#059669', textTransform: 'uppercase' }}>
                Adresse
              </span>
              <p style={{ fontSize: '16px', fontWeight: '600', margin: '4px 0 0 0' }}>{admin.address || 'Non renseignée'}</p>
            </div>
            <div>
              <span style={{ fontSize: '12px', fontWeight: '700', color: '#059669', textTransform: 'uppercase' }}>
                Type
              </span>
              <p style={{ fontSize: '16px', fontWeight: '600', margin: '4px 0 0 0' }}>{admin.userType}</p>
            </div>
          </div>
        </div>

        <div className={styles.adminCard}>
          <h2 style={{ marginBottom: '20px' }}>Changer le mot de passe</h2>

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
              ✅ Mot de passe modifié avec succès !
            </div>
          )}

          <form onSubmit={handlePasswordChange}>
            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: '600' }}>
                Mot de passe actuel *
              </label>
              <input
                type="password"
                value={passwordData.currentPassword}
                onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })}
                required
                disabled={changingPassword}
                style={{ 
                  width: '100%', 
                  maxWidth: '400px',
                  padding: '10px', 
                  border: '1px solid #ddd', 
                  borderRadius: '4px',
                  fontSize: '14px'
                }}
              />
            </div>

            <div style={{ marginBottom: '15px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: '600' }}>
                Nouveau mot de passe * (min. 8 caractères)
              </label>
              <input
                type="password"
                value={passwordData.newPassword}
                onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })}
                required
                minLength={8}
                disabled={changingPassword}
                style={{ 
                  width: '100%', 
                  maxWidth: '400px',
                  padding: '10px', 
                  border: '1px solid #ddd', 
                  borderRadius: '4px',
                  fontSize: '14px'
                }}
              />
            </div>

            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: '600' }}>
                Confirmer le nouveau mot de passe *
              </label>
              <input
                type="password"
                value={passwordData.confirmPassword}
                onChange={(e) => setPasswordData({ ...passwordData, confirmPassword: e.target.value })}
                required
                minLength={8}
                disabled={changingPassword}
                style={{ 
                  width: '100%', 
                  maxWidth: '400px',
                  padding: '10px', 
                  border: '1px solid #ddd', 
                  borderRadius: '4px',
                  fontSize: '14px'
                }}
              />
            </div>

            <button
              type="submit"
              className={styles.actionButton}
              disabled={changingPassword}
              style={{ 
                backgroundColor: changingPassword ? '#999' : 'var(--primary)',
                cursor: changingPassword ? 'not-allowed' : 'pointer'
              }}
            >
              {changingPassword ? 'Modification...' : 'Modifier le mot de passe'}
            </button>
          </form>
        </div>
      </div>
    </Layout>
  );
}


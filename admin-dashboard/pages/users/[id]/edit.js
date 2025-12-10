import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../../../components/Layout';
import { usersAPI } from '../../../lib/api';
import styles from '../../../styles/UserDetail.module.css';

export default function EditUser() {
  const router = useRouter();
  const { id } = router.query;
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    categorie: '',
    ville: '',
    tarif: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    if (id) {
      loadUser();
    }
  }, [id, router]);

  const loadUser = async () => {
    try {
      setLoading(true);
      setError('');
      const userData = await usersAPI.getById(id);
      setUser(userData);
      setFormData({
        name: userData.name || '',
        email: userData.email || '',
        phone: userData.phone || '',
        categorie: userData.categorie || '',
        ville: userData.ville || '',
        tarif: userData.tarif || '',
      });
    } catch (error) {
      console.error('Erreur lors du chargement:', error);
      setError('Erreur lors du chargement de l\'utilisateur');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess(false);
    setSaving(true);

    try {
      // Validation
      if (!formData.name.trim()) {
        setError('Le nom est requis');
        setSaving(false);
        return;
      }

      if (!formData.email.trim()) {
        setError('L\'email est requis');
        setSaving(false);
        return;
      }

      // Validation email
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(formData.email.trim())) {
        setError('Format d\'email invalide');
        setSaving(false);
        return;
      }

      // Préparer les données à envoyer
      const updateData = {
        name: formData.name.trim(),
        email: formData.email.trim(),
        phone: formData.phone.trim() || null,
        categorie: formData.categorie.trim() || null,
        ville: formData.ville.trim() || null,
        tarif: formData.tarif ? parseFloat(formData.tarif) : null,
      };

      await usersAPI.update(id, updateData);
      
      setSuccess(true);
      
      // Rediriger vers la page de détail après 1 seconde
      setTimeout(() => {
        router.push(`/users/${id}`);
      }, 1000);
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error);
      setError(error.message || 'Erreur lors de la mise à jour de l\'utilisateur');
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Réinitialiser les messages d'erreur/succès lors de la modification
    if (error) setError('');
    if (success) setSuccess(false);
  };

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  if (!user) {
    return (
      <Layout>
        <div className={styles.container}>
          <div style={{ 
            padding: '20px', 
            backgroundColor: '#fee', 
            border: '1px solid #fcc', 
            borderRadius: '4px',
            color: '#c33'
          }}>
            Utilisateur non trouvé
          </div>
          <button 
            onClick={() => router.push('/users')} 
            className={styles.backButton}
            style={{ marginTop: '20px' }}
          >
            ← Retour à la liste
          </button>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.container}>
        <button onClick={() => router.push(`/users/${id}`)} className={styles.backButton}>
          ← Retour
        </button>

        <div className={styles.header}>
          <h1 className={styles.title}>Modifier l'utilisateur</h1>
        </div>

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
            ✅ Modifications enregistrées avec succès ! Redirection...
          </div>
        )}

        <form onSubmit={handleSubmit} className={styles.content}>
          <div className={styles.section}>
            <h2>Informations personnelles</h2>
            <div className={styles.infoGrid}>
              <div className={styles.infoItem}>
                <label htmlFor="name">Nom *</label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  disabled={saving}
                  style={{ 
                    width: '100%', 
                    padding: '8px 12px', 
                    border: '1px solid #ddd', 
                    borderRadius: '4px',
                    fontSize: '14px',
                    marginTop: '4px'
                  }}
                />
              </div>

              <div className={styles.infoItem}>
                <label htmlFor="email">Email *</label>
                <input
                  type="email"
                  id="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  disabled={saving}
                  style={{ 
                    width: '100%', 
                    padding: '8px 12px', 
                    border: '1px solid #ddd', 
                    borderRadius: '4px',
                    fontSize: '14px',
                    marginTop: '4px'
                  }}
                />
              </div>

              <div className={styles.infoItem}>
                <label htmlFor="phone">Téléphone</label>
                <input
                  type="tel"
                  id="phone"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  disabled={saving}
                  placeholder="Ex: 0612345678"
                  style={{ 
                    width: '100%', 
                    padding: '8px 12px', 
                    border: '1px solid #ddd', 
                    borderRadius: '4px',
                    fontSize: '14px',
                    marginTop: '4px'
                  }}
                />
              </div>

              <div className={styles.infoItem}>
                <label htmlFor="categorie">Catégorie</label>
                <input
                  type="text"
                  id="categorie"
                  name="categorie"
                  value={formData.categorie}
                  onChange={handleChange}
                  disabled={saving}
                  placeholder="Ex: Auxiliaire de vie"
                  style={{ 
                    width: '100%', 
                    padding: '8px 12px', 
                    border: '1px solid #ddd', 
                    borderRadius: '4px',
                    fontSize: '14px',
                    marginTop: '4px'
                  }}
                />
              </div>

              <div className={styles.infoItem}>
                <label htmlFor="ville">Ville</label>
                <input
                  type="text"
                  id="ville"
                  name="ville"
                  value={formData.ville}
                  onChange={handleChange}
                  disabled={saving}
                  placeholder="Ex: Paris"
                  style={{ 
                    width: '100%', 
                    padding: '8px 12px', 
                    border: '1px solid #ddd', 
                    borderRadius: '4px',
                    fontSize: '14px',
                    marginTop: '4px'
                  }}
                />
              </div>

              {user.userType === 'professionnel' && (
                <div className={styles.infoItem}>
                  <label htmlFor="tarif">Tarif (€/h)</label>
                  <input
                    type="number"
                    id="tarif"
                    name="tarif"
                    value={formData.tarif}
                    onChange={handleChange}
                    min="0"
                    step="0.01"
                    disabled={saving}
                    placeholder="Ex: 25.00"
                    style={{ 
                      width: '100%', 
                      padding: '8px 12px', 
                      border: '1px solid #ddd', 
                      borderRadius: '4px',
                      fontSize: '14px',
                      marginTop: '4px'
                    }}
                  />
                </div>
              )}

              <div className={styles.infoItem}>
                <label>Type d'utilisateur</label>
                <p style={{ 
                  margin: '4px 0 0 0', 
                  padding: '8px 12px', 
                  color: '#666',
                  backgroundColor: '#f5f5f5',
                  borderRadius: '4px',
                  display: 'inline-block'
                }}>
                  {user.userType === 'professionnel' ? 'Professionnel' : 'Famille'}
                </p>
                <small style={{ color: '#999', fontSize: '12px', marginTop: '4px', display: 'block' }}>
                  Le type d'utilisateur ne peut pas être modifié
                </small>
              </div>
            </div>
          </div>

          <div style={{ marginTop: '30px', display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
            <button
              type="submit"
              className={styles.editButton}
              disabled={saving || success}
              style={{ 
                backgroundColor: saving ? '#999' : 'var(--primary)', 
                color: 'white',
                cursor: saving ? 'not-allowed' : 'pointer'
              }}
            >
              {saving ? 'Enregistrement...' : success ? 'Enregistré ✓' : 'Enregistrer les modifications'}
            </button>
            <button
              type="button"
              className={styles.editButton}
              onClick={() => router.push(`/users/${id}`)}
              disabled={saving}
              style={{ 
                backgroundColor: '#666', 
                color: 'white',
                cursor: saving ? 'not-allowed' : 'pointer'
              }}
            >
              Annuler
            </button>
          </div>
        </form>
      </div>
    </Layout>
  );
}


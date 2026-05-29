import { useState } from 'react';
import Link from 'next/link';
import { authAPI } from '../lib/api';
import styles from '../styles/Register.module.css';

export default function Register() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    adminKey: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  const [passwordStrength, setPasswordStrength] = useState({
    length: false,
    uppercase: false,
    lowercase: false,
    number: false,
    special: false,
  });

  // Évaluer la force du mot de passe
  const evaluatePassword = (password) => {
    setPasswordStrength({
      length: password.length >= 8,
      uppercase: /[A-Z]/.test(password),
      lowercase: /[a-z]/.test(password),
      number: /[0-9]/.test(password),
      special: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
    });
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));

    if (name === 'password') {
      evaluatePassword(value);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    // Validation du formulaire
    if (!formData.name || !formData.email || !formData.password || !formData.confirmPassword || !formData.adminKey) {
      setError('Tous les champs sont requis');
      setLoading(false);
      return;
    }

    // Vérifier les mots de passe
    if (formData.password !== formData.confirmPassword) {
      setError('Les mots de passe ne correspondent pas');
      setLoading(false);
      return;
    }

    // Vérifier la force du mot de passe
    if (formData.password.length < 8) {
      setError('Le mot de passe doit contenir au moins 8 caractères');
      setLoading(false);
      return;
    }

    // Vérifier le format de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(formData.email)) {
      setError('Veuillez entrer une adresse email valide');
      setLoading(false);
      return;
    }

    try {
      console.log('📝 Tentative d\'enregistrement admin avec:', formData.email);
      
      const response = await authAPI.registerAdmin(
        formData.email,
        formData.password,
        formData.name,
        formData.adminKey
      );

      console.log('✅ Enregistrement réussi');
      
      if (response.token) {
        setSuccess('Administrateur créé avec succès ! Redirection...');
        localStorage.setItem('token', response.token);
        if (response.user) {
          localStorage.setItem('user', JSON.stringify(response.user));
        }
        
        // Rediriger vers le dashboard après 2 secondes
        setTimeout(() => {
          window.location.replace('/dashboard');
        }, 2000);
      } else {
        setError('Erreur lors de l\'enregistrement : token manquant');
      }
    } catch (err) {
      console.error('❌ Erreur d\'enregistrement:', err);
      
      // Gérer les erreurs spécifiques
      if (err.message.includes('Clé admin invalide')) {
        setError('Clé admin invalide. Veuillez vérifier et réessayer.');
      } else if (err.message.includes('déjà enregistré')) {
        setError('Cet email est déjà enregistré dans le système.');
      } else {
        setError(err.message || 'Erreur lors de l\'enregistrement. Veuillez réessayer.');
      }
    } finally {
      setLoading(false);
    }
  };

  const isPasswordValid = Object.values(passwordStrength).every(v => v);

  return (
    <div className={styles.container}>
      <div className={styles.registerBox}>
        <h1 className={styles.title}>Aidalya Admin</h1>
        <p className={styles.subtitle}>Création d'un compte administrateur</p>
        
        <form onSubmit={handleSubmit} className={styles.form}>
          {error && <div className={styles.error}>{error}</div>}
          {success && <div className={styles.success}>{success}</div>}
          
          <div className={styles.inputGroup}>
            <label htmlFor="name">Nom complet *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder="Jean Dupont"
              required
            />
          </div>

          <div className={styles.inputGroup}>
            <label htmlFor="email">Email administrateur *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="admin@auxivie.org"
              required
            />
            <small>Cet email sera utilisé pour vous connecter</small>
          </div>

          <div className={styles.inputGroup}>
            <label htmlFor="password">Mot de passe *</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="••••••••"
              required
            />
            <small>Minimum 8 caractères</small>
            
            {formData.password && (
              <div className={styles.passwordRequirements}>
                <ul>
                  <li style={{ color: passwordStrength.length ? '#16a34a' : '#999' }}>
                    Au moins 8 caractères
                  </li>
                  <li style={{ color: passwordStrength.uppercase ? '#16a34a' : '#999' }}>
                    Une lettre majuscule
                  </li>
                  <li style={{ color: passwordStrength.lowercase ? '#16a34a' : '#999' }}>
                    Une lettre minuscule
                  </li>
                  <li style={{ color: passwordStrength.number ? '#16a34a' : '#999' }}>
                    Un chiffre
                  </li>
                  <li style={{ color: passwordStrength.special ? '#16a34a' : '#999' }}>
                    Un caractère spécial
                  </li>
                </ul>
              </div>
            )}
          </div>

          <div className={styles.inputGroup}>
            <label htmlFor="confirmPassword">Confirmer le mot de passe *</label>
            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              placeholder="••••••••"
              required
            />
          </div>

          <div className={styles.inputGroup}>
            <label htmlFor="adminKey">Clé d'activation administrateur *</label>
            <input
              type="password"
              id="adminKey"
              name="adminKey"
              value={formData.adminKey}
              onChange={handleChange}
              placeholder="Entrez la clé sécurisée"
              required
            />
            <small>Clé fournie par un administrateur système</small>
          </div>

          <button 
            type="submit" 
            className={styles.button}
            disabled={loading || !isPasswordValid}
            title={!isPasswordValid ? 'Veuillez respecter les critères de sécurité' : ''}
          >
            {loading ? 'Création en cours...' : 'Créer le compte administrateur'}
          </button>
        </form>

        <div className={styles.footer}>
          Vous avez déjà un compte ?{' '}
          <Link href="/login">
            Se connecter
          </Link>
        </div>

        <div className={styles.footer} style={{ marginTop: '32px', fontSize: '12px', color: '#999' }}>
          <p>
            ⚠️ Cette page est réservée aux administrateurs. 
            <br />
            Gardez votre clé d'activation confidentielle.
          </p>
        </div>
      </div>
    </div>
  );
}

import { useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import { authAPI } from '../lib/api';
import styles from '../styles/Login.module.css';

export default function Login() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      console.log('🔐 Tentative de connexion avec:', email);
      const response = await authAPI.login(email, password);
      console.log('✅ Connexion réussie');
      
      if (response.token) {
        localStorage.setItem('token', response.token);
        if (response.user) {
          localStorage.setItem('user', JSON.stringify(response.user));
        }
        router.push('/dashboard');
      } else {
        setError('Erreur de connexion : token manquant');
      }
    } catch (err) {
      console.error('❌ Erreur de connexion:', err);
      // Améliorer l'affichage des erreurs multilignes
      const errorMessage = err.message || 'Email ou mot de passe incorrect';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.loginBox}>
        <h1 className={styles.title}>Auxivie Admin</h1>
        <p className={styles.subtitle}>Connexion à l'espace administrateur</p>
        
        <form onSubmit={handleSubmit} className={styles.form}>
          {error && (
            <div className={styles.error} style={{ whiteSpace: 'pre-wrap', lineHeight: '1.6' }}>
              {error}
            </div>
          )}
          
          <div className={styles.inputGroup}>
            <label htmlFor="email">Email</label>
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@auxivie.com"
              required
            />
          </div>

          <div className={styles.inputGroup}>
            <label htmlFor="password">Mot de passe</label>
            <input
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
            />
          </div>

          <button 
            type="submit" 
            className={styles.button}
            disabled={loading}
          >
            {loading ? 'Connexion...' : 'Se connecter'}
          </button>
        </form>

        <div style={{ marginTop: '24px', textAlign: 'center', fontSize: '14px', color: '#666' }}>
          Vous n'avez pas encore de compte ?{' '}
          <Link href="/register">
            <span style={{ color: '#16a34a', textDecoration: 'none', fontWeight: '600', cursor: 'pointer' }}>
              Créer un compte admin
            </span>
          </Link>
        </div>

        <div style={{ marginTop: '16px', textAlign: 'center', fontSize: '12px' }}>
          <Link href="/diagnostic">
            <span style={{ color: '#0066cc', textDecoration: 'underline', cursor: 'pointer' }}>
              Problème de connexion? Exécuter un diagnostic
            </span>
          </Link>
        </div>
      </div>
    </div>
  );
}


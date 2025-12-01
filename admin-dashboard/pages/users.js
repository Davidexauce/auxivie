import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI } from '../lib/api';
import styles from '../styles/Users.module.css';

export default function Users() {
  const router = useRouter();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, professionnel, famille

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadUsers();
  }, [router]);

  const loadUsers = async () => {
    try {
      const data = await usersAPI.getAll();
      setUsers(data);
    } catch (error) {
      console.error('Erreur lors du chargement des utilisateurs:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredUsers = filter === 'all' 
    ? users 
    : users.filter(u => u.userType === filter);

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.container}>
        <div className={styles.header}>
          <h1 className={styles.title}>Gestion des utilisateurs</h1>
          <div className={styles.filters}>
            <button
              className={filter === 'all' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('all')}
            >
              Tous ({users.length})
            </button>
            <button
              className={filter === 'professionnel' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('professionnel')}
            >
              Professionnels ({users.filter(u => u.userType === 'professionnel').length})
            </button>
            <button
              className={filter === 'famille' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('famille')}
            >
              Familles ({users.filter(u => u.userType === 'famille').length})
            </button>
          </div>
        </div>

        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Email</th>
                <th>Type</th>
                <th>Catégorie</th>
                <th>Ville</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map((user) => (
                <tr key={user.id}>
                  <td>{user.id}</td>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td>
                    <span className={styles.badge}>
                      {user.userType === 'professionnel' ? 'Pro' : 'Famille'}
                    </span>
                  </td>
                  <td>{user.categorie || '-'}</td>
                  <td>{user.ville || '-'}</td>
                        <td>
                          <div className={styles.actionButtons}>
                            <button
                              className={styles.actionButton}
                              onClick={() => router.push(`/users/${user.id}`)}
                            >
                              Voir
                            </button>
                            <button
                              className={styles.actionButton}
                              onClick={() => router.push(`/messages?userId=${user.id}`)}
                              style={{ backgroundColor: 'var(--primary)', color: 'white', marginLeft: '8px' }}
                            >
                              Contacter
                            </button>
                          </div>
                        </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
}


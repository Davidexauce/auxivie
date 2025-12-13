import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI } from '../lib/api';
import { exportUsersToCSV, exportUsersToExcel } from '../lib/export';
import Pagination from '../components/Pagination';
import styles from '../styles/Users.module.css';

export default function Users() {
  const router = useRouter();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, professionnel, famille
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(25);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
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

  const filteredUsers = (filter === 'all' 
    ? users 
    : users.filter(u => u.userType === filter)
  ).filter(user => {
    if (!searchTerm.trim()) return true;
    const search = searchTerm.toLowerCase();
    return (
      user.name?.toLowerCase().includes(search) ||
      user.email?.toLowerCase().includes(search) ||
      user.categorie?.toLowerCase().includes(search) ||
      user.ville?.toLowerCase().includes(search)
    );
  });

  // Pagination
  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

  // Réinitialiser la page si nécessaire
  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage]);

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
          <div className={styles.exportButtons}>
            <button
              onClick={() => exportUsersToCSV(filteredUsers)}
              className={styles.exportButton}
            >
              📄 CSV
            </button>
            <button
              onClick={() => exportUsersToExcel(filteredUsers)}
              className={styles.exportButton}
              style={{ backgroundColor: '#059669' }}
            >
              📊 Excel
            </button>
          </div>
        </div>

        {/* Recherche */}
        <div className={styles.searchContainer}>
          <input
            type="text"
            placeholder="🔍 Rechercher par nom, email, catégorie ou ville..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setCurrentPage(1);
            }}
            className={styles.searchInput}
          />
        </div>

        {/* Filtres */}
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
              {paginatedUsers.map((user) => (
                <tr key={user.id} style={user.suspended ? { opacity: 0.6, backgroundColor: '#fee' } : {}}>
                  <td>{user.id}</td>
                  <td>
                    {user.name}
                    {user.suspended && (
                      <span style={{ 
                        marginLeft: '8px', 
                        padding: '2px 8px', 
                        backgroundColor: '#ef4444', 
                        color: 'white', 
                        borderRadius: '4px',
                        fontSize: '11px',
                        fontWeight: 'bold'
                      }}>
                        SUSPENDU
                      </span>
                    )}
                  </td>
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
                            {user.suspended ? (
                              <button
                                className={styles.actionButton}
                                onClick={async () => {
                                  if (confirm(`Voulez-vous réactiver l'utilisateur ${user.name} ?`)) {
                                    try {
                                      await usersAPI.unsuspend(user.id);
                                      loadUsers();
                                    } catch (error) {
                                      console.error('Erreur:', error);
                                      alert('Erreur lors de la réactivation');
                                    }
                                  }
                                }}
                                style={{ backgroundColor: '#10b981', color: 'white', marginLeft: '8px' }}
                                title="Réactiver l'utilisateur"
                              >
                                Activer
                              </button>
                            ) : (
                              <button
                                className={styles.actionButton}
                                onClick={async () => {
                                  if (confirm(`Voulez-vous suspendre l'utilisateur ${user.name} ?`)) {
                                    try {
                                      await usersAPI.suspend(user.id);
                                      loadUsers();
                                    } catch (error) {
                                      console.error('Erreur:', error);
                                      alert('Erreur lors de la suspension');
                                    }
                                  }
                                }}
                                style={{ backgroundColor: '#ef4444', color: 'white', marginLeft: '8px' }}
                                title="Suspendre l'utilisateur"
                              >
                                Suspendre
                              </button>
                            )}
                          </div>
                        </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredUsers.length > 0 && (
          <Pagination
            currentPage={currentPage}
            totalPages={totalPages}
            onPageChange={setCurrentPage}
            itemsPerPage={itemsPerPage}
            totalItems={filteredUsers.length}
            onItemsPerPageChange={(value) => {
              setItemsPerPage(value);
              setCurrentPage(1);
            }}
          />
        )}
      </div>
    </Layout>
  );
}


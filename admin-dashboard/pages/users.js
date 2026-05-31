import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { usersAPI } from '../lib/api';
import { exportUsersToCSV } from '../lib/export';
import { displayUserName } from '../lib/displayUserName';
import Pagination from '../components/Pagination';
import styles from '../styles/Users.module.css';

export default function Users() {
  const router = useRouter();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(25);
  const [openMenuId, setOpenMenuId] = useState(null);
  const menuRef = useRef(null);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }
    loadUsers();
  }, [router]);

  useEffect(() => {
    const closeMenu = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setOpenMenuId(null);
      }
    };
    document.addEventListener('click', closeMenu);
    return () => document.removeEventListener('click', closeMenu);
  }, []);

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
    : users.filter((u) => u.userType === filter)
  ).filter((user) => {
    if (!searchTerm.trim()) return true;
    const search = searchTerm.toLowerCase();
    return (
      displayUserName(user)?.toLowerCase().includes(search) ||
      user.email?.toLowerCase().includes(search) ||
      user.categorie?.toLowerCase().includes(search) ||
      user.ville?.toLowerCase().includes(search)
    );
  });

  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedUsers = filteredUsers.slice(startIndex, startIndex + itemsPerPage);

  useEffect(() => {
    if (currentPage > totalPages && totalPages > 0) {
      setCurrentPage(1);
    }
  }, [totalPages, currentPage]);

  const handleSuspendToggle = async (user, activate) => {
    const label = displayUserName(user);
    const msg = activate
      ? `Réactiver l'utilisateur ${label} ?`
      : `Suspendre l'utilisateur ${label} ?`;
    if (!confirm(msg)) return;
    try {
      if (activate) await usersAPI.unsuspend(user.id);
      else await usersAPI.suspend(user.id);
      setOpenMenuId(null);
      loadUsers();
    } catch (error) {
      console.error('Erreur:', error);
      alert(activate ? 'Erreur lors de la réactivation' : 'Erreur lors de la suspension');
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
      <div className={styles.container}>
        <div className={styles.pageHeader}>
          <div>
            <h1 className={styles.title}>Utilisateurs</h1>
            <p className={styles.subtitle}>
              {filteredUsers.length} compte{filteredUsers.length > 1 ? 's' : ''} affiché
              {filter !== 'all' ? ` · filtre ${filter}` : ''}
            </p>
          </div>
          <button
            type="button"
            className={styles.exportBtn}
            onClick={() => exportUsersToCSV(filteredUsers)}
          >
            Exporter CSV
          </button>
        </div>

        <div className={styles.toolbar}>
          <input
            type="text"
            className={styles.searchInput}
            placeholder="Rechercher par nom, email, catégorie ou ville..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setCurrentPage(1);
            }}
          />
          <div className={styles.filters}>
            <button
              type="button"
              className={filter === 'all' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('all')}
            >
              Tous ({users.length})
            </button>
            <button
              type="button"
              className={filter === 'professionnel' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('professionnel')}
            >
              Pros ({users.filter((u) => u.userType === 'professionnel').length})
            </button>
            <button
              type="button"
              className={filter === 'famille' ? styles.activeFilter : styles.filter}
              onClick={() => setFilter('famille')}
            >
              Familles ({users.filter((u) => u.userType === 'famille').length})
            </button>
          </div>
        </div>

        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>ID</th>
                <th>Utilisateur</th>
                <th>Email</th>
                <th>Type</th>
                <th>Catégorie</th>
                <th>Ville</th>
                <th className={styles.actionsHeader}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {paginatedUsers.map((user) => (
                <tr
                  key={user.id}
                  className={Boolean(user.suspended) ? styles.rowSuspended : undefined}
                >
                  <td className={styles.idCell}>{user.id}</td>
                  <td className={styles.nameCell}>
                    <span className={styles.userName}>{displayUserName(user)}</span>
                    {Boolean(user.suspended) && (
                      <span className={styles.suspendedTag}>Suspendu</span>
                    )}
                  </td>
                  <td className={styles.emailCell}>{user.email}</td>
                  <td>
                    <span
                      className={
                        user.userType === 'professionnel'
                          ? styles.badgePro
                          : styles.badgeFamille
                      }
                    >
                      {user.userType === 'professionnel' ? 'Pro' : 'Famille'}
                    </span>
                  </td>
                  <td>{user.categorie || '—'}</td>
                  <td>{user.ville || '—'}</td>
                  <td className={styles.actionsCell}>
                    <div className={styles.actionsRow} ref={openMenuId === user.id ? menuRef : null}>
                      <button
                        type="button"
                        className={styles.iconBtn}
                        title="Voir le profil"
                        onClick={() => router.push(`/users/${user.id}`)}
                      >
                        Voir
                      </button>
                      <button
                        type="button"
                        className={styles.iconBtn}
                        title="Modifier"
                        onClick={() => router.push(`/users/${user.id}/edit`)}
                      >
                        Modifier
                      </button>
                      <button
                        type="button"
                        className={`${styles.iconBtn} ${styles.iconBtnPrimary}`}
                        title="Envoyer un message"
                        onClick={() => router.push(`/messages?userId=${user.id}`)}
                      >
                        Message
                      </button>
                      <div className={styles.menuWrap}>
                        <button
                          type="button"
                          className={styles.menuTrigger}
                          aria-expanded={openMenuId === user.id}
                          aria-haspopup="true"
                          onClick={(e) => {
                            e.stopPropagation();
                            setOpenMenuId(openMenuId === user.id ? null : user.id);
                          }}
                        >
                          ⋯
                        </button>
                        {openMenuId === user.id && (
                          <div className={styles.menuDropdown} role="menu">
                            {Boolean(user.suspended) ? (
                              <button
                                type="button"
                                role="menuitem"
                                className={styles.menuItemSuccess}
                                onClick={() => handleSuspendToggle(user, true)}
                              >
                                Réactiver le compte
                              </button>
                            ) : (
                              <button
                                type="button"
                                role="menuitem"
                                className={styles.menuItemDanger}
                                onClick={() => handleSuspendToggle(user, false)}
                              >
                                Suspendre le compte
                              </button>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredUsers.length === 0 && (
          <p className={styles.emptyState}>Aucun utilisateur ne correspond à votre recherche.</p>
        )}

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

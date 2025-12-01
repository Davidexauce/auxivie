import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../../components/Layout';
import { usersAPI, badgesAPI, ratingsAPI, reviewsAPI } from '../../lib/api';
import styles from '../../styles/UserDetail.module.css';

export default function UserDetail() {
  const router = useRouter();
  const { id } = router.query;
  const [user, setUser] = useState(null);
  const [badges, setBadges] = useState([]);
  const [rating, setRating] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);

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
      const userData = await usersAPI.getById(id);
      setUser(userData);

      // Charger badges, ratings, reviews
      const [badgesData, ratingData] = await Promise.all([
        badgesAPI.getByUser(id).catch(() => []),
        ratingsAPI.getByUser(id).catch(() => null),
      ]);

      setBadges(badgesData);
      setRating(ratingData);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading || !user) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.container}>
        <button onClick={() => router.back()} className={styles.backButton}>
          ← Retour
        </button>

        <div className={styles.header}>
          <h1 className={styles.title}>{user.name}</h1>
          <button
            className={styles.editButton}
            onClick={() => router.push(`/users/${id}/edit`)}
          >
            Modifier
          </button>
        </div>

        <div className={styles.content}>
          <div className={styles.section}>
            <h2>Informations personnelles</h2>
            <div className={styles.infoGrid}>
              <div className={styles.infoItem}>
                <label>Email</label>
                <p>{user.email}</p>
              </div>
              <div className={styles.infoItem}>
                <label>Téléphone</label>
                <p>{user.phone || '-'}</p>
              </div>
              <div className={styles.infoItem}>
                <label>Type</label>
                <p>{user.userType}</p>
              </div>
              <div className={styles.infoItem}>
                <label>Catégorie</label>
                <p>{user.categorie || '-'}</p>
              </div>
              <div className={styles.infoItem}>
                <label>Ville</label>
                <p>{user.ville || '-'}</p>
              </div>
              <div className={styles.infoItem}>
                <label>Tarif</label>
                <p>{user.tarif ? `${user.tarif} €/h` : '-'}</p>
              </div>
            </div>
          </div>

          {user.userType === 'professionnel' && (
            <>
              <div className={styles.section}>
                <h2>Badges</h2>
                <div className={styles.badges}>
                  {badges.map((badge) => (
                    <span key={badge.id} className={styles.badge}>
                      {badge.badgeName}
                    </span>
                  ))}
                </div>
              </div>

              <div className={styles.section}>
                <h2>Note moyenne</h2>
                {rating ? (
                  <div className={styles.rating}>
                    <span className={styles.ratingValue}>{rating.averageRating.toFixed(1)}</span>
                    <span className={styles.ratingCount}>({rating.totalRatings} avis)</span>
                  </div>
                ) : (
                  <p>Aucune note</p>
                )}
              </div>
            </>
          )}
        </div>
      </div>
    </Layout>
  );
}


import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { reviewsAPI } from '../lib/api';
import styles from '../styles/Reviews.module.css';

export default function Reviews() {
  const router = useRouter();
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, positive, negative

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReviews();
  }, [router, filter]);

  const loadReviews = async () => {
    try {
      const data = await reviewsAPI.getAll();
      let filtered = data;
      
      if (filter === 'positive') {
        filtered = data.filter(r => r.rating >= 4);
      } else if (filter === 'negative') {
        filtered = data.filter(r => r.rating <= 2);
      }
      
      setReviews(filtered);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (reviewId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet avis ?')) {
      return;
    }
    try {
      await reviewsAPI.delete(reviewId);
      loadReviews();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la suppression');
    }
  };

  const renderStars = (rating) => {
    return '★'.repeat(rating) + '☆'.repeat(5 - rating);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
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
        <h1 className={styles.title}>Gestion des avis</h1>

        <div className={styles.filters}>
          <button
            className={filter === 'all' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('all')}
          >
            Tous
          </button>
          <button
            className={filter === 'positive' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('positive')}
          >
            Positifs (4-5★)
          </button>
          <button
            className={filter === 'negative' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('negative')}
          >
            Négatifs (1-2★)
          </button>
        </div>

        <div className={styles.reviewsList}>
          {reviews.length === 0 ? (
            <div className={styles.noData}>Aucun avis trouvé</div>
          ) : (
            reviews.map((review) => (
              <div key={review.id} className={styles.reviewCard}>
                <div className={styles.reviewHeader}>
                  <div className={styles.reviewInfo}>
                    <h3 className={styles.reviewerName}>
                      {review.userName || `User ${review.userId}`}
                    </h3>
                    <p className={styles.professionalName}>
                      Pour {review.professionalName || `Professionnel ${review.professionalId}`}
                    </p>
                    <div className={styles.rating}>
                      <span className={styles.stars}>{renderStars(review.rating)}</span>
                      <span className={styles.ratingValue}>{review.rating}/5</span>
                    </div>
                  </div>
                  <div className={styles.reviewMeta}>
                    <span className={styles.date}>{formatDate(review.createdAt)}</span>
                    <button
                      className={styles.deleteButton}
                      onClick={() => handleDelete(review.id)}
                    >
                      Supprimer
                    </button>
                  </div>
                </div>
                {review.comment && (
                  <p className={styles.comment}>{review.comment}</p>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </Layout>
  );
}


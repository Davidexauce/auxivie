import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { reviewsAPI } from '../lib/api';
import styles from '../styles/Reviews.module.css';

export default function Reviews() {
  const router = useRouter();
  const [reviews, setReviews] = useState([]);
  const [allReviews, setAllReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, positive, negative
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReviews();
  }, [router]);

  useEffect(() => {
    loadReviews();
  }, [filter, searchTerm]);

  const loadReviews = async () => {
    try {
      const data = await reviewsAPI.getAll();
      setAllReviews(data);
      
      let filtered = data;
      
      if (filter === 'positive') {
        filtered = data.filter(r => r.rating >= 4);
      } else if (filter === 'negative') {
        filtered = data.filter(r => r.rating <= 2);
      }

      // Recherche
      if (searchTerm.trim()) {
        const search = searchTerm.toLowerCase();
        filtered = filtered.filter(r =>
          r.userName?.toLowerCase().includes(search) ||
          r.professionalName?.toLowerCase().includes(search) ||
          r.comment?.toLowerCase().includes(search)
        );
      }
      
      setReviews(filtered);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const exportToCSV = () => {
    const headers = ['ID', 'Client', 'Professionnel', 'Note', 'Commentaire', 'Date'];
    const rows = reviews.map(r => [
      r.id,
      r.userName || `User ${r.userId}`,
      r.professionalName || `Pro ${r.professionalId}`,
      r.rating,
      r.comment || '',
      new Date(r.createdAt).toLocaleDateString('fr-FR')
    ]);

    const csv = [headers, ...rows].map(row => row.map(cell => `"${cell}"`).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `avis_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
  };

  const stats = {
    total: allReviews.length,
    average: allReviews.length > 0 
      ? (allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length).toFixed(1)
      : 0,
    positive: allReviews.filter(r => r.rating >= 4).length,
    neutral: allReviews.filter(r => r.rating === 3).length,
    negative: allReviews.filter(r => r.rating <= 2).length,
    distribution: {
      5: allReviews.filter(r => r.rating === 5).length,
      4: allReviews.filter(r => r.rating === 4).length,
      3: allReviews.filter(r => r.rating === 3).length,
      2: allReviews.filter(r => r.rating === 2).length,
      1: allReviews.filter(r => r.rating === 1).length,
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
        <div className={styles.header}>
          <h1 className={styles.title}>Gestion des avis</h1>
          <button onClick={exportToCSV} className={styles.exportButton}>
            📄 Exporter CSV
          </button>
        </div>

        {/* Statistiques */}
        <div className={styles.statsGrid}>
          <div className={styles.statCard}>
            <div className={styles.statValue}>{stats.total}</div>
            <div className={styles.statLabel}>Total avis</div>
          </div>
          <div className={styles.statCard} style={{ borderLeft: '3px solid #f59e0b' }}>
            <div className={styles.statValue}>
              <span style={{ fontSize: '32px' }}>{stats.average}</span>
              <span style={{ fontSize: '20px', color: '#f59e0b' }}> ★</span>
            </div>
            <div className={styles.statLabel}>Note moyenne</div>
          </div>
          <div className={styles.statCard} style={{ borderLeft: '3px solid #10b981' }}>
            <div className={styles.statValue}>{stats.positive}</div>
            <div className={styles.statLabel}>Positifs (4-5★)</div>
          </div>
          <div className={styles.statCard} style={{ borderLeft: '3px solid #ef4444' }}>
            <div className={styles.statValue}>{stats.negative}</div>
            <div className={styles.statLabel}>Négatifs (1-2★)</div>
          </div>
        </div>

        {/* Distribution des notes */}
        <div className={styles.distributionCard}>
          <h3 style={{ marginBottom: '16px', fontSize: '18px', color: '#0b1220' }}>Distribution des notes</h3>
          <div className={styles.distributionBars}>
            {[5, 4, 3, 2, 1].map(rating => {
              const count = stats.distribution[rating];
              const percentage = stats.total > 0 ? (count / stats.total) * 100 : 0;
              return (
                <div key={rating} className={styles.distributionRow}>
                  <span className={styles.ratingLabel}>{rating}★</span>
                  <div className={styles.barContainer}>
                    <div 
                      className={styles.bar} 
                      style={{ 
                        width: `${percentage}%`,
                        backgroundColor: rating >= 4 ? '#10b981' : rating === 3 ? '#f59e0b' : '#ef4444'
                      }}
                    ></div>
                  </div>
                  <span className={styles.countLabel}>{count}</span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Recherche */}
        <div className={styles.searchContainer}>
          <input
            type="text"
            placeholder="🔍 Rechercher par nom, commentaire..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className={styles.searchInput}
          />
        </div>

        {/* Filtres */}
        <div className={styles.filters}>
          <button
            className={filter === 'all' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('all')}
          >
            Tous ({stats.total})
          </button>
          <button
            className={filter === 'positive' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('positive')}
          >
            Positifs ({stats.positive})
          </button>
          <button
            className={filter === 'negative' ? styles.activeFilter : styles.filter}
            onClick={() => setFilter('negative')}
          >
            Négatifs ({stats.negative})
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


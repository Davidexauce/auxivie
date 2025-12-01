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
  const [showAddBadge, setShowAddBadge] = useState(false);
  const [selectedBadge, setSelectedBadge] = useState(null);
  const [showEditRating, setShowEditRating] = useState(false);
  const [showAddReview, setShowAddReview] = useState(false);
  const [newRating, setNewRating] = useState({ averageRating: 0, totalRatings: 0 });
  const [newReview, setNewReview] = useState({ rating: 5, comment: '', userName: '' });

  // Liste des badges prédéfinis
  const predefinedBadges = [
    { type: 'verified', name: 'Vérifié', icon: '✓', description: 'Profil vérifié et authentifié' },
    { type: 'expert', name: 'Expert', icon: '⭐', description: 'Professionnel expert dans son domaine' },
    { type: 'top-rated', name: 'Mieux noté', icon: '🏆', description: 'Professionnel très bien noté' },
    { type: 'fast-response', name: 'Réponse rapide', icon: '⚡', description: 'Répond rapidement aux demandes' },
    { type: 'reliable', name: 'Fiable', icon: '💎', description: 'Professionnel fiable et de confiance' },
    { type: 'experienced', name: 'Expérimenté', icon: '🎓', description: 'Plus de 5 ans d\'expérience' },
    { type: 'certified', name: 'Certifié', icon: '📜', description: 'Certifications professionnelles validées' },
    { type: 'available', name: 'Disponible', icon: '🟢', description: 'Disponible immédiatement' },
    { type: 'recommended', name: 'Recommandé', icon: '👍', description: 'Recommandé par les utilisateurs' },
    { type: 'new', name: 'Nouveau', icon: '🆕', description: 'Nouveau sur la plateforme' },
  ];

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

      // Charger badges pour tous les utilisateurs
      const badgesData = await badgesAPI.getByUser(id).catch(() => []);
      setBadges(badgesData);

      // Charger ratings et reviews uniquement pour les professionnels
      if (userData.userType === 'professionnel') {
        const [ratingData] = await Promise.all([
          ratingsAPI.getByUser(id).catch(() => null),
        ]);
        setRating(ratingData);

        // Charger les avis
        const reviewsData = await reviewsAPI.getAll().catch(() => []);
        const userReviews = reviewsData.filter(r => r.professionalId === parseInt(id));
        setReviews(userReviews);
      }
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddBadge = async () => {
    if (!selectedBadge) {
      alert('Veuillez sélectionner un badge');
      return;
    }
    try {
      await badgesAPI.addToUser(id, {
        badgeType: selectedBadge.type,
        badgeName: selectedBadge.name,
        badgeIcon: selectedBadge.icon,
        description: selectedBadge.description,
      });
      setSelectedBadge(null);
      setShowAddBadge(false);
      loadUser();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de l\'ajout du badge');
    }
  };

  const handleRemoveBadge = async (badgeId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce badge ?')) {
      return;
    }
    try {
      await badgesAPI.delete(badgeId);
      loadUser();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la suppression');
    }
  };

  const handleUpdateRating = async () => {
    if (newRating.averageRating < 0 || newRating.averageRating > 5) {
      alert('La note moyenne doit être entre 0 et 5');
      return;
    }
    if (newRating.totalRatings < 0) {
      alert('Le nombre d\'avis doit être positif');
      return;
    }
    try {
      await ratingsAPI.update(id, {
        averageRating: parseFloat(newRating.averageRating),
        totalRatings: parseInt(newRating.totalRatings),
      });
      setShowEditRating(false);
      loadUser();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la mise à jour de la note');
    }
  };

  const handleAddReview = async () => {
    if (!newReview.userName.trim()) {
      alert('Veuillez saisir un nom d&apos;utilisateur');
      return;
    }
    if (newReview.rating < 1 || newReview.rating > 5) {
      alert('La note doit être entre 1 et 5');
      return;
    }
    try {
      await reviewsAPI.create({
        professionalId: parseInt(id),
        userId: 0, // Utilisateur système/admin
        rating: parseInt(newReview.rating),
        comment: newReview.comment.trim() || null,
        userName: newReview.userName.trim(),
      });
      setNewReview({ rating: 5, comment: '', userName: '' });
      setShowAddReview(false);
      loadUser();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de l\'ajout de l\'avis');
    }
  };

  const handleDeleteReview = async (reviewId) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet avis ?')) {
      return;
    }
    try {
      await reviewsAPI.delete(reviewId);
      loadUser();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la suppression');
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
          <div style={{ display: 'flex', gap: '12px' }}>
            <button
              className={styles.editButton}
              onClick={() => router.push(`/users/${id}/edit`)}
            >
              Modifier
            </button>
            <button
              className={styles.editButton}
              onClick={() => router.push(`/messages?userId=${id}`)}
              style={{ backgroundColor: 'var(--primary)', color: 'white' }}
            >
              Contacter
            </button>
          </div>
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

          <div className={styles.section}>
            <div className={styles.sectionHeader}>
              <h2>Badges du profil</h2>
              <button
                className={styles.addButton}
                onClick={() => setShowAddBadge(true)}
              >
                + Ajouter un badge
              </button>
            </div>
            <div className={styles.badges}>
              {badges.length === 0 ? (
                <p className={styles.noBadges}>Aucun badge attribué</p>
              ) : (
                badges.map((badge) => (
                  <span key={badge.id} className={styles.badge}>
                    {badge.badgeIcon && <span>{badge.badgeIcon}</span>}
                    <span>{badge.badgeName}</span>
                    {badge.description && (
                      <span className={styles.badgeDescription} title={badge.description}>
                        ℹ️
                      </span>
                    )}
                    <button
                      className={styles.removeBadge}
                      onClick={() => handleRemoveBadge(badge.id)}
                      title="Supprimer le badge"
                    >
                      ×
                    </button>
                  </span>
                ))
              )}
            </div>
          </div>

          {user.userType === 'professionnel' && (
            <>

              <div className={styles.section}>
                <div className={styles.sectionHeader}>
                  <h2>Note moyenne</h2>
                  <button
                    className={styles.addButton}
                    onClick={() => {
                      setNewRating(rating ? { 
                        averageRating: rating.averageRating, 
                        totalRatings: rating.totalRatings 
                      } : { averageRating: 0, totalRatings: 0 });
                      setShowEditRating(true);
                    }}
                  >
                    {rating ? 'Modifier' : 'Ajouter'}
                  </button>
                </div>
                {rating ? (
                  <div className={styles.rating}>
                    <span className={styles.ratingValue}>{rating.averageRating.toFixed(1)}</span>
                    <span className={styles.ratingCount}>({rating.totalRatings} avis)</span>
                  </div>
                ) : (
                  <p style={{ color: '#475569' }}>Aucune note</p>
                )}
              </div>

              <div className={styles.section}>
                <div className={styles.sectionHeader}>
                  <h2>Avis ({reviews.length})</h2>
                  <button
                    className={styles.addButton}
                    onClick={() => setShowAddReview(true)}
                  >
                    + Ajouter un avis
                  </button>
                </div>
                {reviews.length === 0 ? (
                  <p style={{ color: '#475569' }}>Aucun avis</p>
                ) : (
                  <div className={styles.reviewsList}>
                    {reviews.map((review) => (
                      <div key={review.id} className={styles.reviewItem}>
                        <div className={styles.reviewHeader}>
                          <span className={styles.reviewerName}>{review.userName || `User ${review.userId}`}</span>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <span className={styles.reviewRating}>★ {review.rating}/5</span>
                            <button
                              className={styles.deleteReviewButton}
                              onClick={() => handleDeleteReview(review.id)}
                              title="Supprimer l'avis"
                            >
                              ×
                            </button>
                          </div>
                        </div>
                        {review.comment && (
                          <p className={styles.reviewComment}>{review.comment}</p>
                        )}
                        <span className={styles.reviewDate}>
                          {new Date(review.createdAt).toLocaleDateString('fr-FR')}
                        </span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </>
          )}
        </div>

        {showAddBadge && (
          <div className={styles.modal}>
            <div className={styles.modalContent}>
              <h3>Ajouter un badge</h3>
              <div className={styles.modalForm}>
                <label className={styles.modalLabel}>Sélectionner un badge :</label>
                <select
                  value={selectedBadge ? selectedBadge.type : ''}
                  onChange={(e) => {
                    const badge = predefinedBadges.find(b => b.type === e.target.value);
                    setSelectedBadge(badge || null);
                  }}
                  className={styles.modalSelect}
                >
                  <option value="">-- Choisir un badge --</option>
                  {predefinedBadges.map((badge) => (
                    <option key={badge.type} value={badge.type}>
                      {badge.icon} {badge.name}
                    </option>
                  ))}
                </select>
                
                {selectedBadge && (
                  <div className={styles.badgePreview}>
                    <div className={styles.badgePreviewIcon}>{selectedBadge.icon}</div>
                    <div className={styles.badgePreviewInfo}>
                      <div className={styles.badgePreviewName}>{selectedBadge.name}</div>
                      <div className={styles.badgePreviewDescription}>{selectedBadge.description}</div>
                    </div>
                  </div>
                )}
                
                <div className={styles.modalActions}>
                  <button 
                    onClick={handleAddBadge} 
                    className={styles.modalButton}
                    disabled={!selectedBadge}
                  >
                    Ajouter
                  </button>
                  <button 
                    onClick={() => {
                      setShowAddBadge(false);
                      setSelectedBadge(null);
                    }} 
                    className={styles.modalButtonCancel}
                  >
                    Annuler
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Modal pour modifier la note moyenne */}
        {showEditRating && (
          <div className={styles.modal}>
            <div className={styles.modalContent}>
              <h3>{rating ? 'Modifier la note moyenne' : 'Ajouter une note moyenne'}</h3>
              <div className={styles.modalForm}>
                <label className={styles.modalLabel}>Note moyenne (0-5) :</label>
                <input
                  type="number"
                  min="0"
                  max="5"
                  step="0.1"
                  value={newRating.averageRating}
                  onChange={(e) => setNewRating({ ...newRating, averageRating: e.target.value })}
                  className={styles.modalInput}
                  placeholder="Ex: 4.5"
                />
                <label className={styles.modalLabel}>Nombre total d'avis :</label>
                <input
                  type="number"
                  min="0"
                  value={newRating.totalRatings}
                  onChange={(e) => setNewRating({ ...newRating, totalRatings: e.target.value })}
                  className={styles.modalInput}
                  placeholder="Ex: 12"
                />
                <div className={styles.modalActions}>
                  <button onClick={handleUpdateRating} className={styles.modalButton}>
                    {rating ? 'Modifier' : 'Ajouter'}
                  </button>
                  <button 
                    onClick={() => {
                      setShowEditRating(false);
                      setNewRating({ averageRating: 0, totalRatings: 0 });
                    }} 
                    className={styles.modalButtonCancel}
                  >
                    Annuler
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Modal pour ajouter un avis */}
        {showAddReview && (
          <div className={styles.modal}>
            <div className={styles.modalContent}>
              <h3>Ajouter un avis</h3>
              <div className={styles.modalForm}>
                <label className={styles.modalLabel}>Nom de l&apos;utilisateur :</label>
                <input
                  type="text"
                  value={newReview.userName}
                  onChange={(e) => setNewReview({ ...newReview, userName: e.target.value })}
                  className={styles.modalInput}
                  placeholder="Ex: Marie Dupont"
                />
                <label className={styles.modalLabel}>Note (1-5) :</label>
                <select
                  value={newReview.rating}
                  onChange={(e) => setNewReview({ ...newReview, rating: parseInt(e.target.value) })}
                  className={styles.modalSelect}
                >
                  <option value="5">5 - Excellent</option>
                  <option value="4">4 - Très bien</option>
                  <option value="3">3 - Bien</option>
                  <option value="2">2 - Moyen</option>
                  <option value="1">1 - Insuffisant</option>
                </select>
                <label className={styles.modalLabel}>Commentaire (optionnel) :</label>
                <textarea
                  value={newReview.comment}
                  onChange={(e) => setNewReview({ ...newReview, comment: e.target.value })}
                  className={styles.modalTextarea}
                  placeholder="Ex: Professionnel très compétent et à l'écoute..."
                  rows="4"
                />
                <div className={styles.modalActions}>
                  <button onClick={handleAddReview} className={styles.modalButton}>
                    Ajouter
                  </button>
                  <button 
                    onClick={() => {
                      setShowAddReview(false);
                      setNewReview({ rating: 5, comment: '', userName: '' });
                    }} 
                    className={styles.modalButtonCancel}
                  >
                    Annuler
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}


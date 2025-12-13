import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../../components/Layout';
import Link from 'next/link';
import styles from '../../styles/ReservationDetail.module.css';

export default function ReservationDetail() {
  const router = useRouter();
  const { id } = router.query;
  const [reservation, setReservation] = useState(null);
  const [reservationDays, setReservationDays] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadReservationDetails();
  }, [id]);

  const loadReservationDetails = async () => {
    try {
      setLoading(true);
      // Charger la réservation
      const resResponse = await fetch(`https://auxivie.org/api/reservations/${id}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      
      if (resResponse.ok) {
        const resData = await resResponse.json();
        setReservation(resData);
        
        // Charger les jours de réservation
        const daysResponse = await fetch(`https://auxivie.org/api/reservations/${id}/days`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          }
        });
        
        if (daysResponse.ok) {
          const daysData = await daysResponse.json();
          setReservationDays(daysData);
        }
      }
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateAction = async (action, value) => {
    try {
      const response = await fetch(`https://auxivie.org/api/reservations/${id}/actions`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ [action]: value })
      });

      if (response.ok) {
        loadReservationDetails();
      } else {
        alert('Erreur lors de la mise à jour');
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la mise à jour');
    }
  };

  const handleUnlockInfo = async (type) => {
    if (!confirm(`Êtes-vous sûr de vouloir débloquer les informations ${type === 'pro' ? 'du professionnel' : 'de la famille'} ?`)) {
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`https://auxivie.org/api/reservations/${id}/unlock-info`, {
        method: 'PUT',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ type }),
      });

      if (response.ok) {
        alert('Informations débloquées avec succès !');
        loadReservationDetails();
      } else {
        alert('Erreur lors du déblocage des informations');
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors du déblocage des informations');
    }
  };

  const calculateTotals = () => {
    if (!reservationDays.length) return { totalHours: 0, totalPrice: 0 };
    
    const totalHours = reservationDays.reduce((sum, day) => sum + (day.heuresCalculees || 0), 0);
    const totalPrice = reservationDays.reduce((sum, day) => sum + (day.prixJour || 0), 0);
    
    return { totalHours, totalPrice };
  };

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  if (!reservation) {
    return (
      <Layout>
        <div className={styles.notFound}>
          <h2>Réservation introuvable</h2>
          <Link href="/reservations" className={styles.backButton}>← Retour aux réservations</Link>
        </div>
      </Layout>
    );
  }

  const getStatusBadge = (status) => {
    const statusMap = {
      pending: { label: 'En attente', class: styles.pending },
      confirmed: { label: 'Confirmée', class: styles.confirmed },
      completed: { label: 'Terminée', class: styles.completed },
      cancelled: { label: 'Annulée', class: styles.cancelled },
    };
    const statusInfo = statusMap[status] || { label: status, class: styles.pending };
    return <span className={`${styles.badge} ${statusInfo.class}`}>{statusInfo.label}</span>;
  };

  // Calculer les totaux
  const { totalHours, totalPrice } = calculateTotals();

  return (
    <Layout>
      <div className={styles.container}>
        <div className={styles.header}>
          <Link href="/reservations" className={styles.backLink}>← Retour</Link>
          <div className={styles.titleRow}>
            <h1 className={styles.title}>Réservation #{reservation.id}</h1>
            {getStatusBadge(reservation.status)}
          </div>
        </div>

        <div className={styles.grid}>
          {/* Informations Famille */}
          <div className={styles.card}>
            <h2 className={styles.cardTitle}>🏠 Informations Famille</h2>
            <div className={styles.infoList}>
              <div className={styles.infoItem}>
                <label>Nom</label>
                <span>{reservation.familleName || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Email</label>
                <span>{reservation.familleEmail || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Téléphone</label>
                <span>{reservation.famillePhone || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Adresse</label>
                <span>{reservation.familleAddress || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Statut identité</label>
                <span className={reservation.familleIdentityVerified ? styles.verified : styles.pending}>
                  {reservation.familleIdentityVerified ? '✓ Vérifiée' : 'En attente'}
                </span>
              </div>
              <Link href={`/users/${reservation.userId}`} className={styles.link}>
                Voir le profil complet →
              </Link>
            </div>
          </div>

          {/* Informations Pro */}
          <div className={styles.card}>
            <h2 className={styles.cardTitle}>👨‍⚕️ Informations Professionnel</h2>
            <div className={styles.infoList}>
              <div className={styles.infoItem}>
                <label>Nom</label>
                <span>{reservation.professionalName || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Email</label>
                <span>{reservation.professionalEmail || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Téléphone</label>
                <span>{reservation.professionalPhone || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Adresse</label>
                <span>{reservation.professionalAddress || '-'}</span>
              </div>
              <div className={styles.infoItem}>
                <label>Documents vérifiés</label>
                <span className={reservation.professionalDocsVerified ? styles.verified : styles.pending}>
                  {reservation.professionalDocsVerified ? '✓ Vérifiés' : 'En attente'}
                </span>
              </div>
              <Link href={`/users/${reservation.professionnelId}`} className={styles.link}>
                Voir le profil complet →
              </Link>
            </div>
          </div>
        </div>

        {/* Informations Réservation */}
        <div className={styles.card} style={{ marginTop: '24px' }}>
          <h2 className={styles.cardTitle}>📋 Informations Réservation</h2>
          <div className={styles.infoGrid}>
            <div className={styles.infoItem}>
              <label>Date de début</label>
              <span>{reservation.dateDebut ? new Date(reservation.dateDebut).toLocaleDateString('fr-FR') : '-'}</span>
            </div>
            <div className={styles.infoItem}>
              <label>Date de fin</label>
              <span>{reservation.dateFin ? new Date(reservation.dateFin).toLocaleDateString('fr-FR') : '-'}</span>
            </div>
            <div className={styles.infoItem}>
              <label>Total heures</label>
              <span className={styles.totalValue}>{typeof totalHours === 'number' ? totalHours.toFixed(2) : '0.00'} h</span>
            </div>
            <div className={styles.infoItem}>
              <label>Total prix</label>
              <span className={styles.totalValue}>{typeof totalPrice === 'number' ? totalPrice.toFixed(2) : '0.00'} €</span>
            </div>
            <div className={styles.infoItem}>
              <label>Créée le</label>
              <span>{reservation.createdAt ? new Date(reservation.createdAt).toLocaleString('fr-FR') : '-'}</span>
            </div>
          </div>
        </div>

        {/* Actions Pro / Famille - Affichage compact */}
        <div className={styles.card} style={{ marginTop: '24px' }}>
          <h2 className={styles.cardTitle}>✅ Actions effectuées</h2>
          <div style={{ 
            display: 'grid', 
            gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', 
            gap: '16px',
            marginTop: '16px'
          }}>
            {/* Pro arrivé */}
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '12px',
              padding: '12px',
              background: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0'
            }}>
              <span style={{ fontSize: '18px' }}>
                {reservation.pro_arrive ? '✅' : '⏳'}
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: '600', fontSize: '14px', color: '#0b1220', marginBottom: '4px' }}>
                  Pro arrivé
                </div>
                <div>
                  {reservation.pro_arrive ? (
                    <>
                      <span className={`${styles.badge} ${styles.confirmed}`}>OUI</span>
                      {reservation.pro_arrive_at && (
                        <span style={{ fontSize: '12px', color: '#64748b', marginLeft: '8px' }}>
                          {new Date(reservation.pro_arrive_at).toLocaleString('fr-FR')}
                        </span>
                      )}
                    </>
                  ) : (
                    <span className={`${styles.badge} ${styles.pending}`}>NON</span>
                  )}
                </div>
              </div>
            </div>

            {/* Famille confirme arrivée */}
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '12px',
              padding: '12px',
              background: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0'
            }}>
              <span style={{ fontSize: '18px' }}>
                {reservation.famille_confirme_arrivee ? '✅' : '⏳'}
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: '600', fontSize: '14px', color: '#0b1220', marginBottom: '4px' }}>
                  Famille confirme arrivée
                </div>
                <div>
                  {reservation.famille_confirme_arrivee ? (
                    <>
                      <span className={`${styles.badge} ${styles.confirmed}`}>OUI</span>
                      {reservation.famille_confirme_at && (
                        <span style={{ fontSize: '12px', color: '#64748b', marginLeft: '8px' }}>
                          {new Date(reservation.famille_confirme_at).toLocaleString('fr-FR')}
                        </span>
                      )}
                    </>
                  ) : (
                    <span className={`${styles.badge} ${styles.pending}`}>NON</span>
                  )}
                </div>
              </div>
            </div>

            {/* Pro a terminé */}
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '12px',
              padding: '12px',
              background: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0'
            }}>
              <span style={{ fontSize: '18px' }}>
                {reservation.pro_a_termine ? '✅' : '⏳'}
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: '600', fontSize: '14px', color: '#0b1220', marginBottom: '4px' }}>
                  Pro a terminé
                </div>
                <div>
                  {reservation.pro_a_termine ? (
                    <>
                      <span className={`${styles.badge} ${styles.confirmed}`}>OUI</span>
                      {reservation.pro_termine_at && (
                        <span style={{ fontSize: '12px', color: '#64748b', marginLeft: '8px' }}>
                          {new Date(reservation.pro_termine_at).toLocaleString('fr-FR')}
                        </span>
                      )}
                    </>
                  ) : (
                    <span className={`${styles.badge} ${styles.pending}`}>NON</span>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Section Visibilité et Confidentialité - Affichage compact */}
        <div className={styles.card} style={{ marginTop: '24px' }}>
          <h2 className={styles.cardTitle}>🔐 Visibilité des Informations</h2>
          
          {/* Statut actuel - Format compact */}
          <div style={{ 
            display: 'grid', 
            gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', 
            gap: '16px',
            marginTop: '16px'
          }}>
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '12px',
              padding: '12px',
              background: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0'
            }}>
              <span style={{ fontSize: '18px' }}>
                {reservation.info_pro_debloquee_at ? '🔓' : '🔒'}
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: '600', fontSize: '14px', color: '#0b1220', marginBottom: '4px' }}>
                  Infos PRO pour famille
                </div>
                <div>
                  {reservation.info_pro_debloquee_at ? (
                    <>
                      <span className={`${styles.badge} ${styles.confirmed}`}>DÉBLOQUÉE</span>
                      <div style={{ fontSize: '12px', color: '#64748b', marginTop: '4px' }}>
                        {new Date(reservation.info_pro_debloquee_at).toLocaleString('fr-FR')}
                      </div>
                    </>
                  ) : (
                    <span className={`${styles.badge} ${styles.pending}`}>BLOQUÉE</span>
                  )}
                </div>
              </div>
            </div>

            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '12px',
              padding: '12px',
              background: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0'
            }}>
              <span style={{ fontSize: '18px' }}>
                {reservation.info_famille_debloquee_at ? '🔓' : '🔒'}
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: '600', fontSize: '14px', color: '#0b1220', marginBottom: '4px' }}>
                  Infos FAMILLE pour pro
                </div>
                <div>
                  {reservation.info_famille_debloquee_at ? (
                    <>
                      <span className={`${styles.badge} ${styles.confirmed}`}>DÉBLOQUÉE</span>
                      <div style={{ fontSize: '12px', color: '#64748b', marginTop: '4px' }}>
                        {new Date(reservation.info_famille_debloquee_at).toLocaleString('fr-FR')}
                      </div>
                    </>
                  ) : (
                    <span className={`${styles.badge} ${styles.pending}`}>BLOQUÉE</span>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Règles de confidentialité */}
          <div style={{ 
            marginTop: '20px', 
            padding: '16px', 
            background: '#f8fafc',
            borderRadius: '8px',
            borderLeft: '4px solid #3b82f6'
          }}>
            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '12px' }}>
              <span style={{ fontSize: '20px' }}>ℹ️</span>
              <div>
                <strong style={{ display: 'block', marginBottom: '8px', color: '#0b1220' }}>
                  Règles de confidentialité appliquées
                </strong>
                <ul style={{ margin: 0, paddingLeft: '20px', fontSize: '14px', color: '#64748b', lineHeight: '1.8' }}>
                  <li>
                    <strong>Infos PRO</strong> visibles par la famille uniquement après 
                    <strong style={{ color: '#1DBF73' }}> paiement confirmé</strong>
                    {reservation.paiement_at && (
                      <span style={{ color: '#10b981' }}>
                        {' '}✓ (effectué le {new Date(reservation.paiement_at).toLocaleString('fr-FR')})
                      </span>
                    )}
                  </li>
                  <li>
                    <strong>Infos FAMILLE</strong> visibles par le pro uniquement après 
                    <strong style={{ color: '#1DBF73' }}> paiement confirmé</strong>
                    {reservation.paiement_at && (
                      <span style={{ color: '#10b981' }}>
                        {' '}✓ (effectué le {new Date(reservation.paiement_at).toLocaleString('fr-FR')})
                      </span>
                    )}
                  </li>
                </ul>
              </div>
            </div>
          </div>

          {/* Boutons déblocage */}
          <div style={{ marginTop: '20px', display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
            {!reservation.info_pro_debloquee_at && (
              <button
                onClick={() => handleUnlockInfo('pro')}
                style={{
                  padding: '10px 16px',
                  background: '#3b82f6',
                  color: 'white',
                  border: 'none',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                🔓 Débloquer infos PRO pour famille
              </button>
            )}
            {!reservation.info_famille_debloquee_at && (
              <button
                onClick={() => handleUnlockInfo('famille')}
                style={{
                  padding: '10px 16px',
                  background: '#3b82f6',
                  color: 'white',
                  border: 'none',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  fontSize: '14px',
                  fontWeight: '500'
                }}
              >
                🔓 Débloquer infos FAMILLE pour pro
              </button>
            )}
          </div>
        </div>

        {/* Jours réservés */}
        {reservationDays.length > 0 && (
          <div className={styles.card} style={{ marginTop: '24px' }}>
            <h2 className={styles.cardTitle}>📅 Jours réservés ({reservationDays.length})</h2>
            <div className={styles.tableContainer}>
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Heure début</th>
                    <th>Heure fin</th>
                    <th>Heures calculées</th>
                    <th>Prix du jour</th>
                  </tr>
                </thead>
                <tbody>
                  {reservationDays.map((day) => (
                    <tr key={day.id}>
                      <td>{new Date(day.date).toLocaleDateString('fr-FR')}</td>
                      <td>{day.heureDebut || '-'}</td>
                      <td>{day.heureFin || '-'}</td>
                      <td><strong>{day.heuresCalculees || 0} h</strong></td>
                      <td><strong>{day.prixJour ? `${Number(day.prixJour).toFixed(2)} €` : '-'}</strong></td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr className={styles.totalRow}>
                    <td colSpan="3"><strong>TOTAL</strong></td>
                    <td><strong>{Number(totalHours).toFixed(2)} h</strong></td>
                    <td><strong>{Number(totalPrice).toFixed(2)} €</strong></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        )}

        {/* Message récapitulatif du pro */}
        {reservation.messageRecapitulatif && (
          <div className={styles.card} style={{ marginTop: '24px' }}>
            <h2 className={styles.cardTitle}>💬 Message récapitulatif du professionnel</h2>
            <div className={styles.message}>
              <p className={styles.messageDate}>
                Envoyé le {reservation.messageRecapitulatifDate ? new Date(reservation.messageRecapitulatifDate).toLocaleString('fr-FR') : '-'}
              </p>
              <div className={styles.messageContent}>
                {reservation.messageRecapitulatif}
              </div>
            </div>
          </div>
        )}

        {/* Timeline */}
        <div className={styles.card} style={{ marginTop: '24px' }}>
          <h2 className={styles.cardTitle}>⏱️ Timeline des événements</h2>
          <div className={styles.timeline}>
            <div className={styles.timelineItem}>
              <div className={styles.timelineDot}></div>
              <div className={styles.timelineContent}>
                <strong>Création réservation</strong>
                <span>{reservation.createdAt ? new Date(reservation.createdAt).toLocaleString('fr-FR') : '-'}</span>
              </div>
            </div>
            
            {reservation.paiement_at && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Paiement famille</strong>
                  <span>{new Date(reservation.paiement_at).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
            
            {reservation.info_pro_debloquee_at && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Info pro débloquée</strong>
                  <span>{new Date(reservation.info_pro_debloquee_at).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
            
            {reservation.info_famille_debloquee_at && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Info famille débloquée</strong>
                  <span>{new Date(reservation.info_famille_debloquee_at).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
            
            {reservation.pro_arrive_at && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Pro arrivé</strong>
                  <span>{new Date(reservation.pro_arrive_at).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
            
            {reservation.famille_confirme_at && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Famille confirme arrivée</strong>
                  <span>{new Date(reservation.famille_confirme_at).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
            
            {reservation.pro_termine_at && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Pro a terminé</strong>
                  <span>{new Date(reservation.pro_termine_at).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
            
            {reservation.status === 'completed' && reservation.completedAt && (
              <div className={styles.timelineItem}>
                <div className={`${styles.timelineDot} ${styles.completed}`}></div>
                <div className={styles.timelineContent}>
                  <strong>Réservation terminée</strong>
                  <span>{new Date(reservation.completedAt).toLocaleString('fr-FR')}</span>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}

import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { documentsAPI } from '../lib/api';
import styles from '../styles/Documents.module.css';

export default function Documents() {
  const router = useRouter();
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all'); // all, pending, verified, rejected
  const [searchTerm, setSearchTerm] = useState('');
  const [rejectReason, setRejectReason] = useState('');
  const [rejectingDocId, setRejectingDocId] = useState(null);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadDocuments();
  }, [router]);

  const loadDocuments = async () => {
    try {
      const data = await documentsAPI.getAll();
      setDocuments(data);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (docId) => {
    try {
      await documentsAPI.verify(docId);
      loadDocuments();
      // Déclencher le rechargement des notifications
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new Event('refreshNotifications'));
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la validation');
    }
  };

  const handleReject = async (docId) => {
    setRejectingDocId(docId);
  };

  const confirmReject = async () => {
    if (!rejectReason.trim()) {
      alert('Veuillez indiquer une raison pour le refus');
      return;
    }
    
    try {
      await documentsAPI.reject(rejectingDocId, rejectReason);
      loadDocuments();
      setRejectingDocId(null);
      setRejectReason('');
      // Déclencher le rechargement des notifications
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new Event('refreshNotifications'));
      }
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors du refus');
    }
  };

  const exportToCSV = () => {
    const filteredDocs = getFilteredDocuments();
    const headers = ['ID', 'Utilisateur', 'Type', 'Statut', 'Date'];
    const rows = filteredDocs.map(doc => [
      doc.id,
      doc.userName || `User ${doc.userId}`,
      doc.type,
      doc.verified ? 'Vérifié' : doc.status === 'rejected' ? 'Refusé' : 'En attente',
      new Date(doc.createdAt).toLocaleDateString('fr-FR')
    ]);

    const csv = [headers, ...rows].map(row => row.join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `documents_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
  };

  const getFilteredDocuments = () => {
    let filtered = documents;

    // Filtrer par statut
    if (filter === 'pending') {
      filtered = filtered.filter(d => !d.verified && d.status !== 'rejected');
    } else if (filter === 'verified') {
      filtered = filtered.filter(d => d.verified);
    } else if (filter === 'rejected') {
      filtered = filtered.filter(d => d.status === 'rejected');
    }

    // Filtrer par recherche
    if (searchTerm.trim()) {
      const search = searchTerm.toLowerCase();
      filtered = filtered.filter(d => 
        d.userName?.toLowerCase().includes(search) ||
        d.type?.toLowerCase().includes(search) ||
        d.userId?.toString().includes(search)
      );
    }

    return filtered;
  };

  const stats = {
    total: documents.length,
    pending: documents.filter(d => !d.verified && d.status !== 'rejected').length,
    verified: documents.filter(d => d.verified).length,
    rejected: documents.filter(d => d.status === 'rejected').length,
  };

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  const filteredDocuments = getFilteredDocuments();

  return (
    <Layout>
      <div className={styles.container}>
        <div className={styles.header}>
          <h1 className={styles.title}>Gestion des documents</h1>
          <button onClick={exportToCSV} className={styles.exportButton}>
            📄 Exporter CSV
          </button>
        </div>

        {/* Statistiques */}
        <div className={styles.statsGrid}>
          <div className={styles.statCard}>
            <div className={styles.statValue}>{stats.total}</div>
            <div className={styles.statLabel}>Total</div>
          </div>
          <div className={styles.statCard} style={{ borderLeft: '3px solid #f59e0b' }}>
            <div className={styles.statValue}>{stats.pending}</div>
            <div className={styles.statLabel}>En attente</div>
          </div>
          <div className={styles.statCard} style={{ borderLeft: '3px solid #10b981' }}>
            <div className={styles.statValue}>{stats.verified}</div>
            <div className={styles.statLabel}>Vérifiés</div>
          </div>
          <div className={styles.statCard} style={{ borderLeft: '3px solid #ef4444' }}>
            <div className={styles.statValue}>{stats.rejected}</div>
            <div className={styles.statLabel}>Refusés</div>
          </div>
        </div>

        {/* Filtres et recherche */}
        <div className={styles.controls}>
          <div className={styles.filters}>
            <button
              className={filter === 'all' ? styles.activeFilter : styles.filterButton}
              onClick={() => setFilter('all')}
            >
              Tous ({stats.total})
            </button>
            <button
              className={filter === 'pending' ? styles.activeFilter : styles.filterButton}
              onClick={() => setFilter('pending')}
            >
              En attente ({stats.pending})
            </button>
            <button
              className={filter === 'verified' ? styles.activeFilter : styles.filterButton}
              onClick={() => setFilter('verified')}
            >
              Vérifiés ({stats.verified})
            </button>
            <button
              className={filter === 'rejected' ? styles.activeFilter : styles.filterButton}
              onClick={() => setFilter('rejected')}
            >
              Refusés ({stats.rejected})
            </button>
          </div>
          <input
            type="text"
            placeholder="Rechercher par utilisateur, type..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className={styles.searchInput}
          />
        </div>

        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>ID</th>
                <th>Utilisateur</th>
                <th>Type</th>
                <th>Document</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredDocuments.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: '#666' }}>
                    Aucun document trouvé
                  </td>
                </tr>
              ) : (
                filteredDocuments.map((doc) => {
                  const documentUrl = doc.path ? `https://auxivie.org${doc.path}` : null;
                  const isImage = doc.path && /\.(jpg|jpeg|png|gif)$/i.test(doc.path);
                  const isPdf = doc.path && /\.pdf$/i.test(doc.path);
                  
                  return (
                    <tr key={doc.id}>
                      <td>{doc.id}</td>
                      <td>
                        <a 
                          href={`/users/${doc.userId}`}
                          style={{ color: 'var(--primary)', textDecoration: 'none' }}
                        >
                          {doc.userName || `User ${doc.userId}`}
                        </a>
                      </td>
                      <td>{doc.type}</td>
                      <td>
                        {documentUrl && (
                          <div style={{ marginBottom: '8px' }}>
                            {isImage ? (
                              <a 
                                href={documentUrl} 
                                target="_blank" 
                                rel="noopener noreferrer"
                                style={{ 
                                  display: 'inline-block',
                                  padding: '4px 8px',
                                  backgroundColor: '#3b82f6',
                                  color: 'white',
                                  borderRadius: '4px',
                                  textDecoration: 'none',
                                  fontSize: '12px',
                                  marginRight: '8px'
                                }}
                              >
                                📷 Voir l'image
                              </a>
                            ) : isPdf ? (
                              <a 
                                href={documentUrl} 
                                target="_blank" 
                                rel="noopener noreferrer"
                                style={{ 
                                  display: 'inline-block',
                                  padding: '4px 8px',
                                  backgroundColor: '#ef4444',
                                  color: 'white',
                                  borderRadius: '4px',
                                  textDecoration: 'none',
                                  fontSize: '12px',
                                  marginRight: '8px'
                                }}
                              >
                                📄 Voir le PDF
                              </a>
                            ) : null}
                            <a 
                              href={documentUrl} 
                              download
                              style={{ 
                                display: 'inline-block',
                                padding: '4px 8px',
                                backgroundColor: '#666',
                                color: 'white',
                                borderRadius: '4px',
                                textDecoration: 'none',
                                fontSize: '12px'
                              }}
                            >
                              ⬇️ Télécharger
                            </a>
                          </div>
                        )}
                      </td>
                      <td>
                        <span className={
                          doc.verified ? styles.verified : 
                          doc.status === 'rejected' ? styles.rejected : 
                          styles.pending
                        }>
                          {doc.verified ? 'Vérifié' : 
                           doc.status === 'rejected' ? 'Refusé' : 
                           'En attente'}
                        </span>
                      </td>
                      <td>
                        <div className={styles.actions}>
                          {!doc.verified && doc.status !== 'rejected' && (
                            <>
                              <button
                                className={styles.verifyButton}
                                onClick={() => handleVerify(doc.id)}
                              >
                                Valider
                              </button>
                              <button
                                className={styles.rejectButton}
                                onClick={() => handleReject(doc.id)}
                              >
                                Refuser
                              </button>
                            </>
                          )}
                          {doc.status === 'rejected' && (
                            <span className={styles.rejected}>Refusé</span>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Modal de refus */}
        {rejectingDocId && (
          <div className={styles.modal}>
            <div className={styles.modalContent}>
              <h3>Refuser le document</h3>
              <p>Veuillez indiquer la raison du refus :</p>
              <textarea
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="Ex: Document illisible, informations manquantes, document expiré..."
                className={styles.textarea}
                rows={4}
              />
              <div className={styles.modalActions}>
                <button onClick={() => {
                  setRejectingDocId(null);
                  setRejectReason('');
                }} className={styles.cancelButton}>
                  Annuler
                </button>
                <button onClick={confirmReject} className={styles.confirmButton}>
                  Confirmer le refus
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}


import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { documentsAPI } from '../lib/api';
import styles from '../styles/Documents.module.css';

export default function Documents() {
  const router = useRouter();
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
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
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la validation');
    }
  };

  const handleReject = async (docId) => {
    if (!confirm('Êtes-vous sûr de vouloir refuser ce document ?')) {
      return;
    }
    try {
      await documentsAPI.reject(docId);
      loadDocuments();
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors du refus');
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
        <h1 className={styles.title}>Gestion des documents</h1>

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
              {documents.map((doc) => {
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
              })}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
}


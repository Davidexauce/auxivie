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
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {documents.map((doc) => (
                <tr key={doc.id}>
                  <td>{doc.id}</td>
                  <td>{doc.userId}</td>
                  <td>{doc.type}</td>
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
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
}


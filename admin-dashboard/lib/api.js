// Récupérer l'URL de l'API depuis les variables d'environnement
// SOLUTION RADICALE: Utiliser UNIQUEMENT le domaine principal (auxivie.org)
// Cela élimine complètement les problèmes de blocage de sous-domaines
const getApiBaseUrl = () => {
  if (typeof window !== 'undefined') {
    // Côté client: toujours utiliser le même domaine
    // Les routes API commencent par /api/ et seront ajoutées après
    return 'https://auxivie.org';
  }
  // Côté serveur: même chose
  return 'https://auxivie.org';
};

const API_BASE_URL = getApiBaseUrl();

// Fonction utilitaire pour les appels API - Version simple et radicale
// Pas de fallback compliqué, juste un domaine unique qui fonctionne toujours
async function apiCall(endpoint, options = {}) {
  const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
  
  const fullUrl = `${API_BASE_URL}${endpoint}`;
  
  // Log pour débogage (uniquement en développement)
  if (process.env.NODE_ENV !== 'production' && typeof window !== 'undefined') {
    console.log('🔗 API Call:', fullUrl, options.method || 'GET');
  }
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  try {
    // Configuration CORS
    const fetchOptions = {
      ...options,
      headers,
      mode: 'cors',
      credentials: 'include',
    };

    // Timeout de 10 secondes
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000);

    const response = await fetch(fullUrl, {
      ...fetchOptions,
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    // Log de la réponse pour débogage
    if (process.env.NODE_ENV !== 'production' && typeof window !== 'undefined') {
      console.log('📡 Response:', response.status, response.statusText);
    }

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ 
        message: `Erreur serveur (${response.status})` 
      }));
      
      // Log de l'erreur pour débogage
      if (typeof window !== 'undefined') {
        console.error('❌ API Error:', errorData);
      }
      
      throw new Error(errorData.message || `Erreur ${response.status}`);
    }

    return response.json();
  } catch (error) {
    // Gestion des erreurs réseau
    if (error.name === 'TypeError' || error.message.includes('Failed to fetch') || error.name === 'AbortError') {
      console.error('❌ Network Error:', error.message);
      console.error('URL:', fullUrl);
      
      let diagnosticMessage = 'Impossible de se connecter au serveur. ';
      
      diagnosticMessage += 'Causes possibles:\n' +
        '• Vérifiez votre connexion internet\n' +
        '• Vérifiez que auxivie.org est accessible\n' +
        '• Votre navigateur ou réseau bloque les connexions\n\n' +
        'Solutions:\n' +
        '• Essayez sur un autre navigateur\n' +
        '• Essayez sur un autre réseau ou avec un VPN\n' +
        '• Visitez https://auxivie.org/diagnostic pour tester la connexion';
      
      throw new Error(diagnosticMessage);
    }
    throw error;
  }
}

// API d'authentification
export const authAPI = {
  login: async (email, password) => {
    return apiCall('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  },
  registerAdmin: async (email, password, name, adminKey) => {
    return apiCall('/api/auth/register-admin', {
      method: 'POST',
      body: JSON.stringify({ email, password, name, adminKey }),
    });
  },
};


// API des utilisateurs
export const usersAPI = {
  getAll: async () => {
    return apiCall('/api/users');
  },
  getById: async (id) => {
    return apiCall(`/api/users/${id}`);
  },
  update: async (id, data) => {
    return apiCall(`/api/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  },
  suspend: async (id) => {
    return apiCall(`/api/users/${id}/suspend`, {
      method: 'POST',
    });
  },
  unsuspend: async (id) => {
    return apiCall(`/api/users/${id}/unsuspend`, {
      method: 'POST',
    });
  },
};

// API des documents
export const documentsAPI = {
  getAll: async () => {
    return apiCall('/api/documents');
  },
  verify: async (id) => {
    return apiCall(`/api/documents/${id}/verify`, {
      method: 'POST',
    });
  },
  reject: async (id) => {
    return apiCall(`/api/documents/${id}/reject`, {
      method: 'POST',
    });
  },
};

// API des messages
export const messagesAPI = {
  getAll: async () => {
    return apiCall('/api/messages/admin');
  },
  getConversation: async (userId) => {
    return apiCall(`/api/messages/admin?userId=${userId}`);
  },
  send: async (data) => {
    return apiCall('/api/messages/admin', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  },
};

// API des réservations
export const reservationsAPI = {
  getAll: async () => {
    return apiCall('/api/reservations/admin');
  },
  getById: async (id) => {
    return apiCall(`/api/reservations/${id}`);
  },
  updateStatus: async (id, status) => {
    return apiCall(`/api/reservations/${id}`, {
      method: 'PUT',
      body: JSON.stringify({ status }),
    });
  },
  delete: async (id) => {
    return apiCall(`/api/reservations/${id}`, {
      method: 'DELETE',
    });
  },
};

// API des paiements
export const paymentsAPI = {
  getAll: async () => {
    return apiCall('/api/payments');
  },
};

// API des badges
export const badgesAPI = {
  getByUser: async (userId) => {
    return apiCall(`/api/badges?userId=${userId}`);
  },
  addToUser: async (userId, badgeData) => {
    return apiCall('/api/badges', {
      method: 'POST',
      body: JSON.stringify({ userId, ...badgeData }),
    });
  },
  delete: async (badgeId) => {
    return apiCall(`/api/badges/${badgeId}`, {
      method: 'DELETE',
    });
  },
};

// API des notes
export const ratingsAPI = {
  getByUser: async (userId) => {
    return apiCall(`/api/ratings?userId=${userId}`);
  },
  update: async (userId, ratingData) => {
    return apiCall(`/api/ratings/${userId}`, {
      method: 'PUT',
      body: JSON.stringify(ratingData),
    });
  },
};

// API des avis
export const reviewsAPI = {
  getAll: async () => {
    return apiCall('/api/reviews');
  },
  create: async (reviewData) => {
    return apiCall('/api/reviews', {
      method: 'POST',
      body: JSON.stringify(reviewData),
    });
  },
  delete: async (reviewId) => {
    return apiCall(`/api/reviews/${reviewId}`, {
      method: 'DELETE',
    });
  },
};

// API des paramètres
export const settingsAPI = {
  get: async () => {
    return apiCall('/api/settings');
  },
  update: async (data) => {
    return apiCall('/api/settings', {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  },
};


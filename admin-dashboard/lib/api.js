// Récupérer l'URL de l'API depuis les variables d'environnement
// En Next.js, NEXT_PUBLIC_* est injecté au build time
const getApiBaseUrl = () => {
  if (typeof window !== 'undefined') {
    // Côté client, utiliser la variable d'environnement ou fallback
    return process.env.NEXT_PUBLIC_API_URL || 'https://api.auxivie.org';
  }
  // Côté serveur
  return process.env.NEXT_PUBLIC_API_URL || 'https://api.auxivie.org';
};

const API_BASE_URL = getApiBaseUrl();

// Fonction utilitaire pour les appels API
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
    const response = await fetch(fullUrl, {
      ...options,
      headers,
    });

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
    if (error.name === 'TypeError' && error.message.includes('fetch')) {
      console.error('❌ Network Error:', error.message);
      throw new Error('Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
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


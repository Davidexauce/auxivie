const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

// Fonction utilitaire pour les appels API
async function apiCall(endpoint, options = {}) {
  const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'Erreur serveur' }));
    throw new Error(error.message || `Erreur ${response.status}`);
  }

  return response.json();
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
};

// API des réservations
export const reservationsAPI = {
  getAll: async () => {
    return apiCall('/api/reservations');
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
  create: async (reviewData) => {
    return apiCall('/api/reviews', {
      method: 'POST',
      body: JSON.stringify(reviewData),
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


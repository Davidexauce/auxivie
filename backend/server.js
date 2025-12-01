// Charger les variables d'environnement
require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.production' : '.env' });

const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Configuration CORS pour production
const corsOptions = {
  origin: process.env.CORS_ORIGIN 
    ? process.env.CORS_ORIGIN.split(',')
    : '*', // En développement, autoriser toutes les origines
  credentials: true,
  optionsSuccessStatus: 200
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());

// Headers de sécurité (basique)
app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'production') {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
  }
  next();
});

// Base de données
const dbPath = path.join(__dirname, 'data', 'auxivie.db');
const db = new sqlite3.Database(dbPath);

// Initialiser la base de données si nécessaire
db.serialize(() => {
  // Créer la table users si elle n'existe pas
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    phone TEXT,
    categorie TEXT NOT NULL,
    ville TEXT,
    tarif REAL,
    experience INTEGER,
    photo TEXT,
    userType TEXT NOT NULL,
    besoin TEXT,
    preference TEXT,
    mission TEXT,
    particularite TEXT
  )`, (err) => {
    if (err) {
      console.error('Erreur création table users:', err);
    } else {
      // Ajouter les colonnes famille si elles n'existent pas
      db.run(`ALTER TABLE users ADD COLUMN besoin TEXT`, (alterErr) => {
        if (alterErr && !alterErr.message.includes('duplicate column')) {
          // Colonne existe déjà ou erreur
        }
      });
      db.run(`ALTER TABLE users ADD COLUMN preference TEXT`, (alterErr) => {
        if (alterErr && !alterErr.message.includes('duplicate column')) {
          // Colonne existe déjà ou erreur
        }
      });
      db.run(`ALTER TABLE users ADD COLUMN mission TEXT`, (alterErr) => {
        if (alterErr && !alterErr.message.includes('duplicate column')) {
          // Colonne existe déjà ou erreur
        }
      });
      db.run(`ALTER TABLE users ADD COLUMN particularite TEXT`, (alterErr) => {
        if (alterErr && !alterErr.message.includes('duplicate column')) {
          // Colonne existe déjà ou erreur
        }
      });
    }
  });
});

// Routes d'authentification
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email et mot de passe requis' });
    }

    // Récupérer l'utilisateur
    db.get(
      'SELECT * FROM users WHERE email = ?',
      [email],
      async (err, user) => {
        if (err) {
          console.error('Erreur DB:', err);
          return res.status(500).json({ message: 'Erreur serveur' });
        }

        if (!user) {
          return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        // Vérifier le mot de passe
        const isValid = await bcrypt.compare(password, user.password);
        
        if (!isValid) {
          return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        // Vérifier que c'est un admin
        if (user.userType !== 'admin') {
          return res.status(403).json({ message: 'Accès réservé aux administrateurs' });
        }

        // Générer le token JWT
        const token = jwt.sign(
          { userId: user.id, email: user.email, userType: user.userType },
          JWT_SECRET,
          { expiresIn: '24h' }
        );

        res.json({
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            userType: user.userType,
          },
        });
      }
    );
  } catch (error) {
    console.error('Erreur login:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route de santé
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Auxivie API' });
});

// Middleware d'authentification
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Token manquant' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Token invalide' });
    }
    req.user = user;
    next();
  });
};

// Routes des utilisateurs
app.get('/api/users', authenticateToken, (req, res) => {
  db.all('SELECT id, name, email, phone, categorie, ville, tarif, userType FROM users WHERE userType != "admin"', (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json(rows);
  });
});

// Route publique pour l'app mobile
app.get('/api/users/:id', (req, res) => {
  const { id } = req.params;
  db.get('SELECT id, name, email, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite FROM users WHERE id = ?', [id], (err, row) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    if (!row) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    res.json(row);
  });
});

// Route protégée pour le Dashboard
app.get('/api/users/:id/admin', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.get('SELECT id, name, email, phone, categorie, ville, tarif, userType FROM users WHERE id = ?', [id], (err, row) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    if (!row) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    res.json(row);
  });
});

app.put('/api/users/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { name, email, phone, categorie, ville, tarif } = req.body;
  
  db.run(
    'UPDATE users SET name = ?, email = ?, phone = ?, categorie = ?, ville = ?, tarif = ? WHERE id = ?',
    [name, email, phone, categorie, ville, tarif, id],
    function(err) {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json({ message: 'Utilisateur mis à jour' });
    }
  );
});

// Routes des documents
app.get('/api/documents', authenticateToken, (req, res) => {
  db.all(`
    SELECT d.*, u.name as userName 
    FROM documents d
    LEFT JOIN users u ON d.userId = u.id
    ORDER BY d.createdAt DESC
  `, (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    // Ajouter un champ verified basé sur le statut
    const documents = rows.map(doc => ({
      ...doc,
      verified: doc.status === 'verified',
    }));
    res.json(documents);
  });
});

app.post('/api/documents/:id/verify', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.run('UPDATE documents SET status = "verified" WHERE id = ?', [id], function(err) {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json({ message: 'Document vérifié' });
  });
});

app.post('/api/documents/:id/reject', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.run('UPDATE documents SET status = "rejected" WHERE id = ?', [id], function(err) {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json({ message: 'Document refusé' });
  });
});

// Routes des paiements
app.get('/api/payments', authenticateToken, (req, res) => {
  db.all(`
    SELECT p.*, u.name as userName, r.id as reservationId
    FROM payments p
    LEFT JOIN users u ON p.userId = u.id
    LEFT JOIN reservations r ON p.reservationId = r.id
    ORDER BY p.createdAt DESC
  `, (err, rows) => {
    if (err) {
      // Si la table n'existe pas ou erreur, retourner un tableau vide
      console.error('Erreur payments:', err);
      return res.json([]);
    }
    res.json(rows || []);
  });
});

// Routes des badges
// Route publique pour l'application mobile (GET uniquement)
app.get('/api/badges', (req, res) => {
  const { userId } = req.query;
  if (userId) {
    db.all('SELECT * FROM user_badges WHERE userId = ?', [userId], (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json(rows);
    });
  } else {
    res.json([]);
  }
});

app.post('/api/badges', authenticateToken, (req, res) => {
  const { userId, badgeType, badgeName, badgeIcon, description } = req.body;
  db.run(
    'INSERT INTO user_badges (userId, badgeType, badgeName, badgeIcon, description, createdAt) VALUES (?, ?, ?, ?, ?, datetime("now"))',
    [userId, badgeType, badgeName, badgeIcon, description],
    function(err) {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json({ id: this.lastID, message: 'Badge ajouté' });
    }
  );
});

app.delete('/api/badges/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM user_badges WHERE id = ?', [id], function(err) {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json({ message: 'Badge supprimé' });
  });
});

// Routes des notes
// Route publique pour l'application mobile
app.get('/api/ratings', (req, res) => {
  const { userId } = req.query;
  if (userId) {
    db.get('SELECT * FROM user_ratings WHERE userId = ?', [userId], (err, row) => {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json(row || null);
    });
  } else {
    res.json(null);
  }
});

app.put('/api/ratings/:userId', authenticateToken, (req, res) => {
  const { userId } = req.params;
  const { averageRating, totalRatings } = req.body;
  db.run(
    'INSERT OR REPLACE INTO user_ratings (userId, averageRating, totalRatings, updatedAt) VALUES (?, ?, ?, datetime("now"))',
    [userId, averageRating, totalRatings],
    function(err) {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json({ message: 'Note mise à jour' });
    }
  );
});

// Routes des avis
// Route publique pour l'application mobile
app.get('/api/reviews', (req, res) => {
  db.all(`
    SELECT 
      r.id,
      r.reservationId,
      r.userId,
      r.professionalId,
      r.rating,
      r.comment,
      r.createdAt,
      COALESCE(r.userName, u.name) as userName,
      p.name as professionalName
    FROM reviews r
    LEFT JOIN users u ON r.userId = u.id
    LEFT JOIN users p ON r.professionalId = p.id
    ORDER BY r.createdAt DESC
  `, (err, rows) => {
    if (err) {
      console.error('Erreur récupération reviews:', err);
      // Si la table n'existe pas, retourner un tableau vide
      return res.json([]);
    }
    res.json(rows);
  });
});

app.post('/api/reviews', authenticateToken, (req, res) => {
  const { professionalId, userId, rating, comment, userName, reservationId } = req.body;

  if (!professionalId || !rating) {
    return res.status(400).json({ message: 'professionalId et rating sont requis' });
  }

  if (rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'La note doit être entre 1 et 5' });
  }

  // Si userName est fourni, on l'utilise, sinon on cherche le nom de l'utilisateur
  let finalUserName = userName;
  if (!finalUserName && userId && userId !== 0) {
    db.get('SELECT name FROM users WHERE id = ?', [userId], (err, user) => {
      if (!err && user) {
        finalUserName = user.name;
      }
      insertReview();
    });
  } else {
    insertReview();
  }

  function insertReview() {
    // reservationId est NOT NULL, donc on utilise 0 si non fourni (avis système/admin)
    const finalReservationId = reservationId || 0;
    
    db.run(
      `INSERT INTO reviews (professionalId, userId, rating, comment, reservationId, createdAt) 
       VALUES (?, ?, ?, ?, ?, datetime("now"))`,
      [professionalId, userId || 0, rating, comment || null, finalReservationId],
      function(err) {
        if (err) {
          console.error('Erreur création avis:', err);
          return res.status(500).json({ 
            message: 'Erreur serveur lors de la création de l\'avis',
            error: err.message 
          });
        }
        
        // Si userName est fourni et que la colonne existe, mettre à jour
        if (finalUserName) {
          db.run(
            'UPDATE reviews SET userName = ? WHERE id = ?',
            [finalUserName, this.lastID],
            (updateErr) => {
              // Ignorer les erreurs si la colonne n'existe pas
              if (updateErr && !updateErr.message.includes('no such column')) {
                console.error('Erreur mise à jour userName:', updateErr);
              }
            }
          );
        }
        
        res.json({ id: this.lastID, message: 'Avis créé avec succès' });
      }
    );
  }
});

app.delete('/api/reviews/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM reviews WHERE id = ?', [id], function(err) {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json({ message: 'Avis supprimé' });
  });
});

// Routes des réservations
// Route publique pour l'app mobile
app.get('/api/reservations', (req, res) => {
  const { userId, professionnelId } = req.query;
  let query = `
    SELECT 
      r.*,
      u1.name as familleName,
      u2.name as professionalName
    FROM reservations r
    LEFT JOIN users u1 ON r.userId = u1.id
    LEFT JOIN users u2 ON r.professionnelId = u2.id
  `;
  const params = [];

  if (userId) {
    query += ' WHERE r.userId = ?';
    params.push(userId);
  } else if (professionnelId) {
    query += ' WHERE r.professionnelId = ?';
    params.push(professionnelId);
  }

  query += ' ORDER BY r.date DESC, r.heure DESC';

  db.all(query, params, (err, rows) => {
    if (err) {
      console.error('Erreur récupération réservations:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json(rows);
  });
});

// Route protégée pour le Dashboard (avec authentification)
app.get('/api/reservations/admin', authenticateToken, (req, res) => {
  db.all(`
    SELECT 
      r.*,
      u1.name as familleName,
      u2.name as professionalName
    FROM reservations r
    LEFT JOIN users u1 ON r.userId = u1.id
    LEFT JOIN users u2 ON r.professionnelId = u2.id
    ORDER BY r.date DESC, r.heure DESC
  `, (err, rows) => {
    if (err) {
      console.error('Erreur récupération réservations:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    res.json(rows);
  });
});

app.get('/api/reservations/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.get(`
    SELECT 
      r.*,
      u1.name as familleName,
      u2.name as professionalName
    FROM reservations r
    LEFT JOIN users u1 ON r.userId = u1.id
    LEFT JOIN users u2 ON r.professionnelId = u2.id
    WHERE r.id = ?
  `, [id], (err, row) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    if (!row) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }
    res.json(row);
  });
});

app.put('/api/reservations/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ message: 'Le statut est requis' });
  }

  const allowedStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];
  if (!allowedStatuses.includes(status)) {
    return res.status(400).json({ message: 'Statut invalide' });
  }

  db.run(
    'UPDATE reservations SET status = ? WHERE id = ?',
    [status, id],
    function(err) {
      if (err) {
        console.error('Erreur mise à jour réservation:', err);
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ message: 'Réservation non trouvée' });
      }
      res.json({ message: 'Réservation mise à jour', id: parseInt(id) });
    }
  );
});

app.delete('/api/reservations/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM reservations WHERE id = ?', [id], function(err) {
    if (err) {
      return res.status(500).json({ message: 'Erreur serveur' });
    }
    if (this.changes === 0) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }
    res.json({ message: 'Réservation supprimée' });
  });
});

// Routes des messages
// Route publique pour l'app mobile
app.get('/api/messages', (req, res) => {
  const { userId, partnerId } = req.query;
  
  if (!userId || !partnerId) {
    return res.status(400).json({ message: 'userId et partnerId requis' });
  }

  db.all(
    'SELECT * FROM messages WHERE (senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?) ORDER BY timestamp ASC',
    [userId, partnerId, partnerId, userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json(rows);
    }
  );
});

app.post('/api/messages', (req, res) => {
  const { senderId, receiverId, content } = req.body;

  if (!senderId || !receiverId || !content) {
    return res.status(400).json({ message: 'Champs requis manquants' });
  }

  db.run(
    'INSERT INTO messages (senderId, receiverId, content, timestamp, isRead) VALUES (?, ?, ?, datetime("now"), 0)',
    [senderId, receiverId, content],
    function(err) {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json({ id: this.lastID, message: 'Message envoyé' });
    }
  );
});

// Route pour récupérer les partenaires de conversation d'un utilisateur
app.get('/api/messages/partners', (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ message: 'userId requis' });
  }

  db.all(
    `SELECT DISTINCT 
      CASE 
        WHEN senderId = ? THEN receiverId 
        ELSE senderId 
      END as partnerId
    FROM messages 
    WHERE senderId = ? OR receiverId = ?`,
    [userId, userId, userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      const partnerIds = rows.map((row) => row.partnerId).filter((id) => id != null);
      res.json(partnerIds);
    }
  );
});

// Routes des messages pour le Dashboard (avec authentification)
app.get('/api/messages/admin', authenticateToken, (req, res) => {
  const { userId } = req.query;

  if (userId) {
    // Récupérer les messages avec un utilisateur spécifique (admin = senderId 0 ou receiverId 0)
    db.all(
      `SELECT m.*, 
        u1.name as senderName, u1.userType as senderType,
        u2.name as receiverName, u2.userType as receiverType
      FROM messages m
      LEFT JOIN users u1 ON m.senderId = u1.id
      LEFT JOIN users u2 ON m.receiverId = u2.id
      WHERE (m.senderId = 0 AND m.receiverId = ?) OR (m.senderId = ? AND m.receiverId = 0)
      ORDER BY m.timestamp ASC`,
      [userId, userId],
      (err, rows) => {
        if (err) {
          return res.status(500).json({ message: 'Erreur serveur' });
        }
        res.json(rows);
      }
    );
  } else {
    // Récupérer tous les messages où l'admin est impliqué
    db.all(
      `SELECT m.*, 
        u1.name as senderName, u1.userType as senderType,
        u2.name as receiverName, u2.userType as receiverType
      FROM messages m
      LEFT JOIN users u1 ON m.senderId = u1.id
      LEFT JOIN users u2 ON m.receiverId = u2.id
      WHERE m.senderId = 0 OR m.receiverId = 0
      ORDER BY m.timestamp DESC`,
      (err, rows) => {
        if (err) {
          return res.status(500).json({ message: 'Erreur serveur' });
        }
        res.json(rows);
      }
    );
  }
});

app.post('/api/messages/admin', authenticateToken, (req, res) => {
  const { senderId, receiverId, content } = req.body;

  if (!receiverId || !content) {
    return res.status(400).json({ message: 'receiverId et content requis' });
  }

  // L'admin envoie toujours avec senderId = 0
  db.run(
    'INSERT INTO messages (senderId, receiverId, content, timestamp, isRead) VALUES (0, ?, ?, datetime("now"), 0)',
    [receiverId, content],
    function(err) {
      if (err) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
      res.json({ id: this.lastID, message: 'Message envoyé' });
    }
  );
});

// Route de synchronisation de réservation depuis Flutter
app.post('/api/reservations/sync', (req, res) => {
  const { userId, professionnelId, date, heure, status } = req.body;

  if (!userId || !professionnelId || !date || !heure) {
    return res.status(400).json({ message: 'Champs requis manquants' });
  }

  // Vérifier si la réservation existe déjà (par userId, professionnelId, date, heure)
  db.get(
    'SELECT id FROM reservations WHERE userId = ? AND professionnelId = ? AND date = ? AND heure = ?',
    [userId, professionnelId, date, heure],
    (err, existing) => {
      if (err) {
        console.error('Erreur vérification réservation:', err);
        return res.status(500).json({ message: 'Erreur serveur' });
      }

      if (existing) {
        // Réservation existe déjà, mettre à jour le statut si nécessaire
        db.run(
          'UPDATE reservations SET status = ? WHERE id = ?',
          [status || 'pending', existing.id],
          function(updateErr) {
            if (updateErr) {
              return res.status(500).json({ message: 'Erreur serveur' });
            }
            res.json({ id: existing.id, message: 'Réservation mise à jour' });
          }
        );
      } else {
        // Créer une nouvelle réservation
        db.run(
          'INSERT INTO reservations (userId, professionnelId, date, heure, status, createdAt) VALUES (?, ?, ?, ?, ?, datetime("now"))',
          [userId, professionnelId, date, heure, status || 'pending'],
          function(insertErr) {
            if (insertErr) {
              console.error('Erreur création réservation:', insertErr);
              return res.status(500).json({ message: 'Erreur serveur' });
            }
            res.json({ id: this.lastID, message: 'Réservation synchronisée' });
          }
        );
      }
    }
  );
});

// Route de synchronisation d'utilisateur depuis Flutter
app.post('/api/users/sync', (req, res) => {
  const { name, email, password, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite } = req.body;

  if (!name || !email || !password || !categorie || !userType) {
    return res.status(400).json({ message: 'Champs requis manquants' });
  }

  // Vérifier si l'utilisateur existe déjà
  db.get('SELECT id FROM users WHERE email = ?', [email], async (err, existingUser) => {
    if (err) {
      console.error('Erreur DB:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }

    if (existingUser) {
      // Mettre à jour l'utilisateur existant
      db.run(
        `UPDATE users SET 
          name = ?, password = ?, phone = ?, categorie = ?, ville = ?, 
          tarif = ?, experience = ?, photo = ?, userType = ?,
          besoin = ?, preference = ?, mission = ?, particularite = ?
         WHERE email = ?`,
        [name, password, phone || null, categorie, ville || null, tarif || null, experience || null, photo || null, userType, besoin || null, preference || null, mission || null, particularite || null, email],
        function(updateErr) {
          if (updateErr) {
            console.error('Erreur mise à jour:', updateErr);
            return res.status(500).json({ message: 'Erreur lors de la mise à jour' });
          }
          res.json({ message: 'Utilisateur mis à jour', id: existingUser.id, user: { id: existingUser.id, name, email, userType, besoin, preference, mission, particularite } });
        }
      );
    } else {
      // Créer un nouvel utilisateur (hasher le mot de passe)
      const bcrypt = require('bcryptjs');
      const hashedPassword = await bcrypt.hash(password, 10);
      
      db.run(
        `INSERT INTO users (name, email, password, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite, createdAt)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime("now"))`,
        [name, email, hashedPassword, phone || null, categorie, ville || null, tarif || null, experience || null, photo || null, userType, besoin || null, preference || null, mission || null, particularite || null],
        function(insertErr) {
          if (insertErr) {
            console.error('Erreur insertion:', insertErr);
            return res.status(500).json({ message: 'Erreur lors de la création' });
          }
          res.json({ 
            message: 'Utilisateur créé', 
            id: this.lastID,
            user: { id: this.lastID, name, email, userType, besoin, preference, mission, particularite }
          });
        }
      );
    }
  });
});

// Route racine
app.get('/', (req, res) => {
  res.json({
    message: 'Auxivie API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      users: '/api/users',
      documents: '/api/documents',
      payments: '/api/payments',
      badges: '/api/badges',
      ratings: '/api/ratings',
      reviews: '/api/reviews',
      reservations: '/api/reservations',
    },
  });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur API démarré sur http://localhost:${PORT}`);
});


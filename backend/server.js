// Charger les variables d'environnement
require('dotenv').config({ path: process.env.NODE_ENV === 'production' ? '.env.production' : '.env' });

const express = require('express');
const cors = require('cors');
const db = require('./db');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const fs = require('fs');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder');
const { sendAdminMessageNotification } = require('./email');

const app = express();

// Routes Stripe
const stripeRoutes = require('./routes/stripe');
const reportsRoutes = require('./routes/reports');
const reviewsRoutes = require('./routes/reviews');
const protectedUsersRoutes = require('./routes/protected-users');

const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Configuration du stockage des fichiers
const uploadsDir = path.join(__dirname, 'uploads');
const documentsDir = path.join(uploadsDir, 'documents');
const photosDir = path.join(uploadsDir, 'photos');

// Créer les dossiers s'ils n'existent pas
[uploadsDir, documentsDir, photosDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Configuration multer pour les documents
const documentStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, documentsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `doc-${req.body.userId || 'unknown'}-${uniqueSuffix}${ext}`);
  }
});

// Configuration multer pour les photos de profil
const photoStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, photosDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `photo-${req.body.userId || 'unknown'}-${uniqueSuffix}${ext}`);
  }
});

const uploadDocument = multer({
  storage: documentStorage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Type de fichier non autorisé. Formats acceptés: JPEG, PNG, PDF'));
    }
  }
});

const uploadPhoto = multer({
  storage: photoStorage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Type de fichier non autorisé. Formats acceptés: JPEG, PNG'));
    }
  }
});

// Configuration CORS pour production
const corsOptions = {
  origin: process.env.CORS_ORIGIN 
    ? process.env.CORS_ORIGIN.split(',').map(origin => origin.trim())
    : process.env.NODE_ENV === 'production'
      ? ['https://www.auxivie.org', 'https://auxivie.org', 'https://api.auxivie.org', 'http://178.16.131.24:3001']
      : '*', // En développement, autoriser toutes les origines
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-request-type']
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());

// Utiliser les routes Stripe
app.use('/api/stripe', stripeRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/reviews', reviewsRoutes);
app.use('/api/protected-users', protectedUsersRoutes);


// Servir les fichiers statiques (photos et documents)
app.use('/uploads', express.static(uploadsDir));

// Headers de sécurité (basique)
app.use((req, res, next) => {
  if (process.env.NODE_ENV === 'production') {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-XSS-Protection', '1; mode=block');
  }
  next();
});

// Initialiser la base de données MySQL
(async () => {
  try {
    await db.initializeTables();
  } catch (error) {
    console.error('Erreur initialisation base de données:', error);
  }
})();

// Routes d'authentification
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const isMobileRequest = req.headers['x-request-type'] === 'mobile';

    if (!email || !password) {
      return res.status(400).json({ message: 'Email et mot de passe requis' });
    }

    // Essayer d'abord de trouver l'utilisateur dans la table admins (pour le dashboard)
    try {
      const admin = await db.get('SELECT * FROM admins WHERE email = ?', [email]);

      if (admin) {
        // Vérifier le mot de passe admin
        let isValid = false;
        
        // Si le mot de passe en base commence par $2b$ ou $2a$, c'est un hash bcrypt
        if (admin.password.startsWith('$2b$') || admin.password.startsWith('$2a$')) {
          isValid = await bcrypt.compare(password, admin.password);
        } else {
          // Sinon, c'est un mot de passe en clair (pour migration)
          isValid = password === admin.password;
          
          // Si la connexion réussit avec un mot de passe en clair, hasher et mettre à jour
          if (isValid) {
            const hashedPassword = await bcrypt.hash(password, 10);
            try {
              await db.run('UPDATE admins SET password = ? WHERE id = ?', [hashedPassword, admin.id]);
              console.log(`✅ Mot de passe hashé pour l'admin ${admin.id}`);
            } catch (err) {
              console.error('Erreur lors du hashage du mot de passe:', err);
            }
          }
        }

        if (!isValid) {
          return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }

        // Générer le token JWT pour l'admin
        const token = jwt.sign(
          { userId: admin.id, email: admin.email, userType: 'admin', isAdmin: true },
          JWT_SECRET,
          { expiresIn: '24h' }
        );

        return res.json({
          token,
          user: {
            id: admin.id,
            name: admin.name,
            email: admin.email,
            userType: 'admin',
          },
        });
      }

      // Si pas trouvé dans admins, chercher dans users
      const user = await db.get('SELECT * FROM users WHERE email = ?', [email]);

      if (!user) {
        return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
      }

      // Vérifier le mot de passe
      let isValid = false;
      
      // Si le mot de passe en base commence par $2b$, c'est un hash bcrypt
      if (user.password.startsWith('$2b$')) {
        isValid = await bcrypt.compare(password, user.password);
      } else {
        // Sinon, c'est un mot de passe en clair (pour migration)
        isValid = password === user.password;
        
        // Si la connexion réussit avec un mot de passe en clair, hasher et mettre à jour
        if (isValid) {
          const hashedPassword = await bcrypt.hash(password, 10);
          try {
            await db.run('UPDATE users SET password = ? WHERE id = ?', [hashedPassword, user.id]);
            console.log(`✅ Mot de passe hashé pour l'utilisateur ${user.id}`);
          } catch (err) {
            console.error('Erreur lors du hashage du mot de passe:', err);
          }
        }
      }

      if (!isValid) {
        return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
      }

      // Si c'est une requête mobile, accepter tous les types d'utilisateurs
      // Sinon, vérifier que c'est un admin (pour le dashboard)
      if (!isMobileRequest && user.userType !== 'admin') {
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
    } catch (error) {
      console.error('Erreur DB:', error);
      return res.status(500).json({ message: 'Erreur serveur' });
    }
  } catch (error) {
    console.error('Erreur login:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});


// Redirection rapide : /login -> frontend
app.get('/login', (req, res) => {
  return res.redirect(301, 'https://auxivie.org/login');
});

// ========== ENDPOINT D'ENREGISTREMENT ADMIN ==========
app.post('/api/auth/register-admin', async (req, res) => {
  try {
    const { email, password, name, adminKey } = req.body;

    // Validation des champs requis
    if (!email || !password || !name || !adminKey) {
      return res.status(400).json({ message: 'Email, mot de passe, nom et clé admin requis' });
    }

    // Vérification de la clé admin (variable d'environnement)
    const ADMIN_KEY = process.env.ADMIN_REGISTRATION_KEY || 'auxivie-admin-2025';
    if (adminKey !== ADMIN_KEY) {
      return res.status(403).json({ message: 'Clé admin invalide' });
    }

    // Vérifier si l'email existe déjà dans la table users
    try {
      const existingUser = await db.get('SELECT id FROM users WHERE email = ?', [email]);
      if (existingUser) {
        return res.status(409).json({ message: 'Cet email est déjà enregistré' });
      }
    } catch (err) {
      console.error('Erreur vérification email:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }

    // Vérifier la force du mot de passe (min 8 caractères)
    if (password.length < 8) {
      return res.status(400).json({ message: 'Le mot de passe doit contenir au moins 8 caractères' });
    }

    // Hasher le mot de passe
    let hashedPassword;
    try {
      hashedPassword = await bcrypt.hash(password, 10);
    } catch (err) {
      console.error('Erreur hashage:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }

    // Créer l'administrateur dans la table admins
    try {
      const result = await db.run(
        'INSERT INTO admins (email, password, name, createdAt) VALUES (?, ?, ?, NOW())',
        [email, hashedPassword, name]
      );

      console.log(`✅ Admin créé avec succès: ${email} (ID: ${result.lastID})`);

      // Générer le token JWT
      const token = jwt.sign(
        {
          userId: result.lastID,
          email: email,
          userType: 'admin',
        },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '7d' }
      );

      res.status(201).json({
        message: 'Administrateur créé avec succès',
        token,
        user: {
          id: result.lastID,
          name: name,
          email: email,
          userType: 'admin',
        },
      });
    } catch (err) {
      console.error('Erreur création admin:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }
  } catch (error) {
    console.error('Erreur register-admin:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});





// Route de santé
// ========== ENDPOINT D'ENREGISTREMENT ADMIN ==========
app.post('/api/auth/register-admin', async (req, res) => {
  try {
    const { email, password, name, adminKey } = req.body;

    // Validation des champs requis
    if (!email || !password || !name || !adminKey) {
      return res.status(400).json({ message: 'Email, mot de passe, nom et clé admin requis' });
    }

    // Vérification de la clé admin (variable d'environnement)
    const ADMIN_KEY = process.env.ADMIN_REGISTRATION_KEY || 'auxivie-admin-2025';
    if (adminKey !== ADMIN_KEY) {
      return res.status(403).json({ message: 'Clé admin invalide' });
    }

    // Vérifier si l'email existe déjà dans la table users
    try {
      const existingUser = await db.get('SELECT id FROM users WHERE email = ?', [email]);
      if (existingUser) {
        return res.status(409).json({ message: 'Cet email est déjà enregistré' });
      }
    } catch (err) {
      console.error('Erreur vérification email:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }

    // Vérifier la force du mot de passe (min 8 caractères)
    if (password.length < 8) {
      return res.status(400).json({ message: 'Le mot de passe doit contenir au moins 8 caractères' });
    }

    // Hasher le mot de passe
    let hashedPassword;
    try {
      hashedPassword = await bcrypt.hash(password, 10);
    } catch (err) {
      console.error('Erreur hashage:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }

    // Créer l'administrateur dans la table admins
    try {
      const result = await db.run(
        'INSERT INTO admins (email, password, name, createdAt) VALUES (?, ?, ?, NOW())',
        [email, hashedPassword, name]
      );

      console.log(`✅ Admin créé avec succès: ${email} (ID: ${result.lastID})`);

      // Générer le token JWT
      const token = jwt.sign(
        {
          userId: result.lastID,
          email: email,
          userType: 'admin',
        },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '7d' }
      );

      res.status(201).json({
        message: 'Administrateur créé avec succès',
        token,
        user: {
          id: result.lastID,
          name: name,
          email: email,
          userType: 'admin',
        },
      });
    } catch (err) {
      console.error('Erreur création admin:', err);
      return res.status(500).json({ message: 'Erreur serveur' });
    }
  } catch (error) {
    console.error('Erreur register-admin:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

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

// ========== GESTION DES ADMINISTRATEURS ==========
// Liste des administrateurs
app.get('/api/admins', async (req, res) => {
  try {
    const admins = await db.all('SELECT id, email, name, age, phone, address, createdAt FROM admins ORDER BY id');
    res.json(admins);
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer un administrateur
app.delete('/api/admins/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Vérifier qu'il reste au moins un admin
    const admins = await db.all('SELECT id FROM admins');
    if (admins.length <= 1) {
      return res.status(400).json({ message: 'Impossible de supprimer le dernier administrateur' });
    }
    
    // Supprimer l'admin
    await db.run('DELETE FROM admins WHERE id = ?', [id]);
    res.json({ message: 'Administrateur supprimé' });
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Routes des utilisateurs
// Route publique pour récupérer les professionnels (app mobile)
app.get('/api/users', async (req, res) => {
  try {
    const { userType } = req.query;
    
    // Si userType=professionnel, route publique pour l'app mobile
    if (userType === 'professionnel') {
      const rows = await db.all('SELECT id, name, email, phone, categorie, ville, tarif, experience, photo, userType FROM users WHERE userType = "professionnel"');
      return res.json(rows);
    }
    
    // Sinon, nécessite authentification (pour le dashboard)
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Token manquant' });
    }
    
    jwt.verify(token, JWT_SECRET, async (err, user) => {
      if (err) {
        return res.status(403).json({ message: 'Token invalide' });
      }
      
      try {
        const rows = await db.all('SELECT id, name, email, phone, categorie, ville, tarif, userType FROM users WHERE userType != "admin"');
        res.json(rows);
      } catch (error) {
        return res.status(500).json({ message: 'Erreur serveur' });
      }
    });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route publique pour l'app mobile
app.get('/api/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const row = await db.get('SELECT id, name, firstName, lastName, email, phone, dateOfBirth, address, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite FROM users WHERE id = ?', [id]);
    if (!row) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    res.json(row);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route protégée pour le Dashboard
app.get('/api/users/:id/admin', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const row = await db.get('SELECT id, name, firstName, lastName, email, phone, dateOfBirth, address, categorie, ville, tarif, experience, photo, userType, suspended, createdAt FROM users WHERE id = ?', [id]);
    if (!row) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    res.json(row);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.put('/api/users/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone, categorie, ville, tarif, password, currentPassword } = req.body;
    
    // Si un nouveau mot de passe est fourni, vérifier l'ancien et hasher le nouveau
    if (password) {
      // Récupérer l'utilisateur actuel pour vérifier le mot de passe
      const user = await db.get('SELECT password FROM users WHERE id = ?', [id]);
      
      if (!user) {
        return res.status(404).json({ message: 'Utilisateur non trouvé' });
      }
      
      // Vérifier le mot de passe actuel si fourni
      if (currentPassword) {
        const isMatch = await bcrypt.compare(currentPassword, user.password);
        if (!isMatch) {
          return res.status(401).json({ message: 'Mot de passe actuel incorrect' });
        }
      }
      
      // Hasher le nouveau mot de passe
      const hashedPassword = await bcrypt.hash(password, 10);
      
      // Mettre à jour avec le mot de passe hashé
      const fields = [];
      const values = [];
      
      if (name !== undefined) { fields.push('name = ?'); values.push(name); }
      if (email !== undefined) { fields.push('email = ?'); values.push(email); }
      if (phone !== undefined) { fields.push('phone = ?'); values.push(phone); }
      if (categorie !== undefined) { fields.push('categorie = ?'); values.push(categorie); }
      if (ville !== undefined) { fields.push('ville = ?'); values.push(ville); }
      if (tarif !== undefined) { fields.push('tarif = ?'); values.push(tarif); }
      fields.push('password = ?'); values.push(hashedPassword);
      values.push(id);
      
      await db.run(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, values);
      return res.json({ message: 'Utilisateur mis à jour' });
    } else {
      // Mise à jour normale sans changement de mot de passe
      const fields = [];
      const values = [];
      
      if (name !== undefined) { fields.push('name = ?'); values.push(name); }
      if (email !== undefined) { fields.push('email = ?'); values.push(email); }
      if (phone !== undefined) { fields.push('phone = ?'); values.push(phone); }
      if (categorie !== undefined) { fields.push('categorie = ?'); values.push(categorie); }
      if (ville !== undefined) { fields.push('ville = ?'); values.push(ville); }
      if (tarif !== undefined) { fields.push('tarif = ?'); values.push(tarif); }
      values.push(id);
      
      if (fields.length === 0) {
        return res.status(400).json({ message: 'Aucun champ à mettre à jour' });
      }
      
      await db.run(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, values);
      return res.json({ message: 'Utilisateur mis à jour' });
    }
  } catch (error) {
    console.error('Erreur mise à jour utilisateur:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Routes des documents
app.get('/api/documents', authenticateToken, async (req, res) => {
  try {
    const rows = await db.all(`
      SELECT d.*, u.name as userName 
      FROM documents d
      LEFT JOIN users u ON d.userId = u.id
      ORDER BY d.createdAt DESC
    `);
    // Ajouter un champ verified basé sur le statut
    const documents = rows.map(doc => ({
      ...doc,
      verified: doc.status === 'verified',
    }));
    res.json(documents);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/documents/:id/verify', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    await db.run('UPDATE documents SET status = "verified" WHERE id = ?', [id]);
    res.json({ message: 'Document vérifié' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/documents/:id/reject', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    await db.run('UPDATE documents SET status = "rejected" WHERE id = ?', [id]);
    res.json({ message: 'Document refusé' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour uploader un document
app.post('/api/documents/upload', uploadDocument.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Aucun fichier fourni' });
    }

    const { userId, type } = req.body;

    if (!userId || !type) {
      // Supprimer le fichier si les paramètres sont invalides
      fs.unlinkSync(req.file.path);
      return res.status(400).json({ message: 'userId et type sont requis' });
    }

    // Enregistrer le document dans la base de données
    const filePath = `/uploads/documents/${path.basename(req.file.path)}`;
    try {
      const result = await db.run(
        'INSERT INTO documents (userId, type, path, status, createdAt) VALUES (?, ?, ?, "pending", NOW())',
        [userId, type, filePath]
      );
      res.json({
        id: result.lastID,
        message: 'Document uploadé avec succès',
        path: filePath,
        url: `${req.protocol}://${req.get('host')}${filePath}`
      });
    } catch (err) {
      // Supprimer le fichier en cas d'erreur
      fs.unlinkSync(req.file.path);
      console.error('Erreur insertion document:', err);
      return res.status(500).json({ message: 'Erreur lors de l\'enregistrement du document' });
    }
  } catch (error) {
    console.error('Erreur upload document:', error);
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ message: 'Erreur serveur lors de l\'upload' });
  }
});

// Route pour uploader une photo de profil
app.post('/api/users/:id/photo', uploadPhoto.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Aucune photo fournie' });
    }

    const { id } = req.params;
    const filePath = `/uploads/photos/${path.basename(req.file.path)}`;
    const photoUrl = `${req.protocol}://${req.get('host')}${filePath}`;

    try {
      // Supprimer l'ancienne photo si elle existe
      const user = await db.get('SELECT photo FROM users WHERE id = ?', [id]);

      if (user && user.photo) {
        const oldPhotoPath = path.join(__dirname, user.photo);
        if (fs.existsSync(oldPhotoPath)) {
          fs.unlinkSync(oldPhotoPath);
        }
      }

      // Mettre à jour la photo dans la base de données
      await db.run('UPDATE users SET photo = ? WHERE id = ?', [photoUrl, id]);
      res.json({
        message: 'Photo de profil mise à jour',
        photo: photoUrl
      });
    } catch (err) {
      fs.unlinkSync(req.file.path);
      console.error('Erreur mise à jour photo:', err);
      return res.status(500).json({ message: 'Erreur lors de la mise à jour de la photo' });
    }
  } catch (error) {
    console.error('Erreur upload photo:', error);
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ message: 'Erreur serveur lors de l\'upload' });
  }
});

// Routes des paiements
app.get('/api/payments', authenticateToken, async (req, res) => {
  try {
    const rows = await db.all(`
      SELECT p.*, u.name as userName, r.id as reservationId
      FROM payments p
      LEFT JOIN users u ON p.userId = u.id
      LEFT JOIN reservations r ON p.reservationId = r.id
      ORDER BY p.createdAt DESC
    `);
    res.json(rows || []);
  } catch (error) {
    // Si la table n'existe pas ou erreur, retourner un tableau vide
    console.error('Erreur payments:', error);
    return res.json([]);
  }
});

// Route pour créer un PaymentIntent Stripe
app.post('/api/payments/create-intent', async (req, res) => {
  try {
    const { amount, currency = 'eur', reservationId, userId } = req.body;

    if (!amount || !reservationId || !userId) {
      return res.status(400).json({ message: 'amount, reservationId et userId sont requis' });
    }

    // Créer un PaymentIntent avec Stripe
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convertir en centimes
      currency: currency.toLowerCase(),
      metadata: {
        reservationId: reservationId.toString(),
        userId: userId.toString(),
      },
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error('Erreur création PaymentIntent:', error);
    res.status(500).json({ message: 'Erreur lors de la création du paiement', error: error.message });
  }
});

// Route pour confirmer un paiement
app.post('/api/payments/confirm', async (req, res) => {
  try {
    const { paymentIntentId, reservationId, userId, amount } = req.body;

    if (!paymentIntentId || !reservationId || !userId || !amount) {
      return res.status(400).json({ message: 'Tous les champs sont requis' });
    }

    // Récupérer le PaymentIntent depuis Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status !== 'succeeded') {
      return res.status(400).json({ message: 'Le paiement n\'a pas été confirmé' });
    }

    // Enregistrer le paiement dans la base de données
    try {
      const result = await db.run(
        `INSERT INTO payments (userId, reservationId, amount, status, paymentMethod, createdAt)
         VALUES (?, ?, ?, 'completed', 'stripe', NOW())`,
        [userId, reservationId, amount]
      );
      res.json({
        id: result.lastID,
        message: 'Paiement confirmé et enregistré',
      });
    } catch (err) {
      console.error('Erreur enregistrement paiement:', err);
      return res.status(500).json({ message: 'Erreur lors de l\'enregistrement du paiement' });
    }
  } catch (error) {
    console.error('Erreur confirmation paiement:', error);
    res.status(500).json({ message: 'Erreur lors de la confirmation du paiement', error: error.message });
  }
});

// Routes des badges
// Route publique pour l'application mobile (GET uniquement)
app.get('/api/badges', async (req, res) => {
  try {
    const { userId } = req.query;
    if (userId) {
      const rows = await db.all('SELECT * FROM user_badges WHERE userId = ?', [userId]);
      res.json(rows);
    } else {
      res.json([]);
    }
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/badges', authenticateToken, async (req, res) => {
  try {
    const { userId, badgeType, badgeName, badgeIcon, description } = req.body;
    const result = await db.run(
      'INSERT INTO user_badges (userId, badgeType, badgeName, badgeIcon, description, createdAt) VALUES (?, ?, ?, ?, ?, NOW())',
      [userId, badgeType, badgeName, badgeIcon, description]
    );
    res.json({ id: result.lastID, message: 'Badge ajouté' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.delete('/api/badges/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    await db.run('DELETE FROM user_badges WHERE id = ?', [id]);
    res.json({ message: 'Badge supprimé' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Routes des notes
// Route publique pour l'application mobile
app.get('/api/ratings', async (req, res) => {
  try {
    const { userId } = req.query;
    if (userId) {
      const row = await db.get('SELECT * FROM user_ratings WHERE userId = ?', [userId]);
      res.json(row || null);
    } else {
      res.json(null);
    }
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.put('/api/ratings/:userId', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { averageRating, totalRatings } = req.body;
    await db.run(
      'INSERT INTO user_ratings (userId, averageRating, totalRatings, updatedAt) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE averageRating = ?, totalRatings = ?, updatedAt = NOW()',
      [userId, averageRating, totalRatings, averageRating, totalRatings]
    );
    res.json({ message: 'Note mise à jour' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE - // Routes des avis
// ANCIENNE ROUTE - // Route publique pour l'application mobile
// ANCIENNE ROUTE - app.get('/api/reviews', async (req, res) => {
// ANCIENNE ROUTE -   try {
// ANCIENNE ROUTE -     const rows = await db.all(`
// ANCIENNE ROUTE -       SELECT 
// ANCIENNE ROUTE -         r.id,
// ANCIENNE ROUTE -         r.reservationId,
// ANCIENNE ROUTE -         r.userId,
// ANCIENNE ROUTE -         r.professionalId,
// ANCIENNE ROUTE -         r.rating,
// ANCIENNE ROUTE -         r.comment,
// ANCIENNE ROUTE -         r.createdAt,
// ANCIENNE ROUTE -         COALESCE(r.userName, u.name) as userName,
// ANCIENNE ROUTE -         p.name as professionalName
// ANCIENNE ROUTE -       FROM reviews r
// ANCIENNE ROUTE -       LEFT JOIN users u ON r.userId = u.id
// ANCIENNE ROUTE -       LEFT JOIN users p ON r.professionalId = p.id
// ANCIENNE ROUTE -       ORDER BY r.createdAt DESC
// ANCIENNE ROUTE -     `);
// ANCIENNE ROUTE -     res.json(rows);
// ANCIENNE ROUTE -   } catch (error) {
// ANCIENNE ROUTE -     console.error('Erreur récupération reviews:', error);
// ANCIENNE ROUTE -     // Si la table n'existe pas, retourner un tableau vide
// ANCIENNE ROUTE -     return res.json([]);
// ANCIENNE ROUTE -   }
// ANCIENNE ROUTE - });
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE - app.post('/api/reviews', authenticateToken, async (req, res) => {
// ANCIENNE ROUTE -   try {
// ANCIENNE ROUTE -     const { professionalId, userId, rating, comment, userName, reservationId } = req.body;
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE -     if (!professionalId || !rating) {
// ANCIENNE ROUTE -       return res.status(400).json({ message: 'professionalId et rating sont requis' });
// ANCIENNE ROUTE -     }
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE -     if (rating < 1 || rating > 5) {
// ANCIENNE ROUTE -       return res.status(400).json({ message: 'La note doit être entre 1 et 5' });
// ANCIENNE ROUTE -     }
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE -     // Si userName est fourni, on l'utilise, sinon on cherche le nom de l'utilisateur
// ANCIENNE ROUTE -     let finalUserName = userName;
// ANCIENNE ROUTE -     if (!finalUserName && userId && userId !== 0) {
// ANCIENNE ROUTE -       try {
// ANCIENNE ROUTE -         const user = await db.get('SELECT name FROM users WHERE id = ?', [userId]);
// ANCIENNE ROUTE -         if (user) {
// ANCIENNE ROUTE -           finalUserName = user.name;
// ANCIENNE ROUTE -         }
// ANCIENNE ROUTE -       } catch (err) {
// ANCIENNE ROUTE -         // Ignorer l'erreur
// ANCIENNE ROUTE -       }
// ANCIENNE ROUTE -     }
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE -     // reservationId est NOT NULL, donc on utilise 0 si non fourni (avis système/admin)
// ANCIENNE ROUTE -     const finalReservationId = reservationId || 0;
// ANCIENNE ROUTE -     
// ANCIENNE ROUTE -     const result = await db.run(
// ANCIENNE ROUTE -       `INSERT INTO reviews (professionalId, userId, rating, comment, reservationId, createdAt) 
// ANCIENNE ROUTE -        VALUES (?, ?, ?, ?, ?, NOW())`,
// ANCIENNE ROUTE -       [professionalId, userId || 0, rating, comment || null, finalReservationId]
// ANCIENNE ROUTE -     );
// ANCIENNE ROUTE -     
// ANCIENNE ROUTE -     // Si userName est fourni et que la colonne existe, mettre à jour
// ANCIENNE ROUTE -     if (finalUserName) {
// ANCIENNE ROUTE -       try {
// ANCIENNE ROUTE -         await db.run('UPDATE reviews SET userName = ? WHERE id = ?', [finalUserName, result.lastID]);
// ANCIENNE ROUTE -       } catch (updateErr) {
// ANCIENNE ROUTE -         // Ignorer les erreurs si la colonne n'existe pas
// ANCIENNE ROUTE -         if (!updateErr.message.includes('Unknown column')) {
// ANCIENNE ROUTE -           console.error('Erreur mise à jour userName:', updateErr);
// ANCIENNE ROUTE -         }
// ANCIENNE ROUTE -       }
// ANCIENNE ROUTE -     }
// ANCIENNE ROUTE -     
// ANCIENNE ROUTE -     res.json({ id: result.lastID, message: 'Avis créé avec succès' });
// ANCIENNE ROUTE -   } catch (error) {
// ANCIENNE ROUTE -     console.error('Erreur création avis:', error);
// ANCIENNE ROUTE -     return res.status(500).json({ 
// ANCIENNE ROUTE -       message: 'Erreur serveur lors de la création de l\'avis',
// ANCIENNE ROUTE -       error: error.message 
// ANCIENNE ROUTE -     });
// ANCIENNE ROUTE -   }
// ANCIENNE ROUTE - });
// ANCIENNE ROUTE - 
// ANCIENNE ROUTE - app.delete('/api/reviews/:id', authenticateToken, async (req, res) => {
// ANCIENNE ROUTE -   try {
// ANCIENNE ROUTE -     const { id } = req.params;
// ANCIENNE ROUTE -     await db.run('DELETE FROM reviews WHERE id = ?', [id]);
// ANCIENNE ROUTE -     res.json({ message: 'Avis supprimé' });
// ANCIENNE ROUTE -   } catch (error) {
// ANCIENNE ROUTE -     return res.status(500).json({ message: 'Erreur serveur' });
// ANCIENNE ROUTE -   }
// ANCIENNE ROUTE - });
// ANCIENNE ROUTE - 
// Routes des réservations
// Route publique pour l'app mobile
app.get('/api/reservations', async (req, res) => {
  try {
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

    const rows = await db.all(query, params);
    res.json(rows);
  } catch (error) {
    console.error('Erreur récupération réservations:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route protégée pour le Dashboard (avec authentification)
app.get('/api/reservations/admin', authenticateToken, async (req, res) => {
  try {
    const rows = await db.all(`
      SELECT 
        r.*,
        u1.name as familleName,
        u2.name as professionalName
      FROM reservations r
      LEFT JOIN users u1 ON r.userId = u1.id
      LEFT JOIN users u2 ON r.professionnelId = u2.id
      ORDER BY r.date DESC, r.heure DESC
    `);
    res.json(rows);
  } catch (error) {
    console.error('Erreur récupération réservations:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.get('/api/reservations/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const row = await db.get(`
      SELECT 
        r.*,
        u1.name as familleName,
        u2.name as professionalName
      FROM reservations r
      LEFT JOIN users u1 ON r.userId = u1.id
      LEFT JOIN users u2 ON r.professionnelId = u2.id
      WHERE r.id = ?
    `, [id]);
    if (!row) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }
    res.json(row);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.put('/api/reservations/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ message: 'Le statut est requis' });
    }

    const allowedStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ message: 'Statut invalide' });
    }

    const result = await db.run('UPDATE reservations SET status = ? WHERE id = ?', [status, id]);
    if (result.changes === 0) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }
    res.json({ message: 'Réservation mise à jour', id: parseInt(id) });
  } catch (error) {
    console.error('Erreur mise à jour réservation:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.delete('/api/reservations/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.run('DELETE FROM reservations WHERE id = ?', [id]);
    if (result.changes === 0) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }
    res.json({ message: 'Réservation supprimée' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Routes des messages
// Route publique pour l'app mobile
app.get('/api/messages', async (req, res) => {
  try {
    const { userId, partnerId } = req.query;
    
    if (!userId || !partnerId) {
      return res.status(400).json({ message: 'userId et partnerId requis' });
    }

    const rows = await db.all(
      'SELECT * FROM messages WHERE (senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?) ORDER BY timestamp ASC',
      [userId, partnerId, partnerId, userId]
    );
    res.json(rows);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/messages', async (req, res) => {
  try {
    const { senderId, receiverId, content } = req.body;

    if (!senderId || !receiverId || !content) {
      return res.status(400).json({ message: 'Champs requis manquants' });
    }

    const result = await db.run(
      'INSERT INTO messages (senderId, receiverId, content, timestamp, isRead) VALUES (?, ?, ?, NOW(), 0)',
      [senderId, receiverId, content]
    );
    res.json({ id: result.lastID, message: 'Message envoyé' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route pour récupérer les partenaires de conversation d'un utilisateur
app.get('/api/messages/partners', async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({ message: 'userId requis' });
    }

    const rows = await db.all(
      `SELECT DISTINCT 
        CASE 
          WHEN senderId = ? THEN receiverId 
          ELSE senderId 
        END as partnerId
      FROM messages 
      WHERE senderId = ? OR receiverId = ?`,
      [userId, userId, userId]
    );
    const partnerIds = rows.map((row) => row.partnerId).filter((id) => id != null);
    res.json(partnerIds);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Routes des messages pour le Dashboard (avec authentification)
app.get('/api/messages/admin', authenticateToken, async (req, res) => {
  try {
    const { userId } = req.query;
    const adminId = req.user.userId; // ID de l'admin connecté

    if (userId) {
      // Récupérer les messages avec un utilisateur spécifique
      // L'admin peut être le sender OU le receiver
      // On inclut aussi les anciens messages avec senderId = 0 pour compatibilité
      const rows = await db.all(
        `SELECT m.*, 
          u1.name as senderName, u1.userType as senderType,
          u2.name as receiverName, u2.userType as receiverType
        FROM messages m
        LEFT JOIN users u1 ON m.senderId = u1.id
        LEFT JOIN users u2 ON m.receiverId = u2.id
        WHERE (
          (m.senderId = ? AND m.receiverId = ?) OR 
          (m.senderId = ? AND m.receiverId = ?) OR
          (m.senderId = 0 AND m.receiverId = ?) OR 
          (m.senderId = ? AND m.receiverId = 0)
        )
        ORDER BY m.timestamp ASC`,
        [adminId, userId, userId, adminId, userId, userId]
      );
      // Marquer les messages comme lus quand l'admin ouvre la conversation
      // Marquer uniquement les messages où l'admin est le receiver et l'utilisateur est le sender
      await db.run(
        `UPDATE messages 
         SET isRead = 1 
         WHERE (
           (receiverId = ? OR receiverId = 0) 
           AND (senderId = ?)
           AND isRead = 0
         )`,
        [adminId, userId]
      );
      
      res.json(rows);
    } else {
      // Récupérer tous les messages où l'admin est impliqué
      // On inclut aussi les anciens messages avec senderId = 0 ou receiverId = 0 pour compatibilité
      const rows = await db.all(
        `SELECT m.*, 
          u1.name as senderName, u1.userType as senderType,
          u2.name as receiverName, u2.userType as receiverType
        FROM messages m
        LEFT JOIN users u1 ON m.senderId = u1.id
        LEFT JOIN users u2 ON m.receiverId = u2.id
        WHERE m.senderId = ? OR m.receiverId = ? OR m.senderId = 0 OR m.receiverId = 0
        ORDER BY m.timestamp DESC`,
        [adminId, adminId]
      );
      res.json(rows);
    }
  } catch (error) {
    console.error('Erreur récupération messages admin:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/messages/admin', authenticateToken, async (req, res) => {
  console.log('POST /api/messages/admin called');
  console.log('Body:', req.body);
  console.log('User:', req.user);
  try {
    const { senderId, receiverId, content } = req.body;

    if (!receiverId || !content) {
      return res.status(400).json({ message: 'receiverId et content requis' });
    }

    // Utiliser l'ID de l'admin connecté (req.user.userId) au lieu de 0 pour éviter les contraintes de clé étrangère
    // Note: Pour l'affichage, on considère toujours que c'est un message admin
    const adminId = req.user.userId || 0;
    const result = await db.run(
      'INSERT INTO messages (senderId, receiverId, content, timestamp, isRead) VALUES (?, ?, ?, NOW(), 0)',
      [adminId, receiverId, content]
    );

    // Envoyer un email de notification à l'utilisateur (expéditeur: contact@auxivie.org)
    try {
      // Récupérer les informations de l'utilisateur destinataire
      const user = await db.get('SELECT email, name FROM users WHERE id = ?', [receiverId]);
      if (user && user.email) {
        // Envoyer l'email de notification avec expéditeur contact@auxivie.org
        await sendAdminMessageNotification(user.email, user.name, content);
        console.log(`✅ Email de notification envoyé à ${user.email} depuis contact@auxivie.org`);
      } else {
        console.warn(`⚠️  Utilisateur ${receiverId} non trouvé ou sans email`);
      }
    } catch (emailError) {
      // Ne pas faire échouer la requête si l'email échoue
      console.error('❌ Erreur lors de l\'envoi de l\'email de notification:', emailError);
    }

    res.json({ id: result.lastID, message: 'Message envoyé' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route de synchronisation de réservation depuis Flutter
app.post('/api/reservations/sync', async (req, res) => {
  try {
    const { userId, professionnelId, date, dateFin, heure, status } = req.body;

    if (!userId || !professionnelId || !date || !heure) {
      return res.status(400).json({ message: 'Champs requis manquants' });
    }

    // Vérifier si la réservation existe déjà (par userId, professionnelId, date, heure)
    const existing = await db.get(
      'SELECT id FROM reservations WHERE userId = ? AND professionnelId = ? AND date = ? AND heure = ?',
      [userId, professionnelId, date, heure]
    );

    if (existing) {
      // Réservation existe déjà, mettre à jour le statut si nécessaire
      await db.run(
        'UPDATE reservations SET status = ? WHERE id = ?',
        [status || 'pending', existing.id]
      );
      res.json({ id: existing.id, message: 'Réservation mise à jour' });
    } else {
      // Créer une nouvelle réservation
      const finalDateFin = dateFin || null;
      const result = await db.run(
        'INSERT INTO reservations (userId, professionnelId, date, dateFin, heure, status, createdAt) VALUES (?, ?, ?, ?, ?, ?, NOW())',
        [userId, professionnelId, date, finalDateFin, heure, status || 'pending']
      );
      res.json({ id: result.lastID, message: 'Réservation synchronisée' });
    }
  } catch (error) {
    console.error('Erreur synchronisation réservation:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Route de synchronisation d'utilisateur depuis Flutter
app.post('/api/users/sync', async (req, res) => {
  try {
    const { name, email, password, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite } = req.body;

    if (!name || !email || !password || !categorie || !userType) {
      return res.status(400).json({ message: 'Champs requis manquants' });
    }

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await db.get('SELECT id FROM users WHERE email = ?', [email]);

    if (existingUser) {
      // Mettre à jour l'utilisateur existant (hasher le mot de passe si fourni)
      let hashedPassword = password;
      
      // Si le mot de passe n'est pas déjà hashé (ne commence pas par $2b$), le hasher
      if (password && !password.startsWith('$2b$')) {
        hashedPassword = await bcrypt.hash(password, 10);
      }
      
      await db.run(
        `UPDATE users SET 
          name = ?, password = ?, phone = ?, categorie = ?, ville = ?, 
          tarif = ?, experience = ?, photo = ?, userType = ?,
          besoin = ?, preference = ?, mission = ?, particularite = ?
         WHERE email = ?`,
        [name, hashedPassword, phone || null, categorie, ville || null, tarif || null, experience || null, photo || null, userType, besoin || null, preference || null, mission || null, particularite || null, email]
      );
      res.json({ message: 'Utilisateur mis à jour', id: existingUser.id, user: { id: existingUser.id, name, email, userType, besoin, preference, mission, particularite } });
    } else {
      // Créer un nouvel utilisateur (hasher le mot de passe)
      const hashedPassword = await bcrypt.hash(password, 10);
      
      const result = await db.run(
        `INSERT INTO users (name, email, password, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite, createdAt)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
        [name, email, hashedPassword, phone || null, categorie, ville || null, tarif || null, experience || null, photo || null, userType, besoin || null, preference || null, mission || null, particularite || null]
      );
      res.json({ 
        message: 'Utilisateur créé', 
        id: result.lastID,
        user: { id: result.lastID, name, email, userType, besoin, preference, mission, particularite }
      });
    }
  } catch (error) {
    console.error('Erreur synchronisation utilisateur:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
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

// ========== ROUTES DISPONIBILITÉS ==========

// Récupérer les disponibilités d'un professionnel
app.get('/api/availabilities', async (req, res) => {
  try {
    const { professionnelId } = req.query;
    
    if (!professionnelId) {
      return res.status(400).json({ message: 'professionnelId requis' });
    }
    
    const rows = await db.all(
      'SELECT * FROM availabilities WHERE professionnelId = ? ORDER BY jourSemaine, heureDebut',
      [professionnelId]
    );
    res.json(rows);
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Créer ou mettre à jour une disponibilité
app.post('/api/availabilities', authenticateToken, async (req, res) => {
  try {
    const { professionnelId, jourSemaine, heureDebut, heureFin } = req.body;
    
    if (!professionnelId || jourSemaine === undefined || !heureDebut || !heureFin) {
      return res.status(400).json({ message: 'Tous les champs sont requis' });
    }
    
    // Vérifier si une disponibilité existe déjà pour ce jour
    const existing = await db.get(
      'SELECT id FROM availabilities WHERE professionnelId = ? AND jourSemaine = ?',
      [professionnelId, jourSemaine]
    );
    
    if (existing) {
      // Mettre à jour
      await db.run(
        'UPDATE availabilities SET heureDebut = ?, heureFin = ? WHERE id = ?',
        [heureDebut, heureFin, existing.id]
      );
      res.json({ id: existing.id, message: 'Disponibilité mise à jour' });
    } else {
      // Créer
      const result = await db.run(
        'INSERT INTO availabilities (professionnelId, jourSemaine, heureDebut, heureFin) VALUES (?, ?, ?, ?)',
        [professionnelId, jourSemaine, heureDebut, heureFin]
      );
      res.json({ id: result.lastID, message: 'Disponibilité créée' });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer une disponibilité
app.delete('/api/availabilities/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    await db.run('DELETE FROM availabilities WHERE id = ?', [id]);
    res.json({ message: 'Disponibilité supprimée' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Démarrer le serveur

// ==================== ROUTES POUR SIGNALEMENTS (REPORTS) ====================

// Récupérer tous les signalements (admin)
app.get('/api/reports', authenticateToken, async (req, res) => {
  try {
    const reports = await db.all(`
      SELECT r.*, 
             u.nom as userNom, 
             u.prenom as userPrenom,
             u.email as userEmail
      FROM reports r
      LEFT JOIN users u ON r.userId = u.id
      ORDER BY r.createdAt DESC
    `);
    res.json(reports);
  } catch (error) {
    console.error('Erreur récupération signalements:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Récupérer un signalement par ID
app.get('/api/reports/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const report = await db.get(`
      SELECT r.*, 
             u.nom as userNom, 
             u.prenom as userPrenom,
             u.email as userEmail,
             u.telephone as userTelephone
      FROM reports r
      LEFT JOIN users u ON r.userId = u.id
      WHERE r.id = ?
    `, [id]);
    
    if (!report) {
      return res.status(404).json({ message: 'Signalement non trouvé' });
    }
    
    res.json(report);
  } catch (error) {
    console.error('Erreur récupération signalement:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Mettre à jour le statut d'un signalement
app.put('/api/reports/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const updateFields = ['status = ?'];
    const values = [status];
    
    if (status === 'resolved') {
      updateFields.push('resolvedAt = NOW()');
    } else if (status === 'open') {
      updateFields.push('resolvedAt = NULL');
    }
    
    values.push(id);
    
    await db.run(
      `UPDATE reports SET ${updateFields.join(', ')} WHERE id = ?`,
      values
    );
    
    res.json({ message: 'Signalement mis à jour' });
  } catch (error) {
    console.error('Erreur mise à jour signalement:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Supprimer un signalement
app.delete('/api/reports/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    await db.run('DELETE FROM reports WHERE id = ?', [id]);
    res.json({ message: 'Signalement supprimé' });
  } catch (error) {
    console.error('Erreur suppression signalement:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// ==================== ROUTES POUR JOURS DE RÉSERVATION ====================

// Récupérer les jours d'une réservation
app.get('/api/reservations/:id/days', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const days = await db.all(`
      SELECT * FROM reservation_days 
      WHERE reservationId = ?
      ORDER BY date ASC
    `, [id]);
    
    res.json(days);
  } catch (error) {
    console.error('Erreur récupération jours réservation:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Mettre à jour les actions d'une réservation
app.put('/api/reservations/:id/actions', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { actionType, value } = req.body;
    
    let updateQuery = '';
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
    
    switch(actionType) {
      case 'pro_arrive':
        updateQuery = value 
          ? 'UPDATE reservations SET pro_arrive = TRUE, pro_arrive_at = ? WHERE id = ?'
          : 'UPDATE reservations SET pro_arrive = FALSE, pro_arrive_at = NULL WHERE id = ?';
        await db.run(updateQuery, value ? [now, id] : [id]);
        break;
        
      case 'famille_confirme_arrivee':
        updateQuery = value 
          ? 'UPDATE reservations SET famille_confirme_arrivee = TRUE, famille_confirme_at = ? WHERE id = ?'
          : 'UPDATE reservations SET famille_confirme_arrivee = FALSE, famille_confirme_at = NULL WHERE id = ?';
        await db.run(updateQuery, value ? [now, id] : [id]);
        break;
        
      case 'pro_a_termine':
        updateQuery = value 
          ? 'UPDATE reservations SET pro_a_termine = TRUE, pro_termine_at = ? WHERE id = ?'
          : 'UPDATE reservations SET pro_a_termine = FALSE, pro_termine_at = NULL WHERE id = ?';
        await db.run(updateQuery, value ? [now, id] : [id]);
        break;
        
      default:
        return res.status(400).json({ message: 'Type d\'action invalide' });
    }
    
    res.json({ message: 'Action mise à jour' });
  } catch (error) {
    console.error('Erreur mise à jour action:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

(async () => {
  // Tester la connexion MySQL avant de démarrer
  const connected = await db.testConnection();
  if (!connected) {
    console.error('❌ Impossible de se connecter à MySQL. Vérifiez votre configuration.');
    process.exit(1);
  }
  
  app.listen(PORT, () => {
    console.log(`🚀 Serveur API démarré sur http://localhost:${PORT}`);
    console.log(`✅ Connexion MySQL établie`);
  });
})();


// Débloquer manuellement les informations (admin uniquement)
app.put('/api/reservations/:id/unlock-info', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { type } = req.body; // 'pro' ou 'famille'
    
    const now = new Date().toISOString().slice(0, 19).replace('T', ' ');
    
    let updateQuery = '';
    if (type === 'pro') {
      updateQuery = 'UPDATE reservations SET info_pro_debloquee_at = ? WHERE id = ?';
    } else if (type === 'famille') {
      updateQuery = 'UPDATE reservations SET info_famille_debloquee_at = ? WHERE id = ?';
    } else {
      return res.status(400).json({ message: 'Type invalide' });
    }
    
    await db.run(updateQuery, [now, id]);
    
    res.json({ 
      message: `Informations ${type === 'pro' ? 'du professionnel' : 'de la famille'} débloquées`,
      timestamp: now
    });
  } catch (error) {
    console.error('Erreur déblocage info:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});


// ============================================
// ============================================

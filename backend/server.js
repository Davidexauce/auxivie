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

    // Récupérer l'utilisateur
    try {
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

    // Route de santé
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

    // Créer l'utilisateur admin dans la table users
    try {
      const result = await db.run(
        'INSERT INTO users (email, password, name, userType, categorie) VALUES (?, ?, ?, ?, ?)',
        [email, hashedPassword, name, 'admin', 'administrateur']
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
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Aidalya API' });
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
// Route publique pour récupérer les professionnels (app mobile)
app.get('/api/users', async (req, res) => {
  try {
    const { userType } = req.query;
    
    // Si userType=professionnel, route publique pour l'app mobile
    if (userType === 'professionnel') {
      const rows = await db.all(
        'SELECT id, name, email, phone, categorie, ville, tarif, experience, photo, userType FROM users WHERE userType = "professionnel" ORDER BY id DESC'
      );
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
        if (user.userType !== 'admin') {
          return res.status(403).json({ message: 'Accès réservé aux administrateurs' });
        }
        const rows = await db.all(
          'SELECT id, name, email, phone, categorie, ville, tarif, experience, userType, suspended, createdAt FROM users WHERE userType != "admin" ORDER BY id DESC'
        );
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
    const row = await db.get('SELECT id, name, email, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite, rib FROM users WHERE id = ?', [id]);
    if (!row) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    let canSeeRib = false;
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (token) {
      try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const targetId = parseInt(id, 10);
        canSeeRib =
          decoded.userId === targetId ||
          decoded.userType === 'admin';
      } catch (_) {
        /* token invalide : pas de rib */
      }
    }
    if (!canSeeRib) {
      delete row.rib;
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
    const row = await db.get('SELECT id, name, email, phone, categorie, ville, tarif, userType FROM users WHERE id = ?', [id]);
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
    const tokenUserId = req.user.userId;
    const requestUserId = parseInt(id, 10);
    if (Number.isNaN(requestUserId)) {
      return res.status(400).json({ message: 'ID invalide' });
    }
    if (req.user.userType !== 'admin' && tokenUserId !== requestUserId) {
      return res.status(403).json({ message: 'Accès refusé' });
    }

    const { name, email, phone, categorie, ville, tarif, password, currentPassword, rib } = req.body;
    
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
      if (rib !== undefined) { fields.push('rib = ?'); values.push(rib); }
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
      if (rib !== undefined) { fields.push('rib = ?'); values.push(rib); }
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

// Suppression de compte (app mobile — aligné Flutter DELETE /users/:id)
app.delete('/api/users/:id', authenticateToken, async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) {
      return res.status(400).json({ message: 'ID invalide' });
    }
    const tokenUserId = req.user.userId;
    const isAdmin = req.user.userType === 'admin';
    if (!isAdmin && tokenUserId !== id) {
      return res.status(403).json({ message: 'Accès refusé' });
    }
    const target = await db.get('SELECT id, userType FROM users WHERE id = ?', [id]);
    if (!target) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    if (target.userType === 'admin' && !isAdmin) {
      return res.status(403).json({ message: 'Accès refusé' });
    }
    await db.run('DELETE FROM users WHERE id = ?', [id]);
    return res.status(204).send();
  } catch (error) {
    console.error('Erreur suppression utilisateur:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

// Suspension compte (dashboard admin — aligné sur admin-dashboard/lib/api.js)
app.post('/api/users/:id/suspend', authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'admin') {
      return res.status(403).json({ message: 'Accès réservé aux administrateurs' });
    }
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) {
      return res.status(400).json({ message: 'ID invalide' });
    }
    const target = await db.get('SELECT id, userType FROM users WHERE id = ?', [id]);
    if (!target) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    if (target.userType === 'admin') {
      return res.status(400).json({ message: 'Impossible de suspendre un administrateur' });
    }
    await db.run('UPDATE users SET suspended = 1 WHERE id = ?', [id]);
    res.json({ message: 'Utilisateur suspendu' });
  } catch (error) {
    console.error('Erreur suspension utilisateur:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/users/:id/unsuspend', authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'admin') {
      return res.status(403).json({ message: 'Accès réservé aux administrateurs' });
    }
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) {
      return res.status(400).json({ message: 'ID invalide' });
    }
    const target = await db.get('SELECT id FROM users WHERE id = ?', [id]);
    if (!target) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
    await db.run('UPDATE users SET suspended = 0 WHERE id = ?', [id]);
    res.json({ message: 'Utilisateur réactivé' });
  } catch (error) {
    console.error('Erreur réactivation utilisateur:', error);
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

// Routes des avis
// Route publique pour l'application mobile
app.get('/api/reviews', async (req, res) => {
  try {
    const rows = await db.all(`
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
    `);
    res.json(rows);
  } catch (error) {
    console.error('Erreur récupération reviews:', error);
    // Si la table n'existe pas, retourner un tableau vide
    return res.json([]);
  }
});

app.post('/api/reviews', authenticateToken, async (req, res) => {
  try {
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
      try {
        const user = await db.get('SELECT name FROM users WHERE id = ?', [userId]);
        if (user) {
          finalUserName = user.name;
        }
      } catch (err) {
        // Ignorer l'erreur
      }
    }

    // reservationId est NOT NULL, donc on utilise 0 si non fourni (avis système/admin)
    const finalReservationId = reservationId || 0;
    
    const result = await db.run(
      `INSERT INTO reviews (professionalId, userId, rating, comment, reservationId, createdAt) 
       VALUES (?, ?, ?, ?, ?, NOW())`,
      [professionalId, userId || 0, rating, comment || null, finalReservationId]
    );
    
    // Si userName est fourni et que la colonne existe, mettre à jour
    if (finalUserName) {
      try {
        await db.run('UPDATE reviews SET userName = ? WHERE id = ?', [finalUserName, result.lastID]);
      } catch (updateErr) {
        // Ignorer les erreurs si la colonne n'existe pas
        if (!updateErr.message.includes('Unknown column')) {
          console.error('Erreur mise à jour userName:', updateErr);
        }
      }
    }
    
    res.json({ id: result.lastID, message: 'Avis créé avec succès' });
  } catch (error) {
    console.error('Erreur création avis:', error);
    return res.status(500).json({ 
      message: 'Erreur serveur lors de la création de l\'avis',
      error: error.message 
    });
  }
});

app.delete('/api/reviews/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    await db.run('DELETE FROM reviews WHERE id = ?', [id]);
    res.json({ message: 'Avis supprimé' });
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

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
    const id = parseInt(req.params.id, 10);
    if (Number.isNaN(id)) {
      return res.status(400).json({ message: 'ID invalide' });
    }
    const row = await db.get(
      'SELECT userId, professionnelId FROM reservations WHERE id = ?',
      [id],
    );
    if (!row) {
      return res.status(404).json({ message: 'Réservation non trouvée' });
    }
    const uid = req.user.userId;
    const isAdmin = req.user.userType === 'admin';
    if (!isAdmin && uid !== row.userId && uid !== row.professionnelId) {
      return res.status(403).json({ message: 'Accès refusé' });
    }
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

    if (userId) {
      // Récupérer les messages avec un utilisateur spécifique (admin = senderId 0 ou receiverId 0)
      const rows = await db.all(
        `SELECT m.*, 
          u1.name as senderName, u1.userType as senderType,
          u2.name as receiverName, u2.userType as receiverType
        FROM messages m
        LEFT JOIN users u1 ON m.senderId = u1.id
        LEFT JOIN users u2 ON m.receiverId = u2.id
        WHERE (m.senderId = 0 AND m.receiverId = ?) OR (m.senderId = ? AND m.receiverId = 0)
        ORDER BY m.timestamp ASC`,
        [userId, userId]
      );
      res.json(rows);
    } else {
      // Récupérer tous les messages où l'admin est impliqué
      const rows = await db.all(
        `SELECT m.*, 
          u1.name as senderName, u1.userType as senderType,
          u2.name as receiverName, u2.userType as receiverType
        FROM messages m
        LEFT JOIN users u1 ON m.senderId = u1.id
        LEFT JOIN users u2 ON m.receiverId = u2.id
        WHERE m.senderId = 0 OR m.receiverId = 0
        ORDER BY m.timestamp DESC`
      );
      res.json(rows);
    }
  } catch (error) {
    return res.status(500).json({ message: 'Erreur serveur' });
  }
});

app.post('/api/messages/admin', authenticateToken, async (req, res) => {
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
    const {
      name,
      email,
      password,
      phone,
      categorie,
      ville,
      tarif,
      experience,
      photo,
      userType,
      user_type,
      besoin,
      preference,
      mission,
      particularite,
      rib,
    } = req.body;

    const effectiveUserType = (userType || user_type || '').toString().trim();
    let experienceValue = null;
    if (experience !== undefined && experience !== null && experience !== '') {
      const n = parseInt(String(experience), 10);
      experienceValue = Number.isFinite(n) ? n : null;
    }

    if (!name || !email || !password || !categorie || !effectiveUserType) {
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

      let ribValue = rib;
      if (rib === undefined) {
        const row = await db.get('SELECT rib FROM users WHERE email = ?', [email]);
        ribValue = row ? row.rib : null;
      }
      
      await db.run(
        `UPDATE users SET 
          name = ?, password = ?, phone = ?, categorie = ?, ville = ?, 
          tarif = ?, experience = ?, photo = ?, userType = ?,
          besoin = ?, preference = ?, mission = ?, particularite = ?, rib = ?
         WHERE email = ?`,
        [name, hashedPassword, phone || null, categorie, ville || null, tarif || null, experienceValue, photo || null, effectiveUserType, besoin || null, preference || null, mission || null, particularite || null, ribValue, email]
      );
      res.json({
        message: 'Utilisateur mis à jour',
        id: existingUser.id,
        user: { id: existingUser.id, name, email, userType: effectiveUserType, besoin, preference, mission, particularite },
      });
    } else {
      // Créer un nouvel utilisateur (hasher le mot de passe)
      const hashedPassword = await bcrypt.hash(password, 10);
      
      const result = await db.run(
        `INSERT INTO users (name, email, password, phone, categorie, ville, tarif, experience, photo, userType, besoin, preference, mission, particularite, rib, createdAt)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
        [name, email, hashedPassword, phone || null, categorie, ville || null, tarif || null, experienceValue, photo || null, effectiveUserType, besoin || null, preference || null, mission || null, particularite || null, rib ?? null]
      );
      res.json({
        message: 'Utilisateur créé',
        id: result.lastID,
        user: { id: result.lastID, name, email, userType: effectiveUserType, besoin, preference, mission, particularite },
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
    message: 'Aidalya API',
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


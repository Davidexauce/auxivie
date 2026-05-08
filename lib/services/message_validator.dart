/// Service de validation des messages pour empêcher l'échange de données privées
/// et les transactions hors plateforme
class MessageValidator {
  /// Valide le contenu d'un message et détecte les données privées
  /// Retourne null si le message est valide, sinon retourne un message d'erreur
  static String? validateMessage(String content) {
    final text = content.trim().toLowerCase();
    
    // Détecter les numéros de téléphone
    if (_containsPhoneNumber(text)) {
      return '⚠️ Pour votre sécurité et celle de tous, nous ne pouvons pas autoriser l\'échange de numéros de téléphone dans les messages. Utilisez la messagerie de la plateforme pour communiquer.';
    }
    
    // Détecter les adresses email
    if (_containsEmail(text)) {
      return '⚠️ Pour votre sécurité et celle de tous, nous ne pouvons pas autoriser l\'échange d\'adresses email dans les messages. Utilisez la messagerie de la plateforme pour communiquer.';
    }
    
    // Détecter les adresses (codes postaux, villes)
    if (_containsAddress(text)) {
      return '⚠️ Pour votre sécurité et celle de tous, nous ne pouvons pas autoriser l\'échange d\'adresses postales dans les messages. Les informations de localisation sont déjà disponibles dans les profils.';
    }
    
    // Détecter les liens vers réseaux sociaux externes
    if (_containsSocialMediaLinks(text)) {
      return '⚠️ Pour votre sécurité et celle de tous, nous ne pouvons pas autoriser l\'échange de liens vers d\'autres plateformes. Utilisez la messagerie de la plateforme pour communiquer.';
    }
    
    // Détecter les mots-clés suspects (ex: "appeler directement", "hors plateforme")
    if (_containsSuspiciousKeywords(text)) {
      return '⚠️ Pour votre sécurité, toutes les communications doivent passer par la plateforme. Les prestations doivent être réservées et payées via Aidalia.';
    }
    
    return null; // Message valide
  }
  
  /// Détecte les numéros de téléphone
  static bool _containsPhoneNumber(String text) {
    // Patterns pour les numéros de téléphone français
    final phonePatterns = [
      // Format français: 06 12 34 56 78, 0612345678, +33 6 12 34 56 78
      RegExp(r'0[1-9]([\s\.\-]?\d{2}){4}'),
      RegExp(r'\+33[\s\.\-]?[1-9]([\s\.\-]?\d{2}){4}'),
      // Format international: +XX...
      RegExp(r'\+[\d\s\-\.]{8,}'),
      // Numéros avec mots-clés
      RegExp(r'(tel|telephone|portable|mobile|fixe)[\s:]*0[1-9]([\s\.\-]?\d{2}){4}'),
      // Numéros écrits en toutes lettres (six, sept, huit, neuf, zéro)
      RegExp(r'0[\s\-]?[1-9]([\s\-]?\d{2}){4}'),
    ];
    
    for (final pattern in phonePatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    
    // Détecter les séquences de chiffres qui ressemblent à des numéros (10 chiffres)
    final digitSequence = RegExp(r'\b\d{10,}\b');
    if (digitSequence.hasMatch(text)) {
      final matches = digitSequence.allMatches(text);
      for (final match in matches) {
        final number = match.group(0)!;
        // Si c'est un numéro qui commence par 0 ou +33
        if (number.startsWith('0') || number.contains('33')) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Détecte les adresses email
  static bool _containsEmail(String text) {
    final emailPattern = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
      caseSensitive: false,
    );
    return emailPattern.hasMatch(text);
  }
  
  /// Détecte les adresses postales
  static bool _containsAddress(String text) {
    // Codes postaux français (5 chiffres)
    final postalCodePattern = RegExp(r'\b\d{5}\b');
    
    // Mots-clés d'adresse
    final addressKeywords = [
      'rue', 'avenue', 'boulevard', 'route', 'impasse', 'place',
      'allée', 'chemin', 'lotissement', 'résidence',
      'appartement', 'appart', 'apt', 'app', 'logement',
      'chez moi', 'domicile', 'adresse complète',
      'cp:', 'code postal', 'n°', 'numéro',
    ];
    
    // Vérifier les codes postaux
    if (postalCodePattern.hasMatch(text)) {
      // Si on trouve un code postal avec des mots-clés d'adresse à proximité
      for (final keyword in addressKeywords) {
        if (text.contains(keyword)) {
          return true;
        }
      }
    }
    
    // Détecter les combinaisons suspectes
    final suspiciousPatterns = [
      RegExp(r'\d+\s*(rue|avenue|boulevard|route|impasse|place|allée|chemin)', caseSensitive: false),
      RegExp(r'(appartement|appart|apt)[\s]*\w*[\s]*\d+', caseSensitive: false),
    ];
    
    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Détecte les liens vers réseaux sociaux
  static bool _containsSocialMediaLinks(String text) {
    final socialMediaPatterns = [
      // WhatsApp, Telegram, etc.
      RegExp(r'(whatsapp|telegram|signal|messenger|discord|skype)[\s:]*[\w\./]+', caseSensitive: false),
      // Liens http/https vers réseaux sociaux
      RegExp(r'https?://(www\.)?(facebook|twitter|x\.com|instagram|linkedin|snapchat|tiktok|youtube|whatsapp|telegram)\.\w+', caseSensitive: false),
      // Handles/username de réseaux sociaux
      RegExp(r'@[\w]+[\s]*(sur|on|sur le)?[\s]*(facebook|instagram|twitter|x|snapchat|tiktok)', caseSensitive: false),
    ];
    
    for (final pattern in socialMediaPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Détecte les mots-clés suspects indiquant une volonté de contourner la plateforme
  static bool _containsSuspiciousKeywords(String text) {
    final suspiciousKeywords = [
      // Mots-clés de contournement
      'appeler directement', 'appelle moi', 'appelez-moi',
      'hors plateforme', 'en dehors', 'directement',
      'passe-moi ton', 'donne moi ton', 'donne-moi',
      'envoie-moi', 'envoie moi', 'envoies-moi',
      'mon numéro', 'mon tel', 'mon telephone',
      'mon email', 'mon mail', 'mon e-mail',
      'mon adresse', 'mon adresse postale',
      'paiement direct', 'payer directement',
      'sans passer par', 'contourner',
      'virement direct', 'espèces direct',
      'contacte-moi sur', 'joins-moi sur',
      'ajoute-moi sur', 'ajoute moi sur',
    ];
    
    for (final keyword in suspiciousKeywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }
}


import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

/// ViewModel pour la gestion des messages
class MessageViewModel extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  
  Map<int, List<MessageModel>> _conversations = {}; // Map<partnerId, messages>
  Map<int, UserModel> _partners = {}; // Map<partnerId, user>
  bool _isLoading = false;
  String? _errorMessage;

  /// Conversations chargées
  Map<int, List<MessageModel>> get conversations => _conversations;

  /// Partenaires de conversation
  Map<int, UserModel> get partners => _partners;

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur éventuel
  String? get errorMessage => _errorMessage;

  /// Charge toutes les conversations d'un utilisateur
  Future<void> loadConversations(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Récupérer les IDs des interlocuteurs
      final partnerIds = await _db.getConversationPartners(userId);
      
      // Charger chaque conversation
      for (final partnerId in partnerIds) {
        final messages = await _db.getConversation(userId, partnerId);
        _conversations[partnerId] = messages;
        
        // Charger les infos du partenaire
        final partner = await _db.getUserById(partnerId);
        if (partner != null) {
          _partners[partnerId] = partner;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des messages';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge une conversation spécifique
  Future<void> loadConversation(int userId, int partnerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messages = await _db.getConversation(userId, partnerId);
      _conversations[partnerId] = messages;
      
      // Charger les infos du partenaire si nécessaire
      if (!_partners.containsKey(partnerId)) {
        final partner = await _db.getUserById(partnerId);
        if (partner != null) {
          _partners[partnerId] = partner;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de la conversation';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envoie un nouveau message
  Future<bool> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      _errorMessage = 'Le message ne peut pas être vide';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = MessageModel(
        senderId: senderId,
        receiverId: receiverId,
        content: content.trim(),
        timestamp: DateTime.now(),
      );

      await _db.createMessage(message);
      
      // Recharger la conversation
      await loadConversation(senderId, receiverId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi du message';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Charge les informations d'un utilisateur pour la conversation
  Future<UserModel?> loadPartnerInfo(int partnerId) async {
    try {
      if (_partners.containsKey(partnerId)) {
        return _partners[partnerId];
      }
      
      final partner = await _db.getUserById(partnerId);
      if (partner != null) {
        _partners[partnerId] = partner;
        notifyListeners();
      }
      return partner;
    } catch (e) {
      return null;
    }
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


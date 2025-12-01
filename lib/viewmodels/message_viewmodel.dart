import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/backend_api_service.dart';

/// ViewModel pour la gestion des messages
class MessageViewModel extends ChangeNotifier {
  
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

  /// Nombre de messages non lus
  int get unreadCount {
    int count = 0;
    for (final messages in _conversations.values) {
      count += messages.where((m) => m.isRead == false).length;
    }
    return count;
  }

  /// Charge toutes les conversations d'un utilisateur
  Future<void> loadConversations(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Récupérer les partenaires de conversation depuis le backend
      final partnerIds = await BackendApiService.getConversationPartners(userId);
      
      // Charger chaque conversation depuis le backend
      for (final partnerId in partnerIds) {
        final messages = await BackendApiService.getConversation(userId, partnerId);
        _conversations[partnerId] = messages;
        
        // Charger les infos du partenaire depuis le backend
        final partner = await BackendApiService.getUserById(partnerId);
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
          // Charger depuis le backend (base de données unique)
          final messages = await BackendApiService.getConversation(userId, partnerId);
          _conversations[partnerId] = messages;
          
          // Charger les infos du partenaire si nécessaire
          if (!_partners.containsKey(partnerId)) {
            final partner = await BackendApiService.getUserById(partnerId);
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

          // Envoyer directement dans le backend (base de données unique)
          final success = await BackendApiService.sendMessage(message);
          if (!success) {
            _errorMessage = 'Erreur lors de l\'envoi du message';
            _isLoading = false;
            notifyListeners();
            return false;
          }
          
          // Recharger la conversation depuis le backend
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
          
          // Charger depuis le backend (base de données unique)
          final partner = await BackendApiService.getUserById(partnerId);
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


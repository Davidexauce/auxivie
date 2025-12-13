import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/message_viewmodel.dart';
import '../../services/backend_api_service.dart';
import '../../services/message_validator.dart';
import '../../theme/app_theme.dart';
import '../professionals/professional_detail_screen.dart';
import '../families/family_detail_screen.dart';

/// Écran de chat/conversation
class ChatScreen extends StatefulWidget {
  final int currentUserId;
  final int otherUserId;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
      messageViewModel.loadConversation(widget.currentUserId, widget.otherUserId);
    });
  }

  @override
  void dispose() {
    // Ne pas recharger ici car dispose est appelé trop tôt
    // Le rechargement sera fait dans home_screen.dart quand on revient sur l'écran d'accueil
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    
    if (messageText.isEmpty) {
      return;
    }

    // Valider le message pour détecter les données privées
    final validationError = MessageValidator.validateMessage(messageText);
    if (validationError != null) {
      if (mounted) {
        // Afficher une alerte explicative
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.security, color: AppTheme.error, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Protection des données',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  validationError,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Pourquoi cette restriction ?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Protéger vos données personnelles\n'
                        '• Assurer la sécurité des transactions\n'
                        '• Garantir le suivi des prestations\n'
                        '• Respecter les conditions d\'utilisation',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('J\'ai compris'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
    
    final success = await messageViewModel.sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      content: messageText,
    );

    if (success && mounted) {
      _messageController.clear();
      // Scroll vers le bas
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messageViewModel.errorMessage ?? 'Erreur lors de l\'envoi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadPartnerInfo() async {
    final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
    await messageViewModel.loadPartnerInfo(widget.otherUserId);
  }

  @override
  Widget build(BuildContext context) {
    final messageViewModel = Provider.of<MessageViewModel>(context);
    final partner = messageViewModel.partners[widget.otherUserId];

    // Charger les infos du partenaire si nécessaire
    if (partner == null) {
      _loadPartnerInfo();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                (partner?.name[0] ?? '?').toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner?.name ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (partner != null)
                    Text(
                      partner.categorie,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Bouton pour voir le profil
          IconButton(
            icon: Icon(
              partner?.userType == 'professionnel'
                  ? Icons.person_outline
                  : Icons.family_restroom,
            ),
            tooltip: 'Voir le profil',
            onPressed: () async {
              if (partner == null) {
                // Charger le partenaire depuis le backend
                final loadedPartner = await BackendApiService.getUserById(widget.otherUserId);
                if (loadedPartner != null && mounted) {
                  final navigator = Navigator.of(context);
                  if (loadedPartner.userType == 'professionnel') {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ProfessionalDetailScreen(
                          professional: loadedPartner,
                        ),
                      ),
                    );
                  } else if (mounted) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => FamilyDetailScreen(
                          family: loadedPartner,
                        ),
                      ),
                    );
                  }
                }
              } else {
                if (partner.userType == 'professionnel') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfessionalDetailScreen(
                        professional: partner,
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FamilyDetailScreen(
                        family: partner,
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: messageViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messageViewModel.conversations[widget.otherUserId]?.isEmpty ?? true
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun message',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envoyez votre premier message',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
                          await messageViewModel.loadConversation(
                            widget.currentUserId,
                            widget.otherUserId,
                          );
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: messageViewModel.conversations[widget.otherUserId]?.length ?? 0,
                          itemBuilder: (context, index) {
                            final messages = messageViewModel.conversations[widget.otherUserId]!;
                            final message = messages[index];
                            final isFromCurrentUser = message.senderId == widget.currentUserId;

                            return _MessageBubble(
                              message: message,
                              isFromCurrentUser: isFromCurrentUser,
                            );
                          },
                        ),
                      ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Tapez votre message...',
                        helperText: '💬 Communiquez via la plateforme pour votre sécurité',
                        helperStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).primaryColor,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour une bulle de message
class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isFromCurrentUser;

  const _MessageBubble({
    required this.message,
    required this.isFromCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment:
            isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              child: Text(
                'U',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromCurrentUser
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isFromCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isFromCurrentUser
                          ? Colors.white70
                          : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              child: Text(
                'Moi',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}


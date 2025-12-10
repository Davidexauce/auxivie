import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/message_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user_model.dart';
import 'chat_screen.dart';
import 'select_professional_screen.dart';
import '../../views/professionals/professional_detail_screen.dart';
import '../../views/families/family_detail_screen.dart';

/// Écran de liste des conversations
class MessagesListScreen extends StatefulWidget {
  final int userId;

  const MessagesListScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
      messageViewModel.loadConversations(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageViewModel = Provider.of<MessageViewModel>(context);

    final authViewModel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;
    final isFamily = currentUser?.userType == 'famille';

    // MessagesListScreen est dans un IndexedStack, donc il n'est pas dans la pile de navigation
    // Le bouton retour système ne devrait rien faire ici
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Ne rien faire - on est dans un IndexedStack, le retour est géré par le HomeScreen
        // Juste empêcher le pop pour éviter toute redirection
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          // Bouton "Nouveau message" uniquement pour les familles
          if (isFamily)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Nouveau message',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SelectProfessionalScreen(
                      currentUserId: widget.userId,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: messageViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : messageViewModel.conversations.isEmpty
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
                        isFamily
                            ? 'Commencez une nouvelle conversation avec un professionnel'
                            : 'Commencez une nouvelle conversation',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (isFamily) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SelectProfessionalScreen(
                                  currentUserId: widget.userId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Nouveau message'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final messageViewModel = Provider.of<MessageViewModel>(context, listen: false);
                    await messageViewModel.loadConversations(widget.userId);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messageViewModel.conversations.length,
                    itemBuilder: (context, index) {
                      final partnerId = messageViewModel.conversations.keys.elementAt(index);
                      final messages = messageViewModel.conversations[partnerId]!;
                      final partner = messageViewModel.partners[partnerId];
                      final lastMessage = messages.isNotEmpty ? messages.last : null;

                      return _ConversationCard(
                        currentUserId: widget.userId,
                        partner: partner,
                        partnerId: partnerId,
                        lastMessage: lastMessage,
                        isFromCurrentUser: lastMessage?.senderId == widget.userId,
                      );
                    },
                  ),
                ),
      ),
    );
  }
}

/// Carte pour une conversation dans la liste
class _ConversationCard extends StatelessWidget {
  final int currentUserId;
  final UserModel? partner;
  final int partnerId;
  final dynamic lastMessage;
  final bool isFromCurrentUser;

  const _ConversationCard({
    required this.currentUserId,
    required this.partner,
    required this.partnerId,
    required this.lastMessage,
    required this.isFromCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final partnerName = partner?.name ?? 'Utilisateur inconnu';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            partnerName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          partnerName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: lastMessage != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    isFromCurrentUser ? 'Vous: ${lastMessage.content}' : lastMessage.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(lastMessage.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              )
            : Text(
                'Aucun message',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton pour voir le profil
            if (partner != null)
              IconButton(
                icon: Icon(
                  partner!.userType == 'professionnel' 
                      ? Icons.person_outline 
                      : Icons.family_restroom,
                  color: Theme.of(context).primaryColor,
                ),
                tooltip: 'Voir le profil',
                onPressed: () {
                  final currentPartner = partner!;
                  if (currentPartner.userType == 'professionnel') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfessionalDetailScreen(
                          professional: currentPartner,
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FamilyDetailScreen(
                          family: currentPartner,
                        ),
                      ),
                    );
                  }
                },
              ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                currentUserId: currentUserId,
                otherUserId: partnerId,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}


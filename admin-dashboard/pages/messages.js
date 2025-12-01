import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { messagesAPI, usersAPI } from '../lib/api';
import styles from '../styles/Messages.module.css';

export default function Messages() {
  const router = useRouter();
  const [conversations, setConversations] = useState([]);
  const [selectedConversation, setSelectedConversation] = useState(null);
  const [messages, setMessages] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [newMessage, setNewMessage] = useState('');
  const [filter, setFilter] = useState('all'); // all, professionnel, famille

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      router.push('/login');
      return;
    }

    loadData();
  }, [router]);

  const loadData = async () => {
    try {
      setLoading(true);
      const [conversationsData, usersData] = await Promise.all([
        messagesAPI.getAll(),
        usersAPI.getAll(),
      ]);
      
      // Organiser les conversations par utilisateur
      const conversationsMap = new Map();
      
      conversationsData.forEach((msg) => {
        const partnerId = msg.senderId !== 0 ? msg.senderId : msg.receiverId;
        if (!conversationsMap.has(partnerId)) {
          const partner = usersData.find(u => u.id === partnerId);
          conversationsMap.set(partnerId, {
            userId: partnerId,
            partner: partner || { id: partnerId, name: 'Utilisateur inconnu' },
            lastMessage: msg,
            unreadCount: 0,
          });
        } else {
          const conv = conversationsMap.get(partnerId);
          if (new Date(msg.timestamp) > new Date(conv.lastMessage.timestamp)) {
            conv.lastMessage = msg;
          }
        }
      });

      setConversations(Array.from(conversationsMap.values()));
      setUsers(usersData);
    } catch (error) {
      console.error('Erreur lors du chargement:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadConversation = async (userId) => {
    try {
      const conversationData = await messagesAPI.getConversation(userId);
      setMessages(conversationData);
      setSelectedConversation(userId);
      
      // Scroll vers le bas après chargement
      setTimeout(() => {
        const messagesList = document.getElementById('messagesList');
        if (messagesList) {
          messagesList.scrollTop = messagesList.scrollHeight;
        }
      }, 100);
    } catch (error) {
      console.error('Erreur lors du chargement de la conversation:', error);
    }
  };

  const sendMessage = async (e) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedConversation || sending) return;

    try {
      setSending(true);
      await messagesAPI.send({
        receiverId: selectedConversation,
        content: newMessage.trim(),
      });
      
      setNewMessage('');
      await loadConversation(selectedConversation);
      await loadData(); // Recharger la liste des conversations
      
      // Scroll vers le bas
      const messagesList = document.querySelector(`.${styles.messagesList}`);
      if (messagesList) {
        messagesList.scrollTop = messagesList.scrollHeight;
      }
    } catch (error) {
      console.error('Erreur lors de l\'envoi:', error);
      alert('Erreur lors de l\'envoi du message');
    } finally {
      setSending(false);
    }
  };

  const filteredConversations = filter === 'all'
    ? conversations
    : conversations.filter(conv => {
        const userType = conv.partner?.userType;
        return filter === 'professionnel' ? userType === 'professionnel' : userType === 'famille';
      });

  const selectedPartner = users.find(u => u.id === selectedConversation);

  if (loading) {
    return (
      <Layout>
        <div className={styles.loading}>Chargement...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.container}>
        <div className={styles.header}>
          <h1 className={styles.title}>Messages</h1>
          <div className={styles.filters}>
            <button
              className={filter === 'all' ? styles.active : ''}
              onClick={() => setFilter('all')}
            >
              Tous
            </button>
            <button
              className={filter === 'professionnel' ? styles.active : ''}
              onClick={() => setFilter('professionnel')}
            >
              Professionnels
            </button>
            <button
              className={filter === 'famille' ? styles.active : ''}
              onClick={() => setFilter('famille')}
            >
              Familles
            </button>
          </div>
        </div>

        <div className={styles.content}>
          {/* Liste des conversations */}
          <div className={styles.conversationsList}>
            {filteredConversations.length === 0 ? (
              <div className={styles.empty}>
                <p>Aucune conversation</p>
              </div>
            ) : (
              filteredConversations.map((conv) => (
                <div
                  key={conv.userId}
                  className={`${styles.conversationItem} ${
                    selectedConversation === conv.userId ? styles.active : ''
                  }`}
                  onClick={() => loadConversation(conv.userId)}
                >
                  <div className={styles.conversationAvatar}>
                    {conv.partner?.name?.[0]?.toUpperCase() || '?'}
                  </div>
                  <div className={styles.conversationInfo}>
                    <div className={styles.conversationHeader}>
                      <span className={styles.conversationName}>
                        {conv.partner?.name || 'Utilisateur inconnu'}
                      </span>
                      <span className={styles.conversationType}>
                        {conv.partner?.userType === 'professionnel' ? '👨‍⚕️' : '👨‍👩‍👧'}
                      </span>
                    </div>
                    <p className={styles.conversationPreview}>
                      {conv.lastMessage?.content || 'Aucun message'}
                    </p>
                    <span className={styles.conversationTime}>
                      {conv.lastMessage?.timestamp
                        ? new Date(conv.lastMessage.timestamp).toLocaleDateString('fr-FR')
                        : ''}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Zone de conversation */}
          <div className={styles.chatArea}>
            {selectedConversation ? (
              <>
                <div className={styles.chatHeader}>
                  <div className={styles.chatPartnerInfo}>
                    <div className={styles.chatAvatar}>
                      {selectedPartner?.name?.[0]?.toUpperCase() || '?'}
                    </div>
                    <div>
                      <h3>{selectedPartner?.name || 'Utilisateur'}</h3>
                      <p className={styles.chatPartnerType}>
                        {selectedPartner?.userType === 'professionnel' ? 'Professionnel' : 'Famille'}
                        {selectedPartner?.categorie && ` • ${selectedPartner.categorie}`}
                      </p>
                    </div>
                  </div>
                  <button
                    className={styles.viewProfileBtn}
                    onClick={() => router.push(`/users/${selectedConversation}`)}
                  >
                    Voir le profil
                  </button>
                </div>

                <div className={styles.messagesList}>
                  {messages.length === 0 ? (
                    <div className={styles.emptyMessages}>
                      <p>Aucun message dans cette conversation</p>
                    </div>
                  ) : (
                    messages.map((msg) => {
                      const isFromAdmin = msg.senderId === 0;
                      return (
                        <div
                          key={msg.id}
                          className={`${styles.messageBubble} ${
                            isFromAdmin ? styles.messageFromAdmin : styles.messageFromUser
                          }`}
                        >
                          <div className={styles.messageContent}>
                            <p>{msg.content}</p>
                            <span className={styles.messageTime}>
                              {new Date(msg.timestamp).toLocaleString('fr-FR', {
                                day: '2-digit',
                                month: '2-digit',
                                year: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit',
                              })}
                            </span>
                          </div>
                        </div>
                      );
                    })
                  )}
                </div>

                <form onSubmit={sendMessage} className={styles.messageForm}>
                  <input
                    type="text"
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    placeholder="Tapez votre message..."
                    className={styles.messageInput}
                    disabled={sending}
                  />
                  <button
                    type="submit"
                    className={styles.sendButton}
                    disabled={sending || !newMessage.trim()}
                  >
                    {sending ? 'Envoi...' : 'Envoyer'}
                  </button>
                </form>
              </>
            ) : (
              <div className={styles.noSelection}>
                <p>Sélectionnez une conversation pour commencer</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}


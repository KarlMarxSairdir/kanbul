import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/models/chat/message_model.dart';
import 'package:kan_bul/features/chat/providers/chat_providers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String requestId;
  final String? otherUserId;
  final String? contextId;
  final List<String> participantIds;

  const ChatScreen({
    required this.chatId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.requestId,
    this.otherUserId,
    this.contextId,
    required this.participantIds,
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _markChatAsRead();
  }

  Future<void> _markChatAsRead() async {
    final currentUser = ref.read(authStateNotifierProvider).user;
    if (currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .set(
            {
              'lastReadAt': {currentUser.id: FieldValue.serverTimestamp()},
            },
            SetOptions(merge: true),
          ); // merge ile sadece ilgili alan güncellenir
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Okuma durumu güncellenemedi: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // Kullanıcı klavyeyi kapattığında odağı kaldır
  void _clearFocus() {
    FocusScope.of(context).unfocus();
  }

  // Mesaj gönderimi
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _messageController.clear();

    try {
      await ref
          .read(chatControllerProvider.notifier)
          .sendMessage(
            chatId: widget.chatId,
            text: text,
            participantIds: widget.participantIds,
          );

      // Mesaj gönderdikten sonra liste sonuna kaydır
      _scrollToBottom();
      await _markChatAsRead();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesaj gönderilemedi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final currentUser = ref.watch(authStateNotifierProvider).user;

    return GestureDetector(
      onTap: _clearFocus,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage:
                    widget.otherUserAvatar != null &&
                            widget.otherUserAvatar!.isNotEmpty
                        ? NetworkImage(widget.otherUserAvatar!)
                        : null,
                child:
                    widget.otherUserAvatar == null ||
                            widget.otherUserAvatar!.isEmpty
                        ? Text(
                          widget.otherUserName.isNotEmpty
                              ? widget.otherUserName[0].toUpperCase()
                              : '?',
                        )
                        : null,
              ),
              const SizedBox(width: 8),
              Text(widget.otherUserName),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Ana Sayfa',
              onPressed: () {
                // Ana sayfaya yönlendir
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Eğer go_router kullanılıyorsa:
                // context.go(AppRoutes.dashboard);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Mesaj listesi
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) =>
                        Center(child: Text('Hata oluştu: ${error.toString()}')),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const _EmptyChatView();
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // En son mesaj altta olacak
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUser?.id;

                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),

            // Mesaj gönderme alanı
            _MessageInput(
              controller: _messageController,
              onSend: _sendMessage,
              isSending: _isSending,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sentTime = message.timestamp?.toDate() ?? DateTime.now();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color:
              isMe
                  ? theme.colorScheme.primary.withAlpha(204)
                  : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color:
                    isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeago.format(sentTime, locale: 'tr'),
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isMe
                          ? theme.colorScheme.onPrimary.withAlpha(204)
                          : theme.colorScheme.onSurfaceVariant.withAlpha(204),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Mesaj yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24.0),
            child: InkWell(
              onTap: isSending ? null : onSend,
              borderRadius: BorderRadius.circular(24.0),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child:
                    isSending
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                        : Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Mesajlaşmaya başla',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'İlk mesajı göndererek konuşmaya başlayabilirsiniz.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

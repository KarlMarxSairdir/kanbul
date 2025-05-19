import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/models/chat/chat_model.dart';
import 'package:kan_bul/features/chat/providers/chat_providers.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyChatsScreen extends ConsumerWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateNotifierProvider).user;
    final myChatsAsync = ref.watch(myChatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlarım'), elevation: 2),
      body: myChatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Hata oluştu: ${error.toString()}')),
        data: (chats) {
          if (chats.isEmpty) {
            return const _EmptyChatList();
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participantIds.firstWhere(
                (id) => id != (currentUser?.id ?? ''),
                orElse: () => '',
              );
              return _ChatListItem(
                chat: chat,
                otherUserId: otherUserId,
                currentUserId: currentUser?.id ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final String otherUserId;
  final String currentUserId;

  const _ChatListItem({
    required this.chat,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserName =
        chat.participantNames[otherUserId] ?? 'İsimsiz Kullanıcı';
    final otherUserAvatar = chat.participantAvatars[otherUserId];
    final lastMessageTime =
        chat.lastMessageTimestamp != null
            ? timeago.format(chat.lastMessageTimestamp!.toDate(), locale: 'tr')
            : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage:
              otherUserAvatar != null && otherUserAvatar.isNotEmpty
                  ? NetworkImage(otherUserAvatar)
                  : null,
          child:
              otherUserAvatar == null || otherUserAvatar.isEmpty
                  ? Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : '?',
                  )
                  : null,
        ),
        title: Text(
          otherUserName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            chat.lastMessage != null && chat.lastMessage!.isNotEmpty
                ? Text(
                  chat.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                : const Text(
                  'Yeni sohbet',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
        trailing: Text(
          lastMessageTime,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          context.push(
            '${AppRoutes.chat}/${chat.id}',
            extra: {
              'otherUserName': otherUserName,
              'otherUserAvatar': otherUserAvatar,
              'requestId': chat.requestId,
              'otherUserId': otherUserId,
              'participantIds': chat.participantIds,
            },
          );
        },
      ),
    );
  }
}

class _EmptyChatList extends StatelessWidget {
  const _EmptyChatList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz mesaj yok',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Kan talepleri ile ilgili konuşmalarınız burada görünecek.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

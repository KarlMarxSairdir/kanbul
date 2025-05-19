import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/models/chat/chat_model.dart';
import 'package:kan_bul/data/models/chat/message_model.dart';
import 'package:kan_bul/data/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/utils/logger.dart';

part 'chat_providers.g.dart';

/// Kullanıcının aktif chatlerini sağlar
@riverpod
Stream<List<ChatModel>> myChats(Ref ref) {
  final user = ref.watch(authStateNotifierProvider).user;
  final repository = ref.watch(chatRepositoryProvider);

  // Kullanıcı yoksa boş liste döndür
  if (user == null) {
    return Stream.value([]);
  }

  return repository.getUserChats(user.id);
}

/// Belirli bir chat oturumundaki mesajları sağlar
@riverpod
Stream<List<MessageModel>> messages(Ref ref, String chatId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(chatId, limit: 50);
}

/// Chat işlemlerini yöneten controller
@riverpod
class ChatController extends _$ChatController {
  bool _isCreatingChat = false;

  // Güvenli state atama işlemi
  void _safeSetState(AsyncValue<void> newState) {
    try {
      state = newState;
    } catch (e) {
      // Eğer "Future already completed" hatası oluşursa sessizce yoksay
      logger.w("State atama hatası (görmezden gelindi): $e");
    }
  }

  @override
  FutureOr<void> build() {
    // Initial state boş olabilir
    return null;
  }

  /// Yeni mesaj gönderir
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required List<String>
    participantIds, // DEĞİŞTİRİLDİ: participantIds parametre olarak eklendi
  }) async {
    final user = ref.read(authStateNotifierProvider).user;
    if (user == null) {
      throw Exception('User not authenticated for sending message');
    }
    if (participantIds.isEmpty || !participantIds.contains(user.id)) {
      throw Exception('Invalid participantIds for sending message');
    }

    // Chat repository'e eriş
    final repository = ref.read(chatRepositoryProvider);

    // Mesajı al ve Firebase'e kaydet
    try {
      state = const AsyncValue.loading();

      // Önceki chat detaylarını alma mantığı kaldırıldı.
      // participantIds doğrudan parametre olarak geliyor.

      // Mesajı gönder
      await repository.sendMessage(
        chatId: chatId,
        senderId: user.id,
        text: text,
        participantIds: participantIds, // Kullanılan participantIds
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Hatanın UI tarafından yakalanabilmesi için tekrar fırlat
    }
  }

  /// Yeni bir chat oluşturur veya varsa mevcut olanı döndürür
  Future<String> createOrGetChat({
    required String otherUserId,
    required String requestId,
    required String otherUserName,
    String? otherUserAvatar,
    String?
    contextId, // Kabul edilen yanıtın ID'si (mesela donationResponse.id)
  }) async {
    // Eğer zaten oluşturma işlemi sürüyorsa, yeni işlemi reddet
    if (_isCreatingChat) {
      logger.w("createOrGetChat: Zaten bir chat oluşturma işlemi sürüyor!");
      return Future.error('Chat already being created');
    }

    _isCreatingChat = true;
    String chatId = '';

    try {
      logger.d("createOrGetChat: Chat oluşturma işlemi başlatıldı...");
      // Yükleniyor durumunu göster
      _safeSetState(const AsyncValue.loading());

      final user = ref.read(authStateNotifierProvider).user;
      if (user == null) throw Exception('User not authenticated');

      final repository = ref.read(chatRepositoryProvider);

      // Chat ID'yi getir/oluştur
      chatId = await repository.createOrGetChat(
        userId1: user.id,
        userId2: otherUserId,
        requestId: requestId,
        contextId: contextId,
      );

      logger.d("createOrGetChat: Chat ID alındı: $chatId");

      // Kullanıcı bilgilerini güncelle
      if (chatId.isNotEmpty) {
        await repository.updateChatMetadata(
          chatId: chatId,
          participantNames: {
            user.id: user.username,
            otherUserId: otherUserName,
          },
          participantAvatars: {
            user.id: user.photoUrl,
            otherUserId: otherUserAvatar,
          },
        );
        logger.d("createOrGetChat: Chat metadata güncellendi");
      }

      // Başarı durumunu güvenli şekilde güncelle
      _safeSetState(const AsyncValue.data(null));
      logger.d("createOrGetChat: İşlem başarılı! ChatID: $chatId");

      return chatId;
    } catch (error, stackTrace) {
      logger.e("createOrGetChat: HATA", error: error, stackTrace: stackTrace);
      // Hata durumunu güvenli şekilde güncelle
      _safeSetState(AsyncValue.error(error, stackTrace));
      rethrow;
    } finally {
      _isCreatingChat = false;
      logger.d("createOrGetChat: İşlem tamamlandı, _isCreatingChat = false");
    }
  }
}

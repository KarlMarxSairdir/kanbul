import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kan_bul/data/models/chat/chat_model.dart';
import 'package:kan_bul/data/models/chat/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/services/firestore_service.dart';

part 'chat_repository.g.dart';

/// Chat Repository interface
abstract class ChatRepository {
  /// Kullanıcının tüm mesajlaşmalarını döner
  Stream<List<ChatModel>> getUserChats(String userId);

  /// Belirli bir chat için mesajları döner
  Stream<List<MessageModel>> getMessages(String chatId, {int limit = 50});

  /// Yeni mesaj gönderir
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required List<String> participantIds,
  });

  /// Chat oluşturur veya varsa mevcut olanı döner
  Future<String> createOrGetChat({
    required String userId1,
    required String userId2,
    required String requestId,
    String? contextId, // Kabul edilen yanıtın ID'si
  });

  /// Chat meta verilerini günceller
  Future<void> updateChatMetadata({
    required String chatId,
    required Map<String, String> participantNames,
    required Map<String, String?> participantAvatars,
  });
}

/// Firestore tabanlı Chat Repository implementasyonu
class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;

  FirestoreChatRepository(this._firestore);

  @override
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ChatModel.fromJson(doc.data()).copyWith(id: doc.id),
                  )
                  .toList(),
        );
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats/$chatId/messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        MessageModel.fromJson(doc.data()).copyWith(id: doc.id),
                  )
                  .toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required List<String> participantIds,
  }) async {
    // Transactions kullanarak tutarlılık sağlama
    return _firestore.runTransaction((transaction) async {
      // 1. Mesaj koleksiyonu referansı
      final messagesRef = _firestore.collection('chats/$chatId/messages');

      // 2. Chat dökümanı referansı
      final chatRef = _firestore.collection('chats').doc(chatId);

      // 3. Yeni mesaj dökümanı oluştur
      final newMessageRef = messagesRef.doc();
      final newMessage = MessageModel(
        id: newMessageRef.id,
        senderId: senderId,
        text: text,
        timestamp: null, // Server timestamp olarak ayarlanacak
      );

      // 4. Mesaj verisini hazırla (timestamp field value olarak güncelleniyor)
      final messageData = newMessage.toJson();
      messageData['timestamp'] = FieldValue.serverTimestamp();

      // 5. Chat üst modelini güncelle
      final chatUpdates = {
        'lastMessage': text,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      };

      // 6. İşlemleri transaction içinde gerçekleştir
      transaction.set(newMessageRef, messageData);
      transaction.update(chatRef, chatUpdates);
    });
  }

  @override
  Future<String> createOrGetChat({
    required String userId1,
    required String userId2,
    required String requestId,
    String? contextId, // Kabul edilen yanıtın ID'si
  }) async {
    // İki kullanıcı ID'sini sıralayarak benzersiz bir chat ID oluştur
    List<String> sortedIds = [userId1, userId2]..sort();
    // contextId'yi chatId'ye eklemiyoruz! Bir talep için iki kullanıcı arasında sadece bir chat olmalı
    final chatId = '$requestId-${sortedIds[0]}_${sortedIds[1]}';

    try {
      // Transaction içinde hem okuma hem yazma işlemini güvenli şekilde yap
      // Bu şekilde aynı createOrGetChat çağrısı paralel olarak yapılsa bile
      // race condition ve çift completion hatasından kaçınmış oluruz
      await _firestore.runTransaction((transaction) async {
        // Chat dökümanını kontrol et
        final chatDoc = _firestore.collection('chats').doc(chatId);
        final docSnapshot = await transaction.get(chatDoc);

        // Eğer döküman yoksa oluştur
        if (!docSnapshot.exists) {
          final newChat = ChatModel(
            id: chatId,
            participantIds: sortedIds,
            participantNames: {}, // Başlangıçta boş, metadata ile güncellenecek
            participantAvatars: {}, // Başlangıçta boş,
            requestId: requestId,
            contextId: contextId, // Kabul edilen yanıtın ID'si (varsa)
          );

          // toJson'dan ID'yi çıkar (JsonKey anotasyonu ile yönetiliyor)
          final data = newChat.toJson();

          // ÖNEMLİ: lastMessage ve lastMessageTimestamp ekle
          // Bu olmadan chat, sohbet listesinde görünmeyebilir
          data['lastMessage'] = ''; // veya 'Henüz mesaj yok'
          data['lastMessageTimestamp'] = FieldValue.serverTimestamp();

          transaction.set(chatDoc, data);
        }
        // Var olsa da olmasa da işlemi başarıyla tamamla
      });

      // Her durumda chatId'yi döndür
      return chatId;
    } catch (e) {
      throw Exception('Chat oluşturulurken hata: $e');
    }
  }

  @override
  Future<void> updateChatMetadata({
    required String chatId,
    required Map<String, String> participantNames,
    required Map<String, String?> participantAvatars,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
    });
  }
}

/// Chat Repository Provider
@riverpod
ChatRepository chatRepository(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreChatRepository(firestore);
}

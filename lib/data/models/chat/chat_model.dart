import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kan_bul/data/models/json_converters.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class ChatModel with _$ChatModel {
  const factory ChatModel({
    @Default('') String id,
    required List<String> participantIds,
    @Default({}) Map<String, String> participantNames,
    @Default({}) Map<String, String?> participantAvatars,
    required String requestId,
    String? contextId, // Yanıt onaylandığında kullanılan donationResponse.id
    @Default('') String? lastMessage, // Varsayılan boş string
    @ServerTimestamp() @TimestampConverter() Timestamp? lastMessageTimestamp,
    @MapTimestampConverter()
    @Default({})
    Map<String, Timestamp> lastReadAt, // Her kullanıcı için son okuma zamanı
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
}

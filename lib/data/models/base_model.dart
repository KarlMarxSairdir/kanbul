// lib/data/models/base_model.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp için eklendi
import 'package:flutter/foundation.dart'; // Equality için

/// Temel veri modeli sınıfı. Firestore dökümanları için ortak alanları tanımlar.
@immutable // Modellerin değiştirilemez (immutable) olması iyi bir pratiktir.
abstract class BaseModel {
  /// Firestore döküman ID'si
  final String id;

  /// Döküman oluşturulma zamanı (Firestore'dan)
  final DateTime createdAt;

  /// Döküman son güncelleme zamanı (Firestore'dan)
  final DateTime updatedAt;

  const BaseModel({
    // <<< const constructor eklendi
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan (Firestore Map'inden) model oluşturma.
  /// Alt sınıflar bu metodu implement ederken `super.fromJson` çağırmaz,
  /// çünkü base alanlar zaten subclass'ın factory constructor'ında işlenir.
  // factory BaseModel.fromJson(String id, Map<String, dynamic> json); // <<< İmza değiştirildi (ID ayrı alınır)

  /// Modeli Firestore'a yazılacak Map formatına dönüştürme.
  /// Alt sınıflar bunu override edip kendi alanlarını ekler.
  /// `id` alanı genellikle Map'e dahil edilmez (döküman ID'si olarak kullanılır).
  /// Bu metod `DateTime`'ları `Timestamp`'e çevirmelidir.
  Map<String, dynamic> toJson();

  /// Modeli kopyalayıp bazı alanları değiştirme.
  /// Alt sınıflar kendi `copyWith` metodunu implement etmelidir.
  BaseModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }); // <<< Soyut kalması daha iyi olabilir veya Tipi döndürmeli >>>
  // Genellikle her alt sınıf kendi spesifik copyWith'ini yazar.

  /// Eşitlik kontrolü (ID bazlı)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel &&
        other.runtimeType == runtimeType && // <<< Tip kontrolü eklendi
        other.id == id;
  }

  /// Hash kodu (ID bazlı)
  @override
  int get hashCode => id.hashCode;
}

// --- Yardımcı Fonksiyonlar ---

/// Firestore Map'inden DateTime okumak için güvenli yardımcı.
DateTime safeDateTimeFromJson(dynamic jsonValue, {DateTime? defaultValue}) {
  if (jsonValue is Timestamp) {
    return jsonValue.toDate();
  } else if (jsonValue is String) {
    return DateTime.tryParse(jsonValue) ??
        (defaultValue ?? DateTime(1970)); // Varsayılanı eski bir tarih yapalım
  }
  return defaultValue ?? DateTime(1970); // null veya bilinmeyen tip için
}

/// DateTime'ı Firestore Timestamp'ine çevirmek için yardımcı.
/// Null ise null döndürür.
Timestamp? safeTimestampFromDateTime(DateTime? dateTime) {
  return dateTime == null ? null : Timestamp.fromDate(dateTime);
}

/// Nullable Timestamp okumak için yardımcı.
DateTime? safeNullableDateTimeFromJson(dynamic jsonValue) {
  if (jsonValue is Timestamp) {
    return jsonValue.toDate();
  } else if (jsonValue is String) {
    return DateTime.tryParse(jsonValue); // null dönebilir
  }
  return null;
}

/// Timestamp okumak için yardımcı (Timestamp veya null döner)
Timestamp? safeTimestampFromJson(dynamic jsonValue) {
  if (jsonValue is Timestamp) {
    return jsonValue;
  }
  return null; // Diğer tipleri null sayalım
}

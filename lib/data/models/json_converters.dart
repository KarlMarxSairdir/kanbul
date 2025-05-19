// lib/data/models/json_converters.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart'; // Import the logging package
import 'package:kan_bul/data/models/user/user_model.dart'; // <<< BU SATIRI EKLE

// --- Logger instances ---
final _loggerTimestamp = Logger('TimestampConverter');
final _loggerGeoPoint = Logger('GeoPointConverter');

// --- ServerTimestamp annotation ---
class ServerTimestamp {
  const ServerTimestamp();
}

// --- TimestampConverter (Null olabilen değerleri ve farklı formatları ele almak için güncellendi) ---
class TimestampConverter implements JsonConverter<Timestamp?, Object?> {
  // <<< Nullable Timestamp ve Object?
  const TimestampConverter();

  @override
  Timestamp? fromJson(Object? json) {
    // <<< Object? alıyor, null dönebilir
    if (json == null) {
      // <<< Null kontrolü eklendi
      return null;
    }
    if (json is Timestamp) {
      return json;
    }
    // Firebase'den bazen map olarak gelebilir
    if (json is Map<String, dynamic> &&
        json.containsKey('_seconds') &&
        json.containsKey('_nanoseconds')) {
      try {
        return Timestamp(json['_seconds'] as int, json['_nanoseconds'] as int);
      } catch (e, s) {
        // Include stack trace
        _loggerTimestamp.warning(
          "Timestamp Map conversion error",
          e,
          s,
        ); // Hata loglama
        return null;
      }
    }
    // Bazen epoch milisaniye olarak (int) gelebilir
    if (json is int) {
      try {
        return Timestamp.fromMillisecondsSinceEpoch(json);
      } catch (e, s) {
        _loggerTimestamp.warning("Timestamp Int conversion error", e, s);
        return null;
      }
    }
    // Bazen ISO String olarak gelebilir (opsiyonel)
    if (json is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(json));
      } catch (e, s) {
        _loggerTimestamp.warning("Timestamp String conversion error", e, s);
        return null;
      }
    }

    _loggerTimestamp.warning(
      "Unknown Timestamp format received: ${json.runtimeType}",
    ); // Bilinmeyen formatı logla
    return null; // Diğer tüm durumlarda null dön
  }

  // Firestore'a yazarken null ise null, değilse Timestamp yaz
  @override
  Object? toJson(Timestamp? timestamp) => timestamp; // Firestore Timestamp'i doğrudan anlar
}

// --- GeoPointConverter (Null olabilen ve doğrudan GeoPoint gelen durumlar için güncellendi) ---
class GeoPointConverter implements JsonConverter<GeoPoint?, Object?> {
  // <<< Nullable GeoPoint ve Object?
  const GeoPointConverter();

  @override
  GeoPoint? fromJson(Object? json) {
    // <<< Object? alıyor, null dönebilir
    if (json == null) {
      // <<< Null kontrolü eklendi
      return null;
    }
    // <<< YENİ: Doğrudan GeoPoint gelme durumunu kontrol et >>>
    if (json is GeoPoint) {
      return json;
    }
    // Firestore genellikle Map olarak saklar veya GeoPoint objesi döndürür
    if (json is Map<String, dynamic>) {
      try {
        // Alanların varlığını ve tipini kontrol et
        final latNum = json['latitude'] as num?;
        final lonNum = json['longitude'] as num?;

        if (latNum != null && lonNum != null) {
          return GeoPoint(latNum.toDouble(), lonNum.toDouble());
        } else {
          _loggerGeoPoint.warning(
            "GeoPoint Map missing latitude or longitude.",
          );
          return null;
        }
      } catch (e, s) {
        _loggerGeoPoint.warning("GeoPoint Map conversion error", e, s);
        return null;
      }
    }

    _loggerGeoPoint.warning(
      "Unknown GeoPoint format received: ${json.runtimeType}",
    ); // Bilinmeyen formatı logla
    return null; // Diğer tüm durumlarda null
  }

  // Firestore'a yazarken null ise null, değilse GeoPoint yaz
  @override
  Object? toJson(GeoPoint? geoPoint) => geoPoint; // Firestore GeoPoint'i doğrudan anlar
}

// UserModel için converter ekleyelim
class UserModelConverter
    implements JsonConverter<UserModel?, Map<String, dynamic>?> {
  const UserModelConverter();

  @override
  UserModel? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return UserModel.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(UserModel? user) {
    if (user == null) return null;
    return user.toJson();
  }
}

/// Map<String, Timestamp> için özel converter
class MapTimestampConverter
    implements JsonConverter<Map<String, Timestamp>, Object?> {
  const MapTimestampConverter();

  @override
  Map<String, Timestamp> fromJson(Object? json) {
    if (json == null) return {};
    if (json is Map<String, dynamic>) {
      return json.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value);
        } else if (value is Map<String, dynamic> &&
            value.containsKey('_seconds') &&
            value.containsKey('_nanoseconds')) {
          return MapEntry(
            key,
            Timestamp(value['_seconds'] as int, value['_nanoseconds'] as int),
          );
        } else if (value is int) {
          return MapEntry(key, Timestamp.fromMillisecondsSinceEpoch(value));
        } else if (value is String) {
          return MapEntry(key, Timestamp.fromDate(DateTime.parse(value)));
        } else {
          return MapEntry(key, Timestamp(0, 0));
        }
      });
    }
    return {};
  }

  @override
  Object? toJson(Map<String, Timestamp> object) {
    return object.map((key, value) => MapEntry(key, value));
  }
}

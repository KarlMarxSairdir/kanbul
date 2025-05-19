// lib/data/models/donation_center_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // UI'da LatLng gerekirse diye kalsın
import 'package:kan_bul/core/utils/logger.dart'; // Logger için

class DonationCenterModel {
  final String id;
  final String name;
  final String? address;
  final String? district; // İlçe
  final String? province;
  final String? phone;
  final String? website;
  final String? email;
  final String? imageUrl;
  final String? operatingHours;
  final bool isVerified;
  final GeoPoint location;
  final double distance;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  DonationCenterModel({
    required this.id,
    required this.name,
    this.address,
    this.district,
    this.province,
    this.phone,
    this.website,
    this.email,
    this.imageUrl,
    this.operatingHours,
    this.isVerified = false,
    required this.location,
    this.distance = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  DonationCenterModel copyWith({
    String? id,
    String? name,
    String? address,
    String? district,
    String? province,
    String? phone,
    String? website,
    String? email,
    String? imageUrl,
    String? operatingHours,
    bool? isVerified,
    GeoPoint? location,
    double? distance,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return DonationCenterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      district: district ?? this.district,
      province: province ?? this.province,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      operatingHours: operatingHours ?? this.operatingHours,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'district': district,
      'province': province,
      'phone': phone,
      'website': website,
      'email': email,
      'imageUrl': imageUrl,
      'operatingHours': operatingHours,
      'isVerified': isVerified,
      'location': location,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory DonationCenterModel.fromJson(Map<String, dynamic> json) {
    return DonationCenterModel(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Bilinmeyen Merkez',
      address: json['address'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      imageUrl: json['imageUrl'] as String?,
      operatingHours: json['operatingHours'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      location:
          json['location'] is GeoPoint
              ? json['location'] as GeoPoint
              : const GeoPoint(0, 0),
      createdAt: json['createdAt'] as Timestamp?,
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }

  // İzmir Belediyesi API'sinden gelen JSON'u parse etmek için GÜNCELLENMİŞ factory
  // Bu metot, API'den gelen `onemliyer` listesindeki her bir objeyi alır.
  factory DonationCenterModel.fromIzmirApiJson(Map<String, dynamic> apiRecord) {
    final String adi = apiRecord['ADI'] as String? ?? 'İsimsiz Merkez';
    final String ilce = apiRecord['ILCE'] as String? ?? '';

    // Adres oluşturma
    String addressValue =
        ""; // Değişken adını 'address' ile çakışmaması için değiştirdim
    if (apiRecord['MAHALLE'] != null &&
        (apiRecord['MAHALLE'] as String).isNotEmpty) {
      addressValue += "${apiRecord['MAHALLE']} Mah. ";
    }
    if (apiRecord['YOL'] != null && (apiRecord['YOL'] as String).isNotEmpty) {
      addressValue += "${apiRecord['YOL']} Cad./Sok./Blv. "; // Daha açıklayıcı
    }
    if (apiRecord['KAPINO'] != null &&
        (apiRecord['KAPINO'] as String).isNotEmpty) {
      addressValue += "No: ${apiRecord['KAPINO']}";
    }
    addressValue = addressValue.trim();
    // Eğer ACIKLAMA alanı varsa ve addressValue boşsa onu kullan
    if (addressValue.isEmpty &&
        apiRecord['ACIKLAMA'] != null &&
        (apiRecord['ACIKLAMA'] as String).isNotEmpty) {
      addressValue = apiRecord['ACIKLAMA'] as String;
    }
    // Hala boşsa ilçe adını kullan
    addressValue = addressValue.isNotEmpty ? addressValue : ilce;

    double lat = 0.0;
    double lon = 0.0;
    final enlem = apiRecord['ENLEM'];
    final boylam = apiRecord['BOYLAM'];

    if (enlem is num && boylam is num) {
      lat = enlem.toDouble();
      lon = boylam.toDouble();
    } else if (enlem is String && boylam is String) {
      lat =
          double.tryParse(enlem.replaceAll(',', '.')) ??
          0.0; // Virgül yerine nokta
      lon =
          double.tryParse(boylam.replaceAll(',', '.')) ??
          0.0; // Virgül yerine nokta
    } else {
      logger.w(
        "Invalid coordinate types or values from API for $adi: ENLEM ($enlem), BOYLAM ($boylam)",
      );
    }

    // ID için API'den gelen birincil bir anahtar yoksa,
    // isim ve koordinatların bir kombinasyonunu kullanmak iyi bir yaklaşımdır.
    // Veya daha basitçe, listenin index'i + sabit bir prefix kullanılabilir ama kalıcı olmaz.
    // Şimdilik basit bir ID üreteci:
    final String centerId =
        'izm_openapi_${adi.hashCode}_${lat.toStringAsFixed(5)}_${lon.toStringAsFixed(5)}';

    return DonationCenterModel(
      id: centerId,
      name: adi,
      address: addressValue,
      district: ilce,
      province: 'İzmir', // API'den il bilgisi gelmediği için sabit
      phone:
          apiRecord['TELEFON']
              as String?, // API'de bu isimle mi geliyor? Kontrol et.
      // İlk örnekte TELEFON1 vardı.
      location: GeoPoint(lat, lon),
      isVerified: true, // API'den geldiği için doğrulanmış kabul edelim
      // Diğer alanlar (website, email, imageUrl, operatingHours, createdAt, updatedAt) API'de yok,
      // bu yüzden null veya varsayılan constructor değerlerini alacaklar.
    );
  }
}

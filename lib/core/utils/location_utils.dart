import 'dart:math';

class LocationUtils {
  // Statik metotlar olarak tanımlayalım, nesne oluşturmaya gerek kalmasın.

  /// İki koordinat arasındaki mesafeyi km cinsinden hesaplar (Haversine formülü)
  static double calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371.0; // Dünya yarıçapı (km)
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// calculateDistance metodunu ekleyelim (Dashboard için uyumluluk)
  /// İki koordinat arasındaki mesafeyi km cinsinden hesaplar
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateDistanceInKm(lat1, lon1, lat2, lon2);
  }

  /// Dereceyi radyana çevirir
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}

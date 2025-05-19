import 'package:kan_bul/data/models/blood_request_model.dart';

/// Kan talebi ile birlikte mesafe bilgisini saklayan model.
/// UI katmanında yakınlık listelemeleri için kullanılır.
class RequestWithDistance {
  final BloodRequest request;
  final double distance;

  const RequestWithDistance({required this.request, required this.distance});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RequestWithDistance &&
        other.request.id == request.id &&
        other.distance == distance;
  }

  @override
  int get hashCode => request.id.hashCode ^ distance.hashCode;
}

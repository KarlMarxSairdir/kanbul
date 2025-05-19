import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod için
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // authStateNotifierProvider için eklendi
import 'package:kan_bul/data/repositories/blood_request_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kan_bul/core/enums/user_role.dart'; // UserRole için import ekledik
import 'package:kan_bul/core/utils/blood_compatibility.dart'; // Kan uyumluluğu için
import 'package:kan_bul/features/blood_request/domain/i_blood_request_repository.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:share_plus/share_plus.dart';

class BloodRequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId; // Rota parametresi olarak gelecek

  const BloodRequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<BloodRequestDetailScreen> createState() =>
      _BloodRequestDetailScreenState();
}

class _BloodRequestDetailScreenState
    extends ConsumerState<BloodRequestDetailScreen> {
  bool _loading = true;
  String? _error;
  BloodRequest? _requestData;
  late final IBloodRequestRepository _bloodRequestRepository;
  late final String? _currentUserId;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _bloodRequestRepository = ref.read(bloodRequestRepositoryProvider);
    _currentUserId = ref.read(authStateNotifierProvider).user?.id;

    logger.d(
      "BloodRequestDetailScreen: initState - Request ID: ${widget.requestId}, Current User: $_currentUserId",
    );

    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final bloodRequest = await _bloodRequestRepository.getById(
        widget.requestId,
      );

      if (bloodRequest == null) {
        setState(() {
          _loading = false;
          _error = "Talep bulunamadı veya silinmiş olabilir.";
        });
        return;
      }

      setState(() {
        _requestData = bloodRequest;
        _loading = false;

        if (bloodRequest.location != null) {
          _addMarker(bloodRequest.location!);
        }
      });

      logger.i("Talep detayları yüklendi: ${bloodRequest.id}");
    } catch (e) {
      logger.e("Talep detayları yüklenirken hata:", error: e);
      setState(() {
        _loading = false;
        _error = "Veriler yüklenirken bir hata oluştu: $e";
      });
    }
  }

  void _addMarker(GeoPoint location) {
    final marker = Marker(
      markerId: const MarkerId('requestLocation'),
      position: LatLng(location.latitude, location.longitude),
      infoWindow: InfoWindow(
        title: _requestData?.title ?? 'Kan Talebi',
        snippet: _requestData?.hospitalName ?? 'Konum',
      ),
    );

    _markers.add(marker);
  }

  Future<void> _closeRequest(String newStatus) async {
    try {
      setState(() => _loading = true);

      await _bloodRequestRepository.updateStatus(widget.requestId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Talep ${newStatus == 'fulfilled' ? 'tamamlandı' : 'iptal edildi'}',
            ),
          ),
        );
        context.pop(); // Önceki sayfaya dön
      }
    } catch (e) {
      logger.e("Talep durumu güncellenirken hata:", error: e);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _shareRequest() async {
    if (_requestData == null) return;

    final String shareText = '''
Kan Bağışı Talebi: ${_requestData!.title}

Hastane: ${_requestData!.hospitalName}
Kan Grubu: ${_requestData!.bloodType}
İhtiyaç Miktarı: ${_requestData!.unitsNeeded} ünite
Acil Durum: ${_requestData!.urgencyLevel == 1 ? 'Acil' : 'Normal'}
Açıklama: ${_requestData!.description}

Bu talebe yardımcı olabilir misiniz? #KanBağışı #HayatKurtar
''';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Talep Detayları')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Talep Detayları')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    if (_requestData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Talep Detayları')),
        body: const Center(child: Text('Veri bulunamadı')),
      );
    }

    final requestData = _requestData!;
    final isOwner = _currentUserId == requestData.creatorId;
    final isActive = requestData.status == 'active';
    final String statusText = _getStatusText(requestData.status);
    final Color statusColor = _getStatusColor(requestData.status);

    final recipientBloodType = requestData.bloodType;
    final authState = ref.read(authStateNotifierProvider);
    final userBloodType = authState.user?.profileData.bloodType;

    // Kan uyumluluğu kontrolü, userBloodType null ise false döner
    final bool isBloodTypeCompatible =
        userBloodType != null
            ? BloodCompatibility.canDonateTo(userBloodType, recipientBloodType)
            : false;

    final bool canRespond = isActive && !isOwner && isBloodTypeCompatible;
    // Uyarıyı sadece kullanıcı kan grubu biliniyorsa ve uyumsuzsa göster
    final bool showIncompatibleBloodTypeWarning =
        isActive && !isOwner && !isBloodTypeCompatible && userBloodType != null;

    String formattedDate = 'Bilinmiyor';
    if (requestData.createdAt != null) {
      final DateTime date = requestData.createdAt!.toDate();
      formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(date);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(requestData.title),
        actions: [
          if (isOwner && isActive)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'fulfilled') {
                  _showConfirmDialog(
                    'Talebi tamamlamak istediğinize emin misiniz?',
                    'fulfilled',
                  );
                } else if (value == 'canceled') {
                  _showConfirmDialog(
                    'Talebi iptal etmek istediğinize emin misiniz?',
                    'canceled',
                  );
                } else if (value == 'manage_offers') {
                  context.pushNamed(
                    AppRoutes.manageDonationOffersDetail,
                    pathParameters: {'requestId': widget.requestId},
                  );
                } else if (value == 'share') {
                  _shareRequest();
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'manage_offers',
                      child: Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Gelen Teklifleri Yönet'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Paylaş'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'fulfilled',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Tamamlandı Olarak İşaretle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'canceled',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('İptal Et'),
                        ],
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor),
              ),
              child: Row(
                children: [
                  Icon(
                    isActive
                        ? Icons.hourglass_top
                        : requestData.status == 'fulfilled'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Durum: $statusText',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (showIncompatibleBloodTypeWarning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kan grubunuz ($userBloodType) bu talep için istenen kan grubu ile ($recipientBloodType) uyumlu değil.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (showIncompatibleBloodTypeWarning) const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requestData.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            requestData.bloodType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('${requestData.unitsNeeded} ünite'),
                          backgroundColor: Colors.blue[100],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            _getUrgencyText(requestData.urgencyLevel),
                          ),
                          backgroundColor: _getUrgencyColor(
                            requestData.urgencyLevel,
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Açıklama:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(requestData.description),
                    const Divider(height: 24),
                    if (requestData.hospitalName != null) ...[
                      const Text(
                        'Hastane:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(requestData.hospitalName!),
                      const SizedBox(height: 8),
                    ],
                    if (requestData.patientInfo != null &&
                        requestData.patientInfo!.isNotEmpty) ...[
                      const Text(
                        'Hasta Bilgisi:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(requestData.patientInfo!),
                      const SizedBox(height: 8),
                    ],
                    if (requestData.contactPhone != null) ...[
                      const Text(
                        'İletişim Telefonu:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(requestData.contactPhone!),
                      const SizedBox(height: 8),
                    ],
                    const Text(
                      'Oluşturulma Tarihi:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(formattedDate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (requestData.location != null) ...[
              const Text(
                'Konum Bilgisi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        requestData.location!.latitude,
                        requestData.location!.longitude,
                      ),
                      zoom: 14,
                    ),
                    markers: _markers,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled:
                        true, // Google'ın kendi yol tarifi toolbar'ı aktif
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(
                    UserRoleExtension.fromJson(requestData.creatorRole) ==
                            UserRole.hospitalStaff
                        ? Icons.local_hospital_outlined
                        : Icons.person_outline,
                    color: Colors.blue[800],
                  ),
                ),
                title: Text(
                  requestData.creatorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(isOwner ? 'Sizin talebiniz' : 'Talep Sahibi'),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),

      floatingActionButton:
          canRespond
              ? FloatingActionButton.extended(
                onPressed: () {
                  context.push(
                    '${AppRoutes.respondToRequest}/${widget.requestId}',
                  );
                },
                label: const Text(
                  'Yanıt Ver',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.volunteer_activism),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Dikdörtgen köşe
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              )
              : null,
    );
  }

  void _showConfirmDialog(String message, String newStatus) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Onay'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _closeRequest(newStatus);
                },
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'fulfilled':
        return 'Tamamlandı';
      case 'canceled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blue;
      case 'fulfilled':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyText(int level) {
    switch (level) {
      case 3:
        return 'ÇOK ACİL';
      case 2:
        return 'ACİL';
      case 1:
        return 'NORMAL';
      default:
        return 'BELİRTİLMEMİŞ';
    }
  }

  Color _getUrgencyColor(int level) {
    switch (level) {
      case 3:
        return Colors.red[700]!;
      case 2:
        return Colors.orange[700]!;
      case 1:
        return Colors.green[700]!;
      default:
        return Colors.blue[700]!;
    }
  }
}

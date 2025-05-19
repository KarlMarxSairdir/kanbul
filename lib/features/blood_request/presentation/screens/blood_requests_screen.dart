import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:go_router/go_router.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // Changed from auth_notifier
import 'package:kan_bul/data/repositories/blood_request_repository.dart'; // FirestoreService yerine Repository
import 'package:kan_bul/features/blood_request/domain/i_blood_request_repository.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
// import 'package:kan_bul/widgets/empty_state_widget.dart'; // Eğer varsa
import 'package:intl/intl.dart'; // Tarih formatlaması için
import 'package:kan_bul/core/theme/app_theme.dart'; // AppTheme import edildi

class BloodRequestsScreen extends ConsumerStatefulWidget {
  const BloodRequestsScreen({super.key});

  @override
  ConsumerState<BloodRequestsScreen> createState() =>
      _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends ConsumerState<BloodRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4, // 4 sekmeye çıkarıldı
      vsync: this,
    );
    logger.d("BloodRequestsScreen: initState");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("BloodRequestsScreen: build");

    final authState = ref.watch(authStateNotifierProvider);
    final userId = authState.user?.id;
    final bloodRequestRepository = ref.watch(bloodRequestRepositoryProvider);

    if (authState.isLoading && userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Aktif talepler ve yanıtı olan talepler için sayıları alalım
    final activeRequestsStream = bloodRequestRepository
        .watchUserRequestsByStatus(userId ?? '', 'active');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talepleri Yönet'), // Başlık güncellendi
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: [
            StreamBuilder<List<BloodRequest>>(
              stream: activeRequestsStream,
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: const Text('Aktif'),
                      ), // ✅ Flexible eklendi
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Badge(
                          label: Text('$count'),
                          backgroundColor: Colors.blue,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            StreamBuilder<List<BloodRequest>>(
              stream: activeRequestsStream.map(
                (list) => list.where((r) => r.responseCount > 0).toList(),
              ),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: const Text('Yanıtlar'),
                      ), // ✅ Flexible eklendi
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Badge(
                          label: Text('$count'),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const Tab(text: 'Tamamlanan'),
            const Tab(text: 'İptal Edilen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserRequestList(
            bloodRequestRepository,
            userId,
            status: 'active',
          ),
          _buildUserRequestList(
            bloodRequestRepository,
            userId,
            status: 'active',
            onlyWithOffers: true,
          ),
          _buildUserRequestList(
            bloodRequestRepository,
            userId,
            status: 'fulfilled',
          ),
          _buildUserRequestList(
            bloodRequestRepository,
            userId,
            status: 'cancelled',
          ),
        ],
      ),
    );
  }

  Widget _buildUserRequestList(
    IBloodRequestRepository bloodRequestRepository,
    String? userId, {
    required String status,
    bool onlyWithOffers = false,
  }) {
    if (userId == null) {
      return const Center(
        child: Text('Kullanıcı bilgisi alınamadı. Lütfen giriş yapın.'),
      );
    }

    return StreamBuilder<List<BloodRequest>>(
      stream: bloodRequestRepository
          .watchUserRequestsByStatus(userId, status)
          .map(
            (list) =>
                onlyWithOffers
                    ? list.where((r) => r.responseCount > 0).toList()
                    : list,
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          logger.d(
            "BloodRequests ($status${onlyWithOffers ? ' with offers' : ''}): Loading",
          );
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          logger.e(
            "BloodRequests ($status${onlyWithOffers ? ' with offers' : ''}): Error - ${snapshot.error}",
          );
          return Center(child: Text('Hata oluştu: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          logger.d(
            "BloodRequests ($status${onlyWithOffers ? ' with offers' : ''}): No data",
          );
          return _buildEmptyView(status, onlyWithOffers: onlyWithOffers);
        }

        final requests = snapshot.data!;

        logger.i(
          "BloodRequests ($status${onlyWithOffers ? ' with offers' : ''}): ${requests.length} talep yüklendi",
        );

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            if (status == 'active' && !onlyWithOffers) {
              return Dismissible(
                key: ValueKey(request.id),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Tamamlandı',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'İptal Et',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.cancel, color: Colors.white),
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    final result = await _showConfirmDialog(
                      context,
                      'Talep tamamlandı olarak işaretlensin mi?',
                    );
                    if (result == true) {
                      await bloodRequestRepository.updateStatus(
                        request.id,
                        'fulfilled',
                      );
                      return true;
                    }
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    final result = await _showConfirmDialog(
                      context,
                      'Talep iptal edilsin mi?',
                    );
                    if (result == true) {
                      await bloodRequestRepository.updateStatus(
                        request.id,
                        'cancelled',
                      );
                      return true;
                    }
                    return false;
                  }
                  return false;
                },
                child: _buildRequestCard(request, ref),
              );
            } else {
              return _buildRequestCard(request, ref);
            }
          },
        );
      },
    );
  }

  Widget _buildRequestCard(
    BloodRequest request,
    WidgetRef ref, {
    bool showCreator = false,
  }) {
    final formattedDate = _formatTimestamp(request.createdAt);
    final bloodInfo = "${request.bloodType} (${request.unitsNeeded} ünite)";
    final urgencyText = _getUrgencyText(request.urgencyLevel);

    final currentUserId = ref.watch(authStateNotifierProvider).user?.id;
    final bool isOwnRequest =
        currentUserId != null && request.creatorId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      color: isOwnRequest ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () {
          logger.i("Talep detayına gidiliyor: ${request.id}");
          if (request.id.isNotEmpty) {
            context.pushNamed(
              AppRoutes.bloodRequestDetail,
              pathParameters: {'requestId': request.id},
            );
          }
        },
        onLongPress: () {
          if (isOwnRequest && request.responseCount > 0) {
            logger.i(
              "Uzun basıldı, yanıtları yönetmeye gidiliyor: ${request.id}",
            );
            context.pushNamed(
              AppRoutes.manageDonationOffersDetail,
              pathParameters: {'requestId': request.id},
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(request.urgencyLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      urgencyText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                bloodInfo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (showCreator) ...[
                Row(
                  children: [
                    Icon(
                      request.creatorRole == 'doctor'
                          ? Icons.medical_services
                          : Icons.person,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.creatorName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isOwnRequest) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Text(
                          'Sizin',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.hospitalName ?? 'Hastane belirtilmemiş',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              if (request.responseCount > 0) ...[
                const SizedBox(height: 8),
                Chip(
                  backgroundColor: Colors.green.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  label: Text(
                    '${request.responseCount} yanıt',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  avatar: Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(String status, {bool onlyWithOffers = false}) {
    String message;
    IconData icon;

    if (onlyWithOffers) {
      message = 'Henüz gelen yanıtınız bulunmuyor.';
      icon = Icons.mark_chat_unread_outlined;
    } else {
      switch (status) {
        case 'active':
          message = 'Aktif kan talebiniz bulunmuyor';
          icon = Icons.hourglass_empty;
          break;
        case 'fulfilled':
          message = 'Tamamlanmış kan talebiniz bulunmuyor';
          icon = Icons.check_circle_outline;
          break;
        case 'cancelled':
          message = 'İptal edilmiş kan talebiniz bulunmuyor';
          icon = Icons.cancel_outlined;
          break;
        default:
          message = 'Kan talebi bulunamadı';
          icon = Icons.search_off;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (status == 'active' && !onlyWithOffers)
            ElevatedButton.icon(
              onPressed: () {
                context.push(AppRoutes.createBloodRequest);
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Talep Oluştur'),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Tarih yok';

    try {
      final date = timestamp.toDate();
      return DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(date);
    } catch (e) {
      logger.w("Tarih formatlama hatası: $e");
      return 'Geçersiz tarih';
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
    return AppTheme.getUrgencyColor(level);
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String message) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Onayla'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Vazgeç'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Evet'),
              ),
            ],
          ),
    );
  }
}

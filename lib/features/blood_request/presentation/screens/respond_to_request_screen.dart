import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/repositories/blood_request_repository.dart'; // Doğru repository import'u
import 'package:kan_bul/data/repositories/donation_repository.dart'; // Doğru repository import'u
import 'package:kan_bul/features/chat/providers/chat_providers.dart'; // Chat providerını ekle
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/theme/app_theme.dart'; // AppTheme için import ekledim
import 'package:kan_bul/routes/app_routes.dart';

class RespondToRequestScreen extends ConsumerStatefulWidget {
  final String requestId; // Yanıt verilecek talep ID'si

  const RespondToRequestScreen({super.key, required this.requestId});

  @override
  ConsumerState<RespondToRequestScreen> createState() =>
      _RespondToRequestScreenState();
}

class _RespondToRequestScreenState
    extends ConsumerState<RespondToRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingRequestDetails = true;
  String? _errorMessage;
  Map<String, dynamic>? _requestData;
  bool _isEligibleConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    try {
      setState(() {
        _isLoadingRequestDetails = true;
        _errorMessage = null;
      });

      final bloodRequestRepository = ref.read(bloodRequestRepositoryProvider);
      final bloodRequest = await bloodRequestRepository.getById(
        widget.requestId,
      );

      if (bloodRequest == null) {
        setState(() {
          _isLoadingRequestDetails = false;
          _errorMessage = "Talep bulunamadı veya silinmiş olabilir.";
        });
        return;
      }

      // Convert BloodRequest to Map for existing code compatibility
      final data = {
        'creatorId': bloodRequest.creatorId,
        'creatorName': bloodRequest.creatorName,
        'title': bloodRequest.title,
        'description': bloodRequest.description,
        'bloodType': bloodRequest.bloodType,
        'unitsNeeded': bloodRequest.unitsNeeded,
        'urgencyLevel': bloodRequest.urgencyLevel,
        'hospitalName': bloodRequest.hospitalName,
        'status': bloodRequest.status,
        'creatorAvatarUrl': null, // GEÇİCİ: Modelde bu alan yoksa null atanır.
      };

      setState(() {
        _requestData = data;
        _isLoadingRequestDetails = false;
      });

      logger.i("Talep detayları yüklendi: ${widget.requestId}");
    } catch (e) {
      logger.e("Talep detayları yüklenirken hata:", error: e);
      setState(() {
        _isLoadingRequestDetails = false;
        _errorMessage = "Veriler yüklenirken bir hata oluştu: $e";
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitResponse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isEligibleConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen kan bağışı için uygun olduğunuzu onaylayın.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authState = ref.read(authStateNotifierProvider);
    final donorId = authState.user?.id;
    final userProfile = authState.user;

    if (donorId == null || userProfile == null) {
      // Bu durum olmamalı, guard korumalı
      logger.e("Yanıt gönderilirken kullanıcı ID veya profil bulunamadı!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı bilgileri alınamadı.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    // Bu değişkenleri try bloğundan önce tanımla ki finally ve sonrası erişebilsin.
    final String? requestCreatorIdFromData =
        _requestData?['creatorId'] as String?;
    final String? requestCreatorNameFromData =
        _requestData?['creatorName'] as String?;

    logger.i(
      "Donation Response gönderiliyor: RequestID=${widget.requestId}, DonorID=$donorId",
    );

    String? createdChatId;

    try {
      // 1. Önce bağış yanıtı oluştur
      final donationRepository = ref.read(donationRepositoryProvider);

      if (requestCreatorIdFromData == null) {
        logger.e("Yanıt oluşturulurken talep sahibi ID'si bulunamadı!");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Talep sahibi bilgileri eksik.')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      await donationRepository.createDonationResponse(
        donorId: donorId,
        requestId: widget.requestId,
        message:
            _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
        // Denormalize edilecek bilgiler:
        donorName: userProfile.username,
        donorBloodType: userProfile.profileData.bloodType,
        donorPhotoUrl: userProfile.photoUrl,
        requestCreatorId: requestCreatorIdFromData,
      );

      logger.i("Yanıt başarıyla gönderildi.");
      // EKSTRA LOG: Yanıt gönderme sonrası
      logger.d("_submitResponse: Donation response created successfully.");

      // 2. Kullanıcı ile chat oluşturma
      try {
        createdChatId = await ref
            .read(chatControllerProvider.notifier)
            .createOrGetChat(
              otherUserId: requestCreatorIdFromData,
              requestId: widget.requestId,
              otherUserName:
                  requestCreatorNameFromData ?? 'Bilinmeyen Kullanıcı',
            );

        logger.i("Chat oluşturuldu/açıldı: $createdChatId");
        // EKSTRA LOG: Chat oluşturma/alma sonrası
        logger.d(
          "_submitResponse: createOrGetChat completed. createdChatId: $createdChatId",
        );
      } catch (chatError) {
        logger.e("Chat oluşturma hatası:", error: chatError);
        // EKSTRA LOG: Chat oluşturma hatası
        logger.w("_submitResponse: Error during createOrGetChat: $chatError");
        // Chat oluşturma hatası ama işlem devam edecek
      }
    } catch (e) {
      logger.e("Yanıt gönderme hatası:", error: e);

      // Kullanıcıya daha anlaşılır bir hata mesajı göster
      String errorMessage = 'Yanıt gönderilirken bir hata oluştu.';

      if (e.toString().contains('Blood request not found')) {
        errorMessage = 'Bu talep artık mevcut değil veya silinmiş olabilir.';
      } else if (e.toString().contains('not-found')) {
        errorMessage = 'Talep bulunamadı veya silinmiş olabilir.';
      } else if (e.toString().contains('Bu talebe zaten bir yanıt verdiniz.')) {
        errorMessage = 'Bu talebe zaten bir yanıt verdiniz.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        setState(() => _isLoading = false);
      }
      return; // Hata durumunda devam etme
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // 3. İşlemler tamamlandıktan sonra kullanıcıya bilgi ver ve yönlendir
    if (mounted) {
      // Önce kullanıcıya bilgi verelim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            createdChatId != null
                ? 'Yanıtınız gönderildi ve sohbet başlatıldı.'
                : 'Yanıtınız başarıyla gönderildi.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // EKSTRA LOG: Yönlendirme öncesi kontrol
      logger.d(
        "_submitResponse: Checking conditions for navigation. createdChatId: $createdChatId, requestCreatorIdFromData: $requestCreatorIdFromData",
      );

      // Navigator'ün durumunu güvenli şekilde handle edelim
      if (mounted) {
        // Delay kullanarak UI işlemlerinin bitmesini bekleyelim
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return; // Widget ağaçtan ayrıldıysa çık

          if (createdChatId != null) {
            final currentUser = ref.read(authStateNotifierProvider).user;
            if (currentUser == null) {
              logger.e(
                "Yanıt sonrası chat yönlendirmesi için mevcut kullanıcı bulunamadı.",
              );
              // EKSTRA LOG: Dashboard'a yönlendirme (currentUser null)
              logger.d(
                "_submitResponse: Navigating to dashboard because currentUser is null.",
              );
              if (mounted) context.go(AppRoutes.dashboard);
            } else {
              final participantIds = [currentUser.id, requestCreatorIdFromData];
              final creatorAvatar =
                  _requestData?['creatorAvatarUrl'] as String?;

              // EKSTRA LOG: Chat ekranına yönlendirme
              logger.d(
                "_submitResponse: Navigating to chat screen. ChatId: $createdChatId, OtherUserId: $requestCreatorIdFromData",
              );
              logger.d(
                "Yanıt sonrası Chat ekranına yönlendiriliyor. ChatId: $createdChatId, Diğer Kullanıcı ID: $requestCreatorIdFromData, Diğer Kullanıcı Adı: ${requestCreatorNameFromData ?? 'Bilinmeyen'}, Talep ID: ${widget.requestId}, Katılımcılar: $participantIds",
              );

              if (mounted) {
                context.pushNamed(
                  AppRoutes.chat,
                  pathParameters: {'chatId': createdChatId},
                  extra: {
                    'otherUserName':
                        requestCreatorNameFromData ?? 'Bilinmeyen Kullanıcı',
                    'otherUserAvatar': creatorAvatar,
                    'requestId': widget.requestId,
                    'otherUserId': requestCreatorIdFromData,
                    'participantIds': participantIds,
                  },
                );
              }
            }
          } else {
            // Sadece bağış yanıtı oluşturuldu, chat yok. Dashboard'a veya uygun bir ekrana yönlendir.
            // EKSTRA LOG: Dashboard'a yönlendirme (chatId null)
            logger.d(
              "_submitResponse: Navigating to dashboard because createdChatId is null.",
            );
            if (mounted) context.go(AppRoutes.dashboard);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRequestDetails) {
      return Scaffold(
        appBar: AppBar(title: const Text('Talebe Yanıt Ver')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Talebe Yanıt Ver')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
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

    final bloodType = _requestData?['bloodType'] ?? 'Belirtilmemiş';
    final urgencyText = _getUrgencyText(_requestData?['urgencyLevel'] ?? 1);
    final hospitalName = _requestData?['hospitalName'] ?? 'Belirtilmemiş';
    final title = _requestData?['title'] ?? 'Kan Talebi';

    return Scaffold(
      appBar: AppBar(title: const Text('Talebe Yanıt Ver')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Talep özet bilgisi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              bloodType,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                AppTheme.getBloodTypeBackgroundColor(bloodType),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(urgencyText),
                            backgroundColor: _getUrgencyColor(
                              _requestData?['urgencyLevel'] ?? 1,
                            ),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Hastane: $hospitalName'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Talep sahibine iletmek istediğiniz bir mesaj var mı?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Mesajınızı buraya yazın... (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text(
                  "Kan bağışı için uygun olduğumu onaylıyorum.",
                ),
                value: _isEligibleConfirmed,
                onChanged: (bool? value) {
                  setState(() {
                    _isEligibleConfirmed = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const Spacer(), // Butonu alta iter
              ElevatedButton(
                onPressed: _isLoading ? null : _submitResponse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Yanıtı Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Aciliyet seviyesi metni
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

  // Aciliyet seviyesi renklerini döndürür
  Color _getUrgencyColor(int level) {
    // AppTheme'deki yardımcı metodu kullanalım
    return AppTheme.getUrgencyColor(level);
  }
}

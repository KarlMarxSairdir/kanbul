// lib/features/blood_request/presentation/screens/manage_donation_offers_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore için
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:kan_bul/data/repositories/donation_repository.dart';
import 'package:kan_bul/routes/app_routes.dart'; // Rotalar için
import 'package:go_router/go_router.dart'; // Navigasyon için
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod için ekledik
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // EKLENDİ: AuthStateNotifier için import
import 'package:kan_bul/features/chat/providers/chat_providers.dart'; // EKLENDİ: ChatController için import

// StatefulWidget yerine ConsumerStatefulWidget kullanıyoruz
class ManageDonationOffersScreen extends ConsumerStatefulWidget {
  final String requestId;

  const ManageDonationOffersScreen({super.key, required this.requestId});

  @override
  ConsumerState<ManageDonationOffersScreen> createState() =>
      _ManageDonationOffersScreenState();
}

// State sınıfını ConsumerState'e çeviriyoruz
class _ManageDonationOffersScreenState
    extends ConsumerState<ManageDonationOffersScreen> {
  late final DonationRepository _donationRepository; // Repository'yi tut
  bool _isProcessing = false; // Kabul/Reddet işlemi sırasında loading

  @override
  void initState() {
    super.initState();
    // Riverpod ref ile provider'a erişiyoruz
    _donationRepository = ref.read(donationRepositoryProvider);
    logger.d(
      "ManageDonationOffersScreen: initState - Request ID: ${widget.requestId}",
    );
  }

  // Teklifi kabul etme fonksiyonu
  Future<void> _acceptOffer(String donationId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    logger.i("Teklif kabul ediliyor: DonationID=$donationId");
    try {
      await _donationRepository.updateDonationStatus(donationId, 'accepted');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Teklif kabul edildi.')));

        // Kabul sonrası bağışçı ile iletişim için ChatScreen'e yönlendirme
        final offerDoc = await _donationRepository.getDonationById(donationId);
        if (offerDoc != null && offerDoc.exists) {
          final offerData = offerDoc.data() as Map<String, dynamic>;
          final donorId = offerData['donorId'] as String?;
          final donorName = offerData['donorName'] as String? ?? 'Bağışçı';

          if (donorId == null || donorId.isEmpty) {
            logger.e("Donor ID eksik, chat açılamıyor.");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Bağışçı bilgisi eksik, sohbet başlatılamadı."),
                ),
              );
            }
            return;
          }

          if (mounted) {
            final currentUser = ref.read(authStateNotifierProvider).user;
            if (currentUser == null) {
              logger.e(
                "Mevcut kullanıcı bulunamadı, chat için participantIds oluşturulamıyor.",
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Sohbet başlatılamadı: Kullanıcı bilgisi eksik.",
                    ),
                  ),
                );
              }
              return;
            }

            // Chat oluştur veya mevcut olanı al
            final chat = await ref
                .read(chatControllerProvider.notifier)
                .createOrGetChat(
                  otherUserId: donorId,
                  requestId: widget.requestId,
                  otherUserName: donorName,
                  contextId: donationId, // Kabul edilen teklif ID'si
                );

            final participantIds = [
              currentUser.id,
              donorId,
            ]; // donorId null kontrolü yukarıda yapıldı

            logger.d(
              "Chat ekranına yönlendiriliyor (kabul sonrası). Rota: ${AppRoutes.chat}/$chat, Diğer Kullanıcı ID: $donorId, Diğer Kullanıcı Adı: $donorName, Talep ID: ${widget.requestId}, Katılımcılar: $participantIds",
            );

            // Kullanıcıyı sohbete yönlendir
            if (mounted) {
              context.pushNamed(
                AppRoutes.chat,
                pathParameters: {'chatId': chat},
                extra: {
                  'otherUserId': donorId,
                  'otherUserName': donorName,
                  'requestId': widget.requestId,
                  'participantIds': participantIds,
                  'contextId':
                      donationId, // Kabul edilen donationResponse ID'si
                },
              );
            }
          }
        }
      }
    } catch (e) {
      logger.e("Teklif kabul etme hatası:", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Teklifi reddetme fonksiyonu
  Future<void> _rejectOffer(String donationId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    logger.i("Teklif reddediliyor: DonationID=$donationId");
    try {
      await _donationRepository.updateDonationStatus(donationId, 'rejected');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Teklif reddedildi.')));
        // Ekran kapanmaz, liste güncellenir (StreamBuilder sayesinde)
      }
    } catch (e) {
      logger.e("Teklif reddetme hatası:", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d("ManageDonationOffersScreen: build");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Bağış Teklifleri'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('bloodRequests')
                    .doc(widget.requestId)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final requestData =
                    snapshot.data!.data() as Map<String, dynamic>?;
                final title = requestData?['title'] ?? '';
                final bloodType = requestData?['bloodType'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '$title • $bloodType kan grubu',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore'dan hem 'pending' hem 'accepted' durumundaki teklifleri dinle
        stream: _donationRepository.getRequestDonationsStream(widget.requestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            logger.d("ManageDonationOffersScreen: Teklifler yükleniyor...");
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            logger.e("Teklifleri yüklerken hata: ", error: snapshot.error);
            return Center(
              child: Text(
                'Teklifler yüklenirken bir hata oluştu: ${snapshot.error}',
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            logger.i("ManageDonationOffersScreen: Teklif yok.");
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Bu talep için henüz bir bağış teklifi bulunmuyor.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Tüm teklifleri al
          final offers = snapshot.data!.docs;
          // Sadece pending ve accepted olanları göster
          final filteredOffers =
              offers.where((doc) {
                final status = (doc.data() as Map<String, dynamic>)['status'];
                return status == 'pending' || status == 'accepted';
              }).toList();

          if (filteredOffers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Bu talep için henüz bir bağış teklifi bulunmuyor.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredOffers.length,
            itemBuilder: (context, index) {
              final offerDoc = filteredOffers[index];
              final offerData = offerDoc.data() as Map<String, dynamic>;
              final donationId = offerDoc.id;
              final donorName = offerData['donorName'] ?? 'Bilinmeyen Bağışçı';
              final message = offerData['message'] as String?;
              final donorPhotoUrl = offerData['donorPhotoUrl'] as String?;
              final donorBloodType = offerData['donorBloodType'] as String?;
              final status = offerData['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          donorPhotoUrl != null
                              ? NetworkImage(donorPhotoUrl)
                              : null,
                      child:
                          donorPhotoUrl == null
                              ? Text(donorName.isNotEmpty ? donorName[0] : '?')
                              : null,
                    ),
                    title: Text(
                      donorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (donorBloodType != null)
                          Text("Kan Grubu: $donorBloodType"),
                        if (message != null)
                          Text(
                            "Mesaj: \"$message\"",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const Text(
                            "Mesaj yok",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                    trailing:
                        _isProcessing
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.chat_outlined,
                                    color: Colors.blue.shade600,
                                  ),
                                  tooltip: 'Sohbet Et',
                                  onPressed: () async {
                                    final donorId =
                                        offerData['donorId'] as String?;
                                    final donorName =
                                        offerData['donorName'] as String? ??
                                        'Bilinmeyen Bağışçı';

                                    if (donorId == null || donorId.isEmpty) {
                                      logger.e(
                                        "Donor ID eksik, chat açılamıyor.",
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Bağışçı bilgisi eksik, sohbet başlatılamadı.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final currentUser =
                                        ref
                                            .read(authStateNotifierProvider)
                                            .user;
                                    if (currentUser == null) {
                                      logger.e(
                                        "Mevcut kullanıcı bulunamadı, chat için participantIds oluşturulamıyor.",
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Sohbet başlatılamadı: Kullanıcı bilgisi eksik.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final participantIds = [
                                      currentUser.id,
                                      donorId,
                                    ]; // ChatController ile chat oluştur veya mevcut olanı al
                                    final chatId = await ref
                                        .read(chatControllerProvider.notifier)
                                        .createOrGetChat(
                                          otherUserId: donorId,
                                          requestId: widget.requestId,
                                          otherUserName: donorName,
                                          contextId:
                                              donationId, // Bağış teklif ID'si context olarak kaydedilir
                                        );

                                    logger.d(
                                      "Chat ekranına yönlendiriliyor (ikon tıklama). Rota: ${AppRoutes.chat}/$chatId, Diğer Kullanıcı ID: $donorId, Diğer Kullanıcı Adı: $donorName, Talep ID: ${widget.requestId}, Context ID: $donationId, Katılımcılar: $participantIds",
                                    );
                                    context.pushNamed(
                                      AppRoutes.chat,
                                      pathParameters: {'chatId': chatId},
                                      extra: {
                                        'otherUserId': donorId,
                                        'otherUserName': donorName,
                                        'requestId': widget.requestId,
                                        'participantIds': participantIds,
                                        'contextId':
                                            donationId, // Context ID olarak donationId eklendi
                                      },
                                    );
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                if (status == 'pending') ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Kabul Et',
                                    onPressed: () => _acceptOffer(donationId),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Reddet',
                                    onPressed: () => _rejectOffer(donationId),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ],
                            ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

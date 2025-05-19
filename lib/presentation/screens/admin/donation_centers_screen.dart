import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kan_bul/data/models/donation_center_model.dart';
// Yeni API provider'ını import et
import 'package:kan_bul/data/repositories/donation_center_repository.dart';
import 'package:kan_bul/core/utils/logger.dart' as app_logger;
import 'package:url_launcher/url_launcher.dart'; // Haritada göstermek için
// import 'package:kan_bul/core/theme/app_theme.dart'; // Tema için // Unused import removed
import 'package:kan_bul/core/providers/location_provider.dart'; // Mevcut konumu almak için

class DonationCentersScreen extends ConsumerStatefulWidget {
  // Harita state'i için Stateful
  const DonationCentersScreen({super.key});

  @override
  ConsumerState<DonationCentersScreen> createState() =>
      _DonationCentersScreenState();
}

class _DonationCentersScreenState extends ConsumerState<DonationCentersScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _customMarkerIcon; // Özel marker ikonu için

  // İzmir için varsayılan kamera pozisyonu
  static const CameraPosition _kIzmirCenter = CameraPosition(
    target: LatLng(38.423733, 27.142747), // İzmir merkezi
    zoom: 11.0,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    // Opsiyonel: Özel bir marker ikonu yükleyebilirsiniz.
    // _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(size: Size(48, 48)),
    //   'assets/images/custom_marker.png', // Kendi ikonunuzun yolu
    // );
    // setState(() {}); // İkon yüklendikten sonra UI'ı güncelle
  }

  void _showCenterDetails(BuildContext context, DonationCenterModel center) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                center.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (center.address != null && center.address!.isNotEmpty)
                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Adres',
                  center.address!,
                ),
              if (center.district != null && center.district!.isNotEmpty)
                _buildDetailRow(Icons.map_outlined, 'İlçe', center.district!),
              if (center.phone != null && center.phone!.isNotEmpty)
                _buildDetailRow(
                  Icons.phone_outlined,
                  'Telefon',
                  center.phone!,
                  isPhoneNumber: true,
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Yol Tarifi Al'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Tam genişlik
                ),
                onPressed: () {
                  _launchMapsUrl(
                    center.location.latitude,
                    center.location.longitude,
                    center.name,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isPhoneNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                isPhoneNumber
                    ? InkWell(
                      onTap: () => _launchPhone(value),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                    : Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMapsUrl(double lat, double lon, String label) async {
    final query = Uri.encodeComponent(label);
    final url =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon&query_place_id=$query';
    // Alternatif: final url = 'geo:$lat,$lon?q=$query'; (Cihazdaki harita uygulamasını açar)

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      app_logger.logger.e('Harita URL\'si açılamadı: $url');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita uygulaması bulunamadı.')),
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      ), // Sadece rakamları bırak
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      app_logger.logger.e('Telefon numarası aranamadı: $phoneNumber');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması bulunamadı.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // API'den gelen İzmir kan merkezlerini izle
    final asyncApiDonationCenters = ref.watch(izmirDonationCentersApiProvider);
    // Kullanıcının mevcut konumunu al (opsiyonel, haritayı oraya odaklamak için)
    final asyncCurrentUserPosition = ref.watch(currentPositionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kan Bağış Merkezleri (İzmir)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // API'den veriyi yeniden çekmek için provider'ı refresh et
              // ignore: unused_result
              ref.refresh(izmirDonationCentersApiProvider);
              app_logger.logger.i("İzmir kan merkezleri listesi yenilendi.");
            },
            tooltip: 'Listeyi Yenile (API)',
          ),
          // Firestore'a kaydetme veya lokal JSON işleme butonları kaldırıldı.
        ],
      ),
      body: asyncApiDonationCenters.when(
        data: (centers) {
          if (centers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('İzmir için kan bağış merkezi bulunamadı.'),
                ],
              ),
            );
          }

          // Marker'ları doğrudan burada oluştur
          final Set<Marker> currentMarkers =
              centers.map((center) {
                return Marker(
                  markerId: MarkerId(center.id),
                  position: LatLng(
                    center.location.latitude,
                    center.location.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: center.name,
                    snippet: center.address ?? center.district ?? 'Detaylar...',
                    onTap: () {
                      _showCenterDetails(context, center);
                    },
                  ),
                  icon:
                      _customMarkerIcon ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRose,
                      ),
                );
              }).toSet();

          // Harita ve Liste görünümü için bir Stack veya Column kullanılabilir.
          // Şimdilik sadece harita.
          return GoogleMap(
            initialCameraPosition: _kIzmirCenter,
            markers:
                currentMarkers, // Doğrudan oluşturulan marker setini kullan
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Eğer kullanıcının konumu varsa, haritayı oraya animasyonla götür
              asyncCurrentUserPosition.whenData((position) {
                if (position != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(position.latitude, position.longitude),
                      13.0, // Daha yakın bir zoom seviyesi
                    ),
                  );
                }
              });
            },
            onTap: (LatLng position) {
              // Haritaya tıklanınca InfoWindow'ları kapatmak için
              // Bu, InfoWindow'lar açıkken haritanın başka bir yerine tıklayınca
              // InfoWindow'un kapanmasını sağlar.
              // Ancak bu bazen marker'a tıklamayı da etkileyebilir.
              // _mapController?.hideMarkerInfoWindow(const MarkerId("some_id")); // Tümünü kapatmak zor.
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          app_logger.logger.e(
            "Kan merkezleri yüklenirken hata (UI)",
            error: error,
            stackTrace: stackTrace,
          );
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Merkezler yüklenirken bir hata oluştu.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString().replaceFirst(
                      "Exception: ",
                      "",
                    ), // Hata mesajını göster
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    onPressed:
                        () => ref.refresh(izmirDonationCentersApiProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // FAB kaldırıldı, çünkü ana işlev haritada göstermek.
      // Eğer yakındaki merkezleri filtrelemek için ayrı bir FAB istenirse eklenebilir.
    );
  }
}

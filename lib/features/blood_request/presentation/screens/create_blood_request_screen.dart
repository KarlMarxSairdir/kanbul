import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/repositories/blood_request_repository.dart'; // Doğru repository import'u
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kan_bul/features/map/presentation/screens/map_screen.dart';
import 'package:kan_bul/data/models/blood_request_model.dart';
import 'package:share_plus/share_plus.dart'; // Paylaşım için eklendi

class CreateBloodRequestScreen extends ConsumerStatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  ConsumerState<CreateBloodRequestScreen> createState() =>
      _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState
    extends ConsumerState<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitsNeededController = TextEditingController(text: '1');
  final _patientInfoController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String? _selectedBloodType;
  int _selectedUrgency = 1;
  Position? _selectedPosition;
  bool _useCurrentLocation = true;
  String? _addressText;

  final List<String> _bloodTypes = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    '0+',
    '0-',
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    logger.d("CreateBloodRequestScreen: initState");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });

    _getCurrentLocation();
  }

  void _loadUserData() {
    final authState = ref.read(authStateNotifierProvider);
    final userProfile = authState.user;

    if (userProfile != null) {
      if (userProfile.role == UserRole.hospitalStaff) {
        setState(() {
          _hospitalNameController.text =
              userProfile.profileData.hospitalName ?? userProfile.username;
        });
      }

      setState(() {
        _contactPhoneController.text = userProfile.phoneNumber ?? '';
        if (userProfile.profileData.bloodType != null) {
          _selectedBloodType = userProfile.profileData.bloodType;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitsNeededController.dispose();
    _patientInfoController.dispose();
    _hospitalNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        logger.w("Konum servisleri kapalı.");
        _showSnackBar(
          "Konum servisleri kapatılmış. Ayarlardan açmanız gerekiyor.",
        );
        return;
      }

      if (await Geolocator.checkPermission() == LocationPermission.denied ||
          await Geolocator.checkPermission() ==
              LocationPermission.deniedForever) {
        logger.w("Konum izni yok.");
        _showSnackBar("Konum izni verilmemiş. Lütfen izin verin.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (mounted) {
        setState(() {
          _selectedPosition = position;
        });

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            setState(() {
              _addressText =
                  "${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, "
                          "${place.subLocality ?? ''} ${place.locality ?? ''}, "
                          "${place.administrativeArea ?? ''}"
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim();
            });
          }
        } catch (e) {
          logger.e("Adres çevirme hatası: $e");
        }
      }
    } catch (e) {
      logger.e("Mevcut konum alınamadı: $e");
      if (mounted) {
        _showSnackBar("Konum bilgisi alınamadı.");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickLocationFromMap() async {
    try {
      logger.d("CreateBloodRequestScreen: Harita ekranına geçiliyor");

      final result = await Navigator.of(context).push<Position>(
        MaterialPageRoute(
          builder:
              (context) => MapScreen(
                isLocationSelectionMode: true,
                initialPosition: _selectedPosition,
              ),
        ),
      );

      if (result != null) {
        logger.i(
          "CreateBloodRequestScreen: Haritadan konum seçildi: ${result.latitude}, ${result.longitude}",
        );
        setState(() {
          _selectedPosition = result;
          _useCurrentLocation = false;
        });

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            result.latitude,
            result.longitude,
          );

          if (placemarks.isNotEmpty && mounted) {
            Placemark place = placemarks[0];
            setState(() {
              _addressText =
                  "${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, "
                          "${place.subLocality ?? ''} ${place.locality ?? ''}, "
                          "${place.administrativeArea ?? ''}"
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim();
            });
          }
        } catch (e) {
          logger.e("Adres çevirme hatası: $e");
        }
      } else {
        logger.d(
          "CreateBloodRequestScreen: Haritadan konum seçilmedi (iptal edildi)",
        );
      }
    } catch (e) {
      logger.e("Konum seçme hatası:", error: e);
      _showSnackBar("Konum seçme işlemi sırasında bir hata oluştu.");
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPosition == null) {
      if (_useCurrentLocation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Mevcut konum bilgisi alınamadı veya bekleniyor. Lütfen tekrar deneyin veya haritadan seçin.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen haritadan bir konum seçin.")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final authState = ref.read(authStateNotifierProvider);
    final creatorId = authState.user?.id;
    final userProfile = authState.user;

    if (creatorId == null || userProfile == null) {
      logger.e("Talep oluşturulurken kullanıcı bilgisi bulunamadı!");
      if (mounted) {
        _showSnackBar(
          'Kullanıcı bilgileri alınamadı. Tekrar giriş yapmayı deneyin.',
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    final GeoPoint location = GeoPoint(
      _selectedPosition!.latitude,
      _selectedPosition!.longitude,
    );
    final units = int.tryParse(_unitsNeededController.text) ?? 1;
    final isHospital = userProfile.role == UserRole.hospitalStaff;

    try {
      final bloodRequestRepository = ref.read(bloodRequestRepositoryProvider);

      // Yeni BloodRequest objesi oluştur
      final String? contactPhoneNumber =
          _contactPhoneController.text.trim().isNotEmpty
              ? _contactPhoneController.text.trim()
              : null;

      final bloodRequest = BloodRequest(
        id: '', // ID Firestore tarafından oluşturulacak
        creatorId: creatorId,
        creatorName: userProfile.username,
        creatorRole: userProfile.role.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        bloodType: _selectedBloodType!,
        unitsNeeded: units,
        urgencyLevel: _selectedUrgency,
        location: location,
        status: 'active',
        hospitalName: _hospitalNameController.text.trim(),
        patientInfo:
            !isHospital && _patientInfoController.text.trim().isNotEmpty
                ? _patientInfoController.text.trim()
                : '',
        contactPhone: contactPhoneNumber,
      );

      // Obje üzerinden repository metodunu çağır
      final newRequestId = await bloodRequestRepository.createBloodRequest(
        bloodRequest,
      );

      logger.i("Kan talebi başarıyla oluşturuldu. ID: $newRequestId");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kan talebiniz başarıyla oluşturuldu.'),
            duration: Duration(seconds: 2),
          ),
        );

        // Önce paylaşım dialog'unu göster, navigationı daha sonra yap
        _showShareDialog(newRequestId, bloodRequest);

        // Dashboard'a yönlendirme, dialog içinde yapılacak
        // context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      logger.e("Talep oluşturma hatası:", error: e);
      if (mounted) {
        _showSnackBar(
          'Talep oluşturulurken bir hata oluştu: ${e.toString().replaceFirst("Exception: ", "")}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Kan talebini sosyal medyada paylaşır
  void _shareBloodRequest(String requestId, BloodRequest request) {
    try {
      // Paylaşım metni oluştur
      final String shareText = """
🔴 ACİL KAN İHTİYACI 🔴

${request.title}
Kan Grubu: ${request.bloodType}
Aciliyet: ${_getUrgencyLabel(request.urgencyLevel)}
Hastane: ${request.hospitalName}
Miktar: ${request.unitsNeeded} ünite

${request.description}

Lütfen yardım edin ve bu mesajı paylaşın!
Kan Bul uygulamasını indirin ve yakındaki kan taleplerine ulaşın:
https://play.google.com/store/apps/details?id=com.kanbul.app

#KanBul #AcilKan #${request.bloodType.replaceAll('+', 'Pozitif').replaceAll('-', 'Negatif')}
""";

      // Paylaşım işlemini başlat
      Share.share(
        shareText,
        subject: 'Acil Kan İhtiyacı: ${request.bloodType} - ${request.title}',
      );

      logger.i("Kan talebi paylaşıldı. ID: $requestId");
    } catch (e) {
      logger.e("Paylaşım sırasında hata oluştu:", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım sırasında bir hata oluştu: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitRequest();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final userRole = authState.user?.role;
    final bool isHospital = userRole == UserRole.hospitalStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kan Talebi Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Yardım',
            onPressed: () => _showHelpDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Talebi Kaydet',
            onPressed: _isLoading ? null : _submitRequest,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _previousStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(
                      _currentStep == 2 ? 'Talebi Oluştur' : 'Devam Et',
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Geri'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Temel Bilgiler'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Talep Başlığı *',
                      hintText: 'Örn: Acil Ameliyat İçin Kan',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Başlık gerekli'
                                : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'İstenen Kan Grubu *',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildBloodTypeSelector(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitsNeededController,
                    decoration: const InputDecoration(
                      labelText: 'İhtiyaç Duyulan Ünite *',
                      prefixIcon: Icon(Icons.local_hospital),
                      suffixText: 'ünite',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ünite sayısı gerekli';
                      }
                      final units = int.tryParse(value);
                      if (units == null || units <= 0) {
                        return 'Geçerli bir sayı girin';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aciliyet Seviyesi *',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildUrgencySelector(),
                ],
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Detaylı Bilgiler'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama *',
                      hintText: 'Durumu ve ihtiyacı detaylandırın...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator:
                        (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Açıklama gerekli'
                                : null,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 24),
                  if (isHospital) ...[
                    TextFormField(
                      controller: _hospitalNameController,
                      decoration: const InputDecoration(
                        labelText: 'Hastane Adı *',
                        hintText: 'Hastane/Kurum adını girin',
                        prefixIcon: Icon(Icons.local_hospital_outlined),
                      ),
                      readOnly: false,
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Hastane adı gerekli'
                                  : null,
                      textInputAction: TextInputAction.next,
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _hospitalNameController,
                      decoration: const InputDecoration(
                        labelText: 'Hastane Adı *',
                        hintText: 'İşlem yapılacak hastane/kurum adını girin',
                        prefixIcon: Icon(Icons.local_hospital_outlined),
                      ),
                      validator:
                          (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Hastane adı gerekli'
                                  : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _patientInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Hasta Adı Soyadı / Yakınlık Derecesi',
                        hintText: 'Gizliliğe dikkat edin',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'İletişim Telefonu *',
                      prefixIcon: Icon(Icons.phone),
                      hintText: '5XX XXX XXXX',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'İletişim telefonu gerekli';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Konum Bilgisi'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Talep için konum bilgisi',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            title: const Text("Mevcut Konumumu Kullan"),
                            value: _useCurrentLocation,
                            onChanged: (value) {
                              setState(() {
                                _useCurrentLocation = value;
                                if (_useCurrentLocation) {
                                  _getCurrentLocation();
                                } else {
                                  _selectedPosition = null;
                                }
                              });
                            },
                            secondary: const Icon(Icons.my_location),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          if (_useCurrentLocation) ...[
                            if (_selectedPosition != null) ...[
                              ListTile(
                                leading: const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                                title: const Text('Mevcut Konum'),
                                subtitle: Text(
                                  _addressText ??
                                      "Koordinatlar: ${_selectedPosition!.latitude.toStringAsFixed(4)}, ${_selectedPosition!.longitude.toStringAsFixed(4)}",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _getCurrentLocation,
                                  tooltip: 'Konumu Yenile',
                                ),
                              ),
                            ] else ...[
                              const Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 8),
                                    Text("Konum alınıyor..."),
                                  ],
                                ),
                              ),
                            ],
                          ] else ...[
                            Center(
                              child: Column(
                                children: [
                                  const Text('Manuel konum seçmek için:'),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _pickLocationFromMap,
                                    icon: const Icon(Icons.map),
                                    label: const Text("Haritadan Seç"),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_selectedPosition == null && !_useCurrentLocation) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Not: Talep oluşturmak için konum bilgisi gereklidir.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _bloodTypes.length,
      itemBuilder: (context, index) {
        final bloodType = _bloodTypes[index];
        final isSelected = _selectedBloodType == bloodType;

        return InkWell(
          onTap: () {
            setState(() => _selectedBloodType = bloodType);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                bloodType,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.red : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.red,
            inactiveTrackColor: Colors.red.shade100,
            trackShape: const RoundedRectSliderTrackShape(),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            thumbColor: Colors.redAccent,
            overlayColor: Colors.red.withAlpha(32),
            valueIndicatorColor: Colors.red,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: _selectedUrgency.toDouble(),
            min: 1,
            max: 3,
            divisions: 2,
            label: _getUrgencyLabel(_selectedUrgency),
            onChanged: (value) {
              setState(() {
                _selectedUrgency = value.round();
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Düşük'),
            Text(
              _getUrgencyLabel(_selectedUrgency),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getUrgencyColor(_selectedUrgency),
              ),
            ),
            const Text('Acil'),
          ],
        ),
      ],
    );
  }

  String _getUrgencyLabel(int urgency) {
    switch (urgency) {
      case 1:
        return 'Düşük Öncelik';
      case 2:
        return 'Orta Öncelik';
      case 3:
        return 'Yüksek Öncelik / Acil';
      default:
        return 'Belirtilmemiş';
    }
  }

  Color _getUrgencyColor(int urgency) {
    switch (urgency) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Talep Oluşturma Yardımı'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1. Temel Bilgiler:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Talep başlığı, kan grubu, ünite sayısı ve aciliyet seviyesini belirtin.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2. Detaylı Bilgiler:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Talep hakkında açıklama ve iletişim bilgilerini girin.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3. Konum Bilgisi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Mevcut konumunuzu kullanabilir veya haritadan seçebilirsiniz.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Talebiniz oluşturulduktan sonra uygun kan grubuna sahip bağışçılar bilgilendirilecektir.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Anladım'),
              ),
            ],
          ),
    );
  }

  void _showShareDialog(String requestId, BloodRequest request) {
    // Paylaşım için dialog göster
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Kan Talebi Paylaşımı'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kan talebiniz başarıyla oluşturuldu!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Talep için konum bilgisi:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _addressText ??
                        "Koordinatlar: ${_selectedPosition!.latitude.toStringAsFixed(4)}, ${_selectedPosition!.longitude.toStringAsFixed(4)}",
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kan talebini sosyal medyada paylaşarak daha fazla bağışçıya ulaşabilirsiniz:',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('later');
                },
                child: const Text('Şimdi Değil'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _shareBloodRequest(requestId, request);
                  Navigator.of(dialogContext).pop('share_and_continue');
                },
                icon: const Icon(Icons.share),
                label: const Text('Paylaş ve Devam Et'),
              ),
            ],
          ),
    ).then((result) async {
      if (!mounted) return;

      if (result == 'share_and_continue') {
        context.go(AppRoutes.dashboard);
      } else if (result == 'later') {
        context.go(AppRoutes.dashboard);
      }
    });
  }
}

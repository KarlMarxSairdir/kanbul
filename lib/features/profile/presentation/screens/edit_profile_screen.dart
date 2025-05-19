import 'package:flutter/material.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Provider yerine Riverpod
import 'package:kan_bul/core/providers/auth_state_notifier.dart'; // AuthProvider yerine AuthNotifier
// TODO: Gerekli widget importları (CustomTextField vb.)

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form Controller'ları
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  // TODO: Role göre diğer controller'lar (hastane adı, kan grubu vb.)

  @override
  void initState() {
    super.initState();
    logger.d("EditProfileScreen: initState");
    // Mevcut kullanıcı bilgilerini controller'lara yükle
    final userProfile = ref.read(authStateNotifierProvider).user;
    _nameController = TextEditingController(text: userProfile?.username ?? '');
    _phoneController = TextEditingController(
      text: userProfile?.phoneNumber ?? '',
    );
    // TODO: Diğer controller'ları yükle
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    // TODO: Diğer controller'ları dispose et
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    // TODO: AuthNotifier veya FirestoreService üzerinden güncelleme işlemini yap
    logger.i("Profil güncelleniyor...");
    await Future.delayed(Duration(seconds: 1)); // Simülasyon
    logger.i("Profil güncellendi (simülasyon).");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi.')),
      );
      setState(() => _isLoading = false);
      Navigator.of(context).pop(); // Geri dön
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcı profilini al (dinlemeye gerek yok, initState'te aldık)
    final userProfile = ref.read(authStateNotifierProvider).user;
    if (userProfile == null) {
      // Bu ekran oturum gerektirdiği için normalde buraya gelinmez
      return Scaffold(
        appBar: AppBar(title: const Text("Profili Düzenle")),
        body: const Center(child: Text("Kullanıcı bulunamadı.")),
      );
    }
    final isHospital = userProfile.role.isHospitalStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Kaydet',
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Form uzun olabilir
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profil fotoğrafı alanı
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage:
                          userProfile.photoUrl != null
                              ? NetworkImage(userProfile.photoUrl!)
                              : null,
                      child:
                          userProfile.photoUrl == null
                              ? Icon(
                                isHospital
                                    ? Icons.local_hospital
                                    : Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // TODO: Fotoğraf yükleme işlemi
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Ad Soyad boş olamaz'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Telefon numarası boş olamaz';
                  }
                  final phoneRegex = RegExp(r'^(5\d{9})$');
                  if (!phoneRegex.hasMatch(
                    value.replaceAll(RegExp(r'\s+'), ''),
                  )) {
                    return 'Geçerli bir telefon numarası girin (5xxxxxxxxx)';
                  }
                  return null;
                },
              ),

              // Role göre farklı alanları gösterelim
              if (isHospital) ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: userProfile.profileData.hospitalName,
                  decoration: const InputDecoration(
                    labelText: 'Hastane Adı',
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Hastane adı boş olamaz'
                              : null,
                ),
              ] else ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: userProfile.profileData.bloodType,
                  decoration: const InputDecoration(
                    labelText: 'Kan Grubu',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items:
                      ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    // Kan grubu değişim işlemi
                  },
                ),
              ],

              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon:
                    _isLoading
                        ? const SizedBox(width: 0)
                        : const Icon(Icons.save),
                label:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Değişiklikleri Kaydet',
                          style: TextStyle(fontSize: 16),
                        ),
                onPressed: _isLoading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

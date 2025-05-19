import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kan_bul/features/auth/providers/register_notifier.dart';
import 'package:kan_bul/widgets/custom_text_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kan_bul/core/enums/user_role.dart';
import 'package:kan_bul/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/models/donation_center_model.dart';
import 'package:kan_bul/data/repositories/donation_center_repository.dart';
import 'package:kan_bul/core/utils/logger.dart' as app_logger;
import 'package:cloud_firestore/cloud_firestore.dart'; // GeoPoint için eklendi

enum UserType { individual, institution }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    6,
    (_) => GlobalKey<FormState>(),
  );
  late final int totalSteps = stepsTitles.length;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();

  UserType? _userType;
  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  DateTime? _lastDonationDate;
  bool _acceptedTerms = false;

  String? _selectedDonationCenterId;
  List<DonationCenterModel> _availableDonationCenters = [];
  bool _donationCentersLoading = false;

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
  final List<String> _genders = const ['Kadın', 'Erkek', 'Diğer'];

  final List<String> stepsTitles = const [
    'Kullanıcı Tipi',
    'Giriş Bilgileri',
    'Profil Bilgileri',
    'Ek Bilgiler',
    'Şifre Belirle',
    'Onay',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _hospitalNameController.dispose();
    super.dispose();
  }

  Future<void> _loadDonationCenters(WidgetRef ref) async {
    if (_userType == UserType.institution &&
        _availableDonationCenters.isEmpty) {
      setState(() {
        _donationCentersLoading = true;
      });
      try {
        final centers = await ref.read(firestoreDonationCentersProvider.future);
        setState(() {
          _availableDonationCenters = centers;
          _donationCentersLoading = false;
        });
        if (centers.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Kayıtlı bağış merkezi bulunamadı."),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _donationCentersLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bağış merkezleri yüklenirken hata: $e")),
          );
        }
        app_logger.logger.e(
          "Error loading donation centers for registration",
          error: e,
        );
      }
    }
  }

  Future<void> _register(WidgetRef ref) async {
    if (!_acceptedTerms) {
      _showValidationError(totalSteps - 1); // Son adım (Onay) için hata göster
      return;
    }

    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    try {
      final bool isIndividual = _userType == UserType.individual;
      String? finalHospitalName;

      if (!isIndividual) {
        if (_selectedDonationCenterId != null &&
            _availableDonationCenters.any(
              (c) => c.id == _selectedDonationCenterId,
            )) {
          final selectedCenter = _availableDonationCenters.firstWhere(
            (c) => c.id == _selectedDonationCenterId,
          );
          finalHospitalName = selectedCenter.name;
        } else {
          finalHospitalName =
              _hospitalNameController.text.trim().isNotEmpty
                  ? _hospitalNameController.text.trim()
                  : null;
          if (finalHospitalName == null) {
            app_logger.logger.w(
              "Kurumsal kullanıcı için hastane adı belirlenemedi ve merkez seçimi de yok.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Lütfen bağlı olduğunuz kan merkezini seçin veya hastane adını girin.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }

      await registerNotifier.run(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: isIndividual ? UserRole.individual : UserRole.hospitalStaff,
        gender: isIndividual ? _selectedGender : null,
        birthDate: isIndividual ? _selectedBirthDate : null,
        bloodType: isIndividual ? _selectedBloodType : null,
        hospitalName: finalHospitalName,
        lastDonationDate: isIndividual ? _lastDonationDate : null,
        associatedDonationCenterId:
            !isIndividual ? _selectedDonationCenterId : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt sırasında bir hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showValidationError(int stepIndex) {
    String message;
    if (stepIndex == 0 && _userType == null) {
      message = 'Lütfen kullanıcı tipinizi seçin.';
    } else if (stepIndex == 3 &&
        _userType == UserType.institution &&
        (_selectedDonationCenterId == null ||
            _selectedDonationCenterId!.isEmpty)) {
      message = 'Lütfen bağlı olduğunuz kan merkezini seçin.';
    } else if (stepIndex == totalSteps - 1 && !_acceptedTerms) {
      message = 'Lütfen Kullanım Koşulları ve Gizlilik Politikasını onaylayın.';
    } else if (_formKeys[stepIndex].currentState == null ||
        !_formKeys[stepIndex].currentState!.validate()) {
      message =
          'Lütfen ${stepsTitles[stepIndex]} adımındaki eksik veya hatalı bilgileri düzeltin.';
    } else {
      message =
          'Lütfen ${stepsTitles[stepIndex]} adımındaki tüm zorunlu alanları doldurun.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _onStepContinue(WidgetRef ref) {
    bool isCurrentStepFormValid =
        _formKeys[_currentStep].currentState?.validate() ?? false;

    if (_currentStep == 0 && _userType == null) {
      isCurrentStepFormValid = false;
      _showValidationError(_currentStep);
    } else if (_currentStep == 0 && _userType == UserType.institution) {
      _loadDonationCenters(ref);
    } else if (_currentStep == 3 && _userType == UserType.institution) {
      if (_selectedDonationCenterId == null ||
          _selectedDonationCenterId!.isEmpty) {
        isCurrentStepFormValid = false;
        _showValidationError(_currentStep);
      }
    } else if (_currentStep == totalSteps - 1) {
      if (!_acceptedTerms) {
        isCurrentStepFormValid = false;
        _showValidationError(_currentStep);
      }
    }

    if (isCurrentStepFormValid) {
      if (_currentStep < totalSteps - 1) {
        setState(() => _currentStep += 1);
      } else {
        _register(ref);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.example.com/kvkk');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Link açılamadı.')));
      }
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText: 'Doğum Tarihinizi Seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final registerState = ref.watch(registerNotifierProvider);
        final isLoading = registerState.isLoading;
        final steps = _getSteps(ref);

        ref.listen(authStateNotifierProvider, (previous, current) {
          if (current.errorMessage != null &&
              current.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(current.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (current.user != null && !current.user!.emailVerified) {
            context.go(AppRoutes.emailVerification);
          } else if (current.user != null && current.user!.emailVerified) {
            context.go(AppRoutes.authWrapper);
          }
        });

        return Scaffold(
          appBar: AppBar(title: const Text('Kayıt Ol'), elevation: 0),
          body: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: isLoading ? null : () => _onStepContinue(ref),
            onStepCancel: isLoading ? null : _onStepCancel,
            steps: steps,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              final bool isLastStep = _currentStep == totalSteps - 1;
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child:
                            isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(isLastStep ? 'Hesap Oluştur' : 'Devam'),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Geri'),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Step> _getSteps(WidgetRef ref) {
    return [
      Step(
        title: Text(stepsTitles[0]),
        content: Form(
          key: _formKeys[0],
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lütfen kullanıcı tipinizi seçin:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              RadioListTile<UserType>(
                title: const Text('Bireysel Kullanıcı'),
                subtitle: const Text('Kan bağışçısı ve/veya hasta yakını'),
                value: UserType.individual,
                groupValue: _userType,
                onChanged:
                    (UserType? value) => setState(() {
                      _userType = value;
                      _formKeys[2].currentState?.reset();
                      _formKeys[3].currentState?.reset();
                      _selectedGender = null;
                      _selectedBirthDate = null;
                      _selectedBloodType = null;
                      _hospitalNameController.clear();
                    }),
              ),
              RadioListTile<UserType>(
                title: const Text('Kurumsal Kullanıcı'),
                subtitle: const Text('Hastane personeli'),
                value: UserType.institution,
                groupValue: _userType,
                onChanged:
                    (UserType? value) => setState(() {
                      _userType = value;
                      _formKeys[2].currentState?.reset();
                      _formKeys[3].currentState?.reset();
                      _selectedGender = null;
                      _selectedBirthDate = null;
                      _selectedBloodType = null;
                      _hospitalNameController.clear();
                    }),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(stepsTitles[1]),
        content: Form(
          key: _formKeys[1],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: CustomTextField(
            controller: _emailController,
            hintText: 'E-posta',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lütfen e-posta adresinizi girin';
              }
              final emailRegex = RegExp(
                r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
              );
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(stepsTitles[2]),
        content: Form(
          key: _formKeys[2],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Ad Soyad',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen adınızı ve soyadınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _phoneController,
                hintText: 'Telefon Numarası (5xxxxxxxxx)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen telefon numaranızı girin';
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
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Cinsiyet *',
                  prefixIcon: const Icon(Icons.wc_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedGender,
                items:
                    _genders
                        .map(
                          (String g) =>
                              DropdownMenuItem(value: g, child: Text(g)),
                        )
                        .toList(),
                onChanged: (String? v) => setState(() => _selectedGender = v),
                validator:
                    (v) => v == null ? 'Lütfen cinsiyetinizi seçin' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text:
                      _selectedBirthDate == null
                          ? ''
                          : DateFormat(
                            'dd.MM.yyyy',
                          ).format(_selectedBirthDate!),
                ),
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi *',
                  hintText: 'Seçmek için dokunun',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () => _selectBirthDate(context),
                validator:
                    (v) =>
                        _selectedBirthDate == null
                            ? 'Lütfen doğum tarihinizi seçin'
                            : null,
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(stepsTitles[3]),
        content: Form(
          key: _formKeys[3],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userType == UserType.individual) ...[
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Kan Grubu *',
                    prefixIcon: const Icon(Icons.bloodtype_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedBloodType,
                  hint: const Text('Kan grubunuzu seçin'),
                  items:
                      _bloodTypes
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Lütfen kan grubunuzu seçin' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text:
                        _lastDonationDate == null
                            ? ''
                            : DateFormat(
                              'dd.MM.yyyy',
                            ).format(_lastDonationDate!),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Son Kan Verme Tarihi (Opsiyonel)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _lastDonationDate = null;
                        });
                      },
                    ),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _lastDonationDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != _lastDonationDate) {
                      setState(() {
                        _lastDonationDate = picked;
                      });
                    }
                  },
                ),
              ] else if (_userType == UserType.institution) ...[
                if (_donationCentersLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_availableDonationCenters.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Kayıtlı bağış merkezi bulunamadı. Lütfen daha sonra tekrar deneyin veya bir yönetici ile iletişime geçin.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Bağlı Olduğunuz Kan Merkezi *',
                      prefixIcon: const Icon(Icons.local_hospital_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedDonationCenterId,
                    hint: const Text('Merkez Seçin'),
                    isExpanded: true,
                    items:
                        _availableDonationCenters.map((center) {
                          return DropdownMenuItem<String>(
                            value: center.id,
                            child: Text(
                              center.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDonationCenterId = newValue;
                        final selectedCenter = _availableDonationCenters
                            .firstWhere(
                              (c) => c.id == newValue,
                              orElse:
                                  () => DonationCenterModel(
                                    id: '',
                                    name: '',
                                    location: const GeoPoint(0, 0),
                                  ),
                            );
                        _hospitalNameController.text = selectedCenter.name;
                      });
                    },
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Lütfen bağlı olduğunuz kan merkezini seçin'
                                : null,
                  ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _hospitalNameController,
                  hintText: 'Hastane/Merkez Adı (Otomatik Gelebilir)',
                  prefixIcon: Icons.local_hospital_outlined,
                  readOnly: _selectedDonationCenterId != null,
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Lütfen hastane adını girin veya listeden seçin'
                              : null,
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Lütfen 1. adımda kullanıcı tipinizi seçin.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(stepsTitles[4]),
        content: Form(
          key: _formKeys[4],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              CustomTextField(
                controller: _passwordController,
                hintText: 'Şifre (en az 6 karakter)',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Şifreyi Doğrula',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi tekrar girin';
                  }
                  if (value != _passwordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(stepsTitles[5]),
        content: Form(
          key: _formKeys[5],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged:
                        (v) => setState(() => _acceptedTerms = v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.4),
                        children: [
                          const TextSpan(text: 'Okudum, anladım ve '),
                          TextSpan(
                            text: 'Kullanım Koşulları ile Gizlilik Politikası',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()..onTap = _launchURL,
                          ),
                          const TextSpan(text: '\'nı onaylıyorum.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 5,
        state: _currentStep == 5 ? StepState.indexed : StepState.disabled,
      ),
    ];
  }
}

lib/
├── main.dart
├── app.dart
├── config/
│   └── firebase_options.dart              # Firebase ayarları (FlutterFire CLI üretimi)
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                # Renk paleti
│   │   ├── app_text_styles.dart           # Yazı tipleri/stiller
│   │   └── app_strings.dart               # Sabit string'ler
│   ├── enums/
│   │   ├── user_role.dart                 # UserRole {donor, hospital, relative}
│   │   └── blood_type.dart                # A+, A-, B+ vb.
│   ├── theme/
│   │   └── app_theme.dart                 # Işık/Karanlık temalar
│   ├── services/
│   │   ├── auth_service.dart              # Firebase Auth işlemleri
│   │   ├── location_service.dart          # Lokasyon erişimi ve izin yönetimi
│   │   ├── notification_service.dart      # FCM push bildirimi
│   │   └── firestore_service.dart         # Firestore CRUD işlemleri
│   └── utils/
│       ├── validators.dart                # Form doğrulama
│       └── date_utils.dart                # Tarih formatlama ve karşılaştırmalar
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── blood_request_model.dart
│   │   └── donation_model.dart
│   ├── datasources/
│   │   └── firebase_datasource.dart       # Firestore veri çekme/gönderme
│   └── repositories/
│       ├── auth_repository.dart
│       ├── blood_request_repository.dart
│       └── user_repository.dart
├── features/
│   ├── auth/
│   │   ├── logic/
│   │   │   └── auth_provider.dart         # Sign in / register işlemleri
│   │   ├── presentation/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── verify_email_screen.dart
│   │   └── auth_wrapper.dart              # Kullanıcıya göre yönlendirme
│   ├── dashboard/
│   │   └── presentation/
│   │       └── dashboard_screen.dart
│   ├── map/
│   │   ├── logic/
│   │   │   └── map_provider.dart
│   │   └── presentation/
│   │       └── map_screen.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── profile_screen.dart
│   ├── notifications/
│   │   └── presentation/
│   │       └── notifications_screen.dart
│   ├── blood_request/
│   │   ├── hospital_panel/
│   │   │   └── hospital_request_screen.dart
│   │   └── patient_request/
│   │       └── patient_request_screen.dart
├── routes/
│   └── app_routes.dart                    # Tüm route tanımları ve yönlendirme
├── widgets/
│   ├── custom_text_field.dart             # Giriş alanı bileşeni
│   ├── custom_button.dart                 # Tekrarlanabilir buton yapısı
│   └── role_selector.dart                 # Bağışçı/Hastane/Hasta Yakını seçimi
├── l10n/
│   └── app_en.arb                         # Çok dil desteği başlangıcı

🚀 KanBul – Faz 1: Proje Kurulumu ve Klasör Yapısı
🎯 Hedefler
Uygulama için temiz, modüler ve sürdürülebilir bir proje yapısı oluşturmak

Flutter çatısı altında hem kullanıcı hem hastane panellerine uygun olarak organize edilmiş bir klasör sistemi kurmak

Geliştirme sürecinin ilerleyen fazlarında okunabilirliği ve bakım kolaylığını artırmak

Projeyi ekipli veya bireysel şekilde yönetilebilecek yapıya kavuşturmak

📌 Adım 1.1: Flutter Projesinin Oluşturulması
Açıklama
flutter create kanbul komutu ile temel proje iskeleti oluşturulacak

lib/ klasörü yeniden yapılandırılacak

Proje, modüler mimariyi temel alacak şekilde bölünecek

Her özellik “feature-based” olarak ayrılacak (auth, map, request, profile vs.)

🛠 Kullanılan Teknolojiler
Flutter 3.x

Dart 3.x

VS Code / Android Studio

pubspec.yaml yönetimi

Platform: Android + iOS

📂 Klasör Yapısı
bash
Kopyala
Düzenle
📦 lib/
┣ 📜 main.dart
┣ 📜 app.dart
┣ 📂 config/                 # Firebase ve genel ayarlar
┃ ┗ 📜 firebase_options.dart
┣ 📂 core/
┃ ┣ 📂 constants/            # Renkler, yazı stilleri, sabit string’ler
┃ ┣ 📂 enums/                # UserRole, BloodType gibi enum’lar
┃ ┣ 📂 services/             # Auth, Firestore, Location servisleri
┃ ┣ 📂 theme/                # Uygulama teması (light/dark)
┃ ┗ 📂 utils/                # Yardımcı fonksiyonlar
┣ 📂 data/
┃ ┣ 📂 models/               # UserModel, BloodRequestModel
┃ ┣ 📂 datasources/          # Firestore bağlantı sınıfları
┃ ┗ 📂 repositories/         # API/firestore soyutlamaları
┣ 📂 features/
┃ ┣ 📂 auth/                 # Login/Register
┃ ┣ 📂 dashboard/            # Bağışçı ana panel
┃ ┣ 📂 map/                  # Harita ekranı
┃ ┣ 📂 profile/              # Profil görüntüleme
┃ ┣ 📂 blood_request/
┃ ┃ ┣ 📂 hospital_panel/     # Hastane tarafı
┃ ┃ ┗ 📂 patient_request/    # Hasta yakını tarafı
┃ ┗ 📂 notifications/        # Bildirim listesi
┣ 📂 routes/                 # Tüm sayfa yönlendirmeleri
┣ 📂 widgets/                # Ortak bileşenler (buton, input, kart vs.)
┣ 📂 l10n/                   # Çoklu dil desteği
┗ 📜 pubspec.yaml
✅ Kontrol Noktaları
 Flutter projesi başarıyla oluşturuldu

 lib/ içeriği yukarıdaki yapıya uygun olarak yeniden düzenlendi

 Gereksiz varsayılan dosyalar (counter app vs.) temizlendi

 pubspec.yaml içerisine gerekli bağımlılıklar eklendi (örneğin: firebase_core, cloud_firestore, google_maps_flutter, provider)

 Tüm klasörler boş README.md veya index.dart dosyalarıyla oluşturuldu (Git takip edebilsin diye)

📌 Onay Gereksinimleri
 Tüm klasör yapısı belgeye uygun şekilde oluşturuldu

 Kod okunabilirliği ve modülerlik değerlendirildi

 main.dart dosyası, KanBulApp() widget’ına yönlendirildi

 İlk flutter run çalıştırıldı, app crash atmadan açılıyor

💡 Ekstra Notlar
Klasör adlandırmaları lowercase + underscore formatında (blood_request)

Her feature/ içinde presentation/, logic/, widgets/ gibi alt yapılar ilerleyen adımlarda açılabilir

Ortak bileşenler widgets/ altında tutulmalı, “button.dart” tekrar etmemeli

🚀 Faz 1 Çıktıları
✅ Temiz, sürdürülebilir klasör yapısı kuruldu
✅ Flutter uygulaması açılıyor ve çalışır durumda
✅ Takım üyeleri veya bireysel geliştirme için standart zemin hazır

🔄 Sonraki Adım: Firebase Bağlantısı
Bir sonraki fazda Firebase entegrasyonu yapılacak:

firebase_core, firebase_auth, cloud_firestore

FlutterFire CLI ile proje bağlantısı

Firebase Console’da kullanıcı rollerinin tutulacağı yapı


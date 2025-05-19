# KanBul – Akıllı Kan Bağışı ve Eşleştirme Sistemi

KanBul, gönüllü kan bağışçıları ile acil kana ihtiyaç duyan hastaneleri ve hasta yakınlarını gerçek zamanlı, konum tabanlı, hızlı ve güvenli bir şekilde eşleştiren, toplumsal fayda odaklı bir mobil uygulamadır. Uygulama, kan bağışı bilincini artırmayı ve kan bulunamaması kaynaklı can kayıplarını azaltmayı hedefler.

## 🎯 Proje Amacı

- Acil kan ihtiyacına hızlı çözüm üretmek
- Gönüllü bağışçıları konum bazlı eşleştirerek zaman kaybını önlemek
- Kan bağışı bilincini artırmak ve bağışçıları teşvik etmek
- Afet dönemlerinde merkezi yardım koordinasyonunu kolaylaştırmak

## 👥 Hedef Kitle

- **Gönüllü Bağışçılar**: Düzenli veya ilk defa kan bağışı yapmak isteyen bireyler
- **Hastaneler / Kan Merkezleri**: Kan ihtiyacı olduğunda hızlıca bağışçı çağırmak isteyen kuruluşlar
- **Hasta Yakınları**: Uygulama üzerinden bağış talebi oluşturabilecek kişiler
- **Resmî Kurumlar**: Kızılay, Sağlık Bakanlığı gibi veri analizine ihtiyaç duyan kuruluşlar

## 🚀 Ana Özellikler

- **Gerçek Zamanlı Kan İsteği ve Eşleştirme**: Konum tabanlı, hızlı kan bağış çağrısı ve eşleşme
- **Harita Entegrasyonu**: Google Maps ile bağış noktalarını ve talepleri görselleştirme
- **Bildirim Sistemi**: Firebase Cloud Messaging ile anlık bildirimler
- **Kullanıcı Rolleri**: Bağışçı, hastane, hasta yakını için özelleştirilmiş paneller
- **Sohbet ve Koordinasyon**: Kan talebi ve bağışçı arasında güvenli iletişim
- **Profil ve Geçmiş**: Kullanıcı profili, bağış geçmişi, rozetler
- **Yetkilendirme**: E-posta, Google ile giriş, e-posta doğrulama, şifre sıfırlama

## 🛠️ Kullanılan Teknolojiler

- **Flutter** (Mobil uygulama)
- **Firebase**: Authentication, Firestore, Cloud Messaging, Storage
- **Google Maps API** (Harita ve konum)
- **State Management**: Riverpod
- **Navigasyon**: GoRouter
- **Diğer**: Lottie, Shimmer, Shared Preferences, Permission Handler, Logger, Freezed, Json Serializable

## 📂 Klasör Yapısı

Proje, modüler ve sürdürülebilir bir mimariye sahiptir. Temel klasör yapısı:

```
lib/
├── main.dart
├── app.dart
├── config/
│   └── firebase_options.dart
├── core/
│   ├── constants/ (renkler, yazı stilleri, stringler)
│   ├── enums/ (roller, kan grupları)
│   ├── services/ (auth, lokasyon, bildirim, firestore)
│   ├── theme/ (uygulama teması)
│   └── utils/ (yardımcı fonksiyonlar)
├── data/
│   ├── models/ (veri modelleri)
│   ├── datasources/ (veri kaynakları)
│   └── repositories/ (veri soyutlamaları)
├── features/
│   ├── auth/ (kimlik doğrulama)
│   ├── dashboard/ (ana panel)
│   ├── map/ (harita)
│   ├── profile/ (profil)
│   ├── blood_request/ (kan talebi)
│   ├── notifications/ (bildirimler)
│   ├── chat/ (sohbet)
│   └── ...
├── routes/ (sayfa yönlendirme)
├── widgets/ (ortak bileşenler)
├── l10n/ (çoklu dil desteği)
```

Daha fazla detay için: [`docs/architecture.md`](docs/architecture.md) ve [`docs/faz1.md`](docs/faz1.md)

## 🔑 Kurulum ve Çalıştırma

1. **Projeyi Klonlayın:**
   ```bash
   git clone <proje-linki>
   cd kan_bul
   ```
2. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Firebase Kurulumu:**
   - `lib/config/firebase_options.dart` dosyasının projenize özel Firebase yapılandırmasını içerdiğinden emin olun.
   - Yoksa, FlutterFire CLI ile oluşturun:
     ```bash
     flutterfire configure
     ```
   - Detaylı bilgi için [`docs/faz2.md`](docs/faz2.md) dokümanına bakın.
4. **Uygulamayı Çalıştırın:**
   ```bash
   flutter run
   ```

## 📄 Dokümantasyon

- [PRD (Product Requirements Document)](docs/PRD.md)
- [MVP (Minimum Viable Product)](docs/MVP.md)
- [Proje Fazları ve Teknik Detaylar](docs/)
- [Mimari Şema](docs/architecture.md)

## ✨ Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen katkıdan önce varsa `CONTRIBUTING.md` dosyasını okuyun. Sorularınız ve önerileriniz için issue açabilirsiniz.

---

Flutter ile geliştirmeye yeni başlıyorsanız:

- [Flutter Başlangıç Kılavuzu](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Dokümantasyonu](https://docs.flutter.dev/)

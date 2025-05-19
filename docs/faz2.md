Harika! Aşağıda **KanBul** projesi için “**Faz 2 – Firebase Entegrasyonu**” adımının tüm detaylarıyla profesyonel bir teknik dokümantasyon formatında hazırlanmış hali yer alıyor. Bu belge; **Firebase’in tüm temel servislerinin entegrasyonunu**, yapılandırma ayarlarını ve uygulamaya entegrasyon sürecini eksiksiz şekilde kapsar.

---

# 🔥 **KanBul – Faz 2: Firebase Entegrasyonu**

---

## 🎯 Hedefler

- Uygulamanın **kimlik doğrulama**, **veri yönetimi** ve **bildirim** altyapısını kurmak
- Firebase’in Flutter ile entegre edilmesini sağlamak
- Giriş/kayıt işlemleri, veri okuma/yazma ve opsiyonel olarak bildirim göndermeyi mümkün kılmak
- Proje genelinde kullanılmak üzere **firebase servisleri için reusable (tekrar kullanılabilir) servis sınıfları** oluşturmak

---

## 📌 Adım 2.1: Firebase Projesinin Oluşturulması

### Açıklama

- [https://console.firebase.google.com](https://console.firebase.google.com) üzerinden yeni bir proje oluşturulacak
- Proje adı: **kanbul** (isteğe bağlı olarak özgün isim de kullanılabilir)
- Analytics **kapalı bırakılabilir** (sunum/demoda gerekli değil)

### Yapılacaklar

- Android ve iOS platformları eklenecek
- Android için `android/app/google-services.json` dosyası indirilecek
- iOS için `ios/Runner/GoogleService-Info.plist` yüklenecek
- Flutter projesi ile eşleştirme FlutterFire CLI ile yapılacak

---

### 🛠 Gerekli Araçlar

- Firebase Console
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Flutter SDK

---

## 📌 Adım 2.2: Firebase CLI Bağlantısı

### Açıklama

Firebase servisini Flutter projenize bağlamak için FlutterFire CLI kullanılacaktır.

### Komutlar

```bash
flutterfire configure
```

- Platform olarak Android ve iOS seçilecek
- CLI, `lib/config/firebase_options.dart` dosyasını oluşturacaktır

---

### 📂 Üretilen Dosya

```bash
📂 lib/config/
┗ 📜 firebase_options.dart
```

- Bu dosya `Firebase.initializeApp()` içinde kullanılacaktır

---

## 📌 Adım 2.3: Gerekli Paketlerin Kurulması

### pubspec.yaml içine eklenmesi gereken paketler:

```yaml
dependencies:
  firebase_core: ^2.25.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.9.0
  firebase_messaging: ^14.7.0      # (opsiyonel - bildirim için)
  flutter_local_notifications: ^16.3.0 # (opsiyonel - local notification)
```

```bash
flutter pub get
```

---

## 📌 Adım 2.4: Uygulama Başlatılırken Firebase’i Başlatma

### `main.dart` dosyasında:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KanBulApp());
}
```

---

## 📌 Adım 2.5: Firebase Auth Servisinin Oluşturulması

### Konum:
`lib/core/services/auth_service.dart`

### Örnek Yapı:
```dart
class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> registerWithEmail(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

---

## 📌 Adım 2.6: Firestore Yapısının Oluşturulması

### Koleksiyonlar

```bash
📂 users/
┗ 📄 userId → {
     email: string,
     role: ["donor", "relative"],
     bloodType: "0 Rh+",
     lastDonationDate: Date
   }

📂 blood_requests/
┗ 📄 requestId → {
     creatorId: string,
     type: "hospital" | "relative",
     bloodType: "A-",
     location: GeoPoint,
     status: "active" | "fulfilled"
   }

📂 donations/
┗ 📄 donationId → {
     userId: string,
     requestId: string,
     respondedAt: Timestamp
   }
```

---

## 📌 Adım 2.7: Firestore Servisi Oluşturulması

### Konum:
`lib/core/services/firestore_service.dart`

### Örnek:
```dart
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) {
    return _db.collection("users").doc(user.uid).set(user.toMap());
  }

  Future<void> createBloodRequest(Map<String, dynamic> data) {
    return _db.collection("blood_requests").add(data);
  }

  Stream<List<Map<String, dynamic>>> getActiveRequests() {
    return _db
        .collection("blood_requests")
        .where("status", isEqualTo: "active")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
```

---

## 📌 Adım 2.8: Opsiyonel – FCM ile Bildirim Ayarları

### Açıklama

Sunum etkisi için FCM bildirimleri kullanılabilir. Kullanıcıya çağrı bildirimi gönderilebilir.

- Firebase Console üzerinden test bildirimi gönderilebilir
- Kullanıcı token'ları `users` koleksiyonuna kaydedilir
- Flutter tarafında `firebase_messaging` ile dinlenir

### Not:
Android `AndroidManifest.xml` ve iOS `Info.plist` dosyalarına gerekli izinler eklenmelidir.

---

## ✅ Kontrol Noktaları

- [ ] Firebase projesi oluşturuldu ve platformlar eklendi
- [ ] `firebase_options.dart` oluşturuldu ve kullanıldı
- [ ] Firebase paketleri kuruldu ve hata alınmadı
- [ ] Auth servisi çalışıyor (kayıt, giriş, çıkış)
- [ ] Firestore'a veri yazılıp okunabiliyor
- [ ] (Opsiyonel) FCM bildirimi test edildi

---

## 📌 Onay Gereksinimleri

- [ ] `flutter run` ile uygulama açıldığında Firebase bağlantısı kurulabiliyor
- [ ] Auth işlemleri çalışıyor (yeni kullanıcı yaratma test edildi)
- [ ] Firestore'a yazılan örnek veriler kontrol edildi
- [ ] Giriş yapmış kullanıcıya özel veri çekilebildi
- [ ] Firebase hataları uygun şekilde loglanıyor

---

## 🚀 Faz 2 Çıktıları

✅ Firebase tüm temel servisleriyle entegre edildi
✅ Auth sistemi çalışır durumda
✅ Firestore veritabanı üzerinden kan talebi ve kullanıcı kayıtları yapılabiliyor
✅ Bildirim altyapısı kuruldu (opsiyonel)
✅ Firebase’e dayalı modüler servisler oluşturuldu

---

## 🔄 Sonraki Adım: Giriş/Kayıt Ekranlarının Geliştirilmesi

Bir sonraki fazda kullanıcı arayüzü geliştirilecek:
- Giriş (email + şifre)
- Kayıt (kan grubu, ad soyad, rol seçimi)
- Firebase Auth ile bağlantı
- Firestore’a kullanıcı bilgisi kaydı

---

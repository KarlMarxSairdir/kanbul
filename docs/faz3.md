🚀 KanBul – Faz 3: Giriş/Kayıt Ekranları
============================

🎯 **Hedefler**
--------------
- Kullanıcı giriş (login) ve kayıt (register) ekranlarının tasarlanması ve kodlanması
- Kullanıcı kimlik doğrulama işlevlerinin Firebase Authentication ile entegrasyonu
- Doğrulanabilir, güvenli ve kullanıcı dostu bir kayıt süreci oluşturma
- Farklı kullanıcı türleri (bağışçı, hasta yakını, hastane) için kayıt akışlarının belirlenmesi

📌 **Adım 3.1: Kimlik Doğrulama Altyapısının Kurulması**
----------------------------------------------------
**Açıklama**
- Firebase Authentication servisinin projeye entegre edilmesi
- Kimlik doğrulama yöntemlerinin belirlenmesi (e-posta/şifre, telefon, Google/Apple hesabı)
- Kullanıcı oturum durumu dinleyicisinin (auth state listener) yapılandırılması
- Auth repository sınıflarının oluşturulması

🛠 **Kullanılacak Paketler**
--------------------------
- firebase_auth: ^4.x.x
- google_sign_in: ^6.x.x (Opsiyonel)
- sign_in_with_apple: ^4.x.x (iOS için opsiyonel)
- provider/bloc/riverpod (Durum yönetimi için)
- form_validator: ^2.x.x (Form doğrulaması için)

📌 **Adım 3.2: Giriş (Login) Ekranının Tasarlanması**
--------------------------------------------------
**Açıklama**
- Markalı (brandlı), görsel olarak çekici giriş ekranı tasarımı
- E-posta/şifre girişi için form alanları
- Şifremi unuttum fonksiyonu
- Sosyal medya giriş butonları (opsiyonel)
- Kayıt ekranına yönlendirme bağlantısı
- Form doğrulama mantığı ve hata mesajları

**UI Bileşenleri**
- Uygulama logosu ve slogan
- Giriş formu
- E-posta alanı (validation ile)
- Şifre alanı (gizlenebilir, validation ile)
- Giriş butonu
- "Şifremi Unuttum" bağlantısı
- "Hesabın yok mu? Kayıt ol" bağlantısı
- Sosyal medya giriş seçenekleri (opsiyonel)
- Yükleniyor göstergesi

📌 **Adım 3.3: Kayıt (Register) Ekranının Tasarlanması**
----------------------------------------------------
**Açıklama**
- Çok adımlı kayıt formunun tasarlanması
- Adım 1: Temel bilgiler (e-posta, şifre)
- Adım 2: Profil bilgileri (ad, soyad, telefon)
- Adım 3: Kullanıcı rolü seçimi (bağışçı/hasta yakını/hastane)
- Adım 4: Role özel bilgiler (kan grubu, hastane adı vb.)
- E-posta doğrulama mekanizmasının entegrasyonu

**UI Bileşenleri**
- Kayıt formu (çok adımlı)
- İlerleme göstergesi
- Profil bilgileri formu
- Rol seçim ekranı
- Bağışçı profili tamamlama formu (kan grubu, yaş, kronik hastalık vb.)
- Hastane hesabı için doğrulama bilgileri
- Kayıt tamamlama butonu
- Gizlilik politikası ve kullanım şartları onay kutusu
- Giriş ekranına dönüş bağlantısı

📌 **Adım 3.4: Şifremi Unuttum İşlevinin Uygulanması**
---------------------------------------------------
**Açıklama**
- Şifre sıfırlama ekranının tasarlanması
- Firebase password reset e-posta işlevinin entegrasyonu
- Kullanıcıya geri bildirim mekanizmaları

**UI Bileşenleri**
- E-posta girişi formu
- "Sıfırlama Bağlantısı Gönder" butonu
- Geri bildirim mesajları
- Giriş ekranına dönüş bağlantısı

📌 **Adım 3.5: Firebase Authentication Entegrasyonu**
------------------------------------------------
**Açıklama**
- Auth servislerinin uygulanması:
  - createUserWithEmailAndPassword
  - signInWithEmailAndPassword
  - sendPasswordResetEmail
  - signOut
- Kullanıcı oturum durumu değişikliklerinin işlenmesi
- Güvenlik kurallarının belirlenmesi
- Hata işleme ve bildirim mekanizmaları

📝 **Kod Yapısı**
--------------
```dart
// Örnek auth_service.dart

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // E-posta ile kayıt
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // E-posta ile giriş
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Şifre sıfırlama
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Çıkış yapma
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Hata işleme
  Exception _handleAuthError(FirebaseAuthException e) {
    // Hata işleme mantığı...
  }
}
```

✅ **Kontrol Noktaları**
--------------------
- [ ] Firebase Authentication projeye başarıyla entegre edildi
- [ ] Auth service ve repository sınıfları oluşturuldu
- [ ] Giriş ekranı tasarlandı ve işlevsellik kazandırıldı
- [ ] Kayıt ekranı tasarlandı ve işlevsellik kazandırıldı
- [ ] Şifremi unuttum işlevi çalışır durumda
- [ ] Farklı kullanıcı rolleri için kayıt akışları tamamlandı
- [ ] E-posta doğrulama mekanizması uygulandı
- [ ] Tüm ekranlar responsive tasarım prensiplerine uygun
- [ ] Hata işleme ve geri bildirim mekanizmaları çalışıyor
- [ ] Kullanıcı girişi ve kayıt verileri Firestore'da saklanıyor

📌 **Onay Gereksinimleri**
----------------------
- [ ] Tüm ekranlar tasarım kılavuzuna uygun şekilde tasarlandı
- [ ] Form doğrulama mantığı tüm ekranlarda düzgün çalışıyor
- [ ] Başarılı giriş sonrası anasayfaya yönlendirme çalışıyor
- [ ] Kayıt işlemi sonrasında kullanıcı profili veritabanında oluşturuluyor
- [ ] Tüm auth işlemleri exception handling ile korunuyor

💡 **Ekstra Notlar**
----------------
- Formlar için validasyon kuralları belirlenmeli (minimum şifre uzunluğu, e-posta formatı vb.)
- Kullanıcı deneyimini iyileştirmek için loading state'leri eklenmeli
- Giriş sonrası kullanıcı rolüne göre farklı akışlar planlanmalı (Faz 4'te ele alınacak)
- Sosyal medya girişleri opsiyonel olarak değerlendirilmeli, temel flow öncelikli

🔄 **Ekran Tasarımları**
--------------------
1. **Splash Screen**
   - Logo ve slogan
   - Kısa animasyon
   - Otomatik giriş kontrolü

2. **Giriş Ekranı**
   - Uygulama renkleriyle tasarlanmış arayüz
   - Logo ve marka kimliği
   - Giriş formu
   - Alternatif giriş seçenekleri

3. **Kayıt Ekranı**
   - Stepper görünümü
   - Her adım için farklı form alanları
   - Rol seçim ekranı görsel simgelerle
   - İlerleme göstergesi

4. **Şifre Sıfırlama**
   - Minimal tasarım
   - E-posta girişi ve gönderim
   - Başarılı gönderim ekranı

🚀 **Faz 3 Çıktıları**
------------------
✅ Tam işlevsel giriş sistemi
✅ Kullanıcı kayıt formları ve akışları
✅ Firebase ile entegre edilmiş auth sistemi
✅ Kullanıcı profillerinin temel yapısı
✅ Farklı roller için başlangıç noktaları

🔄 **Sonraki Adım: Rol Seçimi ve Yönlendirme**
-----------------------------------------
Bir sonraki fazda (Faz 4), kullanıcının rolüne göre yönlendirme ve rol tabanlı ekranlar ele alınacak:
- Giriş sonrası rol belirleme
- Rol bazlı anasayfa içerikleri
- Rol izinlerinin yapılandırılması
- Rol geçişlerinin yönetimi

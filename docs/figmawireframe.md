
🎨 KanBul MVP – Wireframe Planı (v2.1) – Geliştirilmiş ve Genişletilmiş
🔹 1. Giriş / Kayıt Ekranı
Özellikler:

E-posta ile giriş & şifre sıfırlama

Yeni kullanıcı kaydı:

Ad Soyad

Doğum Yılı

Cinsiyet (Kadın/Erkek/Belirtmek istemiyorum)

Kan Grubu (A+, A-, B+... vb.)

Son Bağış Tarihi (isteğe bağlı)

Kullanıcı tipi seçimi:

👤 Bağışçı

🧑‍⚕️ Hastane/Kan Merkezi Yetkilisi

🧑‍🤝‍🧑 Hasta Yakını

KVKK & Kullanım Sözleşmesi onayı (checkbox zorunlu)

🔹 2. Ana Sayfa (Dashboard)
Ortak Bileşenler:

“Merhaba, [İsim] 👋” başlığı

Bağış uygunluk kutusu (ör. "Bugün kan verebilirsin!")

En yakın bağış noktası → mini harita + mesafe

📢 Acil çağrı kartları:

Kan Grubu / Lokasyon / Aciliyet / “Yardım Et” CTA

Son Bağış Tarihi → Uygunluk durumu (yeşil/kırmızı göstergesi)

Rol Bazlı:

Bağışçı: “Yeni bağış randevusu planla”

Hasta Yakını / Hastane: “Yeni Kan Talebi Oluştur” butonu

🔹 3. Harita Ekranı
Özellikler:

Canlı kullanıcı konumu

📌 Sabit bağış merkezleri

🚨 Acil kan talepleri pinleri (renkli aciliyet ikonları)

Pin tıklanınca açılan bilgi kartı:

Kan grubu, hastane adı, mesafe, “Navigasyon” ve “Yardım Et” butonları

Dinamik Filtreler:

Kan grubu, aciliyet, mesafe aralığı

🔹 4. Profil Ekranı
Bileşenler:

Profil fotoğrafı, ad, doğum yılı, kan grubu

Son Bağış: [Tarih] – Bir sonraki uygun bağış tarihi

Rol: ikon + metin ile gösterim

🎖️ Rozet sayacı ve detay linki

🗂️ Bağış geçmişine git

⚙️ Ayarlar (bildirim, gizlilik, çıkış)

🔹 5. Bildirimler Ekranı
Özellikler:

Gerçek zamanlı bildirim listesi (sondan başa sıralı)

Yanıtlanmış talepler: “✔️ Yanıtlandı” etiketi

Filtre: Tarih aralığı, konum, durum

Detay ekranına geçiş

🔹 6. Kan Talebi Oluşturma Ekranı
(Hastane ve Hasta Yakını için Ortak)

Form Alanları:

Kan Grubu (dropdown)

Miktar (opsiyonel)

Lokasyon (GPS seçimi / manuel adres)

Aciliyet: Normal / Acil / Çok Acil

Açıklama (serbest metin)

Anonim gönderim seçeneği (isteğe bağlı)

📌 Hasta yakını kullanıcıları için sadeleştirilmiş versiyonla başlatılabilir.

🔹 7. Rozetler ve Bağış Geçmişi
Rozetler:

“İlk Bağış”, “5+ Bağış”, “Acil Çağrı Cevapladı” vb. dijital ödüller

Kilitli / Açılmış rozet ayrımı

Sosyal medya paylaşımı opsiyonu

Bağış Geçmişi:

Liste: Tarih / Lokasyon / Durum

Takvim görünümü (geliştirme opsiyonel)

PDF sertifika (opsiyonel)

🔹 8. Ayarlar ve Gizlilik Paneli
Alt Başlıklar:

Bildirim ayarları (push, mail)

Konum paylaşımı → aktif/pasif

“Hesabımı Sil” işlemi

Parola değiştir

KVKK metinlerine erişim

🧭 Navigasyon – Alt Menü (Bottom Navigation Bar)
Sekme	İkon	İçerik
🏠 Ana Sayfa	home	Rol bazlı giriş
🗺️ Harita	map	Tüm talepler ve merkezler
🔔 Bildirimler	notifications	Yanıtlanabilir çağrılar
👤 Profil	person	Kişisel bilgiler ve ayarlar
📱 Figma Sayfa Setleri
Sayfa Grubu	İçerik
Auth Flow	Giriş, kayıt, e-posta doğrulama
Main App Flow	Dashboard, harita, profil, bildirimler
Talep Oluşturma Flow	Talep formu ve başarı ekranı
Rozet / Geçmiş	Rozet koleksiyonu, bağış geçmişi
Ayarlar / Gizlilik	Tüm kullanıcı tercihi ekranları
Boş Ekranlar	“Henüz veri yok” gibi durumlar
Başarı / Hata Ekranları	“Talep başarıyla oluşturuldu” gibi feedbackler
🎨 Stil Rehberi
Ana Renk: #D62828 → Acil çağrı, butonlar

İkincil Renkler: #F8F9FA, #343A40, #FFFFFF

Fontlar: Montserrat (başlık) + Nunito Sans (gövde)

Butonlar: Geniş, yuvarlatılmış, kontrast metin

İkonografi: Feather Icons / Material Icons uyumlu

🟢 Bu versiyon hem tasarımcının Figma’da rahatça wireframe üretmesini sağlar,
hem de geliştiricilerin (Flutter + Firebase tabanlı) tüm ekran mantığını görsel destek olmadan okuyup uygulamasını kolaylaştırır.


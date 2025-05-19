📄 Product Requirements Document (PRD) – KanBul Mobil Uygulaması
1. Proje Adı
KanBul – Akıllı Kan Bağışı ve Eşleştirme Sistemi

2. Proje Özeti
KanBul, gönüllü kan bağışçıları ile acil kana ihtiyaç duyan hastaneleri ve hasta yakınlarını gerçek zamanlı, konum tabanlı, hızlı ve güvenli bir şekilde eşleştiren mobil uygulamadır. Uygulama, sosyal fayda odaklı bir yaklaşımla toplumda kan bağışı farkındalığını artırmayı ve kan bulunamaması kaynaklı can kayıplarını azaltmayı hedefler.

3. Proje Amacı
Acil kan ihtiyacına hızlı çözüm üretmek

Gönüllü bağışçıları konum bazlı eşleştirerek zaman kaybını önlemek

Kan bağışı bilincini artırmak ve bağışçıları teşvik etmek

Afet dönemlerinde merkezi yardım koordinasyonunu kolaylaştırmak

4. Hedef Kitle
Kullanıcı Türü	Açıklama
Gönüllü Bağışçılar	Düzenli veya ilk defa kan bağışı yapmak isteyen bireyler
Hastaneler / Kan Merkezleri	Kan ihtiyacı olduğunda hızlıca bağışçı çağırmak isteyen kuruluşlar
Hasta Yakınları	Uygulama üzerinden bağış talebi oluşturabilecek kişiler
Resmî Kurumlar	Kızılay, Sağlık Bakanlığı gibi veri analizine ihtiyaç duyan kuruluşlar
5. Ana Özellikler
👤 Bağışçı Paneli
Profil oluşturma (ad, yaş, kan grubu, son bağış tarihi, konum)

Uygunluk kontrolü (en son bağış tarihi üzerinden)

Harita üzerinden bağış noktaları

Push bildirim ile acil çağrılar

Dijital rozetler, puan sistemi

🏥 Hastane / Kan Merkezi Paneli
Kan talebi oluşturma (kan grubu, miktar, konum, aciliyet)

Uygun bağışçı eşleştirme ve bildirim gönderme

Bağışçı yanıtlarını takip (“Geliyorum”, “Müsait değilim”)

Talep durumu güncelleme

🌐 Ortak Özellikler
Google Maps tabanlı harita görünümü

Yardım modu (afet durumlarında)

Sosyal medya paylaşım

Bilgilendirici içerikler: “Kan bağışı nedir?”, “Kimler bağış yapabilir?” vb.

6. Başarı Kriterleri (KPIs)
Bağış bildirimine yanıt süresi ≤ 10 dakika

3 ay sonunda 1.000+ aktif bağışçı

Her çağrıya ortalama ≥ 2 bağışçı dönüşü

Uygulama mağazasında 4.5+ puan

7. Platformlar
Mobil: Android & iOS (Flutter ile tek kod tabanı)

Web Panel: Hastaneler ve yönetici yetkililer için (isteğe bağlı)

8. Teknik Gereksinimler
Frontend (Mobil): Flutter

Backend: Node.js veya Django REST

Veritabanı: Firebase Firestore veya PostgreSQL

Auth: Firebase Authentication

Push Bildirim: Firebase Cloud Messaging

Harita & Lokasyon: Google Maps API

Bulut Dosya Depolama: Firebase Storage veya AWS S3

9. Güvenlik & KVKK Uyumu
Kullanıcı verileri şifreli olarak saklanacak

Lokasyon verisi sadece çağrı eşleştirmesi için geçici olarak kullanılacak

Kişisel veriler hiçbir zaman üçüncü kişilerle paylaşılmayacak

KVKK ve GDPR uyumluluğu esas alınacak

10. Riskler ve Önlemler
Risk	Önlem
Düşük kullanıcı katılımı	Rozet/puan sistemi ile teşvik, sosyal medya kampanyaları
Yanlış eşleştirme	Uygunluk kontrolü (kan grubu, konum, zamanlama)
Geciken bildirimler	Gerçek zamanlı sistem ile Firebase Cloud Messaging kullanımı
Güvenlik açıkları	Auth ve HTTPS ile tam güvenlik sağlama, veri şifreleme
11. Sürüm ve Geliştirme Planı
İlk sürümde yalnızca çekirdek işlevler (MVP) sunulacak:

Giriş/kayıt

Kan grubu profili

Çağrı bildirimi

Eşleştirme ve yanıt

Harita görüntüleme

Genişleme için:

Bağış geçmişi

Puanlama sistemi

Afet modu

Kurumsal entegrasyonlar

Bu belge, ürünün hedeflerine ve temel yapı taşlarına dair tüm paydaşların ortak anlayışını sağlamak için hazırlanmıştır.

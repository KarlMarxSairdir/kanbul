🚀 KanBul – Faz 9: Çağrıya Yanıt Verme
==========================

🎯 **Hedefler**
--------------
- Kullanıcıların kan taleplerine yanıt verme sürecinin tasarlanması
- Talep sahibine hızlı ve etkili bir şekilde ulaşma mekanizmasının geliştirilmesi
- Randevu oluşturma ve onaylama süreçlerinin entegrasyonu
- Bağış sürecinin takibi ve doğrulama araçlarının eklenmesi
- Talep yanıtlarının yönetimi ve geri bildirim sisteminin oluşturulması

📌 **Adım 9.1: Talep Yanıt Verme Süreci**
-------------------------------------
**Açıklama**
- Kullanıcıların kan taleplerine yanıt verebilmesi için bir arayüz tasarlanması
- Talep detaylarının görüntülenmesi ve uygunluk kontrolü
- Yanıt verme butonları ve onay mekanizması
- Yanıt sonrası randevu oluşturma ve talep sahibine bildirim gönderme

**UI Bileşenleri**
- Talep detay ekranı
- Yanıt verme butonu
- Randevu oluşturma formu
- Talep sahibine mesaj gönderme seçeneği
- Yanıt onay ekranı

📝 **Örnek Talep Yanıt Verme Akışı**
-----------------------------
```dart
class RequestResponseScreen extends StatefulWidget {
  final BloodRequest request;

  const RequestResponseScreen({required this.request});

  @override
  _RequestResponseScreenState createState() => _RequestResponseScreenState();
}

class _RequestResponseScreenState extends State<RequestResponseScreen> {
  bool _isResponding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talep Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.request.bloodType} Kan İhtiyacı',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Hastane: ${widget.request.hospitalName}'),
            Text('Aciliyet: ${_getUrgencyText(widget.request.urgencyLevel)}'),
            Text('Gerekli Ünite: ${widget.request.unitsNeeded}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isResponding ? null : _respondToRequest,
              child: _isResponding
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Yanıt Ver'),
            ),
          ],
        ),
      ),
    );
  }

  String _getUrgencyText(UrgencyLevel urgencyLevel) {
    switch (urgencyLevel) {
      case UrgencyLevel.veryUrgent:
        return 'Çok Acil';
      case UrgencyLevel.urgent:
        return 'Acil';
      case UrgencyLevel.normal:
      default:
        return 'Normal';
    }
  }

  Future<void> _respondToRequest() async {
    setState(() => _isResponding = true);

    try {
      // Yanıt verme işlemi
      await BloodRequestService().respondToRequest(widget.request.id);

      // Başarı mesajı ve yönlendirme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talebe başarıyla yanıt verildi.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    } finally {
      setState(() => _isResponding = false);
    }
  }
}
```

📌 **Adım 9.2: Randevu Oluşturma ve Onaylama**
------------------------------------------
**Açıklama**
- Yanıt veren bağışçının talep sahibiyle randevu oluşturabilmesi
- Randevu tarih ve saat seçimi
- Talep sahibine bildirim gönderme
- Randevu onaylama ve takvim entegrasyonu

**UI Bileşenleri**
- Randevu oluşturma formu
- Tarih ve saat seçici
- Onay butonu
- Randevu detay ekranı

📝 **Örnek Randevu Oluşturma Kodu**
-----------------------------
```dart
class AppointmentForm extends StatefulWidget {
  final BloodRequest request;

  const AppointmentForm({required this.request});

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Randevu Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarih Seçin:'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectDate,
              child: Text(_selectedDate == null
                  ? 'Tarih Seç'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ),
            SizedBox(height: 16),
            Text('Saat Seçin:'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _selectTime,
              child: Text(_selectedTime == null
                  ? 'Saat Seç'
                  : '${_selectedTime!.hour}:${_selectedTime!.minute}'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAppointment,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Randevuyu Onayla'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tarih ve saat seçin.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final DateTime appointmentDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Randevu oluşturma işlemi
      await BloodRequestService().createAppointment(
        requestId: widget.request.id,
        appointmentDate: appointmentDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Randevu başarıyla oluşturuldu.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
```

📌 **Adım 9.3: Yanıt Yönetimi ve Geri Bildirim**
-------------------------------------------
**Açıklama**
- Talep yanıtlarının durumlarının yönetimi
- Bağışçı ve talep sahibi arasında iletişim araçları
- Bağış sürecinin tamamlanması ve doğrulama
- Geri bildirim ve değerlendirme sistemi

**UI Bileşenleri**
- Yanıt listesi ve durum göstergeleri
- Bağışçı profili görüntüleme
- Mesajlaşma arayüzü
- Bağış tamamlandı onayı
- Geri bildirim formu

📝 **Örnek Yanıt Yönetimi Kodu**
--------------------------
```dart
class ResponseManagementScreen extends StatelessWidget {
  final String requestId;

  const ResponseManagementScreen({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yanıt Yönetimi'),
      ),
      body: FutureBuilder<List<DonationResponse>>(
        future: BloodRequestService().getResponsesForRequest(requestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Henüz yanıt yok.'));
          }

          final responses = snapshot.data!;

          return ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final response = responses[index];
              return ListTile(
                title: Text('Bağışçı: ${response.donorName}'),
                subtitle: Text('Durum: ${response.status}'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Yanıt detaylarına git
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ResponseDetailScreen(response: response),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

✅ **Kontrol Noktaları**
--------------------
- [ ] Talep yanıt verme arayüzü tasarlandı ve işlevsellik kazandırıldı
- [ ] Randevu oluşturma ve onaylama süreçleri tamamlandı
- [ ] Yanıt yönetimi ve durum takibi araçları eklendi
- [ ] Bağış süreci doğrulama ve geri bildirim sistemi entegre edildi
- [ ] Kullanıcı deneyimi testleri yapıldı ve iyileştirmeler tamamlandı

📌 **Onay Gereksinimleri**
----------------------
- [ ] Talep yanıt verme süreci hızlı ve kullanıcı dostu
- [ ] Randevu oluşturma ve onaylama işlemleri sorunsuz
- [ ] Yanıt yönetimi araçları etkili ve anlaşılır
- [ ] Geri bildirim sistemi kullanıcıları teşvik ediyor
- [ ] Tüm süreçler güvenli ve veri tutarlılığı sağlanıyor

💡 **Ekstra Notlar**
----------------
- Yanıt sürecinde kullanıcıya rehberlik eden açıklamalar eklenebilir
- Randevu hatırlatıcı bildirimleri entegre edilebilir
- Geri bildirimler anonim olarak toplanabilir
- Bağış süreci tamamlandığında teşekkür mesajı gönderilebilir
- Yanıt sürecinde kullanıcı gizliliği ön planda tutulmalı

🔄 **Ekran Tasarımları**
--------------------
1. **Talep Detay Ekranı**
   - Talep bilgileri
   - Yanıt verme butonu
   - Randevu oluşturma seçeneği

2. **Randevu Oluşturma Formu**
   - Tarih ve saat seçimi
   - Onay butonu

3. **Yanıt Yönetim Ekranı**
   - Yanıt listesi
   - Bağışçı profili görüntüleme
   - Yanıt detay ekranı

4. **Geri Bildirim Formu**
   - Bağış süreci değerlendirme
   - Öneri ve yorum alanı

🚀 **Faz 9 Çıktıları**
------------------
✅ Talep yanıt verme arayüzü
✅ Randevu oluşturma ve onaylama sistemi
✅ Yanıt yönetimi ve durum takibi araçları
✅ Geri bildirim ve değerlendirme sistemi

🔄 **Sonraki Adım: Profil Ekranı ve Bağış Geçmişi**
---------------------------------------------
Bir sonraki fazda (Faz 10), kullanıcıların profil ekranı ve bağış geçmişi özellikleri ele alınacak:
- Profil bilgileri düzenleme
- Bağış geçmişi görüntüleme
- Rozetler ve başarılar
- Bildirim ve gizlilik ayarları

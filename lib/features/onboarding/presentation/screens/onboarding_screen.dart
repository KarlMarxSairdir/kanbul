import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kan_bul/features/splash/presentation/screens/splash_screen.dart'; // onboardingSeenProvider için
import 'package:kan_bul/core/utils/logger.dart'; // Updated import

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding verisi (sabit olduğu için build dışında tanımlanabilir)
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'KanBul\'a Hoş Geldin!', // Başlık güncellendi
      'description':
          'Acil kan ihtiyaçlarını anında gör, hayat kurtarmaya yardımcı ol.', // Açıklama güncellendi
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Bağışçı Ol, Kahraman Ol', // Başlık güncellendi
      'description':
          'Uygun olduğunda kan bağışı yaparak puan ve rozetler kazan.', // Açıklama güncellendi
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Anında Haberdar Ol', // Başlık güncellendi
      'description':
          'Konum ve bildirim izinlerini açarak yakındaki acil çağrılardan ilk sen haberdar ol.', // Açıklama güncellendi
      'image': 'assets/images/onboarding3.png',
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Onboarding'i tamamla ve state'i güncelle
  Future<void> _completeOnboarding() async {
    try {
      // 1. Riverpod state'ini güncelle - router trigger olacak
      ref.read(onboardingSeenProvider.notifier).state = true;

      // 2. SharedPreferences'a kalıcı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingSeen', true);

      logger.d("Onboarding: State updated and persisted to SharedPreferences");

      // Yönlendirme artık GoRouter redirect tarafından yapılacak
    } catch (e) {
      // Hata yönetimi
      logger.e("Onboarding tamamlama hatası:", error: e);
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Controller'ı dispose etmeyi unutma
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // "Atla" Butonu (Opsiyonel)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding, // Onboarding'i tamamla ve geç
                child: const Text('Atla'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: _onboardingData[index]['title']!,
                    description: _onboardingData[index]['description']!,
                    imagePath: _onboardingData[index]['image']!,
                  );
                },
              ),
            ),
            // Alt Navigasyon Bölümü
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20.0,
                10.0,
                20.0,
                30.0,
              ), // Alt boşluğu artır
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nokta Göstergeleri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) =>
                          _buildDot(index, context), // Metot adını değiştirdim
                    ),
                  ),
                  // İleri / Başla Butonu
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding(); // State'i güncelle, yönlendirme router'da
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(
                            milliseconds: 400,
                          ), // Süreyi biraz artır
                          curve: Curves.easeInOut, // Curve değiştirildi
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ), // Daha yuvarlak
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 12,
                      ), // Padding ayarlandı
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1
                          ? 'Başla'
                          : 'İleri',
                      style: const TextStyle(fontSize: 16), // Yazı boyutu
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nokta göstergesi oluşturan yardımcı metot (Daha iyi okunabilirlik için _ öneki)
  Widget _buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      // Animasyonlu geçiş için
      duration: const Duration(milliseconds: 200), // Animasyon süresi
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
      ),
    );
  }
}

// Tek bir onboarding sayfasını gösteren widget
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Ekran boyutuna göre dinamik padding
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // Container ile sarmalayıp padding vermek daha esnek olabilir
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenHeight * 0.05,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Ortala
        children: [
          Flexible(
            // Görselin taşmasını engellemek için
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // Görseli sığdır
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.image_not_supported_outlined, // Daha uygun ikon
                    size: screenHeight * 0.3, // Boyutu biraz küçült
                    color: Colors.grey[400],
                  ),
            ),
          ),
          SizedBox(height: screenHeight * 0.06), // Dinamik boşluk
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ), // Biraz daha büyük başlık
          ),
          SizedBox(height: screenHeight * 0.03), // Dinamik boşluk
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: Colors.grey[700],
            ), // Satır yüksekliği ve renk
          ),
          const Spacer(), // Alttaki elemanları aşağı itmek için
        ],
      ),
    );
  }
}

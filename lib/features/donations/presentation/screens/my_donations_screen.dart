import 'package:flutter/material.dart';
import 'package:kan_bul/core/utils/logger.dart'; // Updated import
// TODO: İlgili Provider/Service importları (FirestoreService, AuthProvider vb.)

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

// Sekmeli yapı için TickerProviderStateMixin eklenebilir
class _MyDonationsScreenState extends State<MyDonationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Örnek: Bekleyen, Tamamlanan, Planlanan
    logger.d("MyDonationsScreen: initState");
    // TODO: Kullanıcının bağış verilerini çekmeye başla (userId ile)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("MyDonationsScreen: build");

    // Scaffold kullanarak AppBar'ı düzgün şekilde yerleştiriyoruz
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağışlarım'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bekleyen Yanıtlar'),
            Tab(text: 'Tamamlananlar'),
            Tab(text: 'Planlananlar'), // Veya 'Reddedilenler' vb.
          ],
        ),
      ),
      // Body doğrudan TabBarView olacak
      body: TabBarView(
        controller: _tabController,
        children: const [
          // TODO: Her sekme için ilgili bağışları listeleyen widget'lar
          Center(child: Text('Bekleyen Bağış Yanıtları Listesi')),
          Center(child: Text('Tamamlanan Bağışlar Listesi')),
          Center(child: Text('Planlanan Bağış Randevuları Listesi')),
        ],
      ),
    );
  }
}

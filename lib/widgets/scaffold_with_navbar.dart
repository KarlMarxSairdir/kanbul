// lib/widgets/scaffold_with_navbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kan_bul/core/constants/app_sizes.dart';
import 'package:kan_bul/routes/app_routes.dart';
// PROVIDER İMPORTLARI
import 'package:kan_bul/features/chat/providers/chat_providers.dart';
import 'package:kan_bul/core/providers/auth_state_notifier.dart';
import 'package:kan_bul/data/repositories/blood_request_repository.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  // SpeedDial'in açık olup olmadığını takip eden değişken
  final ValueNotifier<bool> _isDialOpen = ValueNotifier<bool>(false);

  // Alt bar ikonuna tıklandığında çağrılacak metot
  void _onTap(BuildContext context, int index) {
    // Speed Dial açıksa önce kapat
    if (_isDialOpen.value) {
      _isDialOpen.value = false;
    }

    widget.navigationShell.goBranch(
      index,
      // Sekmeler arası geçişte aynı konumdaysa state'i koru
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void dispose() {
    // ValueNotifier'ı temizle - memory leak'leri önler
    _isDialOpen.dispose();
    super.dispose();
  }

  // BADGE HELPER
  Widget _navIconWithBadge({
    required IconData icon,
    required IconData selectedIcon,
    required bool selected,
    required int count,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    String? tooltip,
  }) {
    final iconWidget = Icon(selected ? selectedIcon : icon);
    return Badge(
      isLabelVisible: count > 0,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      alignment: AlignmentDirectional.topEnd,
      child: IconButton(
        icon: iconWidget,
        onPressed: onTap,
        onLongPress: onLongPress,
        tooltip: tooltip,
        color: selected ? const Color(0xFFD62828) : Colors.grey.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Arkaplan rengini tema'dan al
      // ÖNEMLİ: AppBar burada TANIMLANMAYACAK. Her alt ekran kendi AppBar'ını yönetebilir.
      body: widget.navigationShell,

      // FAB yerine SpeedDial kullanıyoruz - çift FAB sorununu çözmek için heroTag ekliyoruz
      floatingActionButton: SpeedDial(
        // Benzersiz heroTag - çift gösterimi önler
        heroTag: 'mainSpeedDial',
        // ValueNotifier ile SpeedDial'in durumunu takip etmek
        openCloseDial: _isDialOpen,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: Icons.bloodtype,
        activeIcon: Icons.close,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        spacing: 12,
        spaceBetweenChildren: 8,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 200),
        childrenButtonSize: const Size(56.0, 56.0),
        tooltip: 'Kan Bağışı İşlemleri',
        children: [
          SpeedDialChild(
            child: const Icon(Icons.volunteer_activism),
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            label: 'Bağış Yap',
            labelStyle: GoogleFonts.nunito(fontSize: 14),
            onTap: () => context.push(AppRoutes.map),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_circle_outline),
            backgroundColor: colorScheme.tertiaryContainer,
            foregroundColor: colorScheme.onTertiaryContainer,
            label: 'Talep Oluştur',
            labelStyle: GoogleFonts.nunito(fontSize: 14),
            onTap: () => context.push(AppRoutes.createBloodRequest),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: colorScheme.surface, // Tema rengini kullan
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        height: AppSizes.bottomBarHeight,
        shape: const CircularNotchedRectangle(),
        notchMargin: AppSizes.notchMargin,
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Sol Grup
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  isSelected:
                      widget.navigationShell.currentIndex ==
                      0, // Aktif sekme kontrolü
                  tooltip: 'Ana Sayfa',
                  onPressed: () => _onTap(context, 0), // İlk sekme (Dashboard)
                  color:
                      widget.navigationShell.currentIndex == 0
                          ? const Color(0xFFD62828) // Seçili renk - kırmızı
                          : Colors.grey.shade600, // Seçili olmayan renk - gri
                ),
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  selectedIcon: const Icon(Icons.map),
                  isSelected:
                      widget.navigationShell.currentIndex ==
                      1, // Aktif sekme kontrolü
                  tooltip: 'Harita + Liste',
                  onPressed:
                      () => _onTap(context, 1), // İkinci sekme (MyDonations)
                  color:
                      widget.navigationShell.currentIndex == 1
                          ? const Color(0xFFD62828)
                          : Colors.grey.shade600,
                ),
              ],
            ),
            // Sağ Grup
            Row(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(authStateNotifierProvider).user;
                    if (user == null) {
                      return _navIconWithBadge(
                        icon: Icons.list_alt_outlined,
                        selectedIcon: Icons.list_alt,
                        selected: widget.navigationShell.currentIndex == 2,
                        count: 0,
                        onTap: () => _onTap(context, 2),
                        onLongPress:
                            () => context.push(AppRoutes.createBloodRequest),
                        tooltip: 'Tüm Taleplerim',
                      );
                    }
                    final repo = ref.watch(bloodRequestRepositoryProvider);
                    return StreamBuilder(
                      stream: repo
                          .watchUserRequestsByStatus(user.id, 'active')
                          .map(
                            (list) =>
                                list.where((r) => r.responseCount > 0).toList(),
                          ),
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];
                        final total = list.length;
                        return _navIconWithBadge(
                          icon: Icons.list_alt_outlined,
                          selectedIcon: Icons.list_alt,
                          selected: widget.navigationShell.currentIndex == 2,
                          count: total,
                          onTap: () => _onTap(context, 2),
                          onLongPress:
                              () => context.push(AppRoutes.createBloodRequest),
                          tooltip: 'Tüm Taleplerim',
                        );
                      },
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final asyncChats = ref.watch(myChatsProvider);
                    final user = ref.watch(authStateNotifierProvider).user;
                    if (user == null) {
                      return _navIconWithBadge(
                        icon: Icons.chat_outlined,
                        selectedIcon: Icons.chat,
                        selected: widget.navigationShell.currentIndex == 3,
                        count: 0,
                        onTap: () => _onTap(context, 3),
                        onLongPress: () => context.push(AppRoutes.myChats),
                        tooltip: 'Mesajlarım',
                      );
                    }
                    return asyncChats.when(
                      data: (chats) {
                        int unread = 0;
                        for (final chat in chats) {
                          final lastReadAt = chat.lastReadAt[user.id];
                          final lastMessageAt = chat.lastMessageTimestamp;
                          if (lastMessageAt != null &&
                              (lastReadAt == null ||
                                  lastMessageAt.toDate().isAfter(
                                    lastReadAt.toDate(),
                                  ))) {
                            unread++;
                          }
                        }
                        return _navIconWithBadge(
                          icon: Icons.chat_outlined,
                          selectedIcon: Icons.chat,
                          selected: widget.navigationShell.currentIndex == 3,
                          count: unread,
                          onTap: () => _onTap(context, 3),
                          onLongPress: () => context.push(AppRoutes.myChats),
                          tooltip: 'Mesajlarım',
                        );
                      },
                      loading:
                          () => _navIconWithBadge(
                            icon: Icons.chat_outlined,
                            selectedIcon: Icons.chat,
                            selected: widget.navigationShell.currentIndex == 3,
                            count: 0,
                            onTap: () => _onTap(context, 3),
                            onLongPress: () => context.push(AppRoutes.myChats),
                            tooltip: 'Mesajlarım',
                          ),
                      error:
                          (_, __) => _navIconWithBadge(
                            icon: Icons.chat_outlined,
                            selectedIcon: Icons.chat,
                            selected: widget.navigationShell.currentIndex == 3,
                            count: 0,
                            onTap: () => _onTap(context, 3),
                            onLongPress: () => context.push(AppRoutes.myChats),
                            tooltip: 'Mesajlarım',
                          ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

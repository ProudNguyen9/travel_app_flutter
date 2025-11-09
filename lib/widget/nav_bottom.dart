import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:travel_app/pages/home_screen.dart'; // ✅ HomeScreen là nội dung tab 0
import 'package:travel_app/pages/screen.dart'; // SheduleScreen, ProfileScreen...

class SimpleBottomScaffold extends StatefulWidget {
  const SimpleBottomScaffold({super.key});

  @override
  State<SimpleBottomScaffold> createState() => _SimpleBottomScaffoldState();
}

class _SimpleBottomScaffoldState extends State<SimpleBottomScaffold> {
  int _selectedIndex = 0;

  // ✅ Chỉ 4 trang chính: Home, Lịch, Tin nhắn, Tôi
  final List<Widget> _pages = const [
    HomeScreen(), // ⚠️ Đảm bảo HomeScreen KHÔNG gọi lại SimpleBottomScaffold
    SheduleScreen(),
    _MessagesPage(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // 🔵 AI mở modal riêng (không phải tab)
  void _openAI() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _AiAssistantPage(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF24BAEC);

    return Scaffold(
      extendBody: true, // giúp nav nổi mượt trên nền nội dung
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Nội dung trang
          IndexedStack(index: _selectedIndex, children: _pages),

          // ✅ Nav nổi: đặt bằng Align(alignment: Alignment.bottomCenter)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 90,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Thanh nổi có viền xanh, bo tròn
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: primary, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Gap(2),
                            _BarItem(
                              icon: FontAwesomeIcons.house,
                              label: 'Trang chủ',
                              active: _selectedIndex == 0,
                              onTap: () => _onItemTapped(0),
                            ),
                            _BarItem(
                              icon: FontAwesomeIcons.calendarCheck,
                              label: 'Lịch',
                              active: _selectedIndex == 1,
                              onTap: () => _onItemTapped(1),
                            ),
                            const SizedBox(width: 56), // chừa chỗ cho nút AI
                            _BarItem(
                              icon: FontAwesomeIcons.envelope,
                              label: 'Tin nhắn',
                              active: _selectedIndex == 2,
                              onTap: () => _onItemTapped(2),
                              showBadge: true, // chấm đỏ
                            ),
                            _BarItem(
                              icon: FontAwesomeIcons.user,
                              label: 'Tôi',
                              active: _selectedIndex == 3,
                              onTap: () => _onItemTapped(3),
                            ),
                            const Gap(2),
                          ],
                        ),
                      ),
                    ),

                    // Nút AI giữa (mở modal riêng)
                    Positioned(
                      bottom: 35,
                      child: GestureDetector(
                        onTap: _openAI,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: primary, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/images/AILogo.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF24BAEC);
    final color = active ? primary : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 60,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon + badge đỏ (nếu có)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: color),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ========================
/// Placeholder tối giản
/// ========================
class _MessagesPage extends StatelessWidget {
  const _MessagesPage();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(child: Text('✉️ Tin nhắn')),
    );
  }
}

class _AiAssistantPage extends StatelessWidget {
  const _AiAssistantPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Assistant'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: const SafeArea(
        child: Center(child: Text('AI modal – mở từ nút giữa')),
      ),
    );
  }
}

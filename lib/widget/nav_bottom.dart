import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

class SimpleBottomBar extends StatefulWidget {
  const SimpleBottomBar({super.key});

  @override
  State<SimpleBottomBar> createState() => _SimpleBottomBarState();
}

class _SimpleBottomBarState extends State<SimpleBottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF24BAEC);

    return SafeArea(
      top: false,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Thanh nổi có VIỀN xanh dương, bo tròn
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
                    showBadge: true, // chấm đỏ như ảnh
                  ),
                  _BarItem(
                    icon: FontAwesomeIcons.user,
                    label: 'Tôi',
                    active: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  const Gap(2)
                ],
              ),
            ),
          ),

          // Nút AI giữa (chèn lên viền, có viền xanh & bóng nhẹ)
          Positioned(
            bottom: 35,
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

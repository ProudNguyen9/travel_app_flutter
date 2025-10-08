import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SimpleBottomBar extends StatefulWidget {
  const SimpleBottomBar({super.key});

  @override
  State<SimpleBottomBar> createState() => _SimpleBottomBarState();
}

class _SimpleBottomBarState extends State<SimpleBottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Thanh nổi
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BarItem(
                    icon: FontAwesomeIcons.house,
                    label: 'Home',
                    active: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  _BarItem(
                    icon: FontAwesomeIcons.calendarDays,
                    label: 'Calendar',
                    active: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  const SizedBox(width: 45),
                  _BarItem(
                    icon: FontAwesomeIcons.message,
                    label: 'Messages',
                    active: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                  _BarItem(
                    icon: FontAwesomeIcons.user,
                    label: 'Profile',
                    active: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                ],
              ),
            ),
          ),

          // Nút AI giữa
          Positioned(
            bottom: 35,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 251, 252, 252),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF24BAEC),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF24BAEC).withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/AILogo.png',
                    width: 64,
                    height: 64,
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
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF24BAEC);
    final color = active ? activeColor : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
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

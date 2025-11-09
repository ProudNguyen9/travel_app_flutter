import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/utils/extensions.dart';

import 'screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color accentBlue = const Color(0xFF1FB6FF);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final scale = screenWidth / 390;
        final safeBottom = MediaQuery.of(context).padding.bottom;
        final reserveForFloatingNav = 100.0 * scale + safeBottom + 16.0;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Hồ sơ cá nhân',
              style: GoogleFonts.lato(
                fontSize: 19 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 14 * scale),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.settings_rounded,
                      size: 26 * scale,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24 * scale,
              16 * scale,
              24 * scale,
              reserveForFloatingNav,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10 * scale),
                CircleAvatar(
                  radius: 48 * scale,
                  backgroundImage: const AssetImage('assets/images/main.png'),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(height: 14 * scale),
                Text(
                  'Nguyễn Lê Nhàn Lộc',
                  style: GoogleFonts.lato(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Thaotho199x@gmail.com',
                  style: GoogleFonts.lato(
                    fontSize: 16 * scale,
                    color: accentBlue,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 32 * scale),
                _sectionTitle('Thông tin cá nhân', scale),
                const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
                _infoItem('Nguyễn Lê Nhàn Lộc', scale),
                _infoItem('Thaotho199x@gmail.com', scale),
                _infoItem('039 688 292', scale),
                SizedBox(height: 24 * scale),
                _sectionTitle('Địa chỉ', scale),
                const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
                _infoItem('Thành phố Hồ Chí Minh / Quận 8 / Phường 11', scale),
                SizedBox(height: 20 * scale),
                _quickActions(scale, context),
                SizedBox(height: 24 * scale),
                SizedBox(
                  width: context.deviceSize.width * 0.6,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24BAEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26 * scale),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Chỉnh sửa',
                      style: GoogleFonts.lato(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickActions(double scale, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionTile(
            scale: scale,
            icon: Icons.favorite_rounded,
            label: 'Danh sách yêu thích',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritePlacesPage(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionTile(
            scale: scale,
            icon: Icons.receipt_long_rounded,
            label: 'Lịch sử đặt',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingsHistoryScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required double scale,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * scale),
        child: Container(
          height: 110 * scale,
          decoration: BoxDecoration(
            color: Colors.white, // BASIC COLOR
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: const Color(0xFFE7E7E9), // viền xám rất nhẹ chuẩn travel
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40 * scale,
                height: 40 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF24BAEC).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22 * scale,
                  color: const Color(0xFF24BAEC), // icon theo màu brand
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF151111),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, double scale) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6 * scale),
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String text, double scale) {
    return Column(
      children: [
        SizedBox(height: 12 * scale),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 15.5 * scale,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        const Divider(thickness: 0.4, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}

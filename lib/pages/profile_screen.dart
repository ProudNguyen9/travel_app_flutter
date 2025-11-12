import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/utils/extensions.dart';
import '../data/models/user_model.dart';
import '../data/services/profile_service.dart';
import 'screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color accentBlue = const Color(0xFF1FB6FF);
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService().getCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      user = profile;
      isLoading = false;
    });
  }

  Future<void> _navigateToEdit() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    // Dù cập nhật thông tin hay chỉ đổi ảnh → luôn reload lại dữ liệu
    if (updated == true || updated == null) {
      setState(() => isLoading = true);
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
            // Avatar
            CircleAvatar(
              radius: 48 * scale,
              backgroundImage: isLoading
                  ? null
                  : (user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : const AssetImage('assets/images/main.png')
                          as ImageProvider),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 14 * scale),
            // Name
            Text(
              isLoading ? '' : (user?.name ?? 'Chưa có tên'),
              style: GoogleFonts.lato(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4 * scale),
            // Email
            Text(
              isLoading ? '' : (user?.email ?? ''),
              style: GoogleFonts.lato(
                fontSize: 16 * scale,
                color: accentBlue,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 32 * scale),

            // ================= Thông tin cá nhân =================
            _sectionTitle('Thông tin cá nhân', scale),
            const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
            _infoItem(
                isLoading ? '...' : 'Họ tên: ${user?.name ?? "..."}', scale),
            _infoItem(
                isLoading ? '...' : 'Email: ${user?.email ?? "..."}', scale),
            _infoItem(
                isLoading ? '...' : 'SĐT: ${user?.phone ?? "..."}', scale),

            SizedBox(height: 24 * scale),

            // ================= Địa chỉ =================
            _sectionTitle('Địa chỉ', scale),
            const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
            _infoItem(isLoading ? '...' : (user?.address ?? 'Chưa có địa chỉ'),
                scale),

            SizedBox(height: 20 * scale),
            if (!isLoading) _quickActions(scale, context),
            if (!isLoading) SizedBox(height: 24 * scale),

            // Edit button
            if (!isLoading)
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
                  onPressed: _navigateToEdit,
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

            SizedBox(height: 14 * scale),
          ],
        ),
      ),
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
                  builder: (_) => const FavoriteTourScreen(),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: const Color(0xFFE7E7E9),
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
                  color: const Color(0xFF24BAEC),
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

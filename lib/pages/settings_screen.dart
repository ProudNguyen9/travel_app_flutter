import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool locationEnabled = true;
  bool darkMode = false;
  bool pushNotifications = true;
  bool emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cài đặt',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff151111),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _sectionHeader('Chung'),
          _settingItem('Tài khoản', onTap: () {}),
          _settingItem('Chỉnh sửa hồ sơ', onTap: () {}),
          _switchItem('Vị trí', locationEnabled, (v) {
            setState(() => locationEnabled = v);
          }),
          const Gap(10),
          _switchItem('Chế độ tối', darkMode, (v) {
            setState(() => darkMode = v);
          }),
          const SizedBox(height: 16),
          _sectionHeader('Thông báo'),
          const Gap(10),
          _switchItem('Thông báo đẩy', pushNotifications, (v) {
            setState(() => pushNotifications = v);
          }),
          const Gap(10),
          _switchItem('Email thông báo', emailNotifications, (v) {
            setState(() => emailNotifications = v);
          }),
          const SizedBox(height: 16),
          _sectionHeader('Hỗ trợ'),
          _settingItem('Liên hệ hỗ trợ', onTap: () {}),
          _settingItem('Đánh giá ứng dụng', onTap: () {}),
          _settingItem('Điều khoản dịch vụ', onTap: () {}),
          const SizedBox(height: 16),
          _sectionHeader('Khác'),
          _settingItem(
            'Đơn vị tiền tệ',
            trailing: Text(
              'VND',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff151111),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(36, 186, 236, 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _settingItem(String title,
      {Widget? trailing, VoidCallback? onTap, bool showArrow = true}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xff151111),
        ),
      ),
      trailing: trailing ??
          (showArrow
              ? const Icon(Icons.chevron_right, color: Colors.black45)
              : null),
    );
  }

  Widget _switchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xff151111),
            ),
          ),
          _customSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _customSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36.6,
        height: 22.2,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value
              ? const Color(0xFF24BAEC) // bật
              : const Color(0xFFdadada), // tắt
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          curve: Curves.easeInOut,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 1.5,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

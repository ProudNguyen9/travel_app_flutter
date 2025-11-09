import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/utils/extensions.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  final Color accentBlue = const Color(0xFF24BAEC);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double scale = (screenWidth / 390).clamp(0.8, 1.4);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              '     Chỉnh sửa hồ sơ cá nhân',
              style: GoogleFonts.lato(
                fontSize: 18 * scale, 
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.4,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 20 * scale,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 26 * scale,
              vertical: 16 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10 * scale),

                // 🧑 Avatar
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48 * scale,
                        backgroundImage:
                            const AssetImage('assets/images/main.png'),
                        backgroundColor: Colors.grey[200],
                      ),
                      SizedBox(height: 10 * scale),
                      Text(
                        'Chỉnh sửa',
                        style: GoogleFonts.lato(
                          fontSize: 16 * scale, // +4
                          fontWeight: FontWeight.w500,
                          color: accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32 * scale),

                // 🧾 Name
                _label('Họ và tên', scale),
                _infoBox('Nguyễn Lê Nhàn Lộc', scale),

                SizedBox(height: 16 * scale),

                // 📅 Date
                _label('Ngày sinh', scale),
                _infoBox('17/8/2000', scale),

                SizedBox(height: 16 * scale),

                // 🏠 Address
                _label('Địa chỉ', scale),
                _infoBox(
                  'Thành phố Hồ Chí Minh / Quận 8 / Phường 11',
                  scale,
                ),
                _infoBox(
                  'Tòa nhà Bộ Khoa học và Công nghệ, Số 1196, Đường 3 Tháng 2, '
                  'Phường 8, Quận 11, TP. Hồ Chí Minh',
                  scale,
                ),

                SizedBox(height: 40 * scale),

                // ✅ Nút cập nhật
                Center(
                  child: SizedBox(
                    width: context.deviceSize.width * 0.6,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32 * scale),
                        ),
                        elevation: 2,
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        'Cập nhật',
                        style: GoogleFonts.lato(
                          fontSize: 18 * scale, // +4
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40 * scale),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🏷 Label: vd "Họ và tên", "Ngày sinh"
  Widget _label(String text, double scale) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6 * scale),
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 15.5 * scale, // +4 (từ 11.5)
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // 📄 Box hiển thị thông tin
  Widget _infoBox(String text, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 14 * scale, // tăng nhẹ cho phù hợp font lớn
        horizontal: 4 * scale,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16 * scale, // +4 (từ 12)
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.4,
        ),
      ),
    );
  }
}

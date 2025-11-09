import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/pages/Login/login_screen.dart';
import 'package:travel_app/pages/Signup/signup_screen.dart';
import 'package:travel_app/pages/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showOnboarding = false;
  final PageController _controller = PageController();
  int _currentPage = 0;

  // 📸 Danh sách 3 trang onboarding
  final List<Map<String, dynamic>> _pages = [
    {
      "images": ["splash1.png", "splash2.png", "splash3.png"],
      "title1": "Khám phá những",
      "title2": "Điểm đến tuyệt vời",
      "desc":
          "Chúng tôi tin rằng việc đi du lịch vòng quanh thế giới không nên là điều khó khăn.",
    },
    {
      "images": ["splash4.png", "splash5.png", "splash6.png"],
      "title1": "Đặt tour",
      "title2": "và tận hưởng chuyến đi",
      "desc":
          "Chúng tôi giúp bạn đặt tour và tận hưởng những hành trình tuyệt vời nhất.",
    },
    {
      "images": ["splash7.png", "splash8.png", "splash9.png"],
      "title1": "Khám phá những",
      "title2": "Địa điểm mới mẻ",
      "desc":
          "Lo lắng về những nơi chưa từng đến? Chúng tôi sẽ giúp bạn khám phá chúng.",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Sau 3s chuyển qua trang onboarding
    Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOnboarding = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: _showOnboarding ? _buildOnboarding() : _buildLogo(),
      ),
    );
  }

  // 🌊 Màn hình logo khởi đầu
  Widget _buildLogo() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/background.png', fit: BoxFit.cover),
        Container(color: Colors.blue.withOpacity(0.4)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 180, height: 180),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // 📱 Trang giới thiệu (có thể lướt qua lại)
  Widget _buildOnboarding() {
    return SafeArea(
      child: Stack(
        children: [
          // 🌄 PHẦN TRÊN - PageView hiển thị ảnh và text
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _pages[index];

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double offset = 0.0;
                  if (_controller.position.haveDimensions) {
                    offset = _controller.page! - index;
                  }

                  final slide = offset.clamp(-1.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // 🌄 Cụm 3 hình có hiệu ứng bay
                        SizedBox(
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Transform.translate(
                                  offset: Offset(-150 * slide, 0),
                                  child: _imageBox(page["images"][0]),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Transform.translate(
                                  offset: Offset(-400 * slide, 0),
                                  child: _imageBox(page["images"][1]),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Transform.translate(
                                  offset: Offset(0, 120 * slide),
                                  child: _imageBox(page["images"][2],
                                      width: 250, height: 160, big: true),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        // 🔸 Tiêu đề + mô tả
                        Column(
                          children: [
                            Text(
                              page['title1'],
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff010100),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Transform(
                              transform: Matrix4.skewX(-0.3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE67E22),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Transform(
                                  transform: Matrix4.skewX(0.3),
                                  child: Text(
                                    page['title2'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              page['desc'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff151111),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height: 120), // để chừa chỗ cho nút bên dưới
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // 🌈 PHẦN DƯỚI - Nút & chỉ báo TRÊN CÙNG MỘT VỊ TRÍ CỐ ĐỊNH
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // 🔘 Thanh chỉ báo trang
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8,
                      width: _currentPage == i ? 20 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? Colors.orange
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Nút "Đăng nhập"
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Đăng nhập",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Nút "Tạo tài khoản"
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF24BAEC),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Tạo tài khoản",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff151111),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _imageBox(String img,
    {double width = 145, double height = 110, bool big = false}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(big ? 25 : 20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(2, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(big ? 25 : 20),
      child: Image.asset(
        'assets/images/$img',
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    ),
  );
}

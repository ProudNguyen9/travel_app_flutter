import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoCard extends StatelessWidget {
  final String title;
  final String highlight;
  final List<Color> gradient;
  const PromoCard(
      {super.key,
      required this.title,
      required this.highlight,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 319,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // lớp phủ mờ nhẹ để tạo hiệu ứng glassy
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // vòng tròn mờ trang trí nền
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
          Positioned(
            right: -20,
            bottom: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Nhãn nổi góc trên (nhỏ, kiểu tag quảng cáo)
          Positioned(
            left: 16,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                'ƯU ĐÃI ĐẶC BIỆT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: TweenAnimationBuilder<Duration>(
                duration: const Duration(minutes: 5),
                tween: Tween(
                    begin: const Duration(minutes: 5), end: Duration.zero),
                builder: (context, value, child) {
                  final minutes =
                      value.inMinutes.remainder(60).toString().padLeft(2, '0');
                  final seconds =
                      value.inSeconds.remainder(60).toString().padLeft(2, '0');
                  return Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  );
                },
              ),
            ),
          ),
          const Gap(10),

          // Nội dung chính của banner
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 45, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề nhỏ
                  Text(
                    title, // ví dụ: "Combo biển hè"
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dòng nổi bật chính
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFE985),
                        Color(0xFFFA709A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      highlight, // ví dụ: "Giảm 90%"
                      style: GoogleFonts.lato(
                        fontSize: 40,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 0.95,
                      ),
                    ),
                  ),
                  const Gap(5),
                  // Nút CTA “Xem ngay”
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.9),
                        width: 1.4,
                      ),
                      color: Colors.white.withOpacity(0.06),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Xem ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

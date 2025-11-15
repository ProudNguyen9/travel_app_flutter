import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/widget/nav_bottom.dart';

class FinishActionNoticeScreen extends StatelessWidget {
   final String email ;
   
  const FinishActionNoticeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Gap(140),
            Text(
              "Chúc mừng bạn !",
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF151111),
              ),
            ),
            Text(
              "Giao dịch của bạn đã thành công.",
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0x80151111),
              ),
            ),
            Image.asset('assets/icons/success.png'),
            Text(
              "Chúng tôi đã gửi thông tin giao dịch về email :\n$email",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0x80151111),
              ),
            ),
            const Gap(40),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SimpleBottomScaffold()));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF24BAEC), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "Quay về trang chủ",
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

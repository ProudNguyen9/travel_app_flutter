import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class FinishActionNoticeScreen extends StatelessWidget {
  const FinishActionNoticeScreen({super.key});

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
              "Congratulations !",
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF151111),
              ),
            ),
            Text(
              "Your Room has been successfully booked.",
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0x80151111),
              ),
            ),
            Image.asset('assets/icons/success.png'),
            Text(
              "A confirmation email has been sent to\nabisolasherif23@gmail.com",
              textAlign: TextAlign.center, // 👈 nằm ngoài style
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0x80151111),
              ),
            ),
            const Gap(40),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blueAccent, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                "Back To Homepage",
                style: GoogleFonts.lato(
                  fontSize: 14,
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

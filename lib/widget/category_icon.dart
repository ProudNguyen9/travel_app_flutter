import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CatergoryIcon extends StatelessWidget {
  final String title;
  final String path;
  const CatergoryIcon({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            path,
            width: 56,
            height: 56,
          ),
        ),
        Text(title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ))
      ],
    );
  }
}

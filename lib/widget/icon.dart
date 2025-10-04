import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialIcon extends StatelessWidget {
  final path;
  final VoidCallback ontap;
  const SocialIcon({super.key, this.path, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          color: Colors.white, // nền trắng
        ),
        child: Center(
          child: SvgPicture.asset(
            path,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

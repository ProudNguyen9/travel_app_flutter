import 'package:flutter/material.dart';
import 'reuseable_text.dart';

class MiddleAppText extends StatelessWidget {
  const MiddleAppText({
    super.key,
    required this.text,
    this.onSeeAll,
  });

  final String text;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.02, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Tiêu đề chính
          AppText(
            text: text,
            size: 19,
            color: Colors.black.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),

          /// Nút “Xem tất cả” có hiệu ứng
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText(
                  text: "Xem tất cả",
                  size: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

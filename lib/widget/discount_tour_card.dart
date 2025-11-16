// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiscountTourCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final double scale;

  /// 👉 thêm callback mở DetailScreen
  final VoidCallback? onTap;

  const DiscountTourCard({
    super.key,
    required this.tour,
    required this.scale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final _fmt = NumberFormat("#,###", "vi_VN");

    final original = tour["original_price"] ?? 0;
    final discount = tour["discount_percent"] ?? 0;
    final finalPrice = tour["final_price"] ?? original;

    return GestureDetector(
      onTap: onTap, // 👈 QUAN TRỌNG
      child: Container(
        margin: EdgeInsets.only(bottom: 14 * scale),
        padding: EdgeInsets.all(10 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12 * scale),
              child: Image.network(
                tour['image_url'] ?? '',
                width: 90 * scale,
                height: 70 * scale,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Row(
                    children: [
                      Text(
                        "${_fmt.format(original)}đ",
                        style: TextStyle(
                          fontSize: 13 * scale,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      if (discount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6 * scale, vertical: 2 * scale),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "-${discount.toInt()}%",
                            style: TextStyle(
                              fontSize: 11 * scale,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${_fmt.format(finalPrice)}đ",
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w800,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

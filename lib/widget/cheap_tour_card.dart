// lib/widget/cheap_tour_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheapTourCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final double scale;

  /// 👉 Callback mở DetailScreen
  final VoidCallback? onTap;

  const CheapTourCard({
    super.key,
    required this.tour,
    required this.scale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    final price = tour["total_price"] ?? 0; // ✔ đúng giá tổng
    final days = tour["duration_days"] ?? 1;
    final image = tour["image_url"] ?? "";

    return GestureDetector(
      onTap: onTap, // 👈 QUAN TRỌNG
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.08),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 90 * scale,
                height: 90 * scale,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: 12 * scale),

            // ====== CONTENT ======
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour["name"] ?? "Không có tên",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    "Giá: ${fmt.format(price)}",
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    "$days ngày",
                    style: TextStyle(
                      fontSize: 13 * scale,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

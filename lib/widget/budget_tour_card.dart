import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetTourCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final double scale;

  /// 👉 Callback mở DetailScreen
  final VoidCallback? onTap;

  const BudgetTourCard({
    super.key,
    required this.tour,
    required this.scale,
    this.onTap,
  });

  String _fmt(num n) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
          .format(n);

  // 👉 Format số ngày, tránh hiện 1.1 / 1.2
  String _formatDays(dynamic value) {
    if (value == null) return '1 ngày';

    if (value is int) {
      return '$value ngày';
    }

    if (value is num) {
      final d = value.round(); // 1.1 -> 1, 1.6 -> 2
      return '$d ngày';
    }

    final parsed = double.tryParse(value.toString());
    if (parsed == null) return '1 ngày';
    return '${parsed.round()} ngày';
  }

  @override
  Widget build(BuildContext context) {
    final price = tour['total_price'] ?? 0;
    final image = tour['image_url'] ?? '';
    final duration = tour['duration_days'];

    return GestureDetector(
      onTap: onTap, // 👈 QUAN TRỌNG — mở DetailScreen
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2FAF2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 90 * scale,
                height: 70 * scale,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // ===== Content =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour['name'] ?? "Không có tên",
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Giá từ: ${_fmt(price)}",
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14 * scale),
                      const SizedBox(width: 4),
                      Text(
                        _formatDays(duration), // ⬅️ dùng hàm format
                        style: TextStyle(fontSize: 13 * scale),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

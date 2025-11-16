import 'package:flutter/material.dart';

class DurationTourCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final double scale;

  final VoidCallback? onTap;

  const DurationTourCard({
    super.key,
    required this.tour,
    required this.scale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final raw = tour["duration_days"] ?? 1;

    // ⭐ Chuyển số lẻ thành ngày – đêm
    final days = raw.floor(); // 2.1 → 2
    final nights = days > 1 ? days - 1 : 0; // 2 → 1 đêm

    final durationText = nights > 0 ? "$days ngày $nights đêm" : "$days ngày";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14 * scale),
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                tour["image_url"],
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
                    tour["name"],
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "📅 $durationText",
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 13 * scale,
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

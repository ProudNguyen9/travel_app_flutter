// lib/utils/duration_formatter.dart

/// Format số ngày dạng double thành chuỗi:
/// 1.0 → "1 ngày"
/// 1.5 → "1 ngày 1 đêm"
/// 2.0 → "2 ngày 1 đêm"
/// 2.5 → "2 ngày 1 đêm"
/// 3.5 → "3 ngày 2 đêm"
String formatDuration(double? d) {
  if (d == null) return "Lịch trình linh hoạt";

  int days = d.floor();
  int decimal = ((d % 1) * 10).round(); // vd: .1 → 1, .2 → 2

  int nights = decimal; // quy ước: .1 = 1 đêm, .2 = 2 đêm, .3 = 3 đêm

  if (nights <= 0) return "$days ngày";
  return "$days ngày $nights đêm";
}

import 'package:intl/intl.dart';

class Formatter {
  /// Format tiền Việt Nam: 2500000 → 2.500.000đ
  static String vnd(num? value, {bool compact = false}) {
    final v = (value ?? 0);

    // Compact: 2.5M hoặc 2.5 triệu
    if (compact) {
      if (v >= 1000000) {
        return "${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M";
      }
      if (v >= 1000) {
        return "${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K";
      }
    }

    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(v);
  }

  /// Format số nguyên có dấu phẩy (1,000 → 1.000)
  static String number(num? v) {
    return NumberFormat.decimalPattern('vi_VN').format(v ?? 0);
  }

  /// Format ngày dd/MM/yyyy
  static String date(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  /// Format giờ HH:mm
  static String time(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat('HH:mm').format(dt);
  }
}

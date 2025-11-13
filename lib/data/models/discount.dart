enum DiscountType { percent, amount }

DiscountType _discountTypeFrom(dynamic v) {
  final s = (v ?? '').toString().toLowerCase();
  return (s == 'amount' || s == 'fixed')
      ? DiscountType.amount
      : DiscountType.percent;
}

class Discount {
  final int? discountId;
  final int tourId;
  final String code;
  final String? name;
  final String? description;
  final DiscountType discountType; // percent | amount
  final double value; // % nếu percent, số tiền nếu amount
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int? usageLimit;
  final int? earlyBookingDays; // đặt sớm bao nhiêu ngày
  final bool hidden;
  final double? maxDiscount;
  final int? people;

  const Discount({
    required this.discountId,
    required this.tourId,
    required this.code,
    required this.discountType,
    required this.value,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.usageLimit,
    this.earlyBookingDays,
    this.hidden = true,
    this.maxDiscount,
    this.people,
  });

  bool get isPercent => discountType == DiscountType.percent;

  factory Discount.fromJson(Map<String, dynamic> json) {
    final type = _discountTypeFrom(json['discount_type']);

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return Discount(
      discountId: toInt(json['discount_id']) ?? 0,
      tourId: toInt(json['tour_id']) ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      discountType: type,
      value: toDouble(json['value']) ?? 0,
      startDate: toDate(json['start_date']),
      endDate: toDate(json['end_date']),
      isActive: json['is_active'] ?? false,
      hidden: json['hidden'] ?? false,
      usageLimit: toInt(json['usage_limit']),
      earlyBookingDays: toInt(json['early_booking_days']),
      maxDiscount: toDouble(json['max_discount']),
      people: toInt(json['min_people']),
    );
  }

  @override
  String toString() {
    return 'Discount(id=$discountId, code=$code, type=$discountType, value=$value, earlyBookingDays=$earlyBookingDays)';
  }
}

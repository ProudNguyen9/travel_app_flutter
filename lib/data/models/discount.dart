enum DiscountType { percent, amount }

DiscountType _discountTypeFrom(dynamic v) {
  final s = (v ?? '').toString().toLowerCase();
  return (s == 'amount' || s == 'fixed')
      ? DiscountType.amount
      : DiscountType.percent;
}

class Discount {
  final int discountId;
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
  final int? earlyBookingDays; // 👈 đặt sớm bao nhiêu ngày
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

    return Discount(
      discountId: json['discount_id'] as int,
      tourId: json['tour_id'] as int,
      code: json['code'] ?? '',
      name: json['name'],
      description: json['description'],
      discountType: type,
      value: (json['value'] ?? 0).toDouble(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      isActive: json['is_active'] ?? false,
      hidden: json['hidden'] ?? false,
      usageLimit: json['usage_limit'],
      earlyBookingDays: json['early_booking_days'] ?? 0, // 👈 map mới
      maxDiscount: json['max_discount'] != null
          ? (json['max_discount'] as num).toDouble()
          : null,
      people: json['people'],
    );
  }
}

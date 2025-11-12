enum DiscountType { percent, amount }

DiscountType _discountTypeFrom(dynamic v) {
  final s = (v ?? '').toString().toLowerCase();
  return s == 'amount' ? DiscountType.amount : DiscountType.percent;
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
  final bool hidden;
  final max_discount;
  final people;
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
    this.hidden = true,
    this.max_discount,
    this.people,
  });

  bool get isPercent => discountType == DiscountType.percent;

  factory Discount.fromJson(Map<String, dynamic> json) {
    // 🔹 Lấy discount_type an toàn
    final typeStr = (json['discount_type'] ?? '').toString().toLowerCase();

    late DiscountType type;
    // Chấp nhận cả 'fixed' và 'amount' là số tiền, dưới 100% cũng tự nhận percent
    if (typeStr == 'percent') {
      type = DiscountType.percent;
    } else if (typeStr == 'fixed' || typeStr == 'amount') {
      type = DiscountType.amount;
    } else {
      // fallback: nếu value < 100 thì coi là %
      final value = (json['value'] ?? 0).toDouble();
      type = value < 100 ? DiscountType.percent : DiscountType.amount;
    }

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
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'] ?? false,
      hidden: json['hidden'] ?? false,
      usageLimit: json['usage_limit'],
      max_discount: json['max_discount'],
      people: json['people'],
    );
  }
}

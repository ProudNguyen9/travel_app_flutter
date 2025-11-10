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
  final double value;              // % nếu percent, số tiền nếu amount
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int? usageLimit;

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
  });

  bool get isPercent => discountType == DiscountType.percent;

  factory Discount.fromJson(Map<String, dynamic> j) {
    DateTime? _toDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    double _toD(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);
    int _toI(dynamic v) =>
        v == null ? 0 : (v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0));

    return Discount(
      discountId: _toI(j['discount_id']),
      tourId: _toI(j['tour_id']),
      code: (j['code'] ?? '').toString(),
      name: j['name']?.toString(),
      description: j['description']?.toString(),
      discountType: _discountTypeFrom(j['discount_type']),
      value: _toD(j['value']),
      startDate: _toDate(j['start_date']),
      endDate: _toDate(j['end_date']),
      isActive: (j['is_active'] ?? true) == true,
      usageLimit: j['usage_limit'] == null ? null : _toI(j['usage_limit']),
    );
  }
}

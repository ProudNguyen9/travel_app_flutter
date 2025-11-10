import 'dart:convert';

/// Model cho 1 dòng giá hoạt động theo tour & ngày khởi hành
class TourActivityPrice {
  final int activityId;
  final String activityName;
  final int tourId;
  final double adultPrice;
  final double seniorPrice;
  final double childPrice;

  const TourActivityPrice({
    required this.activityId,
    required this.activityName,
    required this.tourId,
    required this.adultPrice,
    required this.seniorPrice,
    required this.childPrice,
  });

  /// Parse an toàn số (PostgREST có thể trả int / double / String)
  static double _numToDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }

  /// Từ map JSON (Supabase/PostgREST)
  factory TourActivityPrice.fromJson(Map<String, dynamic> json) {
    return TourActivityPrice(
      activityId: (json['activity_id'] as num).toInt(),
      activityName: (json['activity_name'] ?? '') as String,
      tourId: (json['tour_id'] as num).toInt(),
      adultPrice: _numToDouble(json['adult_price']),
      seniorPrice: _numToDouble(json['senior_price']),
      childPrice: _numToDouble(json['child_price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'activity_id': activityId,
        'activity_name': activityName,
        'tour_id': tourId,
        'adult_price': adultPrice,
        'senior_price': seniorPrice,
        'child_price': childPrice,
      };

  TourActivityPrice copyWith({
    int? activityId,
    String? activityName,
    int? tourId,
    double? adultPrice,
    double? seniorPrice,
    double? childPrice,
  }) {
    return TourActivityPrice(
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      tourId: tourId ?? this.tourId,
      adultPrice: adultPrice ?? this.adultPrice,
      seniorPrice: seniorPrice ?? this.seniorPrice,
      childPrice: childPrice ?? this.childPrice,
    );
  }

  @override
  String toString() =>
      'TourActivityPrice(activityId: $activityId, name: $activityName, '
      'adult: $adultPrice, senior: $seniorPrice, child: $childPrice)';

  @override
  bool operator ==(Object other) {
    return other is TourActivityPrice &&
        other.activityId == activityId &&
        other.tourId == tourId &&
        other.activityName == activityName &&
        other.adultPrice == adultPrice &&
        other.seniorPrice == seniorPrice &&
        other.childPrice == childPrice;
  }

  @override
  int get hashCode =>
      activityId.hashCode ^
      activityName.hashCode ^
      tourId.hashCode ^
      adultPrice.hashCode ^
      seniorPrice.hashCode ^
      childPrice.hashCode;

  /// Parse list từ JSON array
  static List<TourActivityPrice> listFromJson(List<dynamic> data) {
    return data
        .map((e) => TourActivityPrice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Parse nhanh từ chuỗi JSON
  static List<TourActivityPrice> listFromJsonString(String jsonStr) {
    final raw = json.decode(jsonStr) as List<dynamic>;
    return listFromJson(raw);
  }
}

class Booking {
  final int? bookingId;
  final int? tourId;
  final int? userId;

  final DateTime? startDate;
  final DateTime? endDate;

  final int adultCount;
  final int childCount;
  final int elderlyCount;

  final String? status;
  final int? discountId;
  final String? discountCode;

  final double discountAmount;
  final double finalAmount;

  final double taxRate;
  final int taxAmount;

  final int adultPrice;
  final int childPrice;
  final int elderlyPrice;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.bookingId,
    this.tourId,
    this.userId,
    this.startDate,
    this.endDate,
    this.adultCount = 1,
    this.childCount = 0,
    this.elderlyCount = 0,
    this.status,
    this.discountId,
    this.discountCode,
    this.discountAmount = 0,
    this.finalAmount = 0,
    this.taxRate = 8,
    this.taxAmount = 0,
    this.adultPrice = 0,
    this.childPrice = 0,
    this.elderlyPrice = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// ============================================
  /// COPY WITH (QUAN TRỌNG NHẤT) — để gán bookingId
  /// ============================================
  Booking copyWith({
    int? bookingId,
    int? tourId,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? adultCount,
    int? childCount,
    int? elderlyCount,
    String? status,
    int? discountId,
    String? discountCode,
    double? discountAmount,
    double? finalAmount,
    double? taxRate,
    int? taxAmount,
    int? adultPrice,
    int? childPrice,
    int? elderlyPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      tourId: tourId ?? this.tourId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      elderlyCount: elderlyCount ?? this.elderlyCount,
      status: status ?? this.status,
      discountId: discountId ?? this.discountId,
      discountCode: discountCode ?? this.discountCode,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      adultPrice: adultPrice ?? this.adultPrice,
      childPrice: childPrice ?? this.childPrice,
      elderlyPrice: elderlyPrice ?? this.elderlyPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ============================================
  /// FROM JSON
  /// ============================================
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'] as int?,
      tourId: json['tour_id'] as int?,
      userId: json['user_id'] as int?,

      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,

      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,

      adultCount: (json['adult_count'] as num?)?.toInt() ?? 1,
      childCount: (json['child_count'] as num?)?.toInt() ?? 0,
      elderlyCount: (json['elderly_count'] as num?)?.toInt() ?? 0,

      status: json['status'],
      discountId: json['discount_id'],
      discountCode: json['discount_code'],

      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0,

      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 8,
      taxAmount: (json['tax_amount'] as num?)?.toInt() ?? 0,

      adultPrice: (json['adult_price'] as num?)?.toInt() ?? 0,
      childPrice: (json['child_price'] as num?)?.toInt() ?? 0,
      elderlyPrice: (json['elderly_price'] as num?)?.toInt() ?? 0,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// ============================================
  /// TO JSON — chuẩn để insert vào Supabase
  /// ============================================
  Map<String, dynamic> toJson() {
    return {
      if (bookingId != null) 'booking_id': bookingId,
      'tour_id': tourId,
      'user_id': userId,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'adult_count': adultCount,
      'child_count': childCount,
      'elderly_count': elderlyCount,
      'status': status,
      'discount_id': discountId,
      'discount_code': discountCode,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'adult_price': adultPrice,
      'child_price': childPrice,
      'elderly_price': elderlyPrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

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
  final double taxRate; // thêm
  final int? taxAmount; // thêm
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
    this.taxRate = 8, // mặc định 8%
    this.taxAmount = 0, // mặc định 0
    this.createdAt,
    this.updatedAt,
  });

  // Tạo từ JSON
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
      status: json['status'] as String?,
      discountId: json['discount_id'] as int?,
      discountCode: json['discount_code'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 8, // thêm
      taxAmount: (json['tax_amount'] as num?)?.toInt() ?? 0, // thêm
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Chuyển sang JSON
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
      'tax_rate': taxRate, // thêm
      'tax_amount': taxAmount, // thêm
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

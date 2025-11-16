class BookingHistoryItem {
  final int bookingId;
  final int tourId;

  final String tourName;
  final String locationName;
  final String? imageUrl;

  final DateTime? startDate;
  final DateTime? endDate;

  /// Thời gian hoạt động đầu tiên (min start_time trong activities)
  final DateTime? firstActivityTime;

  final String status;
  final int adultCount;
  final int childCount;
  final int elderlyCount;
  final num finalAmount;
  final DateTime? createdAt;

  int get totalGuests => adultCount + childCount + elderlyCount;

  BookingHistoryItem({
    required this.bookingId,
    required this.tourId,
    required this.tourName,
    required this.locationName,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.firstActivityTime,
    required this.status,
    required this.adultCount,
    required this.childCount,
    required this.elderlyCount,
    required this.finalAmount,
    required this.createdAt,
  });

  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    final tour = json['tours'] as Map<String, dynamic>?;

    // ===== Location name =====
    String locationName = '';
    DateTime? firstActivityTime;

    final tourLocations = tour?['tour_locations'] as List<dynamic>?;

    if (tourLocations != null && tourLocations.isNotEmpty) {
      // Lấy tên location đầu tiên
      final firstLocWrapper = tourLocations.first;
      final loc = firstLocWrapper['locations'] as Map<String, dynamic>?;
      locationName = (loc?['name'] ?? '') as String;

      // Tìm activity có start_time nhỏ nhất trong tất cả tour_locations
      for (final tl in tourLocations) {
        final activities = tl['activities'] as List<dynamic>?;
        if (activities == null) continue;

        for (final act in activities) {
          final raw = act['start_time'];
          if (raw == null) continue;

          final dt = DateTime.parse(raw as String);
          if (firstActivityTime == null || dt.isBefore(firstActivityTime!)) {
            firstActivityTime = dt;
          }
        }
      }
    }

    final adult = (json['adult_count'] ?? 0) as int;
    final child = (json['child_count'] ?? 0) as int;
    final elderly = (json['elderly_count'] ?? 0) as int;

    final startRaw = json['start_date'];
    final endRaw = json['end_date'];

    return BookingHistoryItem(
      bookingId: (json['booking_id'] as num).toInt(),
      tourId: (tour?['tour_id'] as num?)?.toInt() ?? 0,
      tourName: (tour?['name'] ?? '') as String,
      locationName: locationName,
      imageUrl: tour?['image_url'] as String?,
      startDate: startRaw != null ? DateTime.parse(startRaw as String) : null,
      endDate: endRaw != null ? DateTime.parse(endRaw as String) : null,
      firstActivityTime: firstActivityTime,
      status: (json['status'] ?? '') as String,
      adultCount: adult,
      childCount: child,
      elderlyCount: elderly,
      finalAmount: (json['final_amount'] ?? 0) as num,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

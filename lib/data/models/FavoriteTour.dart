class FavoriteTour {
  final int favoriteId;
  final int userId;
  final int tourId;
  final DateTime? createdAt;

  // Thông tin người dùng
  final String? userName;
  final String? userEmail;

  // Thông tin tour
  final String? tourName;
  final String? tourDescription;
  final String? tourImage;
  final double? basePriceAdult;
  final double? basePriceChild;
  final double? durationDays;
  final int? tourTypeId;

  // Thông tin loại tour
  final String? tourTypeName;
  final String? tourTypeCode;

  const FavoriteTour({
    required this.favoriteId,
    required this.userId,
    required this.tourId,
    this.createdAt,
    this.userName,
    this.userEmail,
    this.tourName,
    this.tourDescription,
    this.tourImage,
    this.basePriceAdult,
    this.basePriceChild,
    this.durationDays,
    this.tourTypeId,
    this.tourTypeName,
    this.tourTypeCode,
  });

  factory FavoriteTour.fromMap(Map<String, dynamic> j) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return FavoriteTour(
      favoriteId: j['favorite_id'] as int,
      userId: j['user_id'] as int,
      tourId: j['tour_id'] as int,
      createdAt: _toDate(j['created_at']),
      userName: j['user_name'],
      userEmail: j['user_email'],
      tourName: j['tour_name'],
      tourDescription: j['tour_description'],
      tourImage: j['tour_image'],
      basePriceAdult: _toDouble(j['base_price_adult']),
      basePriceChild: _toDouble(j['base_price_child']),
      durationDays: _toDouble(j['duration_days']),
      tourTypeId: (j['tour_type_id'] as num?)?.toInt(),
      tourTypeName: j['tour_type_name'],
      tourTypeCode: j['tour_type_code'],
    );
  }

  Map<String, dynamic> toMap() => {
        'favorite_id': favoriteId,
        'user_id': userId,
        'tour_id': tourId,
        'created_at': createdAt?.toIso8601String(),
        'user_name': userName,
        'user_email': userEmail,
        'tour_name': tourName,
        'tour_description': tourDescription,
        'tour_image': tourImage,
        'base_price_adult': basePriceAdult,
        'base_price_child': basePriceChild,
        'duration_days': durationDays,
        'tour_type_id': tourTypeId,
        'tour_type_name': tourTypeName,
        'tour_type_code': tourTypeCode,
      };

  FavoriteTour copyWith({
    int? favoriteId,
    int? userId,
    int? tourId,
    DateTime? createdAt,
    String? userName,
    String? userEmail,
    String? tourName,
    String? tourDescription,
    String? tourImage,
    double? basePriceAdult,
    double? basePriceChild,
    double? durationDays,
    int? tourTypeId,
    String? tourTypeName,
    String? tourTypeCode,
  }) {
    return FavoriteTour(
      favoriteId: favoriteId ?? this.favoriteId,
      userId: userId ?? this.userId,
      tourId: tourId ?? this.tourId,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      tourName: tourName ?? this.tourName,
      tourDescription: tourDescription ?? this.tourDescription,
      tourImage: tourImage ?? this.tourImage,
      basePriceAdult: basePriceAdult ?? this.basePriceAdult,
      basePriceChild: basePriceChild ?? this.basePriceChild,
      durationDays: durationDays ?? this.durationDays,
      tourTypeId: tourTypeId ?? this.tourTypeId,
      tourTypeName: tourTypeName ?? this.tourTypeName,
      tourTypeCode: tourTypeCode ?? this.tourTypeCode,
    );
  }
}

class TourFull {
  final int tourId;
  final String name;
  final String? description;
  final double? basePriceAdult;
  final double? basePriceChild;
  final double? durationDays;
  final int? maxParticipants;
  final int? tourTypeId;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? tourTypeName;
  final String? tourTypeCode;
  List<String>? images;

  // ===== Discount fields (from vw_tours_full) =====
  final int? bestDiscountId; // bv.discount_id
  final int? bestDiscountPeople; // bv.required_people (NULL/1 = 1 người; >=2 = nhóm)
  final String? bestDiscountType; // 'percent' | 'fixed'
  final double? bestDiscountValue; // % hoặc số tiền
  final double? bestDiscountCap; // trần (nếu percent)
  final int? bestDiscountEarlyDays; // bv.early_booking_days

  TourFull({
    required this.tourId,
    required this.name,
    this.description,
    this.basePriceAdult,
    this.basePriceChild,
    this.durationDays,
    this.maxParticipants,
    this.tourTypeId,
    this.imageUrl,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.tourTypeName,
    this.tourTypeCode,
    this.bestDiscountId,
    this.bestDiscountPeople,
    this.bestDiscountType,
    this.bestDiscountValue,
    this.bestDiscountCap,
    this.bestDiscountEarlyDays,
  });

  factory TourFull.fromMap(Map<String, dynamic> j) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return TourFull(
      tourId: (j['tour_id'] as num).toInt(),
      name: j['name'] ?? '',
      description: j['description'],

      basePriceAdult: toDouble(j['base_price_adult']),
      basePriceChild: toDouble(j['base_price_child']),
      durationDays: toDouble(j['duration_days']),
      maxParticipants: toInt(j['max_participants']),
      tourTypeId: toInt(j['tour_type_id']),
      imageUrl: j['image_url'],
      createdAt: toDate(j['created_at']),
      updatedAt: toDate(j['updated_at']),
      tourTypeName: j['tour_type_name'],
      tourTypeCode: j['tour_type_code'],

      // discount fields
      bestDiscountId: toInt(j['best_discount_id']),
      bestDiscountPeople: toInt(j['best_discount_people']),
      bestDiscountType: j['best_discount_type'],
      bestDiscountValue: toDouble(j['best_discount_value']),
      bestDiscountCap: toDouble(j['best_discount_cap']),
      bestDiscountEarlyDays: toInt(j['best_discount_early_days']),
    );
  }

  Map<String, dynamic> toMap() => {
        'tour_id': tourId,
        'name': name,
        'description': description,
        'base_price_adult': basePriceAdult,
        'base_price_child': basePriceChild,
        'duration_days': durationDays,
        'max_participants': maxParticipants,
        'tour_type_id': tourTypeId,
        'image_url': imageUrl,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'tour_type_name': tourTypeName,
        'tour_type_code': tourTypeCode,

        // discount fields
        'best_discount_id': bestDiscountId,
        'best_discount_people': bestDiscountPeople,
        'best_discount_type': bestDiscountType,
        'best_discount_value': bestDiscountValue,
        'best_discount_cap': bestDiscountCap,
        'best_discount_early_days': bestDiscountEarlyDays,
      };

  TourFull copyWith({
    int? tourId,
    String? name,
    String? description,
    double? basePriceAdult,
    double? basePriceChild,
    double? durationDays,
    int? maxParticipants,
    int? tourTypeId,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tourTypeName,
    String? tourTypeCode,
    List<String>? images,

    // discount fields
    int? bestDiscountId,
    int? bestDiscountPeople,
    String? bestDiscountType,
    double? bestDiscountValue,
    double? bestDiscountCap,
    int? bestDiscountEarlyDays,
  }) {
    return TourFull(
      tourId: tourId ?? this.tourId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePriceAdult: basePriceAdult ?? this.basePriceAdult,
      basePriceChild: basePriceChild ?? this.basePriceChild,
      durationDays: durationDays ?? this.durationDays,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      tourTypeId: tourTypeId ?? this.tourTypeId,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tourTypeName: tourTypeName ?? this.tourTypeName,
      tourTypeCode: tourTypeCode ?? this.tourTypeCode,

      // discount fields
      bestDiscountId: bestDiscountId ?? this.bestDiscountId,
      bestDiscountPeople: bestDiscountPeople ?? this.bestDiscountPeople,
      bestDiscountType: bestDiscountType ?? this.bestDiscountType,
      bestDiscountValue: bestDiscountValue ?? this.bestDiscountValue,
      bestDiscountCap: bestDiscountCap ?? this.bestDiscountCap,
      bestDiscountEarlyDays: bestDiscountEarlyDays ?? this.bestDiscountEarlyDays,
    );
  }

  bool get hasDiscount => bestDiscountId != null;
}

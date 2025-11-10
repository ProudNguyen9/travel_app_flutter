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
  });

  factory TourFull.fromMap(Map<String, dynamic> j) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return TourFull(
      tourId: j['tour_id'] as int,
      name: j['name'] ?? "",
      description: j['description'],
      basePriceAdult: toDouble(j['base_price_adult']),
      basePriceChild: toDouble(j['base_price_child']),
      durationDays: toDouble(j['duration_days']),
      maxParticipants: (j['max_participants'] as num?)?.toInt(),
      tourTypeId: (j['tour_type_id'] as num?)?.toInt(),
      imageUrl: j['image_url'],
      createdAt: toDate(j['created_at']),
      updatedAt: toDate(j['updated_at']),
      tourTypeName: j['tour_type_name'],
      tourTypeCode: j['tour_type_code'],
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tourTypeName: tourTypeName ?? this.tourTypeName,
      tourTypeCode: tourTypeCode ?? this.tourTypeCode,
    );
  }
}

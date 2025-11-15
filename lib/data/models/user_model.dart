class UserModel {
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? address;
  final String? role;
  final String? authId;

  /// ⭐ NEW: url chữ ký mẫu lưu trong Supabase Storage
   String? signatureUrl;

  UserModel({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.address,
    this.role,
    this.authId,
    this.signatureUrl, // ⭐ new
  });

  // =====================
  // COPY WITH
  // =====================
  UserModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? address,
    String? role,
    String? authId,
    String? signatureUrl, // ⭐ new
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      role: role ?? this.role,
      authId: authId ?? this.authId,
      signatureUrl: signatureUrl ?? this.signatureUrl, // ⭐ new
    );
  }

  // =====================
  // FROM JSON
  // =====================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String?,
      authId: json['auth_id'] as String?,
      signatureUrl: json['signature_url'] as String?, // ⭐ new
    );
  }

  // =====================
  // TO JSON
  // =====================
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'address': address,
      'role': role,
      'auth_id': authId,
      'signature_url': signatureUrl, // ⭐ new
    };
  }
}

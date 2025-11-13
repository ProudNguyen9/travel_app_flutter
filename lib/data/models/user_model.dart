class UserModel {
  UserModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? address,
    String? role,
    String? authId,
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
    );
  }

  final int? userId; // 👈 thêm userId
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? role;
  final String? address;
  final String? authId;

  UserModel({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.role,
    this.address,
    this.authId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json['user_id'] as int?, // 👈 lấy userId
        name: json['name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        profileImage: json['profile_image'] as String?,
        role: json['role'] as String?,
        address: json['address'] as String?,
        authId: json['auth_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId, // 👈 lưu userId
        'name': name,
        'email': email,
        'phone': phone,
        'profile_image': profileImage,
        'role': role,
        'address': address,
        'auth_id': authId,
      };
}

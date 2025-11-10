// lib/data/models/user_model.dart

class UserModel {
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? address,
    String? role,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      role: role ?? this.role,
    );
  }

  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? role; // 👈 NEW
  final String? address; // 👈 NEW
  final String? authId;

  UserModel({
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.role,
    this.address,
    this.authId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        profileImage: json['profile_image'] as String?,
        role: json['role'] as String?, // 👈
        address: json['address'] as String?, // 👈
        authId: json['auth_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'profile_image': profileImage,
        'role': role, // 👈
        'address': address, // 👈
        'auth_id': authId,
      };
}

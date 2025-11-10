import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  /// 🔹 Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('users')
        .select()
        .eq('auth_id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// 🔹 Cập nhật thông tin người dùng (tên, điện thoại, địa chỉ,...)
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await supabase
        .from('users')
        .update(data)
        .eq('auth_id', user.id)
        .select()
        .maybeSingle();

    return response != null;
  }

  /// 🔹 Upload ảnh đại diện (Supabase Storage) — CHỐNG CACHE
  Future<String?> uploadAvatar(String filePath) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // ✅ Đặt tên file có timestamp để Supabase không cache ảnh cũ
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'avatar_${user.id}_$timestamp.jpg';
    final file = File(filePath);

    // ⚙️ Upload file mới (ghi đè nếu trùng)
    await supabase.storage
        .from('avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    // 🔗 Lấy URL public
    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

    // ✅ Cập nhật URL mới vào users.profile_image
    await supabase.from('users').update({
      'profile_image': publicUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('auth_id', user.id);

    return publicUrl;
  }
}

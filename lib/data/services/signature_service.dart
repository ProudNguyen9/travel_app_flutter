import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignatureService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadSignature(Uint8List bytes) async {
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      print("❌ Not logged in");
      return null;
    }

    final authId = authUser.id;

    // 📌 Lấy user_id từ bảng users
    final row = await supabase
        .from('users')
        .select('user_id')
        .eq('auth_id', authId)
        .maybeSingle();

    if (row == null) {
      print("❌ No row found for auth_id $authId");
      return null;
    }

    final int userId = row['user_id'];

    final filePath = "sig_$userId.png";

    try {
      await supabase.storage.from('signatures').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              contentType: "image/png",
              upsert: true,
            ),
          );

      final url =
          supabase.storage.from('signatures').getPublicUrl(filePath);

      await supabase
          .from('users')
          .update({'signature_url': url})
          .eq('user_id', userId);

      return url;
    } catch (e) {
      print("❌ Upload signature error: $e");
      return null;
    }
  }
}

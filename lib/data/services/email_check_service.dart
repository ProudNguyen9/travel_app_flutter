import 'package:supabase_flutter/supabase_flutter.dart';

class EmailCheckService {
  static final client = Supabase.instance.client;

  static Future<bool> exists(String email) async {
    final res = await client.rpc('check_email_exists', params: {'e': email});
    return res == true;
  }
}

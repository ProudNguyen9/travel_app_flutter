import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  final supabase = Supabase.instance.client;

  Future<void> _resetPassword() async {
    if (newPassCtrl.text.trim().isEmpty || confirmCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng nhập đầy đủ thông tin.")),
      );
      return;
    }

    if (newPassCtrl.text.trim() != confirmCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Mật khẩu nhập lại không khớp.")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassCtrl.text.trim()),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Đổi mật khẩu thành công! Hãy đăng nhập lại."),
          backgroundColor: Colors.green,
        ),
      );

      // Quay về màn Login và xóa lịch sử back
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi đổi mật khẩu: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text("Đặt lại mật khẩu",
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text("Nhập mật khẩu mới cho tài khoản của bạn.",
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: const Color(0xFF7D848D))),
              const SizedBox(height: 40),

              // Mật khẩu mới
              TextField(
                controller: newPassCtrl,
                obscureText: obscure1,
                decoration: InputDecoration(
                  hintText: "Mật khẩu mới",
                  filled: true,
                  fillColor: const Color(0xFFF7F7F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure1 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscure1 = !obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Nhập lại mật khẩu
              TextField(
                controller: confirmCtrl,
                obscureText: obscure2,
                decoration: InputDecoration(
                  hintText: "Nhập lại mật khẩu",
                  filled: true,
                  fillColor: const Color(0xFFF7F7F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure2 ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscure2 = !obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24BAEC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Xác nhận",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

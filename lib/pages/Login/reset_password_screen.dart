import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/pages/screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  final supabase = Supabase.instance.client;

  // ==== VALIDATOR MẬT KHẨU MẠNH ====
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Vui lòng nhập mật khẩu";
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      return "Mật khẩu phải gồm:\n"
          "- Chữ hoa (A–Z)\n"
          "- Chữ thường (a–z)\n"
          "- Số (0–9)\n"
          "- Ký tự đặc biệt (@, #, !, ...)\n"
          "- Tối thiểu 8 ký tự";
    }

    return null;
  }

  Future<void> _resetPassword() async {
    if (!formKey.currentState!.validate()) return;

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "Đặt lại mật khẩu",
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Nhập mật khẩu mới cho tài khoản của bạn.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: const Color(0xFF7D848D)),
                  ),
                  const SizedBox(height: 40),

                  // ====== PASSWORD ======
                  TextFormField(
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: passwordValidator,
                  ),

                  const SizedBox(height: 18),

                  // ====== CONFIRM PASSWORD ======
                  TextFormField(
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập lại mật khẩu";
                      }
                      if (value.trim() != newPassCtrl.text.trim()) {
                        return "Mật khẩu nhập lại không khớp";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      // Nút BACK (Outlined)
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF24BAEC), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                              ),
                            ),
                            child: const Text(
                              "Quay lại",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF24BAEC),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Nút XÁC NHẬN (Elevated)
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: loading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF24BAEC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34),
                              ),
                            ),
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Xác nhận",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

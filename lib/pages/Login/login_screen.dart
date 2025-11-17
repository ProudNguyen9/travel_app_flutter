import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';

import '../../widget/widget.dart';
import '../screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscureText = true;
  bool loading = false;

  final supabase = Supabase.instance.client;

  // Email login
  Future<void> _signInWithEmail() async {
    setState(() => loading = true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (res.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập thành công!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SimpleBottomScaffold(),
          ),
        );
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      String error = "Đã xảy ra lỗi. Vui lòng thử lại.";

      if (msg.contains("invalid login credentials")) {
        error = "Email hoặc mật khẩu không đúng";
      } else if (msg.contains("email not confirmed")) {
        error = "Email chưa được xác thực. Vui lòng kiểm tra hộp thư đến.";
      } else if (msg.contains("user not found")) {
        error = "Tài khoản không tồn tại";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text("Đăng nhập ngay ",
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Vui lòng đăng nhập để sử dụng ứng dụng.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: const Color(0xFF7D848D)),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailCtrl,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập email";
                    }
                    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return "Email không hợp lệ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passCtrl,
                  obscureText: obscureText,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => obscureText = !obscureText),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập mật khẩu";
                    }

                    // Regex kiểm tra độ mạnh của mật khẩu
                    final passwordRegex = RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$',
                    );

                    if (!passwordRegex.hasMatch(value)) {
                      return "Mật khẩu phải gồm:\n- Chữ hoa (A–Z)\n- Chữ thường (a–z)\n- Số (0–9)\n- Ký tự đặc biệt (@, #, !, ...)\n- Tối thiểu 8 ký tự";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotpasswordScreen()));
                    },
                    child: Text(
                      "Quên mật khẩu ?",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontSize: 14, // tương đương 14.sp
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF7029),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: loading ? null : _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24BAEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Đăng nhập",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Chưa có tài khoản? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
                      },
                      child: Text(
                        "Đăng ký",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF7029),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Hoặc kết nối với",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                const Gap(10),
                Image.asset(
                  "assets/images/imglogin.png",
                  width: 150,
                  height: 150,
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialIcon(
                      path: "assets/icons/facebook.svg",
                      ontap: () async {
                        try {
                          await Supabase.instance.client.auth.signInWithOAuth(
                            OAuthProvider.facebook,
                            redirectTo: 'travelapp://login-callback',
                            authScreenLaunchMode:
                                LaunchMode.externalApplication,
                          );

                          final session =
                              Supabase.instance.client.auth.currentSession;

                          if (session != null) {
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SimpleBottomScaffold(),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint("Facebook login error: $e");
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Lỗi đăng nhập Facebook: $e"),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    SocialIcon(
                        path: "assets/icons/google.svg",
                        ontap: () async {
                          await context.read<AuthProvider>().googleSignIn();

                          // Nếu muốn kiểm tra login thành công
                          final session =
                              Supabase.instance.client.auth.currentSession;
                          if (session != null) {
                            // Chuyển sang trang khác
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SimpleBottomScaffold()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Đăng nhập thất bại')),
                            );
                          }
                        }),
                    const SizedBox(width: 10),
                    SocialIcon(
                      path: "assets/icons/X.svg",
                      ontap: () async {
                        try {
                          await Supabase.instance.client.auth.signInWithOAuth(
                            OAuthProvider.twitter,
                            redirectTo: 'travelapp://login-callback',
                            authScreenLaunchMode:
                                LaunchMode.externalApplication,
                          );

                          // Lấy session
                          final session =
                              Supabase.instance.client.auth.currentSession;

                          if (session != null) {
                            // Điều hướng sang màn hình Welcome
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SimpleBottomScaffold()),
                            );
                          }
                        } catch (e) {
                          debugPrint("Twitter login error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Lỗi đăng nhập Twitter: $e")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/pages/welcome_page.dart';

import '../../widget/widget.dart';
import '../screen.dart';

class ForgotpasswordScreen extends StatefulWidget {
  const ForgotpasswordScreen({super.key});

  @override
  State<ForgotpasswordScreen> createState() => _ForgotpasswordScreenState();
}

class _ForgotpasswordScreenState extends State<ForgotpasswordScreen> {
  final emailCtrl = TextEditingController();
  bool obscureText = true;
  bool loading = false;

  final supabase = Supabase.instance.client;
  // Email forgot
  Future<void> _SendEmailForgot() async {
    setState(() => loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final msg = await auth.sendForgotPasswordEmail(emailCtrl.text.trim());

      if (msg == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "✅ Đã gửi email đặt lại mật khẩu! Hãy kiểm tra hộp thư của bạn.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $msg"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                Text("Quên mật khẩu",
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Hãy nhập địa chỉ email của bạn để đặt lại mật khẩu.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: const Color(0xFF7D848D)),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    hintText: "Nhập Email của bạn ....",
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    // Nút BACK dạng viền
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
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

                    // Nút QUÊN MẬT KHẨU (giữ nguyên)
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _SendEmailForgot,
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
                                  "Quên mật khẩu",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Gap(10),
                Image.asset(
                  "assets/images/imgforgot.png",
                  width: 250,
                  height: 300,
                  fit: BoxFit.contain,
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

                          //  get secsion
                          final session =
                              Supabase.instance.client.auth.currentSession;

                          if (session != null) {
                            //  go to page welcaom
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WelcomePage()),
                            );
                          }
                        } catch (e) {
                          debugPrint("Facebook login error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Lỗi đăng nhập Facebook: $e")),
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
                                    builder: (context) => const WelcomePage()));
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
                                  builder: (context) => const WelcomePage()),
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

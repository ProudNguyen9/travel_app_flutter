import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/pages/Login/login_screen.dart';
import 'package:travel_app/pages/home_screen.dart';
import 'package:travel_app/widget/icon.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscureText = true;
  bool loading = false;
  String message = "";

  Future<void> _signUp() async {
    setState(() => loading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        emailRedirectTo: 'travelapp://login-callback',
        data: {
          'full_name': nameCtrl.text.trim(),
        },
      );

      if (res.user != null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Đăng ký thành công! Vui lòng kiểm tra email để xác nhận."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // Title
                Center(
                  child: Text(
                    "Đăng ký ngày ",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vui lòng điền thông tin và tạo tài khoản.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF7D848D),
                  ),
                ),

                const SizedBox(height: 30),

                // Full Name
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Họ và tên ",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                  ),
                ),

                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passCtrl,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "  Mật khẩu phải bao gồm đủ 8 kí tự",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF7D848D),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24BAEC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(34),
                      ),
                    ),
                    onPressed: loading ? null : _signUp,
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Đăng ký",
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have account -> Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Đã có tài khoản ? ",
                      style: TextStyle(color: Color(0xFF707B81)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "Đăng nhập",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF7029),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Hoặc kết nối với",
                    style:
                        GoogleFonts.poppins(color: (const Color(0xFF707B81))),
                  ),
                ),

                const Gap(5),
                Center(
                  child: Image.asset(
                    "assets/images/imgsign.png",
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const Gap(5),
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
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          }
                        } catch (e) {
                          debugPrint("Facebook login error: $e");
                          // ignore: use_build_context_synchronously
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

                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()));
                          } else {
                            // ignore: use_build_context_synchronously
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
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          }
                        } catch (e) {
                          debugPrint("Twitter login error: $e");
                          // ignore: use_build_context_synchronously
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

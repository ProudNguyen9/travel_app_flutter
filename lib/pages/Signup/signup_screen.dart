import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/data/services/email_check_service.dart';
import 'package:travel_app/pages/Login/login_screen.dart';
import 'package:travel_app/pages/home_screen.dart';
import 'package:travel_app/widget/icon.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscureText = true;
  bool loading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    final email = emailCtrl.text.trim();
    final fullName = nameCtrl.text.trim();
    final password = passCtrl.text.trim();

    // ⭐ KIỂM TRA EMAIL TRƯỚC KHI TẠO TÀI KHOẢN
    final exists = await EmailCheckService.exists(email);
    if (exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email đã tồn tại. Vui lòng dùng email khác."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => loading = false);
      return; // ⛔ DỪNG TẠI ĐÂY — KHÔNG SIGN UP!!
    }

    try {
      // Không tồn tại → cho đăng ký
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'travelapp://login-callback',
        data: {'full_name': fullName},
      );

      final user = res.user;

      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'full_name': fullName}),
        );

        if (!mounted) return;

        // Thông báo đăng ký thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công! Kiểm tra email để kích hoạt."),
            backgroundColor: Colors.green,
          ),
        );

        // Điều hướng bằng push (không dùng tên route)
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const LoginScreen()), // đổi LoginScreen nếu tên khác
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Lỗi: ${e.message}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  // Title
                  Center(
                    child: Text(
                      "Đăng ký ngay",
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
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: "Họ và tên",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập họ tên";
                      }
                      if (value.trim().length < 3) {
                        return "Họ tên quá ngắn";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
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

                  // Password
                  TextFormField(
                    controller: passCtrl,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      hintText: "Mật khẩu",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
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
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Already have account -> Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Đã có tài khoản? ",
                        style: TextStyle(color: Color(0xFF707B81)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
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
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF707B81),
                      ),
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

                  // Social Login
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
                                  builder: (context) => const HomeScreen(),
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

                          final session =
                              Supabase.instance.client.auth.currentSession;
                          if (session != null) {
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đăng nhập thất bại'),
                              ),
                            );
                          }
                        },
                      ),
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

                            final session =
                                Supabase.instance.client.auth.currentSession;

                            if (session != null) {
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("Twitter login error: $e");
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Lỗi đăng nhập Twitter: $e"),
                              ),
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
      ),
    );
  }
}

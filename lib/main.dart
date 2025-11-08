import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/pages/screen.dart';
import 'package:travel_app/pages/welcome_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Supabase.initialize(
    url: 'https://yszeuemcqrydkfbhvdhj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzemV1ZW1jcXJ5ZGtmYmh2ZGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyMDIwMTksImV4cCI6MjA3NDc3ODAxOX0.2b1l53MlZoC600ApWemncNNgFnomwaRTSYdWBYqrweo',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;

    // 1) Người dùng bấm link RESET PASSWORD gửi từ email
    if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => false,
      );
      return;
    }

    // 2) Người dùng mới xác thực email đăng ký → session != null
    if (event == AuthChangeEvent.signedIn && session != null) {
      final user = session.user;

      // Đây là dấu hiệu: vừa xác thực email xong (login lần đầu)
      final isFirstTimeVerified = user.lastSignInAt == user.createdAt;

      if (isFirstTimeVerified) {
        // Đăng nhập tự động sau xác thực → ta signOut để đưa về login
        await Supabase.instance.client.auth.signOut();

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text("🎉 Email đã xác thực thành công! Đăng nhập nào 💛"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Travel App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const WelcomePage(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

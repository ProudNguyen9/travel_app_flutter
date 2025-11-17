import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/pages/home_screen.dart';
import 'package:travel_app/pages/screen.dart';
import 'package:travel_app/widget/nav_bottom.dart'; // 👈 thêm file này nếu chưa

// ====== Global Navigator ======
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _isRouting = false;

void _go(String route) {
  if (_isRouting) return;
  _isRouting = true;

  navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (r) => false);

  Future.delayed(const Duration(milliseconds: 300), () => _isRouting = false);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await initializeDateFormatting('vi_VN', null);

  // ====== Stripe ======
  Stripe.publishableKey =
      "pk_test_51STjqjJgtg1GbjTThFaNnlOcFFiSgHgdzGnPusCfrlin0ZcyHwejs6LBplGFy8sFCZ8Q8AD7GTs4JizketnJRzZ800P4dN8sgy";
  await Stripe.instance.applySettings();

  // ====== Supabase ======
  await Supabase.initialize(
    url: 'https://yszeuemcqrydkfbhvdhj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzemV1ZW1jcXJ5ZGtmYmh2ZGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyMDIwMTksImV4cCI6MjA3NDc3ODAxOX0.2b1l53MlZoC600ApWemncNNgFnomwaRTSYdWBYqrweo',
  );

  // ====== AUTH LISTENER ======
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    final session = data.session;

    // --- RESET PASSWORD ---
    if (event == AuthChangeEvent.passwordRecovery) {
      _go('/reset-password');
      return;
    }

    // --- SIGNED IN ---
    if (event == AuthChangeEvent.signedIn && session != null) {
      final user = session.user;
      final provider =
          user.appMetadata["provider"]; // email / google / facebook

      // ——— OAUTH Login (Facebook / Google) → vào SimpleScaffold ———
      if (provider != "email") {
        _go('/simple');
        return;
      }

      // ——— Email/password: xử lý verify lần đầu ———
      final isFirstTimeVerified = user.lastSignInAt == user.createdAt;

      if (isFirstTimeVerified) {
        await Supabase.instance.client.auth.signOut();
        _go('/login');

        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content:
                  Text("🎉 Email đã xác thực thành công! Đăng nhập lại nhé 💛"),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // Email login bình thường → vào SimpleScaffold
      _go('/simple');
      return;
    }

    // --- SIGNED OUT ---
    if (event == AuthChangeEvent.signedOut) {
      _go('/login');
      return;
    }
  });

  // ====== RUN APP ======
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
      debugShowCheckedModeBanner: false,
      title: 'Travel App',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/simple': (context) => const SimpleBottomScaffold(), // 👈 route mới
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

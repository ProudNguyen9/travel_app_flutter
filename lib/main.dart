import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/authenticaion/auth_provider.dart';
import 'package:travel_app/pages/home_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yszeuemcqrydkfbhvdhj.supabase.co', 
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlzemV1ZW1jcXJ5ZGtmYmh2ZGhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyMDIwMTksImV4cCI6MjA3NDc3ODAxOX0.2b1l53MlZoC600ApWemncNNgFnomwaRTSYdWBYqrweo',
  );

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
    return const MaterialApp(
      title: 'Flutter Travel App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

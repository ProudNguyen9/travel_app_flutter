import 'package:flutter/material.dart';
import 'package:flutter_zalopay_sdk/flutter_zalopay_sdk.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class TestZaloPayPage extends StatefulWidget {
  const TestZaloPayPage({super.key});

  @override
  State<TestZaloPayPage> createState() => _TestZaloPayPageState();
}

class _TestZaloPayPageState extends State<TestZaloPayPage> {
  String status = "Bấm nút để test ZaloPay 10.000đ";

  // URL hàm Supabase Function của bạn
  final String functionUrl =
      "https://yszeuemcqrydkfbhvdhj.supabase.co/functions/v1/create_zalopay_order";

  Future<void> _pay() async {
    setState(() => status = "Đang tạo hóa đơn…");

    try {
      // 1. Lấy Supabase access token
      final session = Supabase.instance.client.auth.currentSession;

      if (session == null) {
        setState(() => status = "Bạn chưa đăng nhập Supabase!");
        return;
      }

      final accessToken = session.accessToken;

      // 2. JSON body cần gửi lên function
      final body = jsonEncode({
        "amount": 10000, // SỐ TIỀN TEST
        "app_user": "user_${session.user.id}", // tuỳ bạn
        "description": "Test thanh toán 10k" // mô tả đơn
      });

      // 3. Gọi Supabase Edge Function → tạo order
      final res = await http.post(
        Uri.parse(functionUrl),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (res.statusCode != 200) {
        setState(() => status = "Lỗi Supabase: ${res.body}");
        return;
      }

      final data = jsonDecode(res.body);

      final zpToken = data["zp_trans_token"];
      if (zpToken == null) {
        setState(() => status = "Không có zp_trans_token: ${res.body}");
        return;
      }

      // 4. Mở ZaloPay để thanh toán
      setState(() => status = "Đang mở ZaloPay…");

      final result = await FlutterZaloPaySdk.payOrder(zpToken: zpToken);

      switch (result) {
        case FlutterZaloPayStatus.success:
          setState(() => status = "🎉 Thanh toán thành công!");
          break;
        case FlutterZaloPayStatus.cancelled:
          setState(() => status = "❌ Bạn đã hủy giao dịch");
          break;
        case FlutterZaloPayStatus.failed:
          setState(() => status = "⚠️ Thanh toán thất bại");
          break;
        default:
          setState(() => status = "⏳ Đang xử lý…");
      }
    } catch (e) {
      setState(() => status = "❗ Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test ZaloPay 10k")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pay,
                child: const Text("Thanh toán 10.000đ"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

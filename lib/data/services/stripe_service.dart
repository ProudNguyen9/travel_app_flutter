import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Thanh toán bằng Stripe PaymentSheet
  static Future<bool> pay({
    required int amount,
    String currency = "vnd",
  }) async {
    try {
      // 1. Gọi Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
        },
      );

      // ---------------------------
      // FIX: response.data là String
      // ---------------------------
      final raw = response.data;
      final json = jsonDecode(raw);

      if (json["clientSecret"] == null) {
        throw Exception("Không nhận được clientSecret từ server");
      }

      final clientSecret = json["clientSecret"];

      // 2. Init PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: "Travel App",
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
        ),
      );

      // 3. Present Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      print("Lỗi thanh toán: $e");
      return false;
    }
  }
}

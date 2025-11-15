import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContractService {
  final supabase = Supabase.instance.client;

  /// Upload PDF hợp đồng lên Storage
  Future<String?> uploadContractPdf({
    required Uint8List pdfBytes,
    required int bookingId,
  }) async {
    final filePath = "contract_${bookingId}.pdf";

    try {
      await supabase.storage.from("contracts").uploadBinary(
            filePath,
            pdfBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: "application/pdf",
            ),
          );

      return supabase.storage
          .from("contracts")
          .getPublicUrl(filePath);
    } catch (e) {
      print("❌ Upload PDF Error: $e");
      return null;
    }
  }

  /// Tạo 1 record trong bảng contracts
  Future<bool> createContractRecord({
    required int bookingId,
    required String pdfUrl,
    required String? signatureUrl,
  }) async {
    try {
      final code = "HD-${DateTime.now().millisecondsSinceEpoch}";

      final response = await supabase.from("contracts").insert({
        "booking_id": bookingId,
        "contract_code": code,
        "signed_date": DateTime.now().toIso8601String(),
        "effective_date": DateTime.now().toIso8601String(),
        "expiry_date": DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        "status": "signed",
        "pdf_url": pdfUrl,
        "signature_image_url": signatureUrl,
      });

      print("📄 Contract record created: $response");
      return true;
    } catch (e) {
      print("❌ Insert Contract Error: $e");
      return false;
    }
  }
}

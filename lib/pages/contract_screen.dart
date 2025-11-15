import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/data/models/booking.dart';
import 'package:travel_app/data/models/user_model.dart';
import 'package:travel_app/data/services/contract_service.dart';
import 'package:travel_app/data/services/signature_service.dart';
import 'package:travel_app/pages/screen.dart';
import 'package:travel_app/pages/signature_pad_screen.dart';

/// ===================================================================
/// TÌM TEXTBOX FIELD THEO TÊN TRONG PDF (DÙNG CHO CÁC Ô TEXT)
/// ===================================================================
PdfTextBoxField? getFieldByName(PdfForm form, String name) {
  for (var i = 0; i < form.fields.count; i++) {
    final field = form.fields[i];
    if (field is PdfTextBoxField && field.name == name) {
      return field;
    }
  }
  return null;
}

/// ===================================================================
/// TÌM SIGNATURE FIELD THEO TÊN TRONG PDF (DÙNG CHO Ô KÝ TÊN)
/// ===================================================================
PdfSignatureField? getSignatureFieldByName(PdfForm form, String name) {
  for (var i = 0; i < form.fields.count; i++) {
    final field = form.fields[i];
    if (field is PdfSignatureField && field.name == name) {
      return field;
    }
  }
  return null;
}

/// ===================================================================
/// SET VALUE + STYLE CHO MỘT FIELD TEXT
/// ===================================================================
void setField(
  PdfForm form,
  String name,
  String value,
  PdfFont font,
) {
  final field = getFieldByName(form, name);
  if (field == null) {
    print("⚠ Field '$name' không tồn tại (TextBox)");
    return;
  }

  field.font = font;
  field.text = value;
  field.backColor = PdfColor(255, 255, 255);
  field.borderWidth = 0;
  field.borderColor = PdfColor(255, 255, 255);
  field.textAlignment = PdfTextAlignment.left;
}

/// ===================================================================
/// FIX PNG TRANSPARENT → PNG NỀN TRẮNG
/// ===================================================================
Future<Uint8List> fixSignature(Uint8List pngBytes) async {
  final codec = await ui.instantiateImageCodec(pngBytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // nền trắng
  final paint = Paint()..color = Colors.white;
  canvas.drawRect(
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    paint,
  );

  // vẽ chữ ký lên trên
  canvas.drawImage(image, Offset.zero, Paint());

  final picture = recorder.endRecording();
  final img = await picture.toImage(image.width, image.height);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

/// ===================================================================
/// HÀM CHÍNH: TẠO HỢP ĐỒNG (CÓ THỂ KÈM HOẶC KHÔNG KÈM CHỮ KÝ)
/// ===================================================================
Future<File> generateContractPdf({
  required Booking booking,
  required UserModel user,
  required String tourName,
  Uint8List? signatureBytes, // null = chưa ký, != null = có chữ ký
}) async {
  // 1. Load template PDF gốc
  final data = await rootBundle.load("assets/docx/contract.pdf");
  final bytes = data.buffer.asUint8List();
  final document = PdfDocument(inputBytes: bytes);
  final form = document.form;

  // 2. Font
  final fontData = await rootBundle.load("assets/docx/TIMES.TTF");
  final fontBytes = fontData.buffer.asUint8List();
  final timesFont = PdfTrueTypeFont(fontBytes, 12);

  // 3. Định dạng
  final fmtDate = DateFormat("dd/MM/yyyy");
  final fmtMoney =
      NumberFormat.currency(locale: "vi_VN", symbol: "₫", decimalDigits: 0);
  final now = DateTime.now();

  // 4. Fill thông tin khách
  setField(form, "customer_name", user.name ?? "", timesFont);
  setField(form, "customer_address", user.address ?? "", timesFont);
  setField(form, "customer_phone", user.phone ?? "", timesFont);
  setField(form, "customer_email", user.email ?? "", timesFont);

  // 5. Tour + ngày đi
  setField(form, "tour_name", tourName, timesFont);
  setField(
    form,
    "start_date",
    booking.startDate != null ? fmtDate.format(booking.startDate!) : "",
    timesFont,
  );
  setField(
    form,
    "end_date",
    booking.endDate != null ? fmtDate.format(booking.endDate!) : "",
    timesFont,
  );

  // 6. Số lượng người
  setField(form, "adult_count", "${booking.adultCount}", timesFont);
  setField(form, "elderly_count", "${booking.elderlyCount}", timesFont);
  setField(form, "child_count", "${booking.childCount}", timesFont);

  // 7. Giá & tổng
  setField(form, "adult_price", fmtMoney.format(booking.adultPrice), timesFont);
  setField(
    form,
    "adult_total",
    fmtMoney.format(booking.adultPrice * booking.adultCount),
    timesFont,
  );

  setField(
    form,
    "elderly_price",
    fmtMoney.format(booking.elderlyPrice),
    timesFont,
  );
  setField(
    form,
    "elderly_total",
    fmtMoney.format(booking.elderlyPrice * booking.elderlyCount),
    timesFont,
  );

  setField(form, "child_price", fmtMoney.format(booking.childPrice), timesFont);
  setField(
    form,
    "child_total",
    fmtMoney.format(booking.childPrice * booking.childCount),
    timesFont,
  );

  setField(
    form,
    "discount_amount",
    fmtMoney.format(booking.discountAmount),
    timesFont,
  );
  setField(
    form,
    "price_after_discount",
    fmtMoney.format(booking.finalAmount),
    timesFont,
  );

  setField(
    form,
    "vat_amount",
    fmtMoney.format(booking.taxAmount),
    timesFont,
  );
  setField(
    form,
    "grand_total",
    fmtMoney.format(booking.finalAmount),
    timesFont,
  );

  // 8. Ngày ký
  setField(form, "sign_day", "${now.day}", timesFont);
  setField(form, "sign_month", "${now.month}", timesFont);
  setField(form, "sign_year", "${now.year}", timesFont);

  // 9. Nếu có chữ ký → chèn vào đúng ô SignatureField
  if (signatureBytes != null) {
    final fixedSignature = await fixSignature(signatureBytes);
    final image = PdfBitmap(fixedSignature);

    // Lấy field TextBox chứa vị trí ký
    final sigField = getFieldByName(form, "signature_field");

    if (sigField != null) {
      final bounds = sigField.bounds;
      final page = sigField.page ?? document.pages[document.pages.count - 1];

      // Xóa field trước (để không đè lên chữ)
      form.fields.remove(sigField);

      // ⭐ Tính tọa độ PDF (PDF: gốc ở BOTTOM-LEFT)
      final double x = bounds.left;
      final double y = page.size.height - bounds.top - bounds.height;

      // Nếu cần chỉnh lên 5 px → tránh bị thấp
      final double adjustedY = y - 51;

      print("=== Signature Placement ===");
      print("x=$x, y=$y, adjustedY=$adjustedY");
      print("w=${bounds.width}, h=${bounds.height}");

      // ⭐ Vẽ ảnh chữ ký vào đúng vị trí (không lệch)
      page.graphics.drawImage(
        image,
        Rect.fromLTWH(
          x,
          adjustedY,
          bounds.width,
          bounds.height,
        ),
      );
    } else {
      print("⚠ Không tìm thấy signature_field → fallback");
      final fallbackPage = document.pages[document.pages.count - 1];
      fallbackPage.graphics.drawImage(
        image,
        Rect.fromLTWH(120, fallbackPage.size.height - 280, 150, 80),
      );
    }
  }

  // 10. Flatten toàn bộ form sau khi fill (và có thể đã ký)
  document.form.flattenAllFields();

  final newBytes = await document.save();
  document.dispose();

  final dir = await getTemporaryDirectory();
  final suffix = signatureBytes == null ? "filled" : "signed";
  final file = File("${dir.path}/contract_$suffix.pdf");
  await file.writeAsBytes(newBytes);

  return file;
}

/// ===================================================================
/// FULL VIEWER
/// ===================================================================
class ContractPdfViewer extends StatelessWidget {
  final File pdfFile;
  final Booking booking;
  final UserModel user;
  final String tourName;
  const ContractPdfViewer({
    super.key,
    required this.pdfFile,
    required this.booking,
    required this.user,
    required this.tourName,
  });

  @override
  Widget build(BuildContext context) {
    String pdfurl = "";

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Nút tiếp tục chỉ hiện nếu pdf đã có chữ ký
          if (pdfFile.path.contains("signed"))
            FloatingActionButton.extended(
              backgroundColor: const Color(0xFF24BAEC),
              elevation: 4,
              heroTag: "fab-continue",
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Tiếp tục',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.white, width: 1.2),
              ),
              onPressed: () async {
                final pdfBytes = await pdfFile.readAsBytes();

                /// 1. Upload PDF lên Supabase Storage
                final contractService = ContractService();
                final String? pdfUrl = await contractService.uploadContractPdf(
                  pdfBytes: pdfBytes,
                  bookingId: booking.bookingId!,
                );
                pdfurl = pdfUrl!;

                /// 2. Insert vào DB bảng contracts
                final ok = await contractService.createContractRecord(
                  bookingId: booking.bookingId!,
                  pdfUrl: pdfUrl,
                  signatureUrl: user.signatureUrl, // chữ ký đã upload trước
                );

                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("❌ Lỗi tạo contract trong database")),
                  );
                  return;
                }

                /// 3. Chuyển sang bước chọn phương thức thanh toán
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChooseMethodPayScreen(
                      booking: booking,
                      user: user,
                      pdfurl: pdfurl,
                    ),
                  ),
                );
              },
            ),
          const Gap(10),
          FloatingActionButton.extended(
            backgroundColor: const Color(0xFF24BAEC),
            icon: const Icon(Icons.border_color_rounded, color: Colors.white),
            label: Text(
              // Nếu user có chữ ký và file pdf đã được chèn chữ ký
              (user.signatureUrl != null && pdfFile.path.contains("signed"))
                  ? "Thay đổi chữ ký"
                  : "Ký hợp đồng",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.white, width: 1.2),
            ),
            onPressed: () async {
              Uint8List? oldSig;

              // Nếu user đã có chữ ký -> load preview
              if (user.signatureUrl != null && user.signatureUrl!.isNotEmpty) {
                final res = await http.get(Uri.parse(user.signatureUrl!));
                if (res.statusCode == 200) {
                  oldSig = res.bodyBytes;
                }
              }

              // ⬅ Mở pad + truyền chữ ký cũ (để preview)
              final Uint8List? newSig = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignaturePad(
                    oldSignature: oldSig, // <-- nếu có sẽ preview
                  ),
                ),
              );

              if (newSig == null) return;

              // Upload chữ ký mới
              final url = await SignatureService().uploadSignature(newSig);
              if (url != null) {
                user.signatureUrl = url;
              }

              // Tạo pdf đã ký
              final signed = await generateContractPdf(
                booking: booking,
                user: user,
                tourName: tourName,
                signatureBytes: newSig,
              );

              // reload PDF
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ContractPdfViewer(
                    pdfFile: signed,
                    booking: booking,
                    user: user,
                    tourName: tourName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "       Hợp Đồng Du Lịch",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SfPdfViewer.file(pdfFile),
    );
  }
}

/// ===================================================================
/// MỞ PDF HỢP ĐỒNG (CHƯA KÝ)
/// ===================================================================
Future<void> showContractPdf(
  BuildContext context, {
  required Booking booking,
  required UserModel user,
  required String tourName,
}) async {
  final pdfFile = await generateContractPdf(
    booking: booking,
    user: user,
    tourName: tourName,
    signatureBytes: null, // <-- luôn là null
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ContractPdfViewer(
        pdfFile: pdfFile,
        booking: booking,
        user: user,
        tourName: tourName,
      ),
    ),
  );
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

class SignaturePad extends StatefulWidget {
  final Uint8List? oldSignature; // <-- chữ ký cũ (nếu có)

  const SignaturePad({super.key, this.oldSignature});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final HandSignatureControl control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  @override
  void initState() {
    super.initState();
  }

  bool get hasOldSignature => widget.oldSignature != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Ký tên"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Nếu có chữ ký cũ → preview lên
          if (hasOldSignature)
            Column(
              children: [
                const Text(
                  "Chữ ký đã lưu",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.memory(widget.oldSignature!),
                ),
                const SizedBox(height: 16),

                // Nút Sử dụng chữ ký cũ
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, widget.oldSignature!);
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Dùng chữ ký đã lưu",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24BAEC),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text("Hoặc ký lại bên dưới:",
                    style: TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
              ],
            ),

          // Vùng ký
          SizedBox(
            height: 300,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HandSignature(
                control: control,
                color: Colors.black,
                width: 2.5,
                maxWidth: 5.0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            // Xóa
              ElevatedButton.icon(
                onPressed: () => control.clear(),
                icon: const Icon(Icons.refresh, color: Colors.black54),
                label: const Text("Xóa", style: TextStyle(color: Colors.black87)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDEDED),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              // Trả về chữ ký mới
              ElevatedButton.icon(
                onPressed: () async {
                  final img = await control.toImage();
                  if (img == null) return;

                  Navigator.pop(context, img.buffer.asUint8List());
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  "Lưu chữ ký mới",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24BAEC),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

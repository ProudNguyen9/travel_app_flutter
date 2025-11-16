import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String day; // ví dụ: "Ngày 1"
  final String date; // ví dụ: "06/11/2025"
  final VoidCallback? onTap;

  const LocationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.day,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 240,
          height: 118,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(230, 255, 255, 255),
                Color.fromARGB(160, 255, 255, 255),
                Color.fromARGB(90, 255, 255, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ HÌNH ẢNH (GIỮ NGUYÊN SIZE, CHỈ THAY LOAD)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 89,
                  height: 94,
                  child: imagePath.startsWith("http")
                      ? Image.network(
                          imagePath,
                          width: 89,
                          height: 94,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              "assets/images/default.png",
                              fit: BoxFit.cover),
                        )
                      : Image.asset(
                          imagePath,
                          width: 89,
                          height: 94,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              const SizedBox(width: 10),

              // ⭐ GIỮ Y NGUYÊN LAYOUT BÊN PHẢI – CHỈ THÊM FIX OVERFLOW
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ⭐ NGĂN OVERFLOW DỌC
                  children: [
                    Text(
                      day,
                      style: GoogleFonts.lato(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    Text(
                      date,
                      style: GoogleFonts.lato(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // ⭐ TÊN ĐỊA ĐIỂM – THÊM GIỚI HẠN
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Chi tiết – giữ nguyên
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Chi tiết',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

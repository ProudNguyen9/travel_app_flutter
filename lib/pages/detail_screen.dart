import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const primary = Color(0xFF24BAEC);

  // TODO: đổi thành ảnh của bạn
  final List<String> _images = [
    'assets/images/dongnai.jpg',
    'assets/images/nhatrang.jpg',
    'assets/images/hue.jpg',
    'assets/images/anh-da-lat.jpg',
    'assets/images/dongnai.jpg',
  ];

  int _selectedIndex = 0;

  TextStyle lato(double s,
          {FontWeight w = FontWeight.w400,
          Color c = const Color(0xFF151111),
          double? h}) =>
      GoogleFonts.lato(fontSize: s, fontWeight: w, color: c, height: h);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double imageWidth = size.width - 32;
    final double imageHeight = size.height * 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            Text('Chi tiết', style: lato(18, h: 26 / 18, w: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== ẢNH LỚN (đổi theo thumbnail) ====
              Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primary, width: 2),
                  image: DecorationImage(
                    image: AssetImage(_images[_selectedIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ==== TIỆN ÍCH + RATING ====
              Row(
                children: [
                  _amenity(icon: Icons.wifi, text: 'Miễn phí Wifi'),
                  const SizedBox(width: 18),
                  _amenity(
                      icon: Icons.free_breakfast, text: 'Miễn phí ăn sáng'),
                  const Spacer(),
                  Text('5.0',
                      style: lato(14, w: FontWeight.w600, c: Colors.black87)),
                  const Gap(5),
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFC107), size: 22),
                ],
              ),
              const SizedBox(height: 12),

              // ==== TIÊU ĐỀ ====
              Row(
                children: [
                  Expanded(
                      child: Text('Vũng Tàu',
                          style:
                              lato(22, w: FontWeight.w600, c: Colors.black))),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16, color: primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bãi Sau, Bà Rịa – Vũng Tàu',
                      style: lato(13.5, c: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Text('Mô tả',
                      style: lato(16, w: FontWeight.w700, c: primary)),
                  const Spacer(),
                  Text('400.000VND/người',
                      style: lato(16, w: FontWeight.w700, c: Colors.black87)),
                ],
              ),
              const SizedBox(height: 10),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Each of the 26 houses is a suite with separate living and bedrooms, as well as personal butler, private pool and ocean views. In every house guests can enjoy free wifi, complimentary water, tea, coffee and soft drinks, bottle of champagne on arrival ',
                      style: lato(14, c: Colors.black54, h: 1.5),
                    ),
                    TextSpan(
                        text: 'Đọc thêm',
                        style: lato(13, w: FontWeight.w700, c: primary)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==== PHOTOS HEADER ====
              Row(
                children: [
                  Text('Hình ảnh',
                      style: lato(16, w: FontWeight.w700, c: primary)),
                ],
              ),
              const SizedBox(height: 10),

              // ==== DÃY ẢNH (chọn -> đổi ảnh lớn) ====
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final active = i == _selectedIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: active ? primary : Colors.transparent,
                              width: 2),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: primary.withOpacity(.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                          image: DecorationImage(
                            image: AssetImage(_images[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ==== BOOK NOW ====
              Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: 164,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34)),
                          elevation: 0,
                        ),
                        child: Text('Đặt ngay',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white)),
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      width: 140,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: primary, width: 2), // viền
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(34),
                          ),
                          foregroundColor: primary, // màu chữ & ripple
                        ),
                        child: Text(
                          'Yêu thích',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: primary, // chữ màu primary
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ]),
      ),
    );
  }
}

// ===== Widgets phụ =====

Widget _amenity({required IconData icon, required String text}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.black87),
      const SizedBox(width: 6),
      Text(
        text,
        style: GoogleFonts.lato(
            fontSize: 12.5, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

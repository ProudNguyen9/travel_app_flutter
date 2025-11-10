import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/data.dart'; // TourService + TourFull
import 'package:travel_app/data/services/favorite_tour_service.dart';
import 'package:travel_app/pages/booking_screen.dart';
import 'package:travel_app/utils/formatter.dart'; // Formatter.vnd

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.tourId,
  });

  final int tourId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const primary = Color(0xFF24BAEC);

  List<String> _images = [];
  TourFull? _tour;
  int _selectedIndex = 0;
  bool _loading = true;

  // trạng thái mô tả 80% / full
  bool _expanded = false;

  TextStyle lato(double s,
          {FontWeight w = FontWeight.w400,
          Color c = const Color(0xFF151111),
          double? h}) =>
      GoogleFonts.lato(fontSize: s, fontWeight: w, color: c, height: h);

  @override
  void initState() {
    super.initState();
    _loadData(widget.tourId);
  }

  /// Load tour + ảnh theo ID
  Future<void> _loadData(int tourId) async {
    try {
      final svc = TourService.instance; // singleton
      final tour = await svc.fetchTourForDetailById(tourId); // TourFull?

      // Ảnh: ưu tiên list images, sau đó mainImage/imageUrl, cuối cùng placeholder
      List<String> images =
          (tour?.images ?? []).where((e) => e.trim().isNotEmpty).toList();

      final main = (tour?.imageUrl ?? tour?.imageUrl);
      if (images.isEmpty && (main != null && main.trim().isNotEmpty)) {
        images = [main];
      }
      if (images.isEmpty) {
        images = ['assets/images/placeholder.jpg'];
      }

      setState(() {
        _tour = tour;
        _images = images;
        _selectedIndex = 0;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _tour = null;
        _images = ['assets/images/placeholder.jpg'];
        _selectedIndex = 0;
        _loading = false;
      });
    }
  }

  /// Tự động chọn đúng ImageProvider theo path
  ImageProvider _provider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('/') || path.startsWith('C:\\')) {
      return FileImage(File(path));
    }
    return AssetImage(path);
  }

  String _priceText(TourFull? t) {
    if (t == null) return 'Giá cập nhật sau';
    final price = t.basePriceAdult;
    if (price == null) return 'Giá cập nhật sau';
    return '${Formatter.vnd(price)}/người';
  }

  /// Hiển thị 80% mô tả, bấm để Đọc thêm / Thu gọn
  Widget _description(String desc) {
    final int cutLen = (desc.length * 0.6).floor();
    final bool needMore = desc.length > cutLen;
    final String preview = needMore ? desc.substring(0, cutLen) : desc;

    return GestureDetector(
      onTap: () {
        if (needMore) setState(() => _expanded = !_expanded);
      },
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: _expanded ? desc : preview,
              style: lato(14, c: Colors.black54, h: 1.5),
            ),
            if (needMore && !_expanded)
              TextSpan(
                text: '  ...Đọc thêm',
                style: lato(14, w: FontWeight.w700, c: primary),
              ),
            if (needMore && _expanded)
              TextSpan(
                text: '  Thu gọn',
                style: lato(13, w: FontWeight.w700, c: primary),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double imageWidth = size.width - 32;
    final double imageHeight = size.height * 0.3;
    final tourt = _tour;
    final title = (_tour?.name != null && _tour!.name.toString().isNotEmpty)
        ? _tour!.name.toString()
        : '—';
    // nếu bạn có locationName thì thay ở đây; tạm dùng tourTypeName làm subtitle
    final location =
        _tour?.tourTypeName ?? _tour?.tourTypeName ?? 'Đang cập nhật địa điểm';
    final desc = (_tour?.description?.isNotEmpty ?? false)
        ? _tour!.description!
        : 'Thông tin đang cập nhật…';
    final priceText = _priceText(_tour);

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
                  borderRadius: BorderRadius.circular(21),
                  color: _loading ? Colors.white : null, // khung trắng khi load
                  image: _loading
                      ? null
                      : DecorationImage(
                          image: _provider(_images[_selectedIndex]),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // ==== TIỆN ÍCH + RATING (demo) ====
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

              // ==== TIÊU ĐỀ (tên tour) ====
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: lato(18, w: FontWeight.w600, c: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ==== ĐỊA ĐIỂM / LOẠI TOUR ====
              Row(
                children: [
                  const Icon(Icons.type_specimen_outlined,
                      size: 16, color: primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: lato(13.5, c: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ==== Mô tả + Giá ====
              Row(
                children: [
                  Text('Mô tả',
                      style: lato(16, w: FontWeight.w700, c: primary)),
                  const Spacer(),
                  Text(
                    priceText,
                    style: lato(16, w: FontWeight.w700, c: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ==== MÔ TẢ: 80% + Đọc thêm ====
              _description(desc),

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
                  itemCount: _loading ? 5 : _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final active = !_loading && i == _selectedIndex;
                    return GestureDetector(
                      onTap: _loading
                          ? null
                          : () => setState(() => _selectedIndex = i),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active ? primary : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: primary.withOpacity(.18),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                          color: _loading
                              ? Colors.white
                              : null, // ô trắng khi load
                          image: _loading
                              ? null
                              : DecorationImage(
                                  image: _provider(_images[i]),
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
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingTourScreen(
                                      tour: tourt!,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          disabledBackgroundColor: primary.withOpacity(.35),
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
                      width: 150,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                final client = Supabase.instance.client;
                                final authUser = client.auth.currentUser;
                                if (authUser == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Bạn cần đăng nhập để thêm yêu thích.')),
                                  );
                                  return;
                                }

                                try {
                                  await FavoriteTourService.instance
                                      .addFavoriteByAuth(
                                          authUser.id, tourt!.tourId);
                                  // (tuỳ chọn) cập nhật UI nếu bạn có danh sách id yêu thích:
                                  // setState(() => _favIds.add(t.tourId));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Đã thêm "${tourt.name}" vào yêu thích ❤️')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Lỗi khi thêm yêu thích: $e')),
                                  );
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(34),
                          ),
                          foregroundColor: primary,
                        ),
                        child: Text(
                          'Yêu thích',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: primary,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const Gap(10)
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
          fontSize: 12.5,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

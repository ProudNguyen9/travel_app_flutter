import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/data.dart'; // TourFull
import 'package:travel_app/data/services/favorite_tour_service.dart';
import 'package:travel_app/pages/booking_screen.dart';
import 'package:travel_app/utils/formatter.dart'; // Formatter.vnd

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.tour, // ⬅ truyền thẳng TourFull
  });

  final TourFull tour;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const primary = Color(0xFF24BAEC);

  late TourFull _tour; // ⬅️ luôn có giá trị
  List<String> _images = [];
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
    _initFromTour(widget.tour);
  }

  /// Khởi tạo dữ liệu hiển thị từ TourFull đã truyền vào
  void _initFromTour(TourFull tour) {
    _tour = tour;

    // Ảnh: ưu tiên list images, sau đó imageUrl, cuối cùng placeholder
    List<String> imgs =
        (tour.images ?? []).where((e) => e.trim().isNotEmpty).toList();

    final main = tour.imageUrl;
    if (imgs.isEmpty && (main != null && main.trim().isNotEmpty)) {
      imgs = [main];
    }
    if (imgs.isEmpty) {
      imgs = ['assets/images/placeholder.jpg'];
    }

    setState(() {
      _images = imgs;
      _selectedIndex = 0;
      _loading = false;
    });
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

  String _priceText(TourFull t) {
    final price = t.basePriceAdult;
    if (price == null) return 'Giá cập nhật sau';
    return Formatter.vnd(price);
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

    final title = (_tour.name.isNotEmpty) ? _tour.name : '—';
    // nếu có locationName thật thì thay; tạm dùng tourTypeName làm subtitle
    final location =
        _tour.tourTypeName ?? _tour.tourTypeName ?? 'Đang cập nhật địa điểm';
    final desc = (_tour.description?.isNotEmpty ?? false)
        ? _tour.description!
        : 'Thông tin đang cập nhật…';

    // meta giá (gốc, sau giảm, badge)
    final meta = computePriceMeta(_tour);

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
                  color: _loading ? Colors.white : null,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ===== Cột giá =====
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Giá sau giảm
                      Row(
                        children: [
                          Text(
                            'Chỉ từ ${Formatter.vnd(meta.finalPrice)} /🧍‍♂️',
                            style:
                                lato(16, w: FontWeight.w700, c: Colors.black87),
                          ),
                          // ===== Badge giảm giá (cùng dòng, bên phải) =====
                          if (meta.hasDiscount && meta.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE63946),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                meta.badge!,
                                style: lato(12,
                                    w: FontWeight.w700, c: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      // Giá gốc (nếu có)
                      if (meta.hasDiscount)
                        Text(
                          Formatter.vnd(meta.base),
                          style: lato(13, c: Colors.grey).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // ==== Mô tả  ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mô tả',
                      style: lato(16, w: FontWeight.w700, c: primary)),
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
                          color: _loading ? Colors.white : null,
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
                                      tour: _tour, // ⬅️ truyền cả tour
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
                                          authUser.id, _tour.tourId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Đã thêm "${_tour.name}" vào yêu thích ❤️')),
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

class PriceMeta {
  final double base; // giá gốc / người
  final double finalPrice; // giá sau giảm / người
  final bool hasDiscount;
  final String? badge; // "-20%" hoặc "-500.000 ₫" (kèm " nhóm 4+" nếu có)

  PriceMeta(this.base, this.finalPrice, this.hasDiscount, this.badge);
}

PriceMeta computePriceMeta(TourFull t) {
  double base = (t.basePriceAdult ?? 0).toDouble();
  final String? discountType = t.bestDiscountType;
  final double? discountValue = (t.bestDiscountValue is num)
      ? (t.bestDiscountValue as num).toDouble()
      : double.tryParse('${t.bestDiscountValue}');
  final double? discountCap = (t.bestDiscountCap is num)
      ? (t.bestDiscountCap as num).toDouble()
      : double.tryParse('${t.bestDiscountCap}');
  final int groupMin = (t.bestDiscountPeople ?? 1);
  final int? earlyDays = t.bestDiscountEarlyDays; // thêm dòng này

  bool hasDiscount =
      t.bestDiscountId != null && discountType != null && base > 0;
  if (!hasDiscount) return PriceMeta(base, base, false, null);

  double off = 0;
  String badge;
  if (discountType == 'percent') {
    off = base * ((discountValue ?? 0) / 100);
    if (discountCap != null && off > discountCap) off = discountCap;
    badge = '-${(discountValue ?? 0).toStringAsFixed(0)}%';
  } else {
    off = discountValue ?? 0;
    badge = '-${Formatter.vnd(off)}';
  }

  double finalPrice = base - off;
  if (finalPrice < 0) finalPrice = 0;

  // Thêm nhãn nhóm nếu yêu cầu > 1
  if (groupMin > 1) badge = '$badge  nhóm $groupMin+';

  // ===== Thêm nhãn đặt sớm =====
  if (earlyDays != null && earlyDays > 0) {
    badge = '$badge Đặt trước $earlyDays ngày';
  }

  return PriceMeta(base, finalPrice, true, badge);
}

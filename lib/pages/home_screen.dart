import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/utils/duration_formatter.dart';

import '../data/data.dart';
import '../models_template/people_also_like_model.dart';
import '../utils/utils.dart';
import '../widget/reuseable_text.dart';
import '../models_template/tab_bar_model.dart';
import '../widget/painter.dart';
import '../widget/reuseabale_middle_app_text.dart';
import '../widget/widget.dart';
import 'screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController tabController;
  final EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(horizontal: 10.0);
  //get data
  List<TourFull>? tours;
  Future<void> _loadData() async {
    final data = await TourService.instance.fetchAllTours();
    setState(() => tours = data);
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    _loadData();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // Nếu số lượng không đủ thì tự co lại
    final all = tours ?? const <TourFull>[]; // luôn có list
    final featuredTours = all.take(3).toList(); // 3 nổi bật
    final suggestedTours =
        all.skip(3).take(3).toList(); // 3 tiếp theo, không trùng
    final List<TourFull> all0 =
        List<TourFull>.from(tours ?? const <TourFull>[]);
    all0.shuffle();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // bottomNavigationBar:,
        backgroundColor: Colors.white,
        body: Stack(children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Padding(
              padding: padding,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeaderRow(),
                      const Gap(10),
                      FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            'Khám Phá',
                            style: GoogleFonts.lalezar(
                                color: const Color(0xFF2E323E),
                                fontSize: 29,
                                height: 1,
                                fontWeight: FontWeight.w900),
                          )),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // ✅ căn giữa theo chiều dọc
                          children: [
                            Text(
                              "Vẻ Đẹp Việt Nam",
                              style: GoogleFonts.lalezar(
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFF7029),
                              ),
                            ),
                            const SizedBox(
                                width: 8), // khoảng cách nhỏ giữa chữ và icon
                            Image.asset(
                              'assets/icons/muiten.png',
                              width: 70, // ✅ giảm để vừa chữ
                              height: 50,
                              fit: BoxFit.cover,
                              alignment:
                                  Alignment.center, // căn giữa theo chiều dọc
                            ),
                          ],
                        ),
                      ),
                      const Gap(10),
                      FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: Container(
                              width: size.width * 0.9,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SearchScreen(
                                        hintText: "Bạn muốn đi đâu?",
                                        historyKey: "home_search",
                                        suggestions: [
                                          "Đà Nẵng",
                                          "Nha Trang",
                                          "Vũng Tàu"
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    // Ô tìm kiếm dạng pill
                                    const Gap(4),
                                    Expanded(
                                      child: Container(
                                        height: 52,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(34),
                                          border: Border.all(
                                              color: const Color(0xFF24BAEC),
                                              width: 1.4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.search,
                                                size: 20,
                                                color: Color(0xFF98A2B3)),
                                            SizedBox(width: 8),
                                            // Placeholder tĩnh
                                            Text(
                                              'Tìm điểm đến bạn muốn...',
                                              style: TextStyle(
                                                color: Color(0xFF98A2B3),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // Nút filter tròn nổi
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.tune_rounded,
                                          size: 22, color: Colors.black87),
                                    ),
                                    const Gap(8)
                                  ],
                                ),
                              ))),
                      const Gap(18),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          'Bạn muốn đi đâu hôm nay?',
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF151111),
                          ),
                        ),
                      ),
                      const Gap(18),
                      FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: const SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CatergoryIcon(
                                  path: 'assets/images/dongnai.jpg',
                                  title: 'Đồng Nai ',
                                ),
                                Gap(10),
                                CatergoryIcon(
                                  path: 'assets/images/nhatrang.jpg',
                                  title: 'Nha Trang',
                                ),
                                Gap(10),
                                CatergoryIcon(
                                  path: 'assets/images/hue.jpg',
                                  title: 'Huế',
                                ),
                                Gap(10),
                                CatergoryIcon(
                                  path: 'assets/images/anh-da-lat.jpg',
                                  title: 'Đà Lạt',
                                ),
                                Gap(10),
                                CatergoryIcon(
                                  path: 'assets/images/Vung-Tau.jpg',
                                  title: 'Vũng Tàu',
                                ),
                              ],
                            ),
                          )),
                      const Gap(15),
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: SizedBox(
                          height: 170,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              PromoCard(
                                title: 'Ưu đãi hấp dẫn mùa này',
                                highlight: 'Giảm tới 90%',
                                gradient: [
                                  Color(0xFF00F5D4),
                                  Color(0xFF5F0A87),
                                  Color(0xFFFFA500),
                                ],
                              ),
                              SizedBox(width: 12),
                              PromoCard(
                                title: 'Combo biển hè siêu hot',
                                highlight: 'Giá siêu tốt',
                                gradient: [
                                  Color(0xFF00C6FF),
                                  Color(0xFF0072FF),
                                  Color(0xFFFFC371),
                                ],
                              ),
                              SizedBox(width: 12),
                              PromoCard(
                                title: 'Khám phá núi rừng hoang dã',
                                highlight: 'Trải nghiệm',
                                gradient: [
                                  Color(0xFF00C6FF),
                                  Color(0xFF0072FF),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 900),
                        child: Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          width: size.width,
                          child: Align(
                            alignment: Alignment.center,
                            child: TabBar(
                              tabAlignment: TabAlignment.center,
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              labelPadding: EdgeInsets.only(
                                  left: size.width * 0.05,
                                  right: size.width * 0.05),
                              controller: tabController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              isScrollable: true,
                              indicatorSize: TabBarIndicatorSize.label,
                              indicator: const CircleTabBarIndicator(
                                color: Color(0xFF24BAEC),
                                radius: 4,
                              ),
                              tabs: const [
                                Tab(text: "Địa điểm"),
                                Tab(text: "Xu hướng"),
                                Tab(text: "Khám phá"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1000),
                        child: Container(
                          margin: EdgeInsets.only(top: size.height * 0.01),
                          width: size.width,
                          height: size.height * 0.4,
                          child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: tabController,
                              children: [
                                TabViewChild(tours: all0)
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .shimmer(),
                                TabViewChild(
                                        tours: List<TourFull>.from(all0)
                                          ..shuffle())
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .shimmer(),
                                TabViewChild(
                                        tours: List<TourFull>.from(all0)
                                          ..shuffle())
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .shimmer(),
                              ]),
                        ),
                      ),
                      const Gap(5),
                      FadeInUp(
                          delay: const Duration(milliseconds: 1100),
                          child: MiddleAppText(
                            text: "Gợi ý nổi bật",
                            onSeeAll: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DestinationListScreen()));
                            },
                          )),
                      FadeInUp(
                        delay: const Duration(milliseconds: 900),
                        child: Container(
                          margin: EdgeInsets.only(top: size.height * 0.01),
                          width: size.width,
                          height: 320,
                          child: featuredTours.isEmpty
                              ? ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) =>
                                      const CardItemForYou(
                                    loading: true,
                                    idTour: 0,
                                  ), // khung trắng
                                )
                              : ListView.builder(
                                  itemCount: featuredTours.length,
                                  itemBuilder: (context, index) {
                                    final t = featuredTours[index];
                                    return CardItemForYou(
                                      loading: false,
                                      imageUrl: t.imageUrl,
                                      title: t.name,
                                      tag: t.tourTypeName ?? "Tour",
                                      decription: t.description ?? "Địa điểm",
                                      rating: 4.6,
                                      idTour: t.tourId,
                                    );
                                  },
                                ),
                        ),
                      ),
                      FadeInUp(
                          delay: const Duration(milliseconds: 1200),
                          child: MiddleAppText(
                            text: "Có thể bạn cũng thích",
                            onSeeAll: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DestinationListScreen()));
                            },
                          )),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1300),
                        child: Container(
                          margin: EdgeInsets.only(top: size.height * 0.01),
                          width: size.width,
                          height: size.height,
                          child: tours == null
                              // ⬅ Hiển thị 3 khung trắng khi đang tải
                              ? ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 3,
                                  itemBuilder: (context, index) =>
                                      MayYouLikeItem.loading(size: size),
                                )
                              : suggestedTours.isEmpty
                                  ? Center(
                                      child: Text(
                                        "Chưa có dữ liệu",
                                        style: GoogleFonts.poppins(
                                            color: Colors.black54),
                                      ),
                                    )
                                  : ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: suggestedTours
                                          .length, // suggestedTours đã tối đa 3
                                      itemBuilder: (context, index) {
                                        final t = suggestedTours[index];
                                        return MayYouLikeItem(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        DetailScreen(
                                                          tour: t,
                                                        )));
                                          },
                                          size: size,
                                          title: t.name,
                                          duration:
                                              formatDuration(t.durationDays),
                                          location:
                                              t.tourTypeName ?? "Điểm đến",
                                          imageUrl: t.imageUrl ?? "",
                                          rating: 4.6,
                                        );
                                      },
                                    ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class MayYouLikeItem extends StatelessWidget {
  const MayYouLikeItem({
    super.key,
    required this.size,
    required this.title,
    required this.duration, // ví dụ: "3 ngày 2 đêm"
    required this.location, // ví dụ: "Phú Quốc"
    required this.imageUrl, // URL mạng
    this.rating = 4.6,
    this.fallbackAsset = "assets/images/splash1.png",
    this.onTap,
  }) : isLoading = false;

  /// Skeleton constructor: khung trắng khi đang tải
  const MayYouLikeItem.loading({
    super.key,
    required this.size,
    this.fallbackAsset = "assets/images/splash1.png",
  })  : title = "",
        duration = "",
        location = "",
        imageUrl = "",
        rating = 0,
        onTap = null,
        isLoading = true;

  final Size size;
  final String title;
  final String duration;
  final String location;
  final String imageUrl;
  final double rating;
  final String fallbackAsset;
  final VoidCallback? onTap;
  final bool isLoading;

  /// Tạo từ map (tiện nếu dữ liệu là map)
  factory MayYouLikeItem.fromMap({
    required Size size,
    required Map<String, dynamic> m,
    String fallbackAsset = "assets/images/splash1.png",
    VoidCallback? onTap,
  }) {
    return MayYouLikeItem(
      size: size,
      title: (m["title"] ?? "").toString(),
      duration: (m["duration"] ?? "").toString(),
      location: (m["location"] ?? "").toString(),
      imageUrl: (m["image"] ?? "").toString(),
      rating: (m["rating"] is num) ? (m["rating"] as num).toDouble() : 0.0,
      fallbackAsset: fallbackAsset,
      onTap: onTap,
    );
  }

  // Khung xám placeholder
  Widget _gray({double h = 200, double w = double.infinity, double r = 15}) =>
      Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Skeleton: chỉ khung xám bo tròn
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: size.width * 0.9,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFF2F2F4),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: size.width * 0.9,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Ảnh URL mạng (không cache) + placeholder khung + fallback asset
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loading) {
                if (loading == null) return child;
                return _gray();
              },
              errorBuilder: (context, error, stack) {
                return Image.asset(fallbackAsset, fit: BoxFit.cover);
              },
            ),

            // Lớp gradient mờ phía dưới
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color.fromARGB(180, 0, 0, 0), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Nội dung overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(6),

                  // Duration · Location · Rating
                  Row(
                    children: [
                      // Duration chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          duration, // ví dụ "3 ngày 2 đêm"
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(10),

                      // Location
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.lightBlueAccent),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      // Rating
                      const Gap(8),
                      const Icon(Icons.star,
                          color: Color(0xFFFFD700), size: 16),
                      const Gap(4),
                      Text(
                        rating.toStringAsFixed(
                            rating.truncateToDouble() == rating ? 0 : 1),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

class CardItemForYou extends StatelessWidget {
  const CardItemForYou({
    super.key,
    this.loading = false,
    this.t,
    this.imageUrl,
    this.fallbackAsset = 'assets/images/bgsearch.jpg',
    this.title = 'Núi đẹp lắm',
    this.tag = 'Leo núi',
    this.decription = 'Nốc nhà Đông Dương',
    this.rating = 4.3,
    required this.idTour,
  });

  final bool loading;
  final String? imageUrl;
  final String fallbackAsset;
  final int idTour;
  final String title;
  final TourFull? t;
  final String tag;
  final String decription;
  final double rating;

  @override
  Widget build(BuildContext context) {
    Widget gray({double h = 16, double w = double.infinity, double r = 10}) =>
        Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F4),
            borderRadius: BorderRadius.circular(r),
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailScreen(
                      tour: t!,
                    )),
          );
        },
        child: Container(
          height: 87,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 108, 108, 108).withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ảnh (network + placeholder khung, không cache)
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: SizedBox(
                    width: 78,
                    height: 81,
                    child: loading
                        ? gray(h: 81, w: 78, r: 21)
                        : _netImage(imageUrl, fallbackAsset, gray),
                  ),
                ),
              ),
              const Gap(10),

              // Nội dung
              Expanded(
                child: loading
                    ? _skeletonTexts(gray)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.description_outlined,
                                  size: 14, color: Colors.black54),
                              Expanded(
                                child: Text(
                                  decription,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black54,
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

  // ===== Ảnh mạng thuần, KHÔNG cache, có placeholder khung & fallback asset =====
  Widget _netImage(
    String? url,
    String assetFallback,
    Widget Function({double h, double w, double r}) gray,
  ) {
    if (url == null || url.isEmpty) {
      return Image.asset(assetFallback, fit: BoxFit.cover);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      // Khung placeholder khi đang tải
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return gray(h: 81, w: 78, r: 21);
      },
      // Fallback asset khi lỗi URL/mạng
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(assetFallback, fit: BoxFit.cover);
      },
    );
  }

  // Khung xương phần text khi loading
  Widget _skeletonTexts(Widget Function({double h, double w, double r}) gray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        gray(h: 16, w: 160),
        const SizedBox(height: 6),
        gray(h: 20, w: 64, r: 8),
        const SizedBox(height: 10),
        Row(
          children: [
            gray(h: 14, w: 120),
            const Spacer(),
            gray(h: 16, w: 60),
          ],
        ),
      ],
    );
  }
}

// appbar
class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bên trái: avatar + tên
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                'assets/images/main.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 13.0),
              child: Text(
                "Xin chào Hào nhé",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),

        // Bên phải: chuông + badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/noti.png",
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                )),
            Positioned(
              right: -0.8,
              top: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565D8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '9',
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TabViewChild extends StatelessWidget {
  const TabViewChild({
    super.key,
    required this.tours,
    this.fallbackAsset = 'assets/images/splash1.png',
    this.itemWidthFactor = 0.70, // vừa tay để tránh overflow
    this.itemHeightFactor = 0.42,
  });

  final List<TourFull> tours;
  final String fallbackAsset;
  final double itemWidthFactor;
  final double itemHeightFactor;

  // ===== Helpers =====
  double? _toD(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int? _toI(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  Widget _gray({double h = 160, double w = double.infinity, double r = 18}) =>
      Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F4),
          borderRadius: BorderRadius.circular(r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (tours.isEmpty) {
      return Center(
        child: Text("Chưa có tour",
            style: GoogleFonts.poppins(color: Colors.black54)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      separatorBuilder: (_, __) => const Gap(4),
      itemCount: tours.length,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final t = tours[index];
        final title = t.name ?? 'Tour';
        final location = t.tourTypeName ?? 'Điểm đến';
        final imageUrl = t.imageUrl;

        // Giá “từ”: ưu tiên người lớn, thiếu thì fallback trẻ em
        final baseAdult = _toD(t.basePriceAdult) ?? 0;
        final discountType = t.bestDiscountType;
        final discountValue = _toD(t.bestDiscountValue);
        final discountPeople = _toI(t.bestDiscountPeople);
        final discountCap = _toD(t.bestDiscountCap);
        final hasDiscount = t.bestDiscountId != null && discountType != null;

        double finalPrice = baseAdult;
        String priceLabel = 'Chỉ từ ${Formatter.vnd(baseAdult)} / người';
        String? discountBadge; // 👈 badge giảm giá hiển thị góc phải

        if (hasDiscount && baseAdult > 0) {
          double discountAmount = 0;

          if (discountType == 'percent') {
            discountAmount = baseAdult * (discountValue! / 100);
            if (discountCap != null && discountAmount > discountCap) {
              discountAmount = discountCap;
            }
            // Hiển thị badge phần trăm
            discountBadge = '-${discountValue.toStringAsFixed(0)}%';
          } else if (discountType == 'fixed') {
            discountAmount = discountValue ?? 0;
            // Hiển thị badge số tiền
            discountBadge = '-${Formatter.vnd(discountAmount)}';
          }

          finalPrice = baseAdult - discountAmount;
          if (finalPrice < 0) finalPrice = 0;

          // Nếu là nhóm (>=4 người), thêm chữ nhóm 4+ vào badge
          if (discountPeople != null && discountPeople >= 4) {
            discountBadge = '${discountBadge!}\nnhóm $discountPeople+';
          }

          // Dòng hiển thị giá luôn là "Từ xxx / người"
          priceLabel = 'Chỉ từ ${Formatter.vnd(finalPrice)} / người';
        }
        // Số ngày
        final days = _toI(t.durationDays) ?? 0;
        final daysLabel = formatDuration(t.durationDays is num
            ? (t.durationDays as num).toDouble()
            : double.tryParse("${t.durationDays}") ?? 0.0);

        // Rating demo nếu chưa có dữ liệu
        final rating = (4.4 + (index % 5) * 0.1).clamp(3.5, 5.0);

        final cardW = size.width * itemWidthFactor;
        final cardH = size.height * itemHeightFactor;

        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailScreen(
                          tour: t,
                        )));
          },
          child: SizedBox(
            width: cardW,
            height: cardH,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                // Ảnh + bo góc + shadow
                Hero(
                  tag: '${imageUrl ?? fallbackAsset}#$index',
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    width: cardW,
                    height: cardH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildImage(
                      url: imageUrl,
                      width: cardW,
                      height: cardH,
                    ),
                  ),
                ),

                // Gradient nền dày để chứa 2 hàng chip thoải mái
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 10,
                  child: Container(
                    height: cardH * 0.60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color.fromARGB(210, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Badge loại tour (trái trên) – cũng dùng chip style thống nhất
                Positioned(
                  left: 16,
                  top: 16,
                  child: _chip(
                    text: location,
                    icon: Icons.place,
                  ),
                ),

                // Khối text + chips
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),

                      const Gap(10),
                      // ✅ TẦNG 1: CHỈ GIÁ
                      _chip(
                        text: priceLabel,
                        icon: Icons.payments_rounded,
                      ),
                      // ✅ TẦNG 2: NGÀY + SAO
                      const Gap(10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _chip(
                            text: daysLabel,
                            icon: Icons.schedule,
                          ),
                          const Gap(12),
                          _chip(
                            text: rating.toStringAsFixed(1),
                            icon: Icons.star_rounded,
                            iconColor: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (discountBadge != null)
                  Positioned(
                    right: 14,
                    top: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFE63946)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Text(
                        discountBadge,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ảnh mạng + placeholder + fallback
  Widget _buildImage({
    required String? url,
    required double width,
    required double height,
  }) {
    if (url == null || url.isEmpty) {
      return Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _gray(h: height, w: width, r: 20);
      },
      errorBuilder: (_, __, ___) {
        return Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// ✅ Chip style thống nhất: nền kính mờ + viền, icon + text căn giữa
  Widget _chip({
    required String text,
    required IconData icon,
    Color iconColor = Colors.white,
    bool fancy = false, // 👈 thêm tham số mới
  }) {
    if (!fancy) {
      // ==== Loại CŨ của bạn ====
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x55FFFFFF), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const Gap(6),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // ==== Loại MỚI (glass + blur + shadow) ====
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.20),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.45),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const Gap(6),
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

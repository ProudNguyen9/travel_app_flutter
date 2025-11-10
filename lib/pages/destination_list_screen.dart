// lib/pages/destination_list_screen.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/data/models/tour_full.dart';
import 'package:travel_app/data/services/tour_service.dart';
import 'package:travel_app/utils/duration_formatter.dart'; // <-- dùng formatDuration
import 'package:travel_app/pages/detail_screen.dart'; // <-- thêm: mở chi tiết

class DestinationListScreen extends StatelessWidget {
  const DestinationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xff151111);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Danh sách điểm đến",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: FutureBuilder<List<TourFull>>(
        future: TourService.instance.fetchAllTours(),
        builder: (context, snap) {
          // ⛳️ Loading: KHÔNG spinner, chỉ khung placeholder
          if (snap.connectionState == ConnectionState.waiting) {
            return _loadingPlaceholder(textColor);
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                'Không tải được danh sách tour.\n${snap.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final tours = snap.data ?? <TourFull>[];
          final popular = tours.take(2).toList();
          final liked = tours.length > 2 ? tours.sublist(2) : <TourFull>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Phần 1: Gói du lịch phổ biến (2 item)
                Text(
                  "Gói du lịch phổ biến",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (popular.isEmpty) _emptyCard("Chưa có tour phổ biến"),
                ...popular.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(tourId: t.tourId),
                            ),
                          );
                        },
                        child: _popularTripCard(
                          imageUrl: t.imageUrl,
                          fallbackAsset: "assets/images/splash1.png",
                          title: t.name,
                          date: formatDuration(t.durationDays), // ✅ dùng util
                          rating: 4.8,
                          joined: t.maxParticipants ?? 0,
                        ),
                      ),
                    )),

                const SizedBox(height: 20),

                // 🔹 Phần 2: Có thể bạn yêu thích (còn lại)
                Text(
                  "Gói du lịch có thể bạn yêu thích",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff151111),
                  ),
                ),
                const SizedBox(height: 12),

                if (liked.isEmpty) _emptyCard("Chưa có dữ liệu"),
                if (liked.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double cardWidth = (constraints.maxWidth - 12) / 2;
                      double aspectRatio = cardWidth / 180;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: liked.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: aspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          final t = liked[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(tourId: t.tourId),
                                ),
                              );
                            },
                            child: _favoriteCard(
                              title: t.name,
                              location:
                                  t.tourTypeName ?? t.tourTypeCode ?? "Tour",
                              imageUrl: t.imageUrl,
                              fallbackAsset: index.isEven
                                  ? "assets/images/splash1.png"
                                  : "assets/images/splash2.png",
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========= Loading placeholder (không spinner) =========
  Widget _loadingPlaceholder(Color textColor) {
    Widget gray({double h = 16, double w = double.infinity, double r = 10}) =>
        Container(
            height: h,
            width: w,
            decoration: BoxDecoration(
                color: const Color(0xFFF2F2F4),
                borderRadius: BorderRadius.circular(r)));

    Widget popularSkeleton() => Container(
          height: 129,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: gray(h: 120, w: 110, r: 18),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gray(h: 18, w: 140),
                      const Gap(8),
                      gray(h: 14, w: 120),
                      const Gap(8),
                      gray(h: 14, w: 60),
                      const Spacer(),
                      Row(
                        children: [
                          gray(h: 16, w: 16, r: 8),
                          const Gap(6),
                          gray(h: 16, w: 16, r: 8),
                          const Gap(6),
                          gray(h: 16, w: 16, r: 8),
                          const Gap(8),
                          gray(h: 14, w: 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    Widget likedSkeleton() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gray(h: 100, r: 18),
            const Gap(8),
            gray(h: 16, w: 120),
            const Gap(6),
            gray(h: 14, w: 80),
          ],
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Gói du lịch phổ biến",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
          const Gap(12),
          popularSkeleton(),
          const Gap(12),
          popularSkeleton(),
          const Gap(20),
          Text("Gói du lịch có thể bạn yêu thích",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
          const Gap(12),
          // Grid 2x2 khung
          LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = (constraints.maxWidth - 12) / 2;
              double aspectRatio = cardWidth / 180;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (_, __) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: likedSkeleton(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ========= Helpers UI =========

  // 🔸 Card gói du lịch phổ biến (đổi tham số để hỗ trợ network image)
  Widget _popularTripCard({
    required String? imageUrl,
    required String fallbackAsset,
    required String title,
    required String date,
    required double rating,
    required int joined,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double scale = screenWidth < 400 ? 0.9 : 1.0;

        final img = (imageUrl == null || imageUrl.isEmpty)
            ? Image.asset(
                fallbackAsset,
                width: 110,
                height: 120,
                fit: BoxFit.cover,
              )
            : Image.network(
                imageUrl,
                width: 110,
                height: 120,
                fit: BoxFit.cover,
              );

        return Container(
          height: 129,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: img,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Tên tour
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff151111),
                        ),
                      ),
                      const SizedBox(height: 3),

                      // 🔹 Ngày/Thời lượng
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              date,
                              style: GoogleFonts.poppins(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // 🔹 Dòng sao đánh giá
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "$rating",
                            style: GoogleFonts.poppins(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff151111),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      // 🔹 Dòng số người tham gia
                      Row(
                        children: [
                          ...List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: CircleAvatar(
                                radius: 8,
                                backgroundImage: AssetImage(
                                    'assets/images/splash${(i % 2) + 1}.png'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        "$joined người đã tham gia",
                        style: GoogleFonts.poppins(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔸 Card “có thể bạn yêu thích” (hỗ trợ network image)
  Widget _favoriteCard({
    required String title,
    required String location,
    required String? imageUrl,
    required String fallbackAsset,
  }) {
    final img = (imageUrl == null || imageUrl.isEmpty)
        ? Image.asset(
            fallbackAsset,
            width: double.infinity,
            height: 100,
            fit: BoxFit.cover,
          )
        : Image.network(
            imageUrl,
            width: double.infinity,
            height: 100,
            fit: BoxFit.cover,
          );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            child: img,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff151111),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(msg, style: GoogleFonts.poppins(color: Colors.black54)),
    );
  }
}

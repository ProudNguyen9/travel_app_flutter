import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/utils/extensions.dart';
import 'package:travel_app/widget/reuseable_text.dart';

/// Mô tả 1 hoạt động trong timeline theo giờ
class ActivityItem {
  final String time;
  final String title;
  final String subtitle;

  const ActivityItem({
    required this.time,
    required this.title,
    required this.subtitle,
  });
}

class BottomSheetContent extends StatelessWidget {
  /// Ngày đang xem (ví dụ ngày 1 của tour)
  final DateTime? dayDate;

  /// Danh sách ảnh (thumbnail)
  final List<String>? images;

  /// Danh sách hoạt động theo thời gian (timeline)
  final List<ActivityItem>? activities;

  const BottomSheetContent({
    super.key,
    this.dayDate,
    this.images,
    this.activities,
  });

  // ====== DỮ LIỆU MẶC ĐỊNH (để dùng được ngay khi gọi const BottomSheetContent()) ======
  DateTime get _defaultDate => DateTime(2025, 11, 6);

  List<String> get _defaultImages => const [
        'assets/images/hue.jpg',
        'assets/images/hue.jpg',
        'assets/images/hue.jpg',
        'assets/images/hue.jpg',
        'assets/images/hue.jpg',
      ];

  List<ActivityItem> get _defaultActivities => const [
        ActivityItem(
          time: '08:00',
          title: 'Ăn sáng tại khách sạn',
          subtitle: 'Thưởng thức món địa phương ☕',
        ),
        ActivityItem(
          time: '09:30',
          title: 'Thăm bãi biển Mỹ Khê',
          subtitle: 'Chụp ảnh và thư giãn bên bờ biển 🌊',
        ),
        ActivityItem(
          time: '11:00',
          title: 'Trải nghiệm chèo kayak',
          subtitle: 'Hoạt động vui và an toàn 🛶',
        ),
        ActivityItem(
          time: '12:30',
          title: 'Ăn trưa tại quán địa phương',
          subtitle: 'Thưởng thức hải sản tươi ngon 🦐',
        ),
        ActivityItem(
          time: '14:00',
          title: 'Khám phá trung tâm Đà Nẵng',
          subtitle: 'Cầu Rồng, Chợ Hàn, phố xá nhộn nhịp 🏙️',
        ),
        ActivityItem(
          time: '18:30',
          title: 'Ăn tối ven sông',
          subtitle: 'Không khí lãng mạn, view đêm đẹp 🍷',
        ),
        ActivityItem(
          time: '20:00',
          title: 'Nhạc sống & thư giãn',
          subtitle: 'Tận hưởng không gian âm nhạc 🎶',
        ),
      ];

  String _fmtDateVi(DateTime d) => DateFormat('dd/MM/yyyy', 'vi_VN').format(d);

  @override
  Widget build(BuildContext context) {
    final DateTime useDate = dayDate ?? _defaultDate;
    final List<String> useImages = images ?? _defaultImages;
    final List<ActivityItem> useActivities = activities ?? _defaultActivities;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(29)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Nội dung cuộn
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề
                          const AppText(
                            text: "Lịch trình tour",
                            size: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          const Gap(6),
                          // Ngày 1 (dd/MM/yyyy) — nếu bạn có index ngày, truyền từ ngoài vào
                          AppText(
                            text: "Ngày 1 (${_fmtDateVi(useDate)})",
                            size: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          const Gap(12),

                          // ====== LIST ẢNH NGANG ======
                          _ImageRow(
                            images: useImages,
                            itemSize: 62,
                            borderRadius: 16,
                            overlayCountText:
                                '+${(useImages.length > 5) ? (useImages.length - 4) : 16}',
                            // tuỳ bạn: ở đây demo “+16” giống ảnh mẫu
                          ),

                          const Gap(16),

                          // ====== TIMELINE THEO GIỜ ======
                          ..._buildTimeline(useActivities),
                          const Gap(8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTimeline(List<ActivityItem> items) {
    // Nếu cần, có thể sort theo time ở đây
    // items.sort((a, b) => a.time.compareTo(b.time));

    return List.generate(items.length, (i) {
      final it = items[i];
      return Padding(
        padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột giờ
            _TimeBadge(time: it.time),

            const SizedBox(width: 12),

            // Cột nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: it.title,
                    size: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    it.subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Huy hiệu giờ bo góc
class _TimeBadge extends StatelessWidget {
  final String time;
  const _TimeBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5FF)),
      ),
      alignment: Alignment.center,
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B1E28),
        ),
      ),
    );
  }
}

/// Hàng ảnh ngang: 4 ảnh đầu hiển thị, ảnh cuối overlay "+N"
class _ImageRow extends StatelessWidget {
  final List<String> images;
  final double itemSize;
  final double borderRadius;
  final String overlayCountText;

  const _ImageRow({
    required this.images,
    this.itemSize = 62,
    this.borderRadius = 16,
    this.overlayCountText = '+16',
  });

  @override
  Widget build(BuildContext context) {
    // Hiển thị tối đa 5 item; item cuối có overlay “+N”
    final display = images.length <= 5 ? images : images.take(5).toList();
    return SizedBox(
      height: itemSize,
      width: context.deviceSize.width, // dùng extensions của bạn
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: display.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isLast = index == display.length - 1;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Image.asset(
                  display[index],
                  width: itemSize,
                  height: itemSize,
                  fit: BoxFit.cover,
                ),
              ),
              if (isLast)
                Container(
                  width: itemSize,
                  height: itemSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    overlayCountText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

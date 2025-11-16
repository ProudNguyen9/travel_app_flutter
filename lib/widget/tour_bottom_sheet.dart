import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/widget/reuseable_text.dart';

class ActivityItem {
  final DateTime originalDate; // ngày thực tế từ API
  final String time;
  final String title;
  final String subtitle;

  const ActivityItem({
    required this.originalDate,
    required this.time,
    required this.title,
    required this.subtitle,
  });
}

class BottomSheetContent extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? images;
  final List<ActivityItem>? activities;

  const BottomSheetContent({
    super.key,
    required this.startDate,
    required this.endDate,
    this.images,
    this.activities,
  });

  String fmtDate(DateTime d) => DateFormat('dd/MM/yyyy', 'vi_VN').format(d);

  /// ⭐ Group activity theo ngày thực tế
  Map<String, List<ActivityItem>> groupByOriginalDate(List<ActivityItem> list) {
    Map<String, List<ActivityItem>> group = {};

    for (var a in list) {
      final key = DateFormat("yyyy-MM-dd").format(a.originalDate);
      group.putIfAbsent(key, () => []).add(a);
    }

    return group;
  }

  @override
  Widget build(BuildContext context) {
    final list = activities ?? [];

    /// Group theo ngày thực tế
    final grouped = groupByOriginalDate(list);

    /// Sort theo ngày
    final sortedKeys = grouped.keys.toList()..sort();

    /// Tạo list ngày map theo startDate
    final mappedDays = List.generate(sortedKeys.length, (i) {
      return startDate.add(Duration(days: i));
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scroll) {
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
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: "Lịch trình tour",
                        size: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      const Gap(10),

                      /// ⭐ HIỂN THỊ THEO NGÀY MAP ĐÚNG
                      ...List.generate(sortedKeys.length, (dayIndex) {
                        final originalKey = sortedKeys[dayIndex];
                        final acts = grouped[originalKey]!;
                        final showDate = mappedDays[dayIndex];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text:
                                  "Ngày ${dayIndex + 1} — ${fmtDate(showDate)}",
                              size: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            const Gap(8),
                            ...acts.map((a) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _TimeBadge(time: a.time),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            text: a.title,
                                            size: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            a.subtitle,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Gap(20),
                          ],
                        );
                      }),
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
}

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

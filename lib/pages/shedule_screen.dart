import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:travel_app/data/services/booking_service.dart';
import 'package:travel_app/widget/reuseabale_middle_app_text.dart';
import 'package:travel_app/pages/screen.dart';

class SheduleScreen extends StatefulWidget {
  const SheduleScreen({super.key});

  @override
  State<SheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<SheduleScreen> {
  DateTime _focusDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<DateTime> _highlightDates = [
    DateTime(2025, 11, 6),
    DateTime(2025, 11, 8),
    DateTime(2025, 11, 10),
  ];

  late Map<DateTime, List<String>> _eventMap;
  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();

    _focusedDay = _focusDate;
    _selectedDay = _onlyDate(_focusDate);

    _eventMap = {};

    _loadBookings();
  }

  /// 🔥 Lấy auth_id → users.user_id → booking → tour
  Future<void> _loadBookings() async {
    setState(() => _loading = true);

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      print("⚠ Không có người dùng đăng nhập");
      setState(() => _loading = false);
      return;
    }

    final authId = currentUser.id;

    // 1️⃣ Lấy user_id nội bộ từ bảng users
    final userRow = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', authId)
        .maybeSingle();

    if (userRow == null) {
      print("⚠ Không tìm thấy user_id trong bảng users");
      setState(() => _loading = false);
      return;
    }

    final int userId = userRow['user_id'];

    // 2️⃣ Lấy booking + tour
    final data = await BookingService().getPaidBookingsWithTour(userId);

    setState(() {
      _items = data;
      _loading = false;

      // Clear old highlight
      _eventMap.clear();

      // Add highlight for startDate of each tour
      for (final item in data) {
        final DateTime start = _onlyDate(item["startDate"]);

        // Map structure: Date → list of events
        _eventMap[start] = ['tour'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Lịch trình',
          style: GoogleFonts.lato(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(10),

              /// ========== CALENDAR ==========
              Center(
                child: Container(
                  width: 335,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: TableCalendar<String>(
                    locale: 'vi_VN',
                    firstDay: DateTime.utc(2010, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.week,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    eventLoader: (day) => _eventMap[_onlyDate(day)] ?? const [],
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = _onlyDate(selectedDay);
                        _focusedDay = focusedDay;
                        _focusDate = focusedDay;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.chevron_left),
                      rightChevronIcon: Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ),

              const Gap(20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                child: Text(
                  'Danh sách hoạt động',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              const Gap(20),

              /// =========== BOOKINGS ============
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_items.isEmpty)
                const Center(child: Text("Bạn chưa có tour đã thanh toán"))
              else
                Column(
                  children: _items.map((item) {
                    final tour = item["tour"];
                    final DateTime startDate = item["startDate"];
                    final DateTime endDate = item["endDate"];
                    return TravelCardWidget(
                      imagePath: tour.images.isNotEmpty
                          ? tour.images.first
                          : "assets/images/default.jpg",
                      startdate:
                          "${startDate.day}/${startDate.month}/${startDate.year}",
                      endate: "${endDate.day}/${endDate.month}/${endDate.year}",
                      title: tour.name,
                      location: tour.tourTypeName,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItineraryMapScreen(
                              tourId: tour.tourId, startDate:startDate , endDate: endDate,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================== CARD ======================
class TravelCardWidget extends StatelessWidget {
  final String imagePath;
  final String startdate;
  final String endate;
  final String title;
  final String location;
  final VoidCallback? onPressed;

  const TravelCardWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.location,
    this.onPressed,
    required this.startdate,
    required this.endate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// --- FIX ẢNH KHÔNG BỊ LỖI LAYOUT --- ///
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// CONTENT
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          location,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Từ $startdate',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const Gap(3),
                      Text(
                        'Đến $endate',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onPressed,
              icon: Transform.rotate(
                angle: 3.1416,
                child: SvgPicture.asset(
                  'assets/icons/Arrow.svg',
                  width: 26,
                  height: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travel_app/pages/screen.dart';
import 'package:travel_app/widget/reuseabale_middle_app_text.dart';

class SheduleScreen extends StatefulWidget {
  const SheduleScreen({super.key});

  @override
  State<SheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<SheduleScreen> {
  // Ngày đang dùng ở chỗ khác trong file
  DateTime _focusDate = DateTime.now();

  // State cho TableCalendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// ✅ Danh sách ngày cần highlight (dot cam)
  final List<DateTime> _highlightDates = [
    DateTime(2025, 11, 6),
    DateTime(2025, 11, 8),
    DateTime(2025, 11, 10),
  ];

  /// Map sự kiện để TableCalendar render markers (dot)
  late final Map<DateTime, List<String>> _eventMap;

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _focusedDay = _focusDate;
    _selectedDay = _onlyDate(_focusDate);

    // Chuẩn hóa highlight -> event map
    _eventMap = {
      for (final d in _highlightDates.map(_onlyDate)) d: ['event'],
    };
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
            height: 26 / 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(10),

              // ======================== WEEK CALENDAR (VI) ========================
              Container(
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
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: TableCalendar<String>(
                  locale: 'vi_VN', // yêu cầu flutter_localizations + intl
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.week, // Dạng strip tuần
                  startingDayOfWeek: StartingDayOfWeek.monday, // Thứ 2 bắt đầu

                  // Nạp sự kiện cho từng ngày
                  eventLoader: (day) => _eventMap[_onlyDate(day)] ?? const [],

                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = _onlyDate(selectedDay);
                      _focusedDay = focusedDay;
                      _focusDate =
                          focusedDay; // đồng bộ biến cũ nếu cần dùng nơi khác
                    });
                  },

                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    leftChevronIcon: Icon(Icons.chevron_left),
                    rightChevronIcon: Icon(Icons.chevron_right),
                  ),

                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.grey),
                    weekdayStyle: TextStyle(color: Colors.grey),
                  ),

                  calendarStyle: CalendarStyle(
                    // Ngày được chọn
                    selectedDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),

                    // Hôm nay -> viền xanh
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.blueAccent, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    todayTextStyle: const TextStyle(color: Colors.black),

                    // Decor mặc định
                    defaultDecoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    weekendDecoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    defaultTextStyle:
                        const TextStyle(fontSize: 14, color: Colors.black),
                    weekendTextStyle:
                        const TextStyle(fontSize: 14, color: Colors.black),

                    // Dấu “dot” dưới ngày có event
                    markerDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    markersAlignment: Alignment.bottomCenter,
                    markersMaxCount: 1,
                  ),
                ),
              ),
              // ======================== END WEEK CALENDAR ========================

              const Gap(10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: MiddleAppText(text: 'Danh sách hoạt động'),
              ),
              const Gap(10),

              TravelCardWidget(
                imagePath: 'assets/images/hue.jpg',
                date: '26 Tháng 1 2022',
                title: 'Cung đình Huế',
                location: 'Thành phố Huế',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ItineraryMapScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelCardWidget extends StatelessWidget {
  final String imagePath;
  final String date;
  final String title;
  final String location;
  final VoidCallback? onPressed;

  const TravelCardWidget({
    super.key,
    required this.imagePath,
    required this.date,
    required this.title,
    required this.location,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 100,
        width: 370,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 108, 108, 108).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.asset(
                  imagePath,
                  width: 98,
                  height: 91,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  const Gap(5),
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Gap(5),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  )
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
            )
          ],
        ),
      ),
    );
  }
}

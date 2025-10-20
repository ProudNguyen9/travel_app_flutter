import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:travel_app/widget/reuseabale_middle_app_text.dart';

class SheduleScreen extends StatefulWidget {
  const SheduleScreen({super.key});

  @override
  State<SheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<SheduleScreen> {
  DateTime _focusDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color(0xFFF7F7F9),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/Arrow.svg',
                        width: 22,
                        height: 22,
                      ),
                    ),
                    Text(
                      'Schedule',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B1E28),
                      ),
                    ),
                    IconButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color(0xFFF7F7F9),
                        ),
                      ),
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/Notifications.svg',
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(15),
              Container(
                width: 335,
                height: 160,
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: EasyDateTimeLine(
                  initialDate: _focusDate,
                  onDateChange: (selectedDate) {
                    setState(() {
                      _focusDate = selectedDate;
                    });
                  },
                  headerProps: const EasyHeaderProps(
                    monthPickerType: MonthPickerType.switcher,
                    centerHeader: false,
                    monthStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    showHeader: true,
                    padding: EdgeInsets.only(bottom: 4),
                  ),
                  dayProps: const EasyDayProps(
                    height: 80,
                    width: 46,
                    activeDayDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    inactiveDayDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    inactiveDayNumStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    inactiveDayStrStyle: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    activeDayNumStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    activeDayStrStyle: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Gap(10),
              const Padding(
                padding: EdgeInsets.only(left: 18.0, right: 18),
                child: MiddleAppText(
                  text: 'Shedule',
                ),
              ),
              const Gap(10),
              TravelCardWidget(
                imagePath: 'assets/images/bgsearch.jpg',
                date: '26 January 2022',
                title: 'Kerinci Mountain',
                location: 'Solok, Jambi',
                onPressed: () {
                  print('Pressed Arrow');
                },
              ),
              const Gap(10),
              TravelCardWidget(
                imagePath: 'assets/images/bgsearch.jpg',
                date: '26 January 2022',
                title: 'Kerinci Mountain',
                location: 'Solok, Jambi',
                onPressed: () {
                  print('Pressed Arrow');
                },
              ),
              const Gap(10),
              TravelCardWidget(
                imagePath: 'assets/images/bgsearch.jpg',
                date: '26 January 2022',
                title: 'Kerinci Mountain',
                location: 'Solok, Jambi',
                onPressed: () {
                  print('Pressed Arrow');
                },
              ),
              const Gap(10),
              TravelCardWidget(
                imagePath: 'assets/images/bgsearch.jpg',
                date: '26 January 2022',
                title: 'Kerinci Mountain',
                location: 'Solok, Jambi',
                onPressed: () {
                  print('Pressed Arrow');
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
      padding: const EdgeInsets.only(left: 18.0, right: 18),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(5),
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
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
                angle: 3.1416, // 180 độ
                child: SvgPicture.asset(
                  'assets/icons/Arrow.svg',
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

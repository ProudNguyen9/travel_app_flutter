import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:travel_app/data/services/booking_history_service.dart';
import '../data/models/booking_history_item.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key}); // ❗ không còn userId

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> {
  static const Color accentBlue = Color(0xFF24BAEC);

  final _bookingService = BookingHistoryService();
  final _fmtVnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  final _fmtDay = DateFormat('dd MMM', 'vi_VN');
  final _fmtTime = DateFormat('HH:mm');

  late Future<List<BookingHistoryItem>> _upcomingFuture;
  late Future<List<BookingHistoryItem>> _completedFuture;
  late Future<List<BookingHistoryItem>> _canceledFuture;

  @override
  void initState() {
    super.initState();
    _upcomingFuture = _bookingService.getMyBookingsByStatus(
      status: 'upcoming',
    );
    _completedFuture = _bookingService.getMyBookingsByStatus(
      status: 'completed',
    );
    _canceledFuture = _bookingService.getMyBookingsByStatus(
      status: 'canceled',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double scale = (screenWidth / 390).clamp(0.85, 1.3);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 21 * scale,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Lịch sử đặt Tour',
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.4,
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 12 * scale),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.black54,
                  size: 23 * scale,
                ),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 15 * scale,
                    right: 15 * scale,
                  ),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(18 * scale),
                      ),
                      indicatorColor: Colors.transparent,
                      labelStyle: GoogleFonts.lato(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.lato(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Sắp tới'),
                        Tab(text: 'Hoàn tất'),
                        Tab(text: 'Đã hủy'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFutureTab(
                        future: _upcomingFuture,
                        emptyMessage: "Chưa có chuyến sắp tới",
                        scale: scale,
                      ),
                      _buildFutureTab(
                        future: _completedFuture,
                        emptyMessage: "Chưa có chuyến hoàn tất",
                        scale: scale,
                      ),
                      _buildFutureTab(
                        future: _canceledFuture,
                        emptyMessage: "Không có chuyến đã hủy",
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFutureTab({
    required Future<List<BookingHistoryItem>> future,
    required String emptyMessage,
    required double scale,
  }) {
    return FutureBuilder<List<BookingHistoryItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Lỗi tải dữ liệu',
              style: GoogleFonts.lato(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w400,
                color: Colors.red,
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _emptyTab(emptyMessage, scale);
        }

        return _buildBookingList(scale, items);
      },
    );
  }

  Widget _emptyTab(String message, double scale) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.lato(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildBookingList(double scale, List<BookingHistoryItem> items) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 14 * scale),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 14 * scale),
      itemBuilder: (context, index) {
        final item = items[index];

        final start = item.startDate;
        final end = item.endDate;

        final dateRange = (start != null && end != null)
            ? '${_fmtDay.format(start)} - ${_fmtDay.format(end)}'
            : 'Ngày khởi hành đang cập nhật';

        // ❌ cũ: lấy theo startDate
        // final timeText = start != null ? _fmtTime.format(start) : '--:--';

        // ✅ mới: ưu tiên giờ hoạt động đầu tiên, fallback về startDate booking
        final depart = item.firstActivityTime ?? item.startDate;
        final timeText = depart != null ? _fmtTime.format(depart) : '--:--';

        final priceText = _fmtVnd.format(item.finalAmount);

        final guestsText = '${item.totalGuests} khách';

        return _buildBookingCard(
          scale: scale,
          image: item.imageUrl ?? '',
          title: item.tourName,
          location: item.locationName.isNotEmpty
              ? item.locationName
              : 'Địa điểm đang cập nhật',
          dateRange: dateRange,
          time: timeText,
          price: priceText,
          guests: guestsText,
        );
      },
    );
  }

  Widget _buildBookingCard({
    required double scale,
    required String image,
    required String title,
    required String location,
    required String dateRange,
    required String time,
    required String price,
    required String guests,
  }) {
    final isNetworkImage = image.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== Ảnh + tiêu đề + location + khách ====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20 * scale),
                  child: SizedBox(
                    width: 100 * scale,
                    height: 80 * scale,
                    child: image.isEmpty
                        ? Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image_outlined,
                              size: 32 * scale,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : (isNetworkImage
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                image,
                                fit: BoxFit.cover,
                              )),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 18.5 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 3 * scale),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 18 * scale,
                          ),
                          SizedBox(width: 4 * scale),
                          Expanded(
                            child: Text(
                              location,
                              style: GoogleFonts.lato(
                                fontSize: 16.5 * scale,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: Colors.grey,
                            size: 18 * scale,
                          ),
                          SizedBox(width: 4 * scale),
                          Text(
                            guests,
                            style: GoogleFonts.lato(
                              fontSize: 16.5 * scale,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10 * scale),

            // ==== Ngày + giờ ====
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.grey,
                        size: 20 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Flexible(
                        child: Text(
                          dateRange,
                          style: GoogleFonts.lato(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 20 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Flexible(
                        child: Text(
                          "Khởi hành $time",
                          style: GoogleFonts.lato(
                            fontSize: 16.5 * scale,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10 * scale),

            // ==== Giá + nút ====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Giá: ",
                      style: GoogleFonts.lato(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.lato(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // TODO: cập nhật status booking -> 'canceled'
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 6 * scale,
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                      ),
                      child: Text(
                        "Hủy",
                        style: GoogleFonts.lato(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: mở chi tiết booking / contract / invoice ...
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scale,
                          vertical: 6 * scale,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Xem",
                        style: GoogleFonts.lato(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

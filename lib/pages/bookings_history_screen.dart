import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:travel_app/data/services/booking_history_service.dart';
import 'package:travel_app/pages/contract_screen.dart';
import 'package:travel_app/pages/itinerary_map_screen.dart';
import 'package:travel_app/utils/sendmail.dart';
import '../data/models/booking_history_item.dart';
import 'package:travel_app/data/services/booking_service.dart';

// 🔥 THÊM IMPORT
import 'package:travel_app/data/models/booking.dart';
import 'package:travel_app/data/services/profile_service.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key}); // ❗ không còn userId

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> {
  static const Color accentBlue = Color(0xFF24BAEC);
  final _bookingActionService = BookingService();

  final _bookingService = BookingHistoryService();
  final _fmtVnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  final _fmtDay = DateFormat('dd MMM', 'vi_VN');
  final _fmtTime = DateFormat('HH:mm');

  // 🔥 chống spam nút thanh toán
  bool _isPaying = false;

  late Future<List<BookingHistoryItem>> _upcomingFuture;
  late Future<List<BookingHistoryItem>> _completedFuture;
  late Future<List<BookingHistoryItem>> _canceledFuture;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  /// ✅ Chỉ cho hủy khi còn ít nhất 2 ngày (>= 48 giờ) trước giờ khởi hành
  bool _canCancel(DateTime startDate) {
    final now = DateTime.now();
    if (!startDate.isAfter(now)) return false;
    final diffHours = startDate.difference(now).inHours;
    return diffHours >= 48;
  }

  Future<void> _confirmCancelBooking(BookingHistoryItem item) async {
    final start = item.startDate;

    // ❌ Không đủ điều kiện hủy
    if (start == null || !_canCancel(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ được hủy trước 2 ngày khởi hành.'),
        ),
      );
      return;
    }

    // ❗ Dialog xác nhận
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy tour'),
          content: Text(
            'Bạn có chắc muốn hủy tour\n"${item.tourName}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hủy tour'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    // ============================
    // 🔥 XÁC ĐỊNH STATUS MỚI
    // ============================
    late String newStatus;

    final isPaid = item.status == 'DA_THANH_TOAN';

    if (item.status == 'CHUA_THANH_TOAN') {
      newStatus = 'HUY';
    } else if (isPaid) {
      newStatus = 'DA_HUY_CHUA_HOAN_TIEN';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không thể hủy tour với trạng thái hiện tại.')),
      );
      return;
    }

    // ============================
    // 🔥 UPDATE DATABASE
    // ============================
    final bookingId = item.bookingId;

    final success = await _bookingActionService.updateBookingStatus(
      bookingId,
      newStatus,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hủy tour thất bại, vui lòng thử lại.'),
        ),
      );
      return;
    }

    // ============================
    // 🔥 GỬI EMAIL THÔNG BÁO HỦY
    // ============================
    final profile = await ProfileService().getCurrentUserProfile();
    final email = profile?.email;

    try {
      await sendBookingCancelEmail(
        bookingId: item.bookingId,
        userEmail: email!,
        tourName: item.tourName,
        reason: "Người dùng yêu cầu hủy tour",
        refundPending: isPaid,
      );
    } catch (e) {
      print("❌ Gửi email hủy thất bại: $e");
    }

    // ============================
    // 🎉 THÔNG BÁO UI
    // ============================
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'HUY'
              ? 'Đã hủy tour.'
              : 'Đã hủy tour, đang chờ hoàn tiền.',
        ),
      ),
    );

    // 🔄 Refresh UI
    setState(_loadAll);
  }

  /// ✅ Thanh toán lại: dùng booking cũ nhưng ký HỢP ĐỒNG MỚI
  Future<void> _goToPayment(BookingHistoryItem item) async {
    if (_isPaying) return; // chặn double tap
    setState(() => _isPaying = true);

    try {
      // 1. Lấy profile hiện tại
      final profile = await ProfileService().getCurrentUserProfile();
      if (profile == null || profile.userId == null) {
        _toast('Không lấy được thông tin người dùng, vui lòng đăng nhập lại.');
        return;
      }

      // 2. Lấy booking đầy đủ từ DB theo bookingId
      final Booking? booking =
          await _bookingActionService.getBookingById(item.bookingId);

      if (booking == null) {
        _toast('Không tìm thấy thông tin đơn đặt tour này.');
        return;
      }

      // 3. Đảm bảo vẫn là CHUA_THANH_TOAN
      if (booking.status != 'CHUA_THANH_TOAN') {
        _toast('Đơn này hiện không còn ở trạng thái chờ thanh toán.');
        return;
      }

      // 4. Mở màn hình hợp đồng PDF để ký lại + thanh toán
      //    👉 Mỗi lần gọi showContractPdf, backend có thể tạo 1 record hợp đồng mới
      //       => user "ký hợp đồng mới" cho lần thanh toán này.
      await showContractPdf(
        context,
        booking: booking,
        user: profile,
        tourName: item.tourName,
      );

      // 5. Sau khi thanh toán + cập nhật trạng thái xong, refresh lại list
      setState(_loadAll);
    } catch (e) {
      _toast('Lỗi khi thực hiện thanh toán: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isPaying = false);
    }
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
                        Tab(text: 'Đã Hủy'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 🔥 Tab SẮP TỚI có riêng logic nút Hủy + Thanh toán
                      _buildFutureTab(
                        future: _upcomingFuture,
                        emptyMessage: "Chưa có chuyến sắp tới",
                        scale: scale,
                        isUpcoming: true,
                      ),
                      _buildFutureTab(
                        future: _completedFuture,
                        emptyMessage: "Chưa có chuyến hoàn tất",
                        scale: scale,
                        isUpcoming: false,
                      ),
                      _buildFutureTab(
                        future: _canceledFuture,
                        emptyMessage: "Không có chuyến đã hủy",
                        scale: scale,
                        isUpcoming: false,
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
    required bool isUpcoming,
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

        return _buildBookingList(scale, items, isUpcoming: isUpcoming);
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

  Widget _buildBookingList(
    double scale,
    List<BookingHistoryItem> items, {
    required bool isUpcoming,
  }) {
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

        // ưu tiên giờ hoạt động đầu tiên, fallback về startDate booking
        final depart = item.firstActivityTime ?? item.startDate;
        final timeText = depart != null ? _fmtTime.format(depart) : '--:--';

        final priceText = _fmtVnd.format(item.finalAmount);
        final guestsText = '${item.totalGuests} khách';

        return _buildBookingCard(
          scale: scale,
          item: item,
          isUpcoming: isUpcoming,
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
    required BookingHistoryItem item,
    required bool isUpcoming,
    required String dateRange,
    required String time,
    required String price,
    required String guests,
  }) {
    final image = item.imageUrl ?? '';
    final title = item.tourName;
    final location = item.locationName.isNotEmpty
        ? item.locationName
        : 'Địa điểm đang cập nhật';

    final isNetworkImage = image.startsWith('http');
    final start = item.startDate;

    // ====== Trạng thái ======
    final canCancel = isUpcoming && start != null && _canCancel(start);
    final isUnpaid = isUpcoming && item.status == 'CHUA_THANH_TOAN';
    final isPaid = isUpcoming && item.status == 'DA_THANH_TOAN';

    final isCanceledPlain = item.status == 'HUY';
    final isCanceledRefundPending = item.status == 'DA_HUY_CHUA_HOAN_TIEN';
    final isCanceledRefunded = item.status == 'DA_HUY_DA_HOAN_TIEN';

    // 🎯 Chip trạng thái hiển thị ở góc phải dòng "Giá"
    Widget? statusChip;
    if (isPaid) {
      statusChip = Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Text(
          "Đã thanh toán",
          style: GoogleFonts.lato(
            fontSize: 12.5 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
      );
    } else if (isCanceledRefunded) {
      statusChip = Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Text(
          "Đã hoàn tiền",
          style: GoogleFonts.lato(
            fontSize: 12.5 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
      );
    } else if (isCanceledRefundPending) {
      statusChip = Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Text(
          "Đang hoàn tiền",
          style: GoogleFonts.lato(
            fontSize: 12.5 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade700,
          ),
        ),
      );
    } else if (isCanceledPlain) {
      statusChip = Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Text(
          "Đã hủy",
          style: GoogleFonts.lato(
            fontSize: 12.5 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade600,
          ),
        ),
      );
    }

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
                            ? Image.network(image, fit: BoxFit.cover)
                            : Image.asset(image, fit: BoxFit.cover)),
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
                          Icon(Icons.location_on_outlined,
                              color: Colors.grey, size: 18 * scale),
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
                          Icon(Icons.people_outline,
                              color: Colors.grey, size: 18 * scale),
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
                      Icon(Icons.calendar_month_outlined,
                          color: Colors.grey, size: 20 * scale),
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
                      Icon(Icons.access_time,
                          color: Colors.grey, size: 20 * scale),
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

            // ==== Giá + CHIP TRẠNG THÁI ====
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
                if (statusChip != null) statusChip,
              ],
            ),

            SizedBox(height: 10 * scale),

            // ==== Nút hành động (xuống dòng riêng) ====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 4 * scale,
                  children: [
                    // === Nút HỦY (Dài & cân đẹp) - chỉ tab Sắp tới ===
                    if (isUpcoming)
                      OutlinedButton(
                        onPressed: canCancel
                            ? () => _confirmCancelBooking(item)
                            : null,
                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              Size(95 * scale, 40 * scale), // ⭐ dài hơn
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale, // ⭐ nút dài hơn
                            vertical: 10 * scale,
                          ),
                          side: BorderSide(
                            color: canCancel
                                ? Colors.grey.shade500
                                : Colors.grey.shade300,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                        ),
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w500,
                            color: canCancel ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),

                    // === Nút THANH TOÁN - chỉ đơn chưa thanh toán & còn sắp tới ===
                    if (isUnpaid)
                      ElevatedButton(
                        onPressed: () => _goToPayment(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: Size(110 * scale, 40 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale,
                            vertical: 10 * scale,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Thanh toán",
                          style: TextStyle(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // === Nút LỊCH TRÌNH - luôn có (xem chi tiết tour) ===
                    ElevatedButton(
                      onPressed: () {
                        if (item.startDate == null || item.endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Thiếu thông tin tour để xem lịch trình.'),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItineraryMapScreen(
                              tourId: item.tourId,
                              startDate: item.startDate!,
                              endDate: item.endDate!,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        minimumSize: Size(105 * scale, 40 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 18 * scale,
                          vertical: 10 * scale,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Lịch trình",
                        style: TextStyle(
                          fontSize: 15 * scale,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ==== Cảnh báo hủy (chỉ sắp tới & không còn đủ 2 ngày) ====
            if (isUpcoming && !canCancel)
              Padding(
                padding: EdgeInsets.only(top: 4 * scale),
                child: Text(
                  'Chỉ được hủy trước 2 ngày khởi hành',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    color: Colors.redAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

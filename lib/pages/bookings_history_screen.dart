import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingsHistoryScreen extends StatelessWidget {
  const BookingsHistoryScreen({super.key});

  final Color accentBlue = const Color(0xFF24BAEC);

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
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black, size: 21 * scale),
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
                child: Icon(Icons.more_vert,
                    color: Colors.black54, size: 23 * scale),
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
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.8),
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
                      _buildBookingList(scale),
                      _emptyTab("Chưa có chuyến hoàn tất", scale),
                      _emptyTab("Không có chuyến đã hủy", scale),
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

  Widget _buildBookingList(double scale) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 14 * scale),
      children: [
        _buildBookingCard(
          scale: scale,
          image: "assets/images/607d0368488549e7b9179724b0db4940.jpg",
          title: "The Nautilus Maldives",
          location: "Baa Atoll, Maldives",
          dateRange: "06 Thg 2 - 09 Thg 2",
          time: "16:25",
          price: "400.000 VND",
        ),
        SizedBox(height: 14 * scale),
        _buildBookingCard(
          scale: scale,
          image: "assets/images/mountain2.png",
          title: "Da Lat Mộng Mơ Resort",
          location: "Đà Lạt, Việt Nam",
          dateRange: "20 Thg 4 - 23 Thg 4",
          time: "14:00",
          price: "1.200.000 VND",
        ),
      ],
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
  }) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20 * scale),
                  child: Image.asset(
                    image,
                    width: 100 * scale,
                    height: 80 * scale,
                    fit: BoxFit.fill,
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
                            "1 khách (1 phòng)",
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
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale, vertical: 6 * scale),
                        side:
                            BorderSide(color: Colors.grey.shade400, width: 0.8),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16 * scale, vertical: 6 * scale),
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

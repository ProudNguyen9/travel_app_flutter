import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/people_also_like_model.dart';
import '../widget/reuseable_text.dart';
import '../models/tab_bar_model.dart';
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

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
                                        borderRadius: BorderRadius.circular(34),
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
                                          color: Colors.black.withOpacity(0.08),
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
                                TabViewChild(list: places)
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .shimmer(),
                                TabViewChild(list: inspiration)
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .shimmer(),
                                TabViewChild(list: popular)
                                    .animate()
                                    .fadeIn(duration: 400.ms)
                                    .shimmer(),
                              ]),
                        ),
                      ),
                      const Gap(5),
                      FadeInUp(
                          delay: const Duration(milliseconds: 1100),
                          child: const MiddleAppText(text: "Gợi ý nổi bật")),
                      FadeInUp(
                        delay: const Duration(milliseconds: 900),
                        child: Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            width: size.width,
                            height: 320,
                            child: ListView.builder(
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return const CardItemForYou();
                              },
                            )),
                      ),
                      FadeInUp(
                          delay: const Duration(milliseconds: 1200),
                          child: const MiddleAppText(
                              text: "Có thể bạn cũng thích")),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1300),
                        child: Container(
                          margin: EdgeInsets.only(top: size.height * 0.01),
                          width: size.width,
                          height: size.height * 1,
                          child: ListView.builder(
                              itemCount: 3,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                PeopleAlsoLikeModel current =
                                    peopleAlsoLikeModel[index];
                                return MayYouLikeItem(
                                    size: size, current: current);
                              }),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Thanh nổi ở dưới cùng
          const Align(
            alignment: Alignment.bottomCenter,
            child: SimpleBottomBar(),
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
    required this.current,
  });

  final Size size;
  final PeopleAlsoLikeModel current;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChooseMethodPayScreen(
            startDate: DateTime.now(),
            endDate: DateTime.now(),
          ),
        ),
      ),
      child: Container(
          margin: const EdgeInsets.all(8.0),
          width: size.width * 0.9,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage(current.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // lớp mờ phía dưới
              Container(
                height: 59,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              // nội dung overlay
              Positioned(
                bottom: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Islamabad → Bali",
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "12th June 2023 - 18th June 2023",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                          const Gap(4),
                          const Icon(Icons.location_on,
                              color: Colors.lightBlueAccent, size: 16),
                          const Gap(4),
                          Text("Indonesia",
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class CardItemForYou extends StatelessWidget {
  const CardItemForYou({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 87,
        width: 370,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 108, 108, 108).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.asset(
                  'assets/images/bgsearch.jpg',
                  width: 78,
                  height: 81,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Text(
                  'Kerinci Mountain',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                // Chip Hiking
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hiking',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Địa điểm + Sao + Điểm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Solok, Jambi',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.black54),
                    ),
                    const Gap(55),
                    const Icon(FontAwesomeIcons.solidStar,
                        size: 16, color: Color(0xFFFFD700)),
                    const Gap(6),
                    Text(
                      '4.3',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
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

// card item
class TabViewChild extends StatelessWidget {
  const TabViewChild({
    required this.list,
    Key? key,
  }) : super(key: key);

  final List<TabBarModel> list;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ListView.builder(
      itemCount: list.length,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        TabBarModel current = list[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailScreen(
                  // personData: null,
                  // tabData: current,
                  // isCameFromPersonSection: false,
                  ),
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Hero(
                tag: current.image,
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  width: size.width * 0.62,
                  height: size.height * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(current.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: size.height * 0.2,
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  width: size.width * 0.56,
                  height: size.height * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(153, 0, 0, 0),
                        Color.fromARGB(118, 29, 29, 29),
                        Color.fromARGB(54, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: size.width * 0.07,
                bottom: size.height * 0.045,
                child: AppText(
                  text: current.title,
                  size: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Positioned(
                left: size.width * 0.07,
                bottom: size.height * 0.025,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(
                      width: size.width * 0.01,
                    ),
                    AppText(
                      text: current.location,
                      size: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              // Positioned(
              //   top: 20,
              //   right: 20,
              //   child: Container(
              //     width: 32,
              //     height: 32,
              //     padding: const EdgeInsets.all(1),
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(0.25),
              //       shape: BoxShape.circle,
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.05),
              //           blurRadius: 4,
              //           offset: const Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     child: const Center(
              //       child: Icon(
              //         FontAwesomeIcons.solidHeart,
              //         color: Color(0xFFEB5757),
              //         size: 19,
              //       ),
              //     ),
              //   ),
              // ),
              const Positioned(
                  bottom: 25,
                  right: 20,
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.solidStar,
                        color: Colors.yellowAccent,
                        size: 17,
                      ),
                      Gap(5),
                      Text(
                        '5.0',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ))
            ],
          ),
        );
      },
    );
  }
}

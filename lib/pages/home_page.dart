import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/utils/extensions.dart';

import '../models/people_also_like_model.dart';
import '../pages/details_page.dart';
import '../widget/reuseable_text.dart';
import '../models/tab_bar_model.dart';
import '../widget/painter.dart';
import '../widget/reuseabale_middle_app_text.dart';
import '../widget/widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
        appBar: _buildAppBar(size),
        body: Stack(children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Padding(
              padding: padding,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: const Text(
                            'Explore the',
                            style: TextStyle(
                                color: Color(0xFF2E323E),
                                fontSize: 35,
                                fontWeight: FontWeight.w300),
                          )),
                      FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Beautiful ",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E323E),
                                      ),
                                    ),
                                    TextSpan(
                                      text: "world!",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFF7029),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/icons/muiten.png',
                                width: 60,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ],
                          )),
                      const Gap(20),
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
                            child: Center(
                              child: TextField(
                                  decoration: InputDecoration(
                                prefixIcon: SvgPicture.asset(
                                  'assets/icons/search.svg',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.scaleDown,
                                ),
                                hint: Text(
                                  'Where do you want now !',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF000000)),
                                ),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00B7C2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.sliders,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 45,
                                  minHeight: 45,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 17),
                              )),
                            ),
                          )),
                      const Gap(18),
                      FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CatergoryIcon(
                                  path: 'assets/icons/mountain.png',
                                  title: 'Mountian',
                                ),
                                CatergoryIcon(
                                  path: 'assets/icons/camp.png',
                                  title: 'Camp',
                                ),
                                CatergoryIcon(
                                  path: 'assets/icons/beach.png',
                                  title: 'Beach',
                                ),
                                CatergoryIcon(
                                  path: 'assets/icons/forest.png',
                                  title: 'Forest',
                                ),
                              ],
                            ),
                          )),
                      const Gap(15),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Container(
                          width: size.width * 0.9,
                          height: 160,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(224, 80, 237, 251),
                              borderRadius: BorderRadius.circular(21),
                              border: BoxBorder.all(
                                  width: 1, color: const Color(0xFF24BAEC))),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 20,
                                top: 25,
                                child: Column(
                                  children: [
                                    Text(
                                      'Get Discount\nup to',
                                      style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFFFFFFF)),
                                    ),
                                    Text(
                                      '90 %',
                                      style: GoogleFonts.lato(
                                          fontSize: 48,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFFFFFFF)),
                                    )
                                  ],
                                ),
                              ),
                              FadeInUp(
                                delay: const Duration(milliseconds: 600),
                                child: Container(
                                  width: size.width * 0.9,
                                  height: 160,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          224, 80, 237, 251),
                                      borderRadius: BorderRadius.circular(21),
                                      border: BoxBorder.all(
                                          width: 1,
                                          color: const Color(0xFF24BAEC))),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 20,
                                        top: 25,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Get Discount\nup to',
                                              style: GoogleFonts.lato(
                                                  fontSize: 18,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w900,
                                                  color:
                                                      const Color(0xFFFFFFFF)),
                                            ),
                                            Text(
                                              '80%',
                                              style: GoogleFonts.lato(
                                                  fontSize: 48,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w900,
                                                  color:
                                                      const Color(0xFFFFFFFF)),
                                            )
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                          right: -6,
                                          bottom: -50,
                                          child: Container(
                                            height: 200,
                                            width: 200,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFFF4E4DE),
                                                shape: BoxShape.circle),
                                          )),
                                      Positioned(
                                          right: -2,
                                          bottom: -50,
                                          child: Container(
                                            height: 180,
                                            width: 180,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFF3999B2),
                                                shape: BoxShape.circle),
                                          )),
                                      Positioned(
                                        right: 2,
                                        bottom: -8,
                                        child: Image.asset(
                                          'assets/images/discount.png',
                                          width: 170,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
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
                                Tab(
                                  text: "Places",
                                ),
                                Tab(text: "Inspiration"),
                                Tab(text: "Popular"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
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
                          delay: const Duration(milliseconds: 800),
                          child: const MiddleAppText(text: "Recommended")),
                      FadeInUp(
                        delay: const Duration(milliseconds: 900),
                        child: Container(
                            margin: EdgeInsets.only(top: size.height * 0.01),
                            width: size.width,
                            height: 320,
                            child: ListView.builder(
                              itemCount: 3,
                              itemBuilder: (context, index) {
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
                                            color: const Color.fromARGB(
                                                    255, 108, 108, 108)
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(21),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Tiêu đề
                                            Text(
                                              'Kerinci Mountain',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 4),

                                            // Chip Hiking
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black26),
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: Colors.black54),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Solok, Jambi',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                                const Gap(55),
                                                const Icon(
                                                    FontAwesomeIcons.solidStar,
                                                    size: 16,
                                                    color: Color(0xFFFFD700)),
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
                              },
                            )),
                      ),
                      FadeInUp(
                          delay: const Duration(milliseconds: 1100),
                          child: const MiddleAppText(text: "People Also Like")),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1200),
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
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsPage(
                                        personData: current,
                                        tabData: null,
                                        isCameFromPersonSection: true,
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
                                                  const BorderRadius.vertical(
                                                      bottom:
                                                          Radius.circular(20)),
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                            ),
                                          ),
                                          // nội dung overlay
                                          Positioned(
                                            bottom: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, bottom: 8),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Islamabad → Bali",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "12th June 2023 - 18th June 2023",
                                                        style: GoogleFonts.poppins(
                                                            color: const Color(
                                                                0xFFFFFFFF),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12),
                                                      ),
                                                      const Gap(4),
                                                      const Icon(
                                                          Icons.location_on,
                                                          color: Colors
                                                              .lightBlueAccent,
                                                          size: 16),
                                                      const Gap(4),
                                                      Text("Indonesia",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                );
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

  PreferredSize _buildAppBar(Size size) {
    return PreferredSize(
      preferredSize: Size.fromHeight(size.height * 0.09),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: const Icon(
            FontAwesomeIcons.bars,
            color: Colors.black,
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset("assets/images/main.png"),
                        ),
                      ),
                      const Gap(2),
                      const Text(
                        'Leonardo',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: Colors.black),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
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
              builder: (context) => DetailsPage(
                personData: null,
                tabData: current,
                isCameFromPersonSection: false,
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
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      FontAwesomeIcons.solidHeart,
                      color: Color(0xFFEB5757),
                      size: 19,
                    ),
                  ),
                ),
              ),
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

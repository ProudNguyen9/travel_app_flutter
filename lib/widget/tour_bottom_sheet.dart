import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:travel_app/widget/reuseable_text.dart';
import 'package:travel_app/utils/extensions.dart';

class BottomSheetContent extends StatelessWidget {
  const BottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 1.0, // 👈 Kéo full màn hình
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
              // 🔹 Thanh kéo cố định (drag handle)
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

              // 🔹 Phần nội dung có thể cuộn
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            text: "Detailed schedule",
                            size: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          const Gap(10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: Image.asset(
                              'assets/images/mountain2.png',
                              width: context.deviceSize.width,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Gap(20),
                          const Row(
                            children: [
                              AppText(
                                text: "Day 1  Morning",
                                size: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(width: 6),
                              Icon(FontAwesomeIcons.cloudSun,
                                  color: Colors.orangeAccent, size: 20),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 🕓 Timeline hoạt động buổi sáng
                          const Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.mugHot,
                                      color: Colors.brown, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "08:00 - Breakfast at hotel",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Enjoy local dishes with coffee ☕"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.umbrellaBeach,
                                      color: Colors.blueAccent, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "09:30 - Visit My Khe Beach",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Take photos and relax by the sea 🌊"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.personSwimming,
                                      color: Colors.teal, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "11:00 - Kayaking adventure",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Enjoy a fun kayaking experience 🛶"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(20),
                          const Row(
                            children: [
                              AppText(
                                text: "Day 1  Lunch",
                                size: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(width: 6),
                              Icon(FontAwesomeIcons.sun,
                                  color: Colors.amber, size: 20),
                            ],
                          ),
                          // 🕛 Lunch activities
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.utensils,
                                      color: Colors.deepOrange, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text:
                                              "12:30 - Lunch at local restaurant",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Taste the best seafood dishes 🦐"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.city,
                                      color: Colors.blueGrey, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text:
                                              "14:00 - Explore Da Nang city center",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Visit Dragon Bridge and Han Market 🏙️"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              AppText(
                                text: "Day 1  Dinner",
                                size: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(width: 6),
                              Icon(FontAwesomeIcons.moon,
                                  color: Colors.indigo, size: 20),
                            ],
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.bowlFood,
                                      color: Colors.purple, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "18:30 - Dinner by the river",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Romantic dinner with night view 🍷"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(FontAwesomeIcons.music,
                                      color: Colors.deepPurple, size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: "20:00 - Live music & chill",
                                          size: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        Text(
                                            "Enjoy live music near the riverside 🎶"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
}

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:travel_app/nav_pages.dart/main_wrapper.dart';

import '../models/welcome_model.dart';
import '../widget/reuseable_text.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: welcomeComponents.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final current = welcomeComponents[index];

              return SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- Top Text + Button ---
                    SizedBox(
                      width: size.width,
                      height: size.height * 0.4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: size.height * 0.03,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left texts
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FadeInRight(
                                    child: AppText(
                                      text: current.title,
                                      size: 36,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  FadeInLeft(
                                    child: AppText(
                                      text: current.subTitle,
                                      size: 26,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FadeInUp(
                                    delay: const Duration(milliseconds: 400),
                                    child: SizedBox(
                                      width: size.width * 0.75,
                                      child: AppText(
                                        text: current.description,
                                        size: 14,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  FadeInUpBig(
                                    duration:
                                        const Duration(milliseconds: 1100),
                                    child: MaterialButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      minWidth: size.width * 0.35,
                                      height: size.height * 0.055,
                                      color: Colors.deepPurpleAccent,
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MainWrapper(),
                                          ),
                                        );
                                      },
                                      child: const AppText(
                                        text: "Let's Go",
                                        size: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right dots indicator
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                welcomeComponents.length,
                                (indexDots) => GestureDetector(
                                  onTap: () {
                                    pageController.animateToPage(
                                      indexDots,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.linear,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    margin: EdgeInsets.only(
                                      bottom: size.height * 0.008,
                                    ),
                                    width: 10,
                                    height: index == indexDots ? 45 : 10,
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: index == indexDots
                                          ? Colors.deepPurpleAccent
                                          : const Color.fromARGB(
                                              255,
                                              193,
                                              170,
                                              255,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Bottom Image ---
                    FadeInUpBig(
                      duration: const Duration(milliseconds: 1200),
                      child: ShapeOfView(
                        width: size.width,
                        elevation: 4,
                        height: size.height * 0.55,
                        shape: DiagonalShape(
                          position: DiagonalPosition.Top,
                          direction: DiagonalDirection.Right,
                          angle: DiagonalAngle.deg(angle: 8),
                        ),
                        child: Image.asset(
                          current.imageUrl,
                          fit: BoxFit.cover,
                          width: size.width,
                          height: size.height * 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

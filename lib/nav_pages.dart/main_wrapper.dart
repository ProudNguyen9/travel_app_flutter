import 'package:flutter/material.dart';


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late final PageController pageController;
  int currentIndex = 0;
  List<Widget> pages = const [
   
  ];

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

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      children: pages,
    )
    ,
     
    ));
  }
}

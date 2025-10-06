class WelcomeModel {
  final String title;
  final String subTitle;
  final String description;
  final String imageUrl;

  WelcomeModel({
    required this.title,
    required this.subTitle,
    required this.description,
    required this.imageUrl,
  });
}

List<WelcomeModel> welcomeComponents = [
  WelcomeModel(
    title: "Travel",
    subTitle: "Roads",
    description:
        "Explore the charming roads of Dong Nai — where nature meets culture. Each journey reveals beautiful landscapes and local stories waiting to be discovered.",
    imageUrl: "assets/images/mountain.jpg",
  ),
  WelcomeModel(
    title: "Enjoy",
    subTitle: "Seas",
    description:
        "Relax by peaceful lakes and rivers like Tri An Lake and Dong Nai River. Enjoy the calm atmosphere and connect with the gentle rhythm of nature.",
    imageUrl: "assets/images/mountain2.png",
  ),
  WelcomeModel(
    title: "Discover",
    subTitle: "Mountains",
    description:
        "Climb Chua Chan Mountain or explore Buu Long’s rocky hills. Experience the adventure and the stunning views that make Dong Nai unforgettable.",
    imageUrl: "assets/images/3.jpg",
  ),
];

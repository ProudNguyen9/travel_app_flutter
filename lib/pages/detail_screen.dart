import 'dart:ui';
import 'package:flutter/material.dart';
import 'more_detail_screen.dart';
import '../models/people_also_like_model.dart';
import '../models/tab_bar_model.dart';
import '../widget/reuseable_text.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    super.key,
    required this.tabData,
    required this.personData,
    required this.isCameFromPersonSection,
  });

  final TabBarModel? tabData;
  final PeopleAlsoLikeModel? personData;
  final bool isCameFromPersonSection;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with TickerProviderStateMixin {
  final EdgeInsetsGeometry padding =
      const EdgeInsets.symmetric(horizontal: 20.0);
  dynamic current;

  double _headerScale = 1.0;
  late final AnimationController _rebound;
  late Animation<double> _reboundTween;
  VoidCallback? _reboundListener;

  late final AnimationController _entrance;
  late final Animation<double> _fadeIn;
  late final DraggableScrollableController _sheetCtrl;

  late List<String> galleryImages;
  int selectedImageIndex = 0;

  void _pickCurrent() {
    current = (widget.tabData == null) ? widget.personData : widget.tabData;
  }

  @override
  void initState() {
    super.initState();
    _pickCurrent();

    galleryImages = [
      current.image,
      "assets/images/main.png",
      'assets/images/discount.png',
    ];

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeIn = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);

    _rebound = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _sheetCtrl = DraggableScrollableController();

    _entrance.forward();
  }

  @override
  void dispose() {
    if (_reboundListener != null) {
      _rebound.removeListener(_reboundListener!);
      _reboundListener = null;
    }
    _rebound.dispose();
    _entrance.dispose();
    super.dispose();
  }

  bool _onScrollNotif(ScrollNotification n) {
    if (n is OverscrollNotification && n.overscroll < 0) {
      final add = (-n.overscroll) / 300;
      final next = (1.0 + add).clamp(1.0, 1.25);
      setState(() => _headerScale = next);
      return false;
    }
    if ((n is ScrollEndNotification || n is UserScrollNotification) &&
        _headerScale > 1.0) {
      if (_reboundListener != null) {
        _rebound.removeListener(_reboundListener!);
        _reboundListener = null;
      }
      _rebound.stop();
      _rebound.reset();
      _reboundTween = Tween<double>(begin: _headerScale, end: 1.0).animate(
          CurvedAnimation(parent: _rebound, curve: Curves.easeOutCubic));
      _reboundListener =
          () => setState(() => _headerScale = _reboundTween.value);
      _rebound.addListener(_reboundListener!);
      _rebound.forward();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const snaps = [0.52, 0.8, 1.0];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotif,
        child: Stack(
          children: [
            // ======= HEADER IMAGE =======
            Positioned.fill(
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Hero(
                      key: ValueKey(galleryImages[selectedImageIndex]),
                      tag: widget.isCameFromPersonSection
                          ? (current.day ?? current.image)
                          : current.image,
                      child: Transform.scale(
                        scale: _headerScale,
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: size.height * 0.65,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage(galleryImages[selectedImageIndex]),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ======= MINI GALLERY PILL =======
                  Positioned(
                    right: 14,
                    top: size.height * 0.18,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: _MiniGalleryPill(
                        images: galleryImages,
                        selectedIndex: selectedImageIndex,
                        onImageTap: (i) {
                          setState(() => selectedImageIndex = i);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======= WHITE SHEET CONTENT =======
            _BottomSnapSheet(
              controller: _sheetCtrl,
              initial: snaps.first,
              min: snaps.first,
              max: snaps.last,
              snaps: snaps,
              padding: padding,
              entrance: _fadeIn,
              header: const SizedBox(height: 16),
              contentBuilder: (ctx, controller) => [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: current.title ?? 'The Nautilus',
                            size: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            text: current.location ?? 'Maldives',
                            size: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          text: '\$85/Day',
                          size: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _BlueLink(text: 'Overview'),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    _InfoBadge(
                      icon: Icons.access_time_filled,
                      title: 'DURATION           ',
                      value: '3 Days',
                    ),
                    SizedBox(width: 14),
                    _InfoBadge(
                      icon: Icons.star,
                      title: 'RATING',
                      value: '5.0  (2.9k Reviews)',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AppText(
                  text:
                      'The Nautilus is a privately-owned luxury resort in the Baa atoll UNESCO biosphere reserve, near Hanifaru Bay where you can swim with manta rays in season. This natural island has its own outstanding coral reef just metres from its beaches.',
                  size: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24BAEC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoreDetailScreen(
                                  image: current.image,
                                  title:
                                      current.title ?? 'The Nautilus Maldives',
                                  location:
                                      '${current.title ?? 'The Nautilus Maldives'}, ${current.location ?? 'Baa Atoll'}',
                                  pricePerDay: '\$85/Day',
                                  rating: 5.0,
                                  photos: galleryImages,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF24BAEC), width: 1.6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21)),
                          ),
                          child: const Text(
                            'More Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF24BAEC),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SafeArea(top: false, child: SizedBox(height: 4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 22,
        ),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
    );
  }
}

/* ------------------------- Sub-widgets ------------------------- */
class _MiniGalleryPill extends StatelessWidget {
  const _MiniGalleryPill({
    required this.images,
    required this.selectedIndex,
    required this.onImageTap,
    this.bg,
    this.blur = 6,
  });

  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onImageTap;
  final Color? bg;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final Color base = bg ?? Colors.white.withOpacity(0.75);
    final bool isLight = base.computeLuminance() > 0.5;
    final Color borderColor = isLight ? Colors.black26 : Colors.white30;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < images.length; i++) ...[
                GestureDetector(
                  onTap: () => onImageTap(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == selectedIndex
                            ? const Color(0xFF24BAEC)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        images[i],
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '+${images.length - 3 > 0 ? images.length - 3 : 0}',
                style: const TextStyle(
                  color: Color(0xFF24BAEC),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------- Reusable Widgets ------------------------- */
class _BlueLink extends StatelessWidget {
  const _BlueLink({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF24BAEC),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F9FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24BAEC), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF24BAEC)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF24BAEC),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSnapSheet extends StatelessWidget {
  const _BottomSnapSheet({
    required this.padding,
    required this.header,
    required this.contentBuilder,
    required this.entrance,
    required this.controller,
    this.initial = 0.52,
    this.min = 0.52,
    this.max = 1.0,
    this.snaps = const [0.52, 0.8, 1.0],
  });

  final double initial;
  final double min;
  final double max;
  final List<double> snaps;
  final EdgeInsetsGeometry padding;
  final Widget header;
  final List<Widget> Function(BuildContext, ScrollController) contentBuilder;
  final Animation<double> entrance;
  final DraggableScrollableController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initial,
      minChildSize: min,
      maxChildSize: max,
      snap: true,
      snapSizes: snaps,
      builder: (ctx, listCtrl) {
        final pad = padding.resolve(Directionality.of(ctx));
        return FadeTransition(
          opacity: entrance,
          child: Material(
            color: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              controller: listCtrl,
              physics: const BouncingScrollPhysics(),
              padding: pad.copyWith(
                bottom: pad.bottom + MediaQuery.of(ctx).padding.bottom + 18,
              ),
              children: [
                const SizedBox(height: 8),
                header,
                ...contentBuilder(ctx, listCtrl),
              ],
            ),
          ),
        );
      },
    );
  }
}

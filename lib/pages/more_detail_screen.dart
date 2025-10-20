import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:gap/gap.dart';

class MoreDetailScreen extends StatefulWidget {
  const MoreDetailScreen({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    required this.pricePerDay, // ví dụ: "$85/Day"
    this.rating = 5.0,
    this.photos = const [],
  });

  final String image;
  final String title;
  final String location;
  final String pricePerDay;
  final double rating;
  final List<String> photos;

  @override
  State<MoreDetailScreen> createState() => _MoreDetailScreenState();
}

class _MoreDetailScreenState extends State<MoreDetailScreen>
    with TickerProviderStateMixin {
  DateTime? checkIn;
  DateTime? checkOut;

  Future<void> _pickCheckIn() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: checkIn ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => checkIn = d);
  }

  Future<void> _pickCheckOut() async {
    final base = checkIn ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: checkOut ?? base.add(const Duration(days: 1)),
      firstDate: base.add(const Duration(days: 1)),
      lastDate: base.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => checkOut = d);
  }

  @override
  Widget build(BuildContext context) {
    const kRadius = 26.0;
    final h = MediaQuery.of(context).size.height;
    final expandedH = math.min(h * 0.38, 360.0); // Ảnh to hơn, tối đa 360

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, inner) => [
            // === REPLACE SliverAppBar in headerSliverBuilder with this ===
            SliverAppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                pinned: true,
                floating: false,

                // Ảnh header to hơn (40% màn hình, tối đa 380px)
                expandedHeight: (() {
                  final h = MediaQuery.of(context).size.height;
                  return math.min(h * 0.40, 380.0);
                })(),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                ),

                // KHÔNG bo tròn AppBar nữa; để ảnh full-width
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.image,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                      Positioned(
                        right: 16,
                        top: 40,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                // Phần "navbar" dạng sheet bo tròn như ảnh mẫu
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 18), // chừa chỗ cho handle
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      child: Material(
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: const Align(
                            alignment:
                                Alignment.center, // căn giữa toàn bộ TabBar
                            child: TabBar(
                              isScrollable:
                                  false, // quan trọng: tắt scroll để căn giữa
                              labelColor: Color(0xFF24BAEC),
                              unselectedLabelColor: Color(0xFF151111),
                              labelStyle: TextStyle(
                                fontSize: 13,
                                height: 1.25, // tương đương lineHeight = 16
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 13,
                                height: 1.25,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                              ),
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                    width: 2.5, color: Color(0xFF24BAEC)),
                                insets: EdgeInsets.symmetric(horizontal: 28),
                              ),
                              labelPadding:
                                  EdgeInsets.symmetric(horizontal: 18),
                              tabs: [
                                Tab(text: 'Details'),
                                Tab(text: 'Reviews'),
                                Tab(text: 'Choose date'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
          body: const TabBarView(
            children: [
              _DetailsTab(),
              _ReviewsTab(),
              _ChooseDateTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/* ========================= Tabs ========================= */

class _DetailsTab extends StatelessWidget {
  const _DetailsTab();

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF24BAEC);
    final args =
        context.findAncestorStateOfType<_MoreDetailScreenState>()!; // lấy props

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- Header: Amenities + Rating ---
        Card(
          elevation: 0,
          color: Colors.blue[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const _Amenity(icon: Icons.wifi, label: 'Free Wifi'),
                const SizedBox(width: 14),
                const _Amenity(icon: Icons.free_breakfast, label: 'Breakfast'),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        args.widget.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // --- Title + Price ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                args.widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                args.widget.pricePerDay,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: kPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // --- Location ---
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 18, color: kPrimary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                args.widget.location,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Divider(),

        // --- Description ---
        const SizedBox(height: 12),
        const Text(
          'Description',
          style: TextStyle(
            color: kPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Each of the 26 houses is a suite with separate living and bedrooms, as well as a personal butler, private pool and ocean views. Guests can enjoy free wifi, complimentary drinks, and champagne on arrival.as well as a personal butler, private pool and ocean views. Guests can enjoy free wifi, complimentary drinks, and champagne on arrival.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),

        const SizedBox(height: 18),

        // --- View Schedule Button ---
        Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24BAEC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
              ),
              elevation: 3,
            ),
            onPressed: () {
              // TODO: add navigation or action
            },
            icon: const Icon(Icons.calendar_month_rounded, size: 20),
            label: const Text(
              'View Schedule',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Amenity extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Amenity({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF24BAEC), size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: const [
        _ReviewTile(
          name: 'Alex',
          rating: 5,
          text:
              'Amazing stay! Staff were super friendly and the villa view is breathtaking.',
        ),
        SizedBox(height: 12),
        _ReviewTile(
          name: 'Mina',
          rating: 4,
          text:
              'Great breakfast and clean rooms. A bit far from downtown but totally worth it.',
        ),
      ],
    );
  }
}

class _ChooseDateTab extends StatelessWidget {
  const _ChooseDateTab();

  String _fmt(DateTime? d) {
    if (d == null) return 'Select';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF24BAEC);
    final state = context.findAncestorStateOfType<_MoreDetailScreenState>()!;
    final enabled = state.checkIn != null && state.checkOut != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Opening Hours ---
                  const OpeningHoursSection(),
                  const SizedBox(height: 10),

                  // --- Section title ---
                  const Row(
                    children: [
                      Icon(Icons.event_available, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Select your stay',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // --- Date selectors ---
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Check in',
                          value: _fmt(state.checkIn),
                          onTap: state._pickCheckIn,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateField(
                          label: 'Check out',
                          value: _fmt(state.checkOut),
                          onTap: state._pickCheckOut,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  // --- Book Now button ---
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: enabled ? () {} : null,
                        icon:
                            const Icon(Icons.flight_takeoff_rounded, size: 20),
                        label: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          disabledBackgroundColor: kPrimary.withOpacity(.4),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF24BAEC);
    final isSelected = value != 'Select';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimary : Colors.black26,
            width: 1.2,
          ),
          color: isSelected ? kPrimary.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 18, color: isSelected ? kPrimary : Colors.black45),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? kPrimary : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== Small pieces ===================== */

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.text,
  });

  final String name;
  final int rating;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 18, child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OpeningHoursSection extends StatelessWidget {
  const OpeningHoursSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(children: [
          Icon(Icons.access_time, color: Colors.black54),
          SizedBox(width: 8),
          Text('Opening Hours',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        const SizedBox(height: 8),
        Container(height: 1, color: Colors.black12.withOpacity(.15)),
        const SizedBox(height: 10),
        ..._weekRows,
      ],
    );
  }
}

final _weekRows = <Widget>[
  _hoursRow('Sunday', '24 Hours'),
  _hoursRow('Monday', '24 Hours'),
  _hoursRow('Tuesday', '24 Hours'),
  _hoursRow('Wednesday', '24 Hours'),
  _hoursRow('Thursday', '24 Hours', highlight: true),
  _hoursRow('Friday', '24 Hours'),
  _hoursRow('Saturday', '24 Hours'),
];

Widget _hoursRow(String day, String hours, {bool highlight = false}) {
  final style = TextStyle(
    fontSize: 14,
    color: highlight ? const Color(0xFF1E66FF) : Colors.black87,
    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
  );
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(child: Text(day, style: style)),
        Text(hours,
            style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    ),
  );
}

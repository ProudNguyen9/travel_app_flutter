import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/models/TourActivityPrice.dart';

import 'package:travel_app/data/services/tour_pricing_service.dart';

/// ===== Full-screen Price Detail (dữ liệu thật từ Supabase RPC) =====
/// - Nhận tourId + travelDate
/// - Gọi get_tour_activity_prices_min
/// - Hiển thị bảng: Hoạt động | Người lớn | Trẻ em | Người già
class PriceDetailScreen extends StatefulWidget {
  const PriceDetailScreen({
    super.key,
    required this.tourId,
    required this.travelDate,
  });

  final int tourId;
  final DateTime travelDate;

  @override
  State<PriceDetailScreen> createState() => _PriceDetailScreenState();
}

class _PriceDetailScreenState extends State<PriceDetailScreen> {
  final _fmt =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  late final TourPricingService _service;

  bool _loading = true;
  String? _error;
  List<TourActivityPrice> _rows = [];

  @override
  void initState() {
    super.initState();
    _service = TourPricingService(Supabase.instance.client);
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getActivityPrices(
        tourId: widget.tourId,
        travelDate: widget.travelDate,
      );
      setState(() {
        _rows = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  EdgeInsets _cellPad([double h = 10, double v = 8]) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  @override
  Widget build(BuildContext context) {
    final headerStyle =
        GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 13);
    final bodyBold =
        GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 13);
    final bodySemi =
        GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 13);

    Widget th(String text, {TextAlign align = TextAlign.left}) => Padding(
        padding: _cellPad(),
        child: Text(text, textAlign: align, style: headerStyle));

    Widget td(String text,
            {TextAlign align = TextAlign.left, bool strong = false}) =>
        Padding(
            padding: _cellPad(),
            child: Text(text,
                textAlign: align, style: strong ? bodyBold : bodySemi));

    Widget buildTablePortrait(double screenW) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenW),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              columnWidths: const <int, TableColumnWidth>{
                0: IntrinsicColumnWidth(), // Hoạt động
                1: IntrinsicColumnWidth(), // Người lớn
                2: IntrinsicColumnWidth(), // Trẻ em
                3: IntrinsicColumnWidth(), // Người già
              },
              border: const TableBorder(
                horizontalInside:
                    BorderSide(color: Color(0xFFE8E8E8), width: 1),
              ),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                  children: [
                    th('Hoạt động'),
                    th('Người lớn', align: TextAlign.right),
                    th('Trẻ em', align: TextAlign.right),
                    th('Người già', align: TextAlign.right),
                  ],
                ),
                ..._rows.asMap().entries.map((e) {
                  final i = e.key;
                  final r = e.value;
                  final rowBg =
                      i.isOdd ? const Color(0xFFFBFCFD) : Colors.white;
                  return TableRow(
                    decoration: BoxDecoration(color: rowBg),
                    children: [
                      td(r.activityName ?? '—'),
                      td(_fmt.format(r.adultPrice ?? 0),
                          align: TextAlign.right, strong: true),
                      td(_fmt.format(r.childPrice ?? 0),
                          align: TextAlign.right),
                      td(_fmt.format(r.seniorPrice ?? 0),
                          align: TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildTableLandscape(double screenW) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenW),
          child: Table(
            defaultColumnWidth: const FlexColumnWidth(),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            border: const TableBorder(
              horizontalInside: BorderSide(color: Color(0xFFE8E8E8), width: 1),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
                children: [
                  th('Hoạt động'),
                  th('Người lớn', align: TextAlign.right),
                  th('Trẻ em', align: TextAlign.right),
                  th('Người già', align: TextAlign.right),
                ],
              ),
              ..._rows.asMap().entries.map((e) {
                final i = e.key;
                final r = e.value;
                final rowBg = i.isOdd ? const Color(0xFFFBFCFD) : Colors.white;
                return TableRow(
                  decoration: BoxDecoration(color: rowBg),
                  children: [
                    td(r.activityName ?? '—'),
                    td(_fmt.format(r.adultPrice ?? 0),
                        align: TextAlign.right, strong: true),
                    td(_fmt.format(r.childPrice ?? 0), align: TextAlign.right),
                    td(_fmt.format(r.seniorPrice ?? 0), align: TextAlign.right),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bảng giá chi tiết',
            style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 40, color: Colors.redAccent),
                          const SizedBox(height: 8),
                          Text('Không tải được bảng giá.',
                              style: GoogleFonts.lato(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('Chi tiết: $_error',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 12)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _fetch,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          )
                        ],
                      ),
                    ),
                  )
                : OrientationBuilder(
                    builder: (context, orientation) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final screenW = constraints.maxWidth;
                          return orientation == Orientation.portrait
                              ? buildTablePortrait(screenW)
                              : buildTableLandscape(screenW);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

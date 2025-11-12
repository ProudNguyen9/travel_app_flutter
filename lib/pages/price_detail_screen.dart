import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:travel_app/data/models/TourActivityPrice.dart';
import 'package:travel_app/data/services/tour_pricing_service.dart';

/// Bảng giá chi tiết (phẳng kiểu Word) + dòng TỔNG CỘNG
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

  // ===== Styles =====
  EdgeInsets _cellPad([double h = 12, double v = 10]) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);

  TextStyle get _thStyle => GoogleFonts.lato(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: const Color(0xFF1B1E28),
      );

  TextStyle get _tdBold => GoogleFonts.lato(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: const Color(0xFF1B1E28),
      );

  TextStyle get _tdSemi => GoogleFonts.lato(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: const Color(0xFF243039),
      );

  Widget _th(String text, {TextAlign align = TextAlign.left}) => Padding(
        padding: _cellPad(),
        child: Align(
          alignment: align == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Text(text, style: _thStyle),
        ),
      );

  Widget _td(
    String text, {
    TextAlign align = TextAlign.left,
    bool strong = false,
  }) =>
      Padding(
        padding: _cellPad(),
        child: Align(
          alignment: align == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Text(text, style: strong ? _tdBold : _tdSemi),
        ),
      );

  // Tổng theo cột + dòng tổng
  TableRow _buildTotalRow() {
    final totalAdult = _rows.fold<double>(0, (s, r) => s + (r.adultPrice ?? 0));
    final totalChild = _rows.fold<double>(0, (s, r) => s + (r.childPrice ?? 0));
    final totalSenior =
        _rows.fold<double>(0, (s, r) => s + (r.seniorPrice ?? 0));
    final totalAll = totalAdult + totalChild + totalSenior;

    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFEAF5FF),
        border: Border(
          top: BorderSide(color: Color(0xFFD8DEE6), width: 1),
        ),
      ),
      children: [
        Padding(
          padding: _cellPad(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TỔNG CỘNG',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF005BBF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Số hoạt động: ${_rows.length}',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF51616F),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: _cellPad(),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _fmt.format(totalAdult),
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B1E28),
              ),
            ),
          ),
        ),
        Padding(
          padding: _cellPad(),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _fmt.format(totalChild),
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B1E28),
              ),
            ),
          ),
        ),
        Padding(
          padding: _cellPad(),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              _fmt.format(totalSenior),
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B1E28),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Bảng – không khung, header có gạch chân, body zebra + phân cách mảnh
  Widget _buildTablePortrait(double screenW) {
    const headerBg = Color(0xFFF5F7FA);

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
            border: const TableBorder(), // bỏ toàn bộ khung
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: headerBg,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFD8DEE6), width: 1),
                  ),
                ),
                children: [
                  _th('Hoạt động'),
                  _th('Người lớn', align: TextAlign.right),
                  _th('Trẻ em', align: TextAlign.right),
                  _th('Người cao tuổi', align: TextAlign.right),
                ],
              ),
              ..._rows.asMap().entries.map((e) {
                final i = e.key;
                final r = e.value;
                final rowBg = i.isOdd ? const Color(0xFFFAFBFC) : Colors.white;

                return TableRow(
                  children: [
                    Container(
                      color: rowBg,
                      child: _td(r.activityName ?? '—'),
                    ),
                    Container(
                      color: rowBg,
                      child: _td(_fmt.format(r.adultPrice ?? 0),
                          align: TextAlign.right, strong: true),
                    ),
                    Container(
                      color: rowBg,
                      child: _td(_fmt.format(r.childPrice ?? 0),
                          align: TextAlign.right),
                    ),
                    Container(
                      color: rowBg,
                      child: _td(_fmt.format(r.seniorPrice ?? 0),
                          align: TextAlign.right),
                    ),
                  ],
                );
              }),
              _buildTotalRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableLandscape(double screenW) {
    const headerBg = Color(0xFFF5F7FA);

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
          border: const TableBorder(), // bỏ khung
          children: [
            TableRow(
              decoration: const BoxDecoration(
                color: headerBg,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFD8DEE6), width: 1),
                ),
              ),
              children: [
                _th('Hoạt động'),
                _th('Người lớn', align: TextAlign.right),
                _th('Trẻ em', align: TextAlign.right),
                _th('Người già', align: TextAlign.right),
              ],
            ),
            ..._rows.asMap().entries.map((e) {
              final i = e.key;
              final r = e.value;
              final rowBg = i.isOdd ? const Color(0xFFFAFBFC) : Colors.white;

              return TableRow(
                children: [
                  Container(
                    color: rowBg,
                    child: _td(r.activityName ?? '—'),
                  ),
                  Container(
                    color: rowBg,
                    child: _td(_fmt.format(r.adultPrice ?? 0),
                        align: TextAlign.right, strong: true),
                  ),
                  Container(
                    color: rowBg,
                    child: _td(_fmt.format(r.childPrice ?? 0),
                        align: TextAlign.right),
                  ),
                  Container(
                    color: rowBg,
                    child: _td(_fmt.format(r.seniorPrice ?? 0),
                        align: TextAlign.right),
                  ),
                ],
              );
            }),
            _buildTotalRow(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          'Bảng giá chi tiết',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.refresh, color: Colors.black),
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
                              ? _buildTablePortrait(screenW)
                              : _buildTableLandscape(screenW);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

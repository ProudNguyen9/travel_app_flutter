import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:travel_app/data/models/tour_full.dart';
import 'package:travel_app/pages/discount_picker_screen.dart';
import 'package:travel_app/pages/payment_tour_screen.dart';
import 'package:travel_app/utils/duration_formatter.dart';

double fix(double v, double scale) => (v + 4) * scale;

class BookingTourScreen extends StatefulWidget {
  const BookingTourScreen({
    super.key,
    required this.tour,
  });

  final TourFull tour;

  @override
  State<BookingTourScreen> createState() => _BookingTourScreenState();
}

class _BookingTourScreenState extends State<BookingTourScreen> {
  final Color accentBlue = const Color(0xFF24BAEC);
  final Color borderBlue = const Color(0xFF005BBF);
  final Color bgGray = const Color(0xFFF7F7F7);

  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _startDate;

  // Trẻ – Già – Lớn (chỉ khống chế tổng theo tour.maxParticipants)
  int _youth = 0, _senior = 0, _adult = 2;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
  }

  // ==== helpers ====
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
// NGÀY ĐƯỢC PHÉP CHỌN = hôm nay + 3 ngày trở đi
  bool _isSelectableDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minStart = today.add(const Duration(days: 3)); // 👈 +3 ngày

    final x = DateTime(d.year, d.month, d.day);
    return !x.isBefore(minStart); // chỉ cho chọn nếu >= minStart
  }

  int get _maxPeople => widget.tour.maxParticipants ?? 10; // fallback 10
  int get _totalSelected => _youth + _senior + _adult;
  bool get _canAddMore => _totalSelected < _maxPeople;

  // KẾT THÚC = KHỞI HÀNH + số ĐÊM (nights)
  DateTime? get _endDate {
    if (_startDate == null) return null;
    final nights = nightsFromDuration(widget.tour.durationDays);
    return _startDate!.add(Duration(days: nights));
  }

  bool _inSelectedRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    final end = _endDate!;
    final x = DateTime(day.year, day.month, day.day);
    final s = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final e = DateTime(end.year, end.month, end.day);
    return !x.isBefore(s) && !x.isAfter(e);
  }

  List<DateTime> _daysForMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final daysBefore = first.weekday - 1; // Mon=1
    final daysAfter = 7 - last.weekday; // Sun=7 -> 0
    final total = last.day + daysBefore + (daysAfter == 7 ? 0 : daysAfter);
    return List.generate(
        total, (i) => first.subtract(Duration(days: daysBefore - i)));
  }

  void _guardedInc(VoidCallback doInc) {
    if (_canAddMore) {
      setState(doInc);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đã đạt tối đa $_maxPeople người cho tour này.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 390).clamp(0.85, 1.25);
    final days = _daysForMonth(_focusedMonth);
    final monthName = DateFormat('MMMM yyyy', 'vi_VN').format(_focusedMonth);
    final monthTitle = monthName[0].toUpperCase() + monthName.substring(1);

    return Scaffold(
      backgroundColor: Colors.white,

      // === AppBar ===
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 24 * scale, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.tour.name,
          style: GoogleFonts.lato(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: fix(14, scale)),
        ),
      ),

      // === Bottom button ===
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(16 * scale, 8, 16 * scale, 16 * scale),
        child: SizedBox(
          height: 56 * scale,
          child: ElevatedButton(
            onPressed: _startDate == null
                ? null
                : () {
                    final maxP = widget.tour.maxParticipants ?? 9999;
                    final total = _adult + _youth + _senior;

                    if (total < 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Vui lòng chọn ít nhất 1 người.')),
                      );
                      return;
                    }

                    // 1) Trẻ em phải có người lớn đi kèm
                    if (_youth > 0 && _adult == 0 && _senior == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Trẻ em phải có người lớn đi kèm.')),
                      );
                      return;
                    }

                    // 3) Không vượt quá sức chứa
                    if (total > maxP) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Vượt quá sức chứa ($maxP người cho tour này).')),
                      );
                      return;
                    }

                    // OK -> đi tiếp
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentTourScreen(
                          tour: widget.tour,
                          startDate: _startDate!,
                          adults: _adult,
                          children: _youth,
                          seniors: _senior,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              disabledBackgroundColor: accentBlue.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34 * scale)),
              elevation: 2,
            ),
            child: Text(
              _startDate == null ? "Chọn ngày khởi hành" : "Tiếp tục",
              style: GoogleFonts.lato(
                  fontSize: fix(14, scale),
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
      ),

      // === Body ===
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12 * scale),

            // Header tháng + chip "X ngày Y đêm"
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: borderBlue.withOpacity(0.3), width: 0.6),
                  ),
                  child: Text(
                    formatDurationLabel(widget.tour.durationDays), // utils
                    style: GoogleFonts.lato(
                        fontSize: fix(11, scale),
                        fontWeight: FontWeight.w700,
                        color: borderBlue),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.chevron_left,
                      size: 18 * scale, color: Colors.black54),
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1, 1);
                  }),
                ),
                Text(monthTitle,
                    style: GoogleFonts.lato(
                        fontSize: fix(13, scale), fontWeight: FontWeight.w600)),
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      size: 18 * scale, color: Colors.black54),
                  onPressed: () => setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1, 1);
                  }),
                ),
              ],
            ),

            SizedBox(height: 8 * scale),

            // Tên thứ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
                  .map((d) => Expanded(
                        child: Center(
                            child: Text(d,
                                style: GoogleFonts.lato(
                                    fontSize: fix(10, scale),
                                    fontWeight: FontWeight.w700))),
                      ))
                  .toList(),
            ),
            SizedBox(height: 6 * scale),

            // Calendar (tô dải KHỞI HÀNH → KẾT THÚC)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: GridView.builder(
                key: ValueKey(_focusedMonth),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 10 * scale, top: 4 * scale),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                ),
                itemCount: _daysForMonth(_focusedMonth).length,
                itemBuilder: (_, i) {
                  final day = _daysForMonth(_focusedMonth)[i];
                  final inMonth = day.month == _focusedMonth.month;

                  final selectedStart =
                      _startDate != null && _sameDay(_startDate!, day);
                  final selectedEnd = _startDate != null &&
                      _endDate != null &&
                      _sameDay(_endDate!, day);
                  final inRange = _startDate != null && _inSelectedRange(day);

                  // selectable: ngày trong tháng đang xem + từ hôm nay + 3 ngày trở đi
                  final selectable = inMonth && _isSelectableDay(day);

                  Color bg;
                  Color textColor;
                  BoxBorder? border;

                  if (selectedStart || selectedEnd) {
                    bg = accentBlue;
                    textColor = Colors.white;
                    border = null;
                  } else if (inRange) {
                    bg = accentBlue.withOpacity(0.16);
                    textColor = inMonth ? Colors.black : Colors.black26;
                    border = Border.all(color: Colors.transparent);
                  } else {
                    bg = Colors.transparent;
                    textColor = !inMonth
                        ? Colors.black26
                        : (selectable ? Colors.black : Colors.black26);
                    border = Border.all(
                      color: selectable
                          ? Colors.black12
                          : Colors.black12.withOpacity(0.06),
                      width: 0.8,
                    );
                  }

                  return GestureDetector(
                    onTap: selectable
                        ? () => setState(() => _startDate = day)
                        : null,
                    child: Center(
                      child: Container(
                        width: 32 * scale,
                        height: 32 * scale,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                          border: border,
                        ),
                        child: Center(
                          child: Text(
                            "${day.day}",
                            style: GoogleFonts.lato(
                                fontSize: fix(11.5, scale),
                                fontWeight: FontWeight.w700,
                                color: textColor),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ==== Khối thông tin & người ====
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8 * scale, bottom: 16 * scale),
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 9, bottom: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderBlue, width: 0.9),
                borderRadius: BorderRadius.circular(18 * scale),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 1))
                ],
              ),
              child: Column(
                children: [
                  // Dòng 1: Khởi hành - Kết thúc
                  Row(
                    children: [
                      Expanded(child: _dateBox("Khởi hành", _startDate, scale)),
                      const Gap(8),
                      Expanded(
                          child: _dateBox("Kết thúc", _endDate, scale,
                              readonly: true)),
                    ],
                  ),
                  const Gap(15),

                  // Dòng 3: Trẻ + Già
                  Row(
                    children: [
                      Expanded(
                        child: _counterPillCompact(
                          label: "Trẻ em (5–17)",
                          icon: Icons.child_care,
                          value: _youth,
                          canDec: _youth > 0,
                          canInc: _canAddMore,
                          onMinus: () => setState(
                              () => _youth = (_youth - 1).clamp(0, 999)),
                          onPlus: () => _guardedInc(() => _youth++),
                          scale: scale,
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: _counterPillCompact(
                          label: "Cao tuổi (≥ 60)",
                          icon: Icons.elderly,
                          value: _senior,
                          canDec: _senior > 0,
                          canInc: _canAddMore,
                          onMinus: () => setState(
                              () => _senior = (_senior - 1).clamp(0, 999)),
                          onPlus: () => _guardedInc(() => _senior++),
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),

                  // Dòng 4: Lớn (full width)
                  Row(
                    children: [
                      Expanded(
                        child: _counterPillCompact(
                          label: "Người lớn (18–59)",
                          icon: Icons.person,
                          value: _adult,
                          canDec: _adult > 0,
                          canInc: _canAddMore,
                          onMinus: () => setState(
                              () => _adult = (_adult - 1).clamp(0, 999)),
                          onPlus: () => _guardedInc(() => _adult++),
                          scale: scale,
                        ),
                      ),
                    ],
                  ),

                  const Gap(8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tổng: $_totalSelected / $_maxPeople người',
                      style: GoogleFonts.lato(
                        fontSize: fix(10, scale),
                        fontWeight: FontWeight.w700,
                        color: _canAddMore
                            ? Colors.black54
                            : const Color(0xFFE5484D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 100 * scale),
          ],
        ),
      ),
    );
  }

  // ==== sub-widgets ====
  Widget _dateBox(String label, DateTime? date, double scale,
      {bool readonly = false}) {
    final text = date == null
        ? (readonly ? "—" : "Chọn ngày")
        : DateFormat("EEE, dd 'Thg' MM yyyy", 'vi_VN').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: fix(10, scale), fontWeight: FontWeight.w700)),
        SizedBox(height: 8 * scale),
        Container(
          height: 36 * scale,
          decoration: BoxDecoration(
            color: bgGray,
            border: Border.all(color: borderBlue, width: 0.8),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
                fontSize: fix(10, scale), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Pill nhỏ gọn: nhãn trên, dưới là [-] số [+]
  Widget _counterPillCompact({
    required String label,
    required IconData icon,
    required int value,
    required bool canDec,
    required bool canInc,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required double scale,
  }) {
    final double r = 16 * scale;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: bgGray,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: borderBlue.withOpacity(0.7), width: 0.9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nhãn
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16 * scale, color: borderBlue),
              SizedBox(width: 6 * scale),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                      fontSize: fix(10, scale), fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roundIconButton(Icons.remove, onMinus, scale, enabled: canDec),
              SizedBox(width: 10 * scale),
              Text("$value",
                  style: GoogleFonts.lato(
                      fontSize: fix(12, scale), fontWeight: FontWeight.w800)),
              SizedBox(width: 10 * scale),
              _roundIconButton(Icons.add, onPlus, scale, enabled: canInc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap, double scale,
      {bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28 * scale,
        height: 28 * scale,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: borderBlue.withOpacity(0.7), width: 0.9),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1))
          ],
        ),
        child: Icon(icon,
            size: 16 * scale, color: enabled ? borderBlue : Colors.black26),
      ),
    );
  }
}

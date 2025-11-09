import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TourActivity {
  final String name;
  final int priceVnd;
  final bool perPerson;

  const TourActivity({
    required this.name,
    required this.priceVnd,
    this.perPerson = true,
  });
}

class PaymentTourScreen extends StatefulWidget {
  final String tourTitle;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final List<TourActivity> activities;
  final double vatPercent;

  const PaymentTourScreen({
    super.key,
    this.tourTitle = 'Hà Giang Nắng Hồng',
    this.location = 'Hà Giang, Việt Nam',
    required this.startDate,
    required this.endDate,
    this.vatPercent = 10,
    this.activities = const [
      TourActivity(
          name: 'Vé tham quan Đồng Văn', priceVnd: 150000, perPerson: true),
      TourActivity(
          name: 'Thuê xe máy 1 ngày', priceVnd: 180000, perPerson: false),
      TourActivity(
          name: 'Ăn trưa bản Pả Vi', priceVnd: 120000, perPerson: true),
      TourActivity(
          name: 'Vé Mã Pì Lèng Skywalk', priceVnd: 200000, perPerson: true),
    ],
  });

  @override
  State<PaymentTourScreen> createState() => _PaymentTourScreenState();
}

class _PaymentTourScreenState extends State<PaymentTourScreen> {
  int adults = 2;
  int children = 1;
  int infants = 0;

  String paymentBrand = 'VISA';
  String paymentMasked = '•••• 8999';

  final _fmt =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  int get totalPeople => adults + children + infants;

  String _dateRangeText(DateTime from, DateTime to) {
    final d = DateFormat('dd/MM', 'vi');
    final nights = to.difference(from).inDays;
    return '${d.format(from)} - ${DateFormat('dd/MM', 'vi').format(to)} ($nights đêm)';
  }

  String _stayInfoLine2() =>
      '$adults người lớn, $children trẻ em, $infants em bé';

  int _lineAmount(TourActivity a) {
    if (a.perPerson) return a.priceVnd * totalPeople;
    return a.priceVnd;
  }

  int get subTotal => widget.activities.fold(0, (s, a) => s + _lineAmount(a));
  int get vatAmount => (subTotal * (widget.vatPercent / 100)).round();
  int get total => subTotal + vatAmount;

  void _inc(String type) => setState(() {
        if (type == 'adult') adults++;
        if (type == 'child') children++;
        if (type == 'infant') infants++;
      });

  void _dec(String type) => setState(() {
        if (type == 'adult' && adults > 1) adults--;
        if (type == 'child' && children > 0) children--;
        if (type == 'infant' && infants > 0) infants--;
      });

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, color: Color(0xFFE8E8E8));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Thanh toán Tour',
          style: GoogleFonts.lato(
            fontSize: 20,
            color: const Color(0xFF1B1E28),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/hue.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.tourTitle,
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B1E28))),
                          const Gap(6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: Color(0xFF5E6A7D)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(widget.location,
                                    style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: const Color(0xFF5E6A7D))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const Gap(16),
                _SectionCard(
                  title: 'Thông tin chuyến đi',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dateRangeText(widget.startDate, widget.endDate),
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            color: const Color(0xFF1B1E28),
                            fontWeight: FontWeight.w600),
                      ),
                      const Gap(6),
                      Text(
                        _stayInfoLine2(),
                        style: GoogleFonts.lato(
                            fontSize: 13, color: const Color(0xFF5E6A7D)),
                      ),
                      const Gap(12),
                      divider,
                      const Gap(12),
                      _CounterRow(
                        label: 'Người lớn',
                        value: adults,
                        onMinus: () => _dec('adult'),
                        onPlus: () => _inc('adult'),
                      ),
                      const Gap(8),
                      _CounterRow(
                        label: 'Trẻ em',
                        value: children,
                        onMinus: () => _dec('child'),
                        onPlus: () => _inc('child'),
                      ),
                      const Gap(8),
                      _CounterRow(
                        label: 'Em bé',
                        value: infants,
                        onMinus: () => _dec('infant'),
                        onPlus: () => _inc('infant'),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                _SectionCard(
                  title: 'Tóm tắt chi phí',
                  caption: 'Giá tour tính theo hoạt động và số người',
                  child: Column(
                    children: [
                      ...widget.activities.map((a) => _RowPrice(
                            left: a.perPerson
                                ? '${a.name} (x $totalPeople người)'
                                : a.name,
                            amount: _lineAmount(a),
                            fmt: _fmt,
                          )),
                      const Gap(8),
                      _RowPrice(
                          left: 'Tạm tính',
                          amount: subTotal,
                          fmt: _fmt,
                          bold: true),
                      _RowPrice(
                        left:
                            'Thuế VAT (${widget.vatPercent.toStringAsFixed(0)}%)',
                        amount: vatAmount,
                        fmt: _fmt,
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                _SectionCard(
                  title: 'Phương thức thanh toán',
                  child: Row(
                    children: [
                      _BrandChip(brand: paymentBrand),
                      const Gap(12),
                      Text(paymentMasked,
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              color: const Color(0xFF1B1E28),
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Thay đổi',
                          style: GoogleFonts.lato(
                              fontSize: 16,
                              color: const Color(0xFF24BAEC),
                              fontWeight: FontWeight.w400),
                        ),
                      )
                    ],
                  ),
                ),
                const Gap(16),
                _SectionCard(
                  title: 'Chính sách & lưu ý',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Có thể huỷ miễn phí trước 3 ngày khởi hành. Sau thời hạn này có thể phát sinh phí huỷ.',
                        style: GoogleFonts.lato(
                            fontSize: 13, color: const Color(0xFF5E6A7D)),
                      ),
                      const Gap(8),
                      Text(
                        'Mọi thay đổi về thời gian hoặc số lượng người có thể ảnh hưởng đến giá tour.',
                        style: GoogleFonts.lato(
                            fontSize: 13, color: const Color(0xFF5E6A7D)),
                      ),
                    ],
                  ),
                ),
                const Gap(120),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng cộng',
                            style: GoogleFonts.lato(
                                fontSize: 13, color: const Color(0xFF5E6A7D))),
                        const SizedBox(height: 4),
                        Text(
                          _fmt.format(total),
                          style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1B1E28)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24BAEC),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(34)),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Đang xử lý thanh toán...')),
                        );
                      },
                      child: Text('Thanh toán',
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// =================== WIDGET PHỤ ===================

class _SectionCard extends StatelessWidget {
  final String title;
  final String? caption;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 18,
                  color: const Color(0xFF5E6A7D),
                  fontWeight: FontWeight.w700)),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(caption!,
                style: GoogleFonts.lato(
                    fontSize: 12, color: const Color(0xFF9BA5B7))),
          ],
          const Gap(12),
          child,
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 15,
                color: const Color(0xFF1B1E28),
                fontWeight: FontWeight.w600)),
        const Spacer(),
        _RoundIcon(onTap: onMinus, icon: Icons.remove_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$value',
              style:
                  GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        _RoundIcon(onTap: onPlus, icon: Icons.add_rounded),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _RoundIcon({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF1B1E28),
      ),
      splashRadius: 24,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

class _RowPrice extends StatelessWidget {
  final String left;
  final int amount;
  final NumberFormat fmt;
  final bool bold;

  const _RowPrice({
    required this.left,
    required this.amount,
    required this.fmt,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final styleLeft = GoogleFonts.lato(
        fontSize: 14,
        color: const Color(0xFF1B1E28),
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    final styleRight = GoogleFonts.lato(
        fontSize: 14,
        color: const Color(0xFF1B1E28),
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(left, style: styleLeft)),
          Text(fmt.format(amount), style: styleRight),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String brand;
  const _BrandChip({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFE3FF)),
      ),
      alignment: Alignment.center,
      child: Text(brand,
          style: GoogleFonts.lato(
              fontSize: 12,
              color: const Color(0xFF1B1E28),
              fontWeight: FontWeight.w800)),
    );
  }
}

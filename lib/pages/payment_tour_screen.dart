import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:travel_app/data/models/tour_full.dart';
import 'package:travel_app/data/services/profile_service.dart';
import 'package:travel_app/data/services/tour_pricing_service.dart';
import 'package:travel_app/pages/discount_picker_screen.dart';
import 'package:travel_app/pages/price_detail_screen.dart';

import 'screen.dart';

class PaymentTourScreen extends StatefulWidget {
  const PaymentTourScreen({
    super.key,
    required this.tour,
    required this.startDate,
    this.adults = 1,
    this.children = 0,
    this.seniors = 0,
  });

  // INPUT
  final TourFull
      tour; // tourId, name, imageUrl, basePrice..., durationDays, maxParticipants...
  final DateTime startDate; // ngày khởi hành
  final int adults; // số người lớn
  final int children; // số trẻ em
  final int seniors; // số người già

  @override
  State<PaymentTourScreen> createState() => _PaymentTourScreenState();
}

class _PaymentTourScreenState extends State<PaymentTourScreen> {
  // ===== Booker info (UI only) =====
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  bool _profileOK = false;

  // ===== Định dạng tiền =====
  final _fmt =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  // ===== Hệ số mặc định nếu thiếu giá (fallback) =====
  static const double _kChildMultiplier = 0.5; // 50% người lớn
  static const double _kSeniorMultiplier = 0.85; // 85% người lớn

  // ===== Thuế/giảm giá (demo) =====
  final double _vatPercent = 10;
  // Mã giảm giá đã chọn
  String? _discountCode;
  int _discountVnd = 0; // số tiền giảm hiện tại (VNĐ)

  // ===== Counters hiển thị (khởi tạo từ tham số) =====
  late int youth; // trẻ em
  late int adult; // người lớn
  late int senior; // người già

  // ===== Đơn giá (được load từ RPC = sum các activity) =====
  int _unitAdult = 0;
  int _unitChild = 0;
  int _unitSenior = 0;

  bool _loadingPrices = true;
  String? _priceError;

  late final TourPricingService _pricing;

  // ===== Helpers: parse duration D.N (ví dụ 1.1 = 1 ngày 1 đêm) =====
  int _daysFromDuration(double? dn) {
    if (dn == null) return 1;
    final scaled = (dn * 10).round();
    final d = scaled ~/ 10;
    return d > 0 ? d : 1;
  }

  int _nightsFromDuration(double? dn) {
    if (dn == null) return 0;
    final scaled = (dn * 10).round();
    final n = scaled % 10;
    return n >= 0 ? n : 0;
  }

  int get _days => _daysFromDuration(widget.tour.durationDays);
  int get _nights => _nightsFromDuration(widget.tour.durationDays);
  DateTime get _endDate => widget.startDate.add(Duration(days: _days));

  String _dateRangeText(DateTime from, DateTime to) {
    final d = DateFormat('dd/MM', 'vi');
    return '${d.format(from)} - ${d.format(to)} ($_days ngày $_nights đêm)';
  }

  // ===== Tổng theo người (dựa trên đơn giá đã sum từ RPC) =====
  int get _adultTotal => adult * _unitAdult;
  int get _childTotal => youth * _unitChild;
  int get _seniorTotal => senior * _unitSenior;

  int get _peopleSubtotal => _adultTotal + _childTotal + _seniorTotal;
  int get _vatAmount => (_peopleSubtotal * (_vatPercent / 100)).round();
  int get _grandTotal => _peopleSubtotal + _vatAmount - _discountVnd;

  String _peopleLine() =>
      '$youth Trẻ em, $adult Người lớn, $senior Người cao tuổi';

  // UI-only validators
  // call picker discount
  Future<void> _openDiscountPicker() async {
    final people = adult + youth + senior;

    if (people <= 0) {
      _toast('Vui lòng chọn ít nhất 1 hành khách trước khi dùng mã giảm giá.');
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => DiscountPickerScreen(
          tourId: widget.tour.tourId,
          travelDate: DateTime.now(),
          initialCode: _discountCode,
          people: people,
        ),
      ),
    );

    // Người dùng bấm close hoặc không chọn gì
    if (result == null) return;

    final code = result['code'] as String?;
    final bool isPercent = result['is_percent'] == true;

    int discountValue = 0;

    if (isPercent) {
      final percent = (result['percent'] ?? 0) as num;
      discountValue = ((_peopleSubtotal * percent) / 100).round();
    } else {
      final dynamic rawAmount = result['amount'];
      final int amount =
          rawAmount is int ? rawAmount : (rawAmount as num?)?.toInt() ?? 0;
      discountValue = amount;
    }

    // Không cho giảm quá tổng tiền (phòng bug)
    final maxDiscount = _peopleSubtotal + _vatAmount;

    setState(() {
      _discountCode = code;
      _discountVnd = discountValue.clamp(0, maxDiscount);
    });

    if (code != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Đã áp dụng mã $code.')),
      );
    }
  }

// call data user

  Future<void> _updateBookerInfo() async {
    // Lưu lại dữ liệu hiện tại trước khi đi chỉnh sửa
    final beforeName = _nameCtl.text.trim();
    final beforePhone = _phoneCtl.text.trim();
    final beforeAddress = _addressCtl.text.trim();

    // Mở màn chỉnh sửa hồ sơ
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    // Nếu bên EditProfile cập nhật thành công: Navigator.pop(context, true);
    if (result == true) {
      await loadAndFillBookerInfo(); // load lại dữ liệu user vào Payment
      if (!mounted) return;

      // So sánh sau khi load lại
      final afterName = _nameCtl.text.trim();
      final afterPhone = _phoneCtl.text.trim();
      final afterAddress = _addressCtl.text.trim();

      final changed = afterName != beforeName ||
          afterPhone != beforePhone ||
          afterAddress != beforeAddress;

      // Chỉ hiện thông báo nếu thực sự có thay đổi
      if (changed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã cập nhật thông tin người đặt từ hồ sơ.'),
          ),
        );
      }
    }
  }

  Future<void> loadAndFillBookerInfo() async {
    final profile = await ProfileService().getCurrentUserProfile();

    if (profile == null) return;

    // Gán dữ liệu vào TextField
    _nameCtl.text = profile.name ?? '';
    _phoneCtl.text = profile.phone ?? '';
    _addressCtl.text = profile.address ?? '';
    final hasName = (profile.name?.trim().isNotEmpty ?? false);
    final hasPhone = (profile.phone?.trim().isNotEmpty ?? false);
    final hasAddress = (profile.address?.trim().isNotEmpty ?? false);

    bool check = hasName && hasPhone && hasAddress;
    if (check != false) {
      _profileOK = true;
    }
    setState(() {}); // cập nhật UI
  }

  //call data user

  void _inc(String type) => setState(() {
        if (type == 'youth') youth++;
        if (type == 'adult') adult++;
        if (type == 'senior') senior++;
      });

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _dec(String type) => setState(() {
        if (type == 'youth' && youth > 0) {
          youth--;
        }

        if (type == 'adult' && adult > 0) {
          final guardiansAfter =
              (adult - 1) + senior; // người lớn + người già còn lại
          if (guardiansAfter >= 1) {
            adult--;
          } else {
            _toast(
                'Vui lòng đảm bảo có ít nhất một người lớn hoặc một người cao tuổi trong đoàn.');
          }
        }

        if (type == 'senior' && senior > 0) {
          final guardiansAfter = adult + (senior - 1);
          if (guardiansAfter >= 1) {
            senior--;
          } else {
            _toast(
                'Vui lòng đảm bảo có ít nhất một người lớn hoặc một người cao tuổi trong đoàn.');
          }
        }
      });

  // ====== Mở màn hình bảng giá chi tiết (main hình giá) ======
  void _openPriceDetailScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PriceDetailScreen(
          tourId: widget.tour.tourId,
          travelDate: widget.startDate,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _loadUnitPrices() async {
    setState(() {
      _loadingPrices = true;
      _priceError = null;
    });

    try {
      final rows = await _pricing.getActivityPrices(
        tourId: widget.tour.tourId,
        travelDate: widget.startDate,
      );

      // Sum các cột theo yêu cầu: ĐƠN GIÁ = tổng giá của các activity tương ứng
      double adultSum = 0, childSum = 0, seniorSum = 0;
      for (final r in rows) {
        adultSum += (r.adultPrice ?? 0);
        childSum += (r.childPrice ?? 0);
        seniorSum += (r.seniorPrice ?? 0);
      }

      // Fallback nếu không có dữ liệu từ RPC:
      if (rows.isEmpty) {
        final baseAdult = (widget.tour.basePriceAdult ?? 0).toDouble();
        final baseChild = widget.tour.basePriceChild != null
            ? widget.tour.basePriceChild!.toDouble()
            : baseAdult * _kChildMultiplier;
        final baseSenior = baseAdult * _kSeniorMultiplier;

        adultSum = baseAdult;
        childSum = baseChild;
        seniorSum = baseSenior;
      }

      setState(() {
        _unitAdult = adultSum.round();
        _unitChild = childSum.round();
        _unitSenior = seniorSum.round();
        _loadingPrices = false;
      });
    } catch (e) {
      // Fallback khi lỗi
      final baseAdult = (widget.tour.basePriceAdult ?? 0).toDouble();
      final baseChild = widget.tour.basePriceChild != null
          ? widget.tour.basePriceChild!.toDouble()
          : baseAdult * _kChildMultiplier;
      final baseSenior = baseAdult * _kSeniorMultiplier;

      setState(() {
        _priceError = e.toString();
        _unitAdult = baseAdult.round();
        _unitChild = baseChild.round();
        _unitSenior = baseSenior.round();
        _loadingPrices = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // khởi tạo counters theo tham số truyền vào
    adult = widget.adults;
    youth = widget.children;
    senior = widget.seniors;

    _pricing = TourPricingService(Supabase.instance.client);
    _loadUnitPrices();
    loadAndFillBookerInfo();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _addressCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    const divider = Divider(height: 1, color: Color(0xFFE8E8E8));
    final tourTitle = widget.tour.name;
    final tourImage = widget.tour.imageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thanh toán Tour',
            style: GoogleFonts.lato(
                fontSize: 20,
                color: const Color(0xFF1B1E28),
                fontWeight: FontWeight.w600)),
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
          if (_priceError != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF4C7C7)),
              ),
              child: Text(
                'Không tải được đơn giá từ máy chủ. Đang dùng giá mặc định.\n$_priceError',
                style: GoogleFonts.lato(
                    fontSize: 12, color: const Color(0xFFE5484D)),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // ===== Header tour =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: (tourImage == null || tourImage.isEmpty)
                            ? Image.asset('assets/images/hue.jpg',
                                fit: BoxFit.cover)
                            : (tourImage.startsWith('http')
                                ? Image.network(tourImage, fit: BoxFit.cover)
                                : Image.asset(tourImage, fit: BoxFit.cover)),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tourTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B1E28))),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF7FF),
                              borderRadius: BorderRadius.circular(999),
                              border:
                                  Border.all(color: const Color(0xFFBFE3FF)),
                            ),
                            child: Text('$_days ngày $_nights đêm',
                                style: GoogleFonts.lato(
                                    fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                          const Gap(6),
                          Text(
                            _dateRangeText(widget.startDate, _endDate),
                            style: GoogleFonts.lato(
                                fontSize: 12, color: const Color(0xFF5E6A7D)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Gap(16),

                // ===== Thông tin người đặt =====
                _SectionCard(
                  title: 'Thông tin người đặt',
                  caption:
                      'Điền đủ Họ tên, Số điện thoại, địa chỉ để tiếp tục thanh toán.',
                  child: Column(
                    children: [
                      _TextFieldRow(
                          label: 'Họ tên',
                          controller: _nameCtl,
                          keyboardType: TextInputType.name,
                          hint: 'Vui lòng cập nhật !'),
                      const Gap(5),
                      _TextFieldRow(
                          label: 'SDT',
                          controller: _phoneCtl,
                          keyboardType: TextInputType.phone,
                          hint: 'Vui lòng cập nhật !'),
                      const Gap(5),
                      _TextFieldRow(
                          label: 'Địa chỉ',
                          controller: _addressCtl,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'Vui lòng cập nhật !'),
                      const Gap(5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _updateBookerInfo,
                          icon: const Icon(Icons.save_rounded,
                              size: 18, color: Colors.white),
                          label: Text(
                            'Cập nhật',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF24BAEC), // màu xanh Travel
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14), // bo tròn đẹp hơn
                            ),
                          ),
                        ),
                      ),
                      if (!_profileOK)
                        const _WarningBox(
                            message:
                                'Bạn cần cập nhật đủ Họ tên, Số điện thoại và Email trước khi thanh toán.'),
                    ],
                  ),
                ),

                const Gap(16),

                // ===== Thông tin hành khác =====
                _SectionCard(
                  title: 'Số lượng hành khách',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_peopleLine(),
                          style: GoogleFonts.lato(
                              fontSize: 13, color: const Color(0xFF5E6A7D))),
                      const Gap(12),
                      const Divider(height: 1),
                      const Gap(12),
                      // Trẻ em: bình thường
                      _CounterRow(
                        label: 'Trẻ em (5-17)',
                        value: youth,
                        onMinus: () => _dec('youth'),
                        onPlus: () => _inc('youth'),
                        accentColor: const Color(0xFF24BAEC),
                        emoji: '🧒',
                      ),
                      const Gap(5),
                      // Người lớn: nếu không có người già -> tối thiểu 1 người lớn
                      _CounterRow(
                        label: 'Người lớn (18-59)',
                        value: adult,
                        onMinus: () => _dec('adult'),
                        onPlus: () => _inc('adult'),
                        accentColor: const Color(0xFF14AE5C),
                        emoji: '🧍',
                        //minValue: (senior == 0) ? 1 : 0,
                      ),
                      const Gap(5),

                      // Người già: nếu không có người lớn -> tối thiểu 1 người già
                      _CounterRow(
                        label: 'Người cao tuổi (≥ 60)',
                        value: senior,
                        onMinus: () => _dec('senior'),
                        onPlus: () => _inc('senior'),
                        accentColor: const Color(0xFFFFA726),
                        emoji: '👵',
                        //minValue: (adult == 0) ? 1 : 0,
                      ),
                    ],
                  ),
                ),

                const Gap(16),

                // ===== Bảng giá theo người (đơn giá = sum các activity) =====
                _SectionCard(
                  title: 'Bảng giá theo người',
                  caption: _loadingPrices
                      ? 'Đang tải đơn giá từ hoạt động...'
                      : 'Đơn giá = tổng giá các hoạt động theo người.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PricePill(
                        label: 'Trẻ em (5-17)',
                        amount: _unitChild,
                        fmt: _fmt,
                        icon: Icons.child_care,
                        color: const Color(0xFF24BAEC),
                      ),
                      const Gap(8),
                      _PricePill(
                        label: 'Người lớn (18-59)',
                        amount: _unitAdult,
                        fmt: _fmt,
                        icon: Icons.person,
                        color: const Color(0xFF14AE5C),
                      ),
                      const Gap(8),
                      _PricePill(
                        label: 'Người cao tuổi (≥ 60)',
                        amount: _unitSenior,
                        fmt: _fmt,
                        icon: Icons.elderly,
                        color: const Color(0xFFFFA726),
                      ),
                      const Gap(12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _openPriceDetailScreen,
                          icon: const Icon(Icons.table_chart_rounded, size: 18),
                          label: Text('Xem bảng giá chi tiết',
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w700)),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF24BAEC),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(16),
                // ===== Mã giảm giá =====
                _SectionCard(
                  title: 'Mã giảm giá',
                  caption:
                      'Chọn mã khuyến mãi phù hợp với số lượng hành khách.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _discountCode == null
                                ? Text(
                                    'Chưa áp dụng mã nào',
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: const Color(0xFF5E6A7D),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mã: $_discountCode',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF24BAEC),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Giảm: ${_fmt.format(_discountVnd)}',
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1B1E28),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _openDiscountPicker,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF24BAEC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            icon: const Icon(Icons.local_offer_outlined,
                                size: 18, color: Color(0xFF24BAEC)),
                            label: Text(
                              _discountCode == null ? 'Chọn mã' : 'Đổi mã',
                              style: GoogleFonts.lato(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF24BAEC),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_discountCode != null) ...[
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _discountCode = null;
                              _discountVnd = 0;
                            });
                          },
                          child: Text(
                            'Xóa mã giảm giá',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Gap(16),

                // ===== Tóm tắt chi phí =====
                _SectionCard(
                  title: 'Tóm tắt chi phí',
                  caption: 'Theo số người + Thuế VAT.',
                  child: Column(
                    children: [
                      if (adult > 0)
                        _RowPrice(
                          left:
                              'Người lớn ($adult × ${_fmt.format(_unitAdult)})',
                          amount: _adultTotal,
                          fmt: _fmt,
                        ),
                      if (youth > 0)
                        _RowPrice(
                          left: 'Trẻ em ($youth × ${_fmt.format(_unitChild)})',
                          amount: _childTotal,
                          fmt: _fmt,
                        ),
                      if (senior > 0)
                        _RowPrice(
                          left:
                              'Người cao tuổi ($senior × ${_fmt.format(_unitSenior)})',
                          amount: _seniorTotal,
                          fmt: _fmt,
                        ),
                      const Gap(8),
                      const Divider(height: 1),
                      const Gap(8),
                      _RowPrice(
                        left: 'Thuế VAT (${_vatPercent.toStringAsFixed(0)}%)',
                        amount: _vatAmount,
                        fmt: _fmt,
                      ),
                      _RowPrice(
                        left: 'Giảm giá',
                        amount: -_discountVnd,
                        fmt: _fmt,
                      ),
                    ],
                  ),
                ),

                const Gap(120),
              ],
            ),
          ),

          // ===== Footer Thanh toán =====
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_profileOK)
                    const _WarningBox(
                        message:
                            'Chưa đủ thông tin người đặt. Vui lòng cập nhật để tiếp tục thanh toán.'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng cộng',
                                style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: const Color(0xFF5E6A7D))),
                            const SizedBox(height: 4),
                            Text(_fmt.format(_grandTotal),
                                style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B1E28))),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _profileOK
                                ? const Color(0xFF24BAEC)
                                : const Color(0xFFBFC6D0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(34)),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          onPressed: _profileOK
                              ? () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Đang xử lý thanh toán (UI demo)...')))
                              : null,
                          child: Text('Thanh toán',
                              style: GoogleFonts.lato(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================== Helpers & Small Widgets ===================

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
  final String? emoji;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Color accentColor;
  final int? minValue;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    this.emoji,
    this.accentColor = const Color(0xFF24BAEC),
    this.minValue,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.lato(
        fontSize: 13,
        color: const Color(0xFF1B1E28),
        fontWeight: FontWeight.w700);
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Row(children: [
        if (emoji != null)
          Text('$emoji ', style: const TextStyle(fontSize: 14)),
        Text(label, style: textStyle)
      ]),
    );

    return Row(
      children: [
        pill,
        const Spacer(),
        _PillStepper(
            value: value,
            onMinus: onMinus,
            onPlus: onPlus,
            color: accentColor,
            minValue: minValue),
      ],
    );
  }
}

class _PillStepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final Color color;
  final int? minValue;
  const _PillStepper(
      {required this.value,
      required this.onMinus,
      required this.onPlus,
      required this.color,
      this.minValue});

  @override
  Widget build(BuildContext context) {
    final canMinus = minValue == null ? value > 0 : value > (minValue ?? 0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _CircleIcon(
            icon: Icons.remove_rounded,
            onTap: canMinus ? onMinus : null,
            color: canMinus ? color : const Color(0xFFBFC6D0)),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$value',
                style: GoogleFonts.lato(
                    fontSize: 16, fontWeight: FontWeight.w800))),
        _CircleIcon(icon: Icons.add_rounded, onTap: onPlus, color: color),
      ]),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const _CircleIcon({required this.icon, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : const Color(0xFFF2F4F7),
          shape: BoxShape.circle,
          border: Border.all(
              color:
                  enabled ? color.withOpacity(0.5) : const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon,
            size: 18, color: enabled ? color : const Color(0xFFBFC6D0)),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final int amount;
  final NumberFormat fmt;
  final IconData icon;
  final Color color;

  const _PricePill(
      {required this.label,
      required this.amount,
      required this.fmt,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35))),
          child: Icon(icon, size: 18, color: color),
        ),
        const Gap(10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.lato(
                    fontSize: 12,
                    color: const Color(0xFF5E6A7D),
                    fontWeight: FontWeight.w700)),
            const Gap(2),
            Text(fmt.format(amount),
                style: GoogleFonts.lato(
                    fontSize: 16,
                    color: const Color(0xFF1B1E28),
                    fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
    );
  }
}

class _RowPrice extends StatelessWidget {
  final String left;
  final int amount;
  final NumberFormat fmt;
  final bool bold;

  const _RowPrice(
      {required this.left,
      required this.amount,
      required this.fmt,
      this.bold = false});

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
      child: Row(children: [
        Expanded(child: Text(left, style: styleLeft)),
        Text(fmt.format(amount), style: styleRight)
      ]),
    );
  }
}

class _TextFieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hint;

  const _TextFieldRow({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.hint,
  });

  IconData _getIcon() {
    if (keyboardType == TextInputType.phone) return Icons.phone_rounded;
    if (keyboardType == TextInputType.emailAddress) return Icons.location_city;
    return Icons.person_rounded;
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF24BAEC);

    return Container(
      height: 46,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), size: 18, color: primary.withOpacity(0.85)),
          const SizedBox(width: 10),

          // Text
          Expanded(
            child: TextField(
              readOnly: true,
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B1E28),
              ),
              decoration: InputDecoration(
                hintText: hint ?? label,
                hintStyle: GoogleFonts.lato(
                  fontSize: 14,
                  color: const Color(0xFF9BA5B7),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String message;
  const _WarningBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F5), // pastel nhẹ hơn
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF5D1C8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFE5484D),
            size: 18, // nhỏ hơn
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.lato(
                fontSize: 12.5, // nhỏ + gọn
                fontWeight: FontWeight.w600,
                height: 1.3, // line-height đẹp
                color: const Color(0xFFE5484D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

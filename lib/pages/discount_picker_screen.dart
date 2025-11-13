import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/discount.dart';
import '../data/services/discount_service.dart';

class DiscountPickerScreen extends StatefulWidget {
  const DiscountPickerScreen({
    super.key,
    required this.tourId,
    required this.travelDate,
    this.initialCode,
    required this.people,
  });

  final int tourId;
  final DateTime travelDate;
  final String? initialCode;
  final int people;

  @override
  State<DiscountPickerScreen> createState() => _DiscountPickerScreenState();
}

class _DiscountPickerScreenState extends State<DiscountPickerScreen> {
  final _fmtVnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  late final DiscountService _svc;
  final _codeCtl = TextEditingController();
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();

  List<Discount> _items = [];
  Discount? _selected;
  bool _loading = true;
  bool _validating = false;
  String? _error;
  String _filter = 'all'; // all | percent | amount

  @override
  void initState() {
    super.initState();
    _svc = DiscountService(Supabase.instance.client);
    _codeCtl.text = widget.initialCode ?? '';
    _load();
  }

  @override
  void dispose() {
    _codeCtl.dispose();
    _searchCtl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final allList = await _svc.fetchValidDiscounts(tourId: widget.tourId);
      if (!mounted) return;
      setState(() {
        _items = allList;
        _selected = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được danh sách mã. Vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  Future<void> _applyManual() async {
    final code = _codeCtl.text.trim();
    if (code.isEmpty) return;

    setState(() => _validating = true);
    try {
      final res = await Supabase.instance.client
          .from('discounts')
          .select()
          .eq('code', code)
          .maybeSingle();
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Mã không tồn tại trong hệ thống.')),
        );
        return;
      }
      final d = Discount.fromJson(res);

      // Kiểm tra tour
      if (d.tourId != widget.tourId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Mã ${d.code} không áp dụng cho tour này!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final now = DateTime.now();
      final expired = d.endDate != null && d.endDate!.isBefore(now);
      final noUsage = d.usageLimit != null && d.usageLimit == 0;
      final wrongPeople = d.people != null && d.people != widget.people;
      bool tooLate = false;
      if (d.earlyBookingDays != null) {
        final limitDate =
            widget.travelDate.subtract(Duration(days: d.earlyBookingDays!));
        tooLate = now.isAfter(limitDate);
      }

      String? warning;
      if (expired)
        warning = '⏰ Mã ${d.code} đã hết hạn!';
      else if (noUsage)
        warning = '🚫 Mã ${d.code} hết lượt!';
      else if (wrongPeople)
        warning = '👥 Mã ${d.code} chỉ áp dụng cho ${d.people} người!';
      else if (tooLate)
        warning =
            '⏰ Mã ${d.code} yêu cầu đặt sớm hơn ${d.earlyBookingDays} ngày!';

      // Thêm vào danh sách nếu chưa có
      final exists =
          _items.any((x) => x.code.toUpperCase() == d.code.toUpperCase());
      if (!exists) _items.insert(0, d);

      if (warning != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(warning), backgroundColor: Colors.orangeAccent),
        );
      } else {
        setState(() => _selected = d);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Mã ${d.code} đã được thêm và áp dụng!'),
            backgroundColor: const Color(0xFF24BAEC),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 150));
      final idx = _filteredItems.indexWhere((x) => x.code == d.code);
      if (idx >= 0 && _scrollCtl.hasClients) {
        _scrollCtl.animateTo(
          (idx * 120).clamp(0, _scrollCtl.position.maxScrollExtent).toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khi kiểm tra mã: $e')));
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  void _popSelected() {
    final d = _selected;
    if (d == null) return;
    final result = {
      'code': d.code,
      'is_percent': d.isPercent,
      'percent': d.isPercent ? d.value : null,
      'amount': d.isPercent ? null : d.value,
      'name': d.name,
      'description': d.description,
      'discount_id': d.discountId,
      'start_date': d.startDate?.toIso8601String(),
      'end_date': d.endDate?.toIso8601String(),
    };
    Navigator.pop(context, result);
  }

  String _valueText(Discount d) => d.isPercent
      ? 'Giảm ${d.value.toStringAsFixed(0)}%'
      : 'Giảm ${_fmtVnd.format(d.value)}';

  List<Discount> get _filteredItems {
    final q = _searchCtl.text.trim().toLowerCase();
    return _items.where((d) {
      final code = d.code.toLowerCase();
      final name = (d.name ?? '').toLowerCase();
      final desc = (d.description ?? '').toLowerCase();
      final hit =
          q.isEmpty || code.contains(q) || name.contains(q) || desc.contains(q);
      if (!hit) return false;

      switch (_filter) {
        case 'percent':
          return d.isPercent;
        case 'amount':
          return !d.isPercent;
        default:
          return true;
      }
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Mã giảm giá",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 250, 251, 251),
                    Color.fromARGB(255, 249, 251, 251),
                  ],
                ),
              ),
            ),
            RefreshIndicator(
              color: const Color(0xFF24BAEC),
              onRefresh: _load,
              child: CustomScrollView(
                controller: _scrollCtl,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _ModernInputBar(
                        codeCtl: _codeCtl,
                        validating: _validating,
                        onApply: _applyManual,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SearchField(
                            ctl: _searchCtl,
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          _SimpleFilterChips(
                            value: _filter,
                            onChanged: (v) => setState(() => _filter = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_loading)
                    const SliverToBoxAdapter(child: _SimpleLoading())
                  else if (_error != null)
                    SliverToBoxAdapter(
                        child: _SimpleError(message: _error!, onRetry: _load))
                  else if (_filteredItems.isEmpty)
                    const SliverToBoxAdapter(child: _SimpleEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final d = _filteredItems[i];
                          final selected =
                              _selected?.discountId == d.discountId;
                          return _SimpleVoucherCard(
                            discount: d,
                            selected: selected,
                            valueText: _valueText(d),
                            onTap: () => setState(() => _selected = d),
                            people: widget.people,
                            travelDate: widget.travelDate,
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _selected == null
                              ? Text(
                                  'Chưa chọn mã giảm giá',
                                  key: const ValueKey('none'),
                                  style: GoogleFonts.lato(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                )
                              : _SelectedVoucherSummary(
                                  d: _selected!, fmtVnd: _fmtVnd),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24BAEC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _selected == null ? null : _popSelected,
                        child: const Text('Dùng mã'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== Voucher Card =====================
class _SimpleVoucherCard extends StatelessWidget {
  const _SimpleVoucherCard({
    required this.discount,
    required this.selected,
    required this.valueText,
    required this.onTap,
    required this.people,
    required this.travelDate,
  });

  final Discount discount;
  final bool selected;
  final String valueText;
  final VoidCallback onTap;
  final int people;
  final DateTime travelDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expired = discount.endDate != null && discount.endDate!.isBefore(now);
    final noUsage = discount.usageLimit != null && discount.usageLimit == 0;
    final wrongPeople = discount.people != null && discount.people != people;

    bool tooLate = false;
    if (discount.earlyBookingDays != null) {
      final limitDate =
          travelDate.subtract(Duration(days: discount.earlyBookingDays!));
      tooLate = now.isAfter(limitDate);
    }

    final invalid = expired || noUsage || wrongPeople || tooLate;

    String? warningLabel;
    if (expired)
      warningLabel = 'Hết hạn';
    else if (noUsage)
      warningLabel = 'Hết lượt';
    else if (wrongPeople)
      warningLabel = 'Không đủ người';
    else if (tooLate) warningLabel = 'Đặt quá muộn';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: invalid
            ? Colors.red.shade50
            : (selected ? const Color(0xFFF0FAFF) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: invalid
              ? Colors.redAccent
              : (selected
                  ? const Color(0xFF24BAEC).withOpacity(0.5)
                  : Colors.grey.shade200),
          width: selected ? 1.6 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: invalid ? null : onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 44),
              decoration: BoxDecoration(
                color: invalid ? Colors.redAccent : const Color(0xFF24BAEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(discount.code,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(valueText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(discount.name ?? 'Ưu đãi hấp dẫn',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: invalid
                                      ? Colors.redAccent
                                      : Colors.black87))),
                      if (invalid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(warningLabel ?? 'Không hợp lệ',
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        )
                      else
                        Checkbox(
                            value: selected,
                            onChanged: (_) => onTap(),
                            activeColor: const Color(0xFF24BAEC)),
                    ],
                  ),
                  if ((discount.description ?? '').isNotEmpty)
                    Text(discount.description!,
                        style: TextStyle(
                            color: invalid
                                ? Colors.red.shade200
                                : Colors.grey[600],
                            fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    'Từ: ${discount.startDate != null ? DateFormat('dd/MM/yyyy').format(discount.startDate!) : "—"} → Đến: ${discount.endDate != null ? DateFormat('dd/MM/yyyy').format(discount.endDate!) : "—"}',
                    style: TextStyle(
                        color: invalid ? Colors.redAccent : Colors.grey[600],
                        fontSize: 12),
                  ),
                  if (discount.maxDiscount != null && discount.isPercent)
                    Text(
                        'Giảm tối đa: ${NumberFormat.currency(locale: "vi_VN", symbol: "₫").format(discount.maxDiscount)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: invalid
                                ? Colors.redAccent
                                : Colors.blueGrey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== 🔹 Ô TÌM KIẾM 🔹 =====================
class _SearchField extends StatelessWidget {
  const _SearchField({required this.ctl, required this.onChanged});
  final TextEditingController ctl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: ctl,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.grey[500], size: 22),
          hintText: 'Tìm theo mã, tên hoặc mô tả...',
          hintStyle: GoogleFonts.lato(
            color: Colors.grey[500],
            fontSize: 14.5,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ===================== 🔹 FILTER CHIPS 🔹 =====================
class _SimpleFilterChips extends StatelessWidget {
  const _SimpleFilterChips({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'Tất cả', 'icon': Icons.all_inclusive_rounded},
      {'key': 'percent', 'label': 'Phần trăm', 'icon': Icons.percent_rounded},
      {'key': 'amount', 'label': 'Tiền', 'icon': Icons.attach_money_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = value == f['key'] as String; // ✅ ép kiểu
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                f['icon'] as IconData, // ✅ ép kiểu
                size: 16,
                color: selected ? Colors.white : const Color(0xFF24BAEC),
              ),
              label: Text(
                f['label'] as String, // ✅ ép kiểu
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey[800],
                  fontSize: 13.5,
                ),
              ),
              selected: selected,
              onSelected: (_) => onChanged(f['key'] as String), // ✅ ép kiểu
              selectedColor: const Color(0xFF24BAEC),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color:
                      selected ? const Color(0xFF24BAEC) : Colors.grey.shade300,
                  width: 1.1,
                ),
              ),
              elevation: selected ? 3 : 0,
              shadowColor: const Color(0xFF24BAEC).withOpacity(0.15),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SimpleSelectedSummary extends StatelessWidget {
  const _SimpleSelectedSummary({required this.d, required this.fmtVnd});
  final Discount d;
  final NumberFormat fmtVnd;

  @override
  Widget build(BuildContext context) {
    final valueText = d.isPercent
        ? '- ${d.value.toStringAsFixed(0)}%'
        : '- ${fmtVnd.format(d.value)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF24BAEC).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF24BAEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              d.code,
              style: GoogleFonts.lato(
                color: const Color(0xFF24BAEC),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            valueText,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleEmpty extends StatelessWidget {
  const _SimpleEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.discount_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có mã phù hợp',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleLoading extends StatelessWidget {
  const _SimpleLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true, // ✅ Thêm dòng này để ListView tự co chiều cao
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _SimpleError extends StatelessWidget {
  const _SimpleError({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24BAEC),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernInputBar extends StatelessWidget {
  const _ModernInputBar({
    required this.codeCtl,
    required this.validating,
    required this.onApply,
  });

  final TextEditingController codeCtl;
  final bool validating;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4, right: 4, left: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              color: Color(0xFF24BAEC), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: codeCtl,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập mã giảm giá...',
                hintStyle: GoogleFonts.lato(color: Colors.grey[500]),
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onApply(),
            ),
          ),
          if (validating)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF24BAEC)),
              ),
            )
          else
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF24BAEC),
              ),
              child: Text(
                'Áp dụng',
                style: GoogleFonts.lato(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedVoucherSummary extends StatelessWidget {
  const _SelectedVoucherSummary({required this.d, required this.fmtVnd});
  final Discount d;
  final NumberFormat fmtVnd;

  @override
  Widget build(BuildContext context) {
    final valueText = d.isPercent
        ? 'Giảm ${d.value.toStringAsFixed(0)}%'
        : 'Giảm ${fmtVnd.format(d.value)}';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF24BAEC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Mã Giảm:${d.code}',
                style: GoogleFonts.lato(
                  color: const Color(0xFF24BAEC),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Gap(10),
              Text(
                valueText,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

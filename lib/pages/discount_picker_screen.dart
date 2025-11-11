import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/discount.dart';
import '../data/services/discount_service.dart';

/// Discount Picker – Modern Basic Edition
/// - Simplified color system: Primary blue #24BAEC
/// - Clean flat cards with subtle shadows
/// - Minimalist filters as chips
/// - Compact search and input
/// - Bottom bar with clean summary
class DiscountPickerScreen extends StatefulWidget {
  const DiscountPickerScreen({
    super.key,
    required this.tourId,
    required this.travelDate,
    this.initialCode,
  });

  final int tourId;
  final DateTime travelDate;
  final String? initialCode;

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

  String _filter = 'all'; // all | percent | amount | freeship

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
      final list = await _svc.fetchValidDiscounts(
        tourId: widget.tourId,
        atDate: widget.travelDate,
      );
      Discount? preselected;
      if ((widget.initialCode ?? '').trim().isNotEmpty) {
        final u = widget.initialCode!.trim().toUpperCase();
        final found = list.where((x) => (x.code).toUpperCase() == u);
        preselected = found.isNotEmpty
            ? found.first
            : (list.isNotEmpty ? list.first : null);
      } else {
        preselected = list.isNotEmpty ? list.first : null;
      }
      if (!mounted) return;
      setState(() {
        _items = list;
        _selected = preselected;
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
      final d = await _svc.validateCode(
        tourId: widget.tourId,
        code: code,
        atDate: widget.travelDate,
      );
      if (!mounted) return;
      if (d == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mã không hợp lệ hoặc đã hết hạn.')));
      } else {
        setState(() => _selected = d);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Áp dụng mã ${d.code} thành công!')));
        await Future.delayed(const Duration(milliseconds: 120));
        final idx =
            _filteredItems.indexWhere((x) => x.discountId == d.discountId);
        if (idx >= 0 && _scrollCtl.hasClients) {
          _scrollCtl.animateTo(
            (idx * 110)
                .clamp(0, _scrollCtl.position.maxScrollExtent)
                .toDouble(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
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
      ? '- ${d.value.toStringAsFixed(0)}%'
      : '- ${_fmtVnd.format(d.value)}';
  String _rangeText(Discount d) {
    String f(DateTime? x) =>
        x == null ? '—' : DateFormat('dd/MM/yyyy', 'vi').format(x);
    return '${f(d.startDate)} → ${f(d.endDate)}';
  }

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
        case 'freeship':
          return name.contains('free') ||
              name.contains('ship') ||
              desc.contains('free') ||
              desc.contains('ship');
        default:
          return true;
      }
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Subtle hero background
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF24BAEC),
                  const Color(0xFF24BAEC).withOpacity(0.8),
                ],
              ),
            ),
          ),
          // CONTENT
          RefreshIndicator(
            color: const Color(0xFF24BAEC),
            onRefresh: _load,
            child: CustomScrollView(
              controller: _scrollCtl,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding:
                        const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                    title: _SimpleSearchBar(
                      codeCtl: _codeCtl,
                      validating: _validating,
                      onApply: _applyManual,
                    ),
                  ),
                ),

                // Filter section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SearchField(
                          ctl: _searchCtl,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _SimpleFilterChips(
                          value: _filter,
                          onChanged: (v) => setState(() => _filter = v),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_loading)
                  const SliverFillRemaining(
                      hasScrollBody: false, child: _SimpleLoading())
                else if (_error != null)
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: _SimpleError(message: _error!, onRetry: _load))
                else if (_filteredItems.isEmpty)
                  const SliverFillRemaining(
                      hasScrollBody: false, child: _SimpleEmpty())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final d = _filteredItems[i];
                        final selected = _selected?.discountId == d.discountId;
                        return _SimpleVoucherCard(
                          discount: d,
                          selected: selected,
                          valueText: _valueText(d),
                          rangeText: _rangeText(d),
                          onTap: () => setState(() => _selected = d),
                        );
                      },
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),

          // Bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
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
                                'Chưa chọn mã',
                                key: const ValueKey('none'),
                                style: GoogleFonts.lato(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              )
                            : _SimpleSelectedSummary(
                                d: _selected!, fmtVnd: _fmtVnd),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24BAEC),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
    );
  }
}

// ===== UI Components =====

class _SimpleSearchBar extends StatelessWidget {
  const _SimpleSearchBar({
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.confirmation_number_outlined,
              color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: codeCtl,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập mã giảm giá',
                hintStyle: GoogleFonts.lato(color: Colors.grey[500]),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onApply(),
            ),
          ),
          if (validating)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF24BAEC)),
              ),
            )
          else
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: const Color(0xFF24BAEC),
              ),
              child: Text(
                'Áp dụng',
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.ctl, required this.onChanged});
  final TextEditingController ctl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctl,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        hintText: 'Tìm theo mã / tên / mô tả',
        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _SimpleFilterChips extends StatelessWidget {
  const _SimpleFilterChips({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'percent', 'label': '%'},
      {'key': 'amount', 'label': 'Tiền'},
      {'key': 'freeship', 'label': 'Freeship'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = value == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: selected,
              onSelected: (_) => onChanged(f['key']!),
              selectedColor: const Color(0xFF24BAEC),
              backgroundColor: Colors.grey[50],
              side: BorderSide(
                color: selected ? const Color(0xFF24BAEC) : Colors.grey[200]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SimpleVoucherCard extends StatelessWidget {
  const _SimpleVoucherCard({
    required this.discount,
    required this.selected,
    required this.valueText,
    required this.rangeText,
    required this.onTap,
  });

  final Discount discount;
  final bool selected;
  final String valueText;
  final String rangeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 4 : 1,
      color: selected ? const Color(0xFFF0F9FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: const Color(0xFF24BAEC).withOpacity(0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Code and Value Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF24BAEC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      discount.code,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        valueText,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (discount.name ?? 'Ưu đãi cho chuyến đi'),
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: selected
                              ? const Color(0xFF24BAEC)
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                    if ((discount.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        discount.description!,
                        style: GoogleFonts.lato(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Hiệu lực: $rangeText',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: const Color(0xFF24BAEC),
                          ),
                          child: Text(
                            'Chọn',
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF24BAEC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            d.code,
            style: GoogleFonts.lato(
              color: const Color(0xFF24BAEC),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          valueText,
          style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
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

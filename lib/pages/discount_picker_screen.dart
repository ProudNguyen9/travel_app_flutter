import 'package:flutter/material.dart';
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
  List<Discount> _items = [];
  bool _loading = true;
  Discount? _selected;
  final _codeCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _svc = DiscountService(Supabase.instance.client);
    _codeCtl.text = widget.initialCode ?? '';
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _svc.fetchValidDiscounts(
      tourId: widget.tourId,
      atDate: widget.travelDate,
    );
    setState(() {
      _items = list;
      // nếu có initialCode thì tìm và chọn
      if (widget.initialCode != null) {
        _selected = list.firstWhere(
          (d) => d.code.toUpperCase() == widget.initialCode!.toUpperCase(),
          orElse: () => list.isNotEmpty ? list.first : null as Discount,
        );
      }
      _loading = false;
    });
  }

  Future<void> _applyManual() async {
    final code = _codeCtl.text.trim();
    if (code.isEmpty) return;
    final d = await _svc.validateCode(
      tourId: widget.tourId,
      code: code,
      atDate: widget.travelDate,
    );
    if (d == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã không hợp lệ hoặc đã hết hạn.')),
      );
      return;
    }
    setState(() => _selected = d);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Áp dụng mã ${d.code} thành công!')),
    );
  }

  String _valueText(Discount d) {
    if (d.isPercent) {
      return '- ${d.value.toStringAsFixed(0)}%';
    }
    return '- ${_fmtVnd.format(d.value)}';
    // Tùy bạn tính “tối đa” nếu có điều kiện
  }

  String _rangeText(Discount d) {
    String f(DateTime? x) =>
        x == null ? '—' : DateFormat('dd/MM/yyyy', 'vi').format(x);
    return '${f(d.startDate)} → ${f(d.endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn mã giảm giá',
            style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
        actions: [
          if (_selected != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text('ÁP DỤNG'),
            )
        ],
      ),
      body: Column(
        children: [
          // Ô nhập mã tay
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtl,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã (VD: TET2025)',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyManual,
                  child: const Text('Áp dụng'),
                )
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text('Không có mã phù hợp',
                            style: GoogleFonts.lato(color: Colors.black54)),
                      )
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (_, i) {
                          final d = _items[i];
                          final selected =
                              _selected?.discountId == d.discountId;
                          return ListTile(
                            onTap: () => setState(() => _selected = d),
                            leading: CircleAvatar(
                              backgroundColor: selected
                                  ? const Color(0xFF24BAEC)
                                  : const Color(0xFFEFF7FF),
                              child: Icon(
                                selected ? Icons.check : Icons.local_offer,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF24BAEC),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(d.code,
                                    style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEFAF6),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                        color: const Color(0xFFBFE3FF)),
                                  ),
                                  child: Text(
                                    _valueText(d),
                                    style: GoogleFonts.lato(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((d.name ?? '').isNotEmpty)
                                  Text(d.name!,
                                      style: GoogleFonts.lato(
                                          fontSize: 13, color: Colors.black87)),
                                if ((d.description ?? '').isNotEmpty)
                                  Text(d.description!,
                                      style: GoogleFonts.lato(
                                          fontSize: 12, color: Colors.black54)),
                                const SizedBox(height: 4),
                                Text('Hiệu lực: ${_rangeText(d)}',
                                    style: GoogleFonts.lato(
                                        fontSize: 12, color: Colors.black45)),
                              ],
                            ),
                            trailing: selected
                                ? const Icon(Icons.radio_button_checked,
                                    color: Color(0xFF24BAEC))
                                : const Icon(Icons.radio_button_off_outlined),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

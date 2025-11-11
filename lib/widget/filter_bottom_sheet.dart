import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  final List<String> tourTypes;
  final List<String> durations;

  const FilterBottomSheet({
    super.key,
    this.initialFilters,
    required this.tourTypes,
    required this.durations,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  String? _durationDays;
  int? _maxParticipants;
  String? _tourType;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters ?? {};
    _minPrice = (f['minPrice'] ?? 0).toDouble();
    _maxPrice = (f['maxPrice'] ?? 5000000).toDouble();
    _durationDays = f['durationDays'];
    _maxParticipants = f['maxParticipants'];
    _tourType = f['tourType'];
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF24BAEC);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 🌈 Header
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bộ lọc tìm kiếm',
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // 💰 Giá
            _buildSectionCard(
              title: 'Giá người lớn (VNĐ)',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_minPrice.toInt()} - ${_maxPrice.toInt()}',
                        style: GoogleFonts.poppins(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 10000000,
                    divisions: 20,
                    activeColor: accent,
                    inactiveColor: accent.withOpacity(0.2),
                    labels: RangeLabels(
                      '${_minPrice.toInt()}',
                      '${_maxPrice.toInt()}',
                    ),
                    onChanged: (v) {
                      setState(() {
                        _minPrice = v.start;
                        _maxPrice = v.end;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 🕒 Thời lượng
            _buildSectionCard(
              title: 'Thời lượng tour',
              child: DropdownButtonFormField<String>(
                value: _durationDays,
                decoration: _inputDecoration(),
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                items: const [
                  '1 ngày 1 đêm',
                  '1 ngày 2 đêm',
                  '2 ngày 1 đêm',
                  '3 ngày 2 đêm',
                ]
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _durationDays = v),
              ),
            ),

            const SizedBox(height: 14),

            // 👥 Số người
            _buildSectionCard(
              title: 'Số người tối đa',
              child: DropdownButtonFormField<int>(
                value: _maxParticipants,
                decoration: _inputDecoration(),
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                items: [10, 20, 30, 50, 100]
                    .map((p) => DropdownMenuItem(
                        value: p, child: Text('$p người')))
                    .toList(),
                onChanged: (v) => setState(() => _maxParticipants = v),
              ),
            ),

            const SizedBox(height: 14),

            // 🗺️ Loại tour
            _buildSectionCard(
              title: 'Loại tour',
              child: DropdownButtonFormField<String>(
                value: _tourType,
                decoration: _inputDecoration(),
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                items: widget.tourTypes
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tourType = v),
              ),
            ),

            const SizedBox(height: 28),

            // 🔘 Nút áp dụng
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'minPrice': _minPrice,
                    'maxPrice': _maxPrice,
                    'durationDays': _durationDays,
                    'maxParticipants': _maxParticipants,
                    'tourType': _tourType,
                  });
                },
                icon: const Icon(Icons.filter_alt_rounded, color: Colors.white),
                label: Text(
                  'Áp dụng lọc',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ==============================
  /// 🔹 Widget phụ trợ UI
  /// ==============================

  // Ô nhóm từng phần (card)
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // Style ô chọn
  InputDecoration _inputDecoration() {
    return const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF24BAEC), width: 1.5),
      ),
    );
  }
}

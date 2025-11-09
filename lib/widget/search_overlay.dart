import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

/// =======================
/// 🔍 Thanh tìm kiếm ở Home
/// =======================
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.onSubmit,
    required this.suggestions,
    required this.hintText,
    required this.historyKey,
  });

  final ValueChanged<String> onSubmit;
  final List<String> suggestions;
  final String hintText;
  final String historyKey;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'search_bar_$historyKey',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            final result = await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => SearchScreen(
                  hintText: hintText,
                  historyKey: historyKey,
                  suggestions: suggestions,
                ),
              ),
            );
            if (result != null && result.trim().isNotEmpty) {
              onSubmit(result.trim());
            }
          },
          child: _FakeSearchField(hintText: hintText),
        ),
      ),
    );
  }
}

class _FakeSearchField extends StatelessWidget {
  final String hintText;
  const _FakeSearchField({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hintText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black45,
              ),
            ),
          ),
          // Icon lọc để gợi ý (nhấn vào toàn ô sẽ mở màn Search)
          const Icon(Icons.tune, color: Colors.black54, size: 20),
        ],
      ),
    );
  }
}

/// =======================
/// 🌍 Màn hình tìm kiếm (tối giản)
/// =======================
class SearchScreen extends StatelessWidget {
  const SearchScreen({
    super.key,
    required this.hintText,
    required this.historyKey,
    required this.suggestions,
  });

  final String hintText;
  final String historyKey;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    // Dữ liệu "gần đây" demo, có thể thay bằng local storage sau
    final recent = <String>["Quảng Trị", "Vũng Tàu", "Đà Lạt"];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(20),
            // ======= Hàng trên: search + nút X =======
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'search_bar_$historyKey',
                      child: Material(
                        color: Colors.transparent,
                        child:
                            _SearchBar(hintText: hintText), // KHÔNG autofocus
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ======= Nội dung: chỉ "Tìm kiếm gần đây" & "Gợi ý" =======
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // --- Tìm kiếm gần đây ---
                  Text(
                    "Tìm kiếm gần đây",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff151111),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...recent.map(_buildRecentSearchItem),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),

                  // --- Gợi ý cho bạn ---
                  const SizedBox(height: 16),
                  Text(
                    "Gợi ý cho bạn",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff151111),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 210,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildRecommendationCard(
                          image: "assets/images/splash1.png",
                          title: "Vũng Tàu",
                          desc: "Biển tuyệt đẹp, check-in chill",
                          reviews: 120,
                        ),
                        const SizedBox(width: 16),
                        _buildRecommendationCard(
                          image: "assets/images/splash2.png",
                          title: "Nha Trang",
                          desc: "Nha Trang đẹp lắm",
                          reviews: 98,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Row item "gần đây"
  Widget _buildRecentSearchItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 18, color: Colors.black54),
              const SizedBox(width: 10),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff151111),
                ),
              ),
            ],
          ),
          // Dấu X xoá hiển thị (demo, chưa lưu state xoá)
          const Icon(Icons.close, color: Colors.black54, size: 18),
        ],
      ),
    );
  }
}

/// =======================
/// Thanh nhập tìm kiếm thật
/// =======================
class _SearchBar extends StatefulWidget {
  final String hintText;
  const _SearchBar({required this.hintText});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    Navigator.pop(context, text.isEmpty ? null : text);
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune),
                  const SizedBox(width: 8),
                  Text(
                    "Bộ lọc",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip(label: "Gần tôi"),
                    _FilterChip(label: "4★ trở lên"),
                    _FilterChip(label: "Miễn phí vé vào"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Áp dụng"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, color: Colors.black54, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: false, // ❌ không tự mở bàn phím
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff151111),
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black45,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Lọc',
            onPressed: _openFilter,
            icon: const Icon(Icons.tune, color: Colors.black87, size: 22),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: false,
      label: Text(label),
      onSelected: (_) {},
      visualDensity: VisualDensity.compact,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
    );
  }
}

//
Widget _buildRecommendationCard({
  required String image,
  required String title,
  required String desc,
  required int reviews,
}) {
  return Container(
    width: 160,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.asset(
            image,
            width: 160,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff151111),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "$reviews đánh giá",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

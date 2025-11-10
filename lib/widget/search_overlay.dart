import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:travel_app/data/models/tour_full.dart';
import 'package:travel_app/data/services/tour_service.dart';
import 'package:travel_app/data/services/favorite_tour_service.dart';

class SearchScreen extends StatefulWidget {
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
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<TourFull> _results = [];
  List<TourFull> _randomTours = [];
  List<String> _recent = [];
  Set<int> _favIds = {}; // 🩵 tour_id đã yêu thích

  bool _loading = false;
  String _lastKeyword = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadRandomTours();
    _loadMyFavorites();
  }

  /// 🔹 Lấy danh sách tour_id yêu thích
  Future<void> _loadMyFavorites() async {
    final favSet = await FavoriteTourService.instance.fetchMyFavoriteTourIds();
    setState(() => _favIds = favSet);
  }

  /// 🔹 Load lịch sử từ local
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recent = prefs.getStringList(widget.historyKey) ?? [];
    });
  }

  /// 🔹 Lưu lịch sử mới
  Future<void> _saveHistory(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(widget.historyKey) ?? [];

    list.remove(keyword);
    list.insert(0, keyword);
    if (list.length > 10) list.removeRange(10, list.length);

    await prefs.setStringList(widget.historyKey, list);
    setState(() => _recent = list);
  }

  /// 🔹 Xóa 1 item
  Future<void> _deleteHistoryItem(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(widget.historyKey) ?? [];
    list.remove(keyword);
    await prefs.setStringList(widget.historyKey, list);
    setState(() => _recent = list);
  }

  /// 🔹 Xóa toàn bộ lịch sử
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(widget.historyKey);
    setState(() => _recent.clear());
  }

  /// 🔹 Gợi ý random
  Future<void> _loadRandomTours() async {
    final all = await TourService.instance.fetchAllTours();
    if (all.isEmpty) return;
    all.shuffle(Random());
    setState(() => _randomTours = all.take(4).toList());
  }

  /// 🔹 Thực hiện tìm kiếm
  Future<void> _search(String keyword) async {
    if (keyword.trim().isEmpty || keyword == _lastKeyword) return;

    setState(() {
      _loading = true;
      _results = [];
      _lastKeyword = keyword;
    });

    await _saveHistory(keyword);

    final allTours = await TourService.instance.fetchAllTours();
    final lower = keyword.toLowerCase();

    _results = allTours.where((t) {
      return t.name.toLowerCase().contains(lower) ||
          (t.description?.toLowerCase().contains(lower) ?? false);
    }).toList();

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(20),
            // Thanh search
           // 🔹 Thanh tìm kiếm đồng bộ với Home
Padding(
  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
  child: Row(
    children: [
      Expanded(
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0xFF24BAEC), width: 1.4),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, size: 20, color: Color(0xFF98A2B3)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _search,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF151111),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tìm điểm đến bạn muốn...',
                    hintStyle: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.tune_rounded, size: 22, color: Colors.black87),
      ),
      const Gap(8),
    ],
  ),
),


            // Kết quả
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? _buildSuggestions()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _results.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemBuilder: (context, index) {
                            final tour = _results[index];
                            return _buildTourCard(tour);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================
  /// 🔹 Gợi ý + Lịch sử tìm kiếm
  /// ============================
  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tìm kiếm gần đây",
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff151111))),
            if (_recent.isNotEmpty)
              TextButton(onPressed: _clearHistory, child: const Text("Xóa tất cả")),
          ],
        ),
        const SizedBox(height: 10),

        if (_recent.isEmpty)
          const Text("Chưa có lịch sử tìm kiếm",
              style: TextStyle(color: Colors.grey))
        else
          ..._recent.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _controller.text = r;
                        _search(r);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.history,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 10),
                          Text(r,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xff151111),
                              )),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.black45, size: 18),
                      onPressed: () => _deleteHistoryItem(r),
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 20),

        Text("Gợi ý nổi bật",
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xff151111))),
        const SizedBox(height: 12),

        if (_randomTours.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _randomTours.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildRecommendationCard(
                    image: t.imageUrl ?? "",
                    title: t.name,
                    desc: t.description ?? "Chưa có mô tả",
                    reviews: Random().nextInt(300) + 50,
                    isFav: _favIds.contains(t.tourId),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// =====================
  /// 🔹 Thẻ tour kết quả
  /// =====================
  Widget _buildTourCard(TourFull t) {
    final isFav = _favIds.contains(t.tourId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                t.imageUrl != null && t.imageUrl!.isNotEmpty
                    ? Image.network(
                        t.imageUrl!,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined,
                            color: Colors.grey),
                      ),
                Positioned(
  top: 8,
  right: 8,
  child: InkWell(
    onTap: () async {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn cần đăng nhập để thêm yêu thích.')),
        );
        return;
      }

      try {
        // 🔹 Lấy user_id (INT) nội bộ tương ứng với auth.id
        final userData = await Supabase.instance.client
            .from('users')
            .select('user_id')
            .eq('auth_id', user.id)
            .maybeSingle();

        if (userData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy user trong hệ thống.')),
          );
          return;
        }

        final int userId = userData['user_id'];
        final tourId = t.tourId;
        final isFav = _favIds.contains(tourId);

        if (isFav) {
          // 🔹 Gỡ tim
          await FavoriteTourService.instance.removeFavorite(userId, tourId);
          setState(() => _favIds.remove(tourId));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã bỏ yêu thích tour "${t.name}" 💔')),
          );
        } else {
          // 🔹 Thả tim
          await FavoriteTourService.instance.addFavorite(userId, tourId);
          setState(() => _favIds.add(tourId));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm "${t.name}" vào yêu thích ❤️')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật yêu thích: $e')),
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _favIds.contains(t.tourId)
            ? Icons.favorite
            : Icons.favorite_border,
        color:
            _favIds.contains(t.tourId) ? Colors.redAccent : Colors.grey,
        size: 20,
      ),
    ),
  ),
),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff151111))),
                const SizedBox(height: 4),
                Text(t.description ?? "Chưa có mô tả",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 🔹 Thẻ gợi ý nổi bật
/// =======================
Widget _buildRecommendationCard({
  required String image,
  required String title,
  required String desc,
  required int reviews,
  required bool isFav,
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
          child: Stack(
            children: [
              image.isNotEmpty
                  ? Image.network(
                      image,
                      width: 160,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 110,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff151111))),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text("$reviews đánh giá",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      )),
                ],
              ),
              const SizedBox(height: 4),
              Text(desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  )),
            ],
          ),
        ),
      ],
    ),
  );
}

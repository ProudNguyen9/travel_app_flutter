import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class Review {
  final String name;
  final String timeAgo;
  final double rating;
  final String content;
  final String? avatar; // asset path

  Review({
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.content,
    this.avatar,
  });
}

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  // dữ liệu mẫu
  final List<Review> _reviews = [
    Review(
      name: 'Opeyemi',
      timeAgo: '2 ngày trước',
      rating: 4.8,
      content:
          'Vị trí tuyệt vời, dễ tìm và di chuyển. Check-in nhanh gọn. Phòng sạch và rộng, dịch vụ tốt.',
      avatar: 'assets/images/avatar1.png',
    ),
    Review(
      name: 'Abisola',
      timeAgo: '3 ngày trước',
      rating: 4.7,
      content:
          'Rất dễ tìm. Không có gì để chê. Chủ nhà hỗ trợ nhiệt tình. Sẽ quay lại!',
      avatar: 'assets/images/avatar2.png',
    ),
  ];

  // điểm từng tiêu chí (demo)
  final Map<String, double> _criteria = {
    'Độ chính xác': 4.7,
    'Vị trí': 4.5,
    'Giao tiếp': 4.6,
    'Vệ sinh': 4.7,
    'Check-in': 4.9,
    'Giá trị': 4.7,
  };

  // form nhập đánh giá
  double _userRating = 0;
  final _controller = TextEditingController();

  double get _avg => _reviews.isEmpty
      ? 0
      : _reviews.map((e) => e.rating).reduce((a, b) => a + b) / _reviews.length;

  void _submit() {
    final text = _controller.text.trim();
    if (_userRating <= 0 || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao và nhập nội dung.')),
      );
      return;
    }
    setState(() {
      _reviews.insert(
        0,
        Review(
          name: 'Bạn',
          timeAgo: 'vừa xong',
          rating: _userRating,
          content: text,
          avatar: 'assets/images/avatar_me.png',
        ),
      );
      _controller.clear();
      _userRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmtAvg = _avg.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Đánh giá & Nhận xét',
            style: GoogleFonts.lato(
              fontSize: 18,
              color: const Color(0xFF1B1E28),
              fontWeight: FontWeight.w700,
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // header điểm trung bình
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFC107), size: 26),
              const SizedBox(width: 6),
              Text(
                '$fmtAvg  ',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B1E28),
                ),
              ),
              Text(
                '${_reviews.length} đánh giá',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: const Color(0xFF5E6A7D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(16),

          // tiêu chí
          ..._criteria.entries
              .map((e) => _CriteriaRow(label: e.key, score: e.value)),
          const Gap(20),

          // form nhập đánh giá
          Text('Viết đánh giá của bạn',
              style:
                  GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700)),
          const Gap(8),
          _StarSelector(
            value: _userRating,
            onChanged: (v) => setState(() => _userRating = v),
          ),
          const Gap(8),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Chia sẻ trải nghiệm của bạn…',
              hintStyle: GoogleFonts.lato(color: const Color(0xFF9BA5B7)),
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF24BAEC), width: 1.4),
              ),
            ),
          ),
          const Gap(10),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF24BAEC),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(34)),
              ),
              onPressed: _submit,
              child: Text('Gửi đánh giá',
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const Gap(24),

          // danh sách review
          ..._reviews.map((r) => _ReviewTile(review: r)),
        ],
      ),
    );
  }
}

// ====== widgets phụ ======

class _CriteriaRow extends StatelessWidget {
  final String label;
  final double score;
  const _CriteriaRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.lato(
                    fontSize: 14, color: const Color(0xFF1B1E28))),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 6,
                child: Stack(
                  children: [
                    Container(color: const Color(0xFFE8E8E8)),
                    FractionallySizedBox(
                      widthFactor: (score / 5).clamp(0.0, 1.0),
                      child: Container(color: const Color(0xFF1B1E28)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 34,
            child: Text(score.toStringAsFixed(1),
                textAlign: TextAlign.right,
                style: GoogleFonts.lato(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage:
                review.avatar != null ? AssetImage(review.avatar!) : null,
            child: review.avatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.name,
                    style: GoogleFonts.lato(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(review.timeAgo,
                    style: GoogleFonts.lato(
                        fontSize: 12, color: const Color(0xFF5E6A7D))),
                const SizedBox(height: 6),
                _StaticStars(rating: review.rating),
                const SizedBox(height: 8),
                Text(
                  review.content,
                  style: GoogleFonts.lato(
                      fontSize: 14, color: const Color(0xFF1B1E28)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// chọn sao có tương tác
class _StarSelector extends StatelessWidget {
  final double value; // 0–5
  final ValueChanged<double> onChanged;
  const _StarSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1.0;
        final filled = value >= idx - 0.001;
        return IconButton(
          onPressed: () => onChanged(idx),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: const Color(0xFFFFC107),
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }
}

// sao tĩnh cho item review
class _StaticStars extends StatelessWidget {
  final double rating; // 0–5
  const _StaticStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = rating >= idx - 0.001;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFFFC107),
          size: 18,
        );
      }),
    );
  }
}

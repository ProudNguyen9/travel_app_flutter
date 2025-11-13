import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/models/FavoriteTour.dart';
import 'package:travel_app/data/services/favorite_tour_service.dart';

class FavoriteTourScreen extends StatefulWidget {
  const FavoriteTourScreen({super.key});

  @override
  State<FavoriteTourScreen> createState() => _FavoriteTourScreenState();
}

class _FavoriteTourScreenState extends State<FavoriteTourScreen> {
  late Future<List<FavoriteTour>> _favoritesFuture;
  @override
  void initState() {
    super.initState();
    _favoritesFuture = Future.value([]); // ✅ gán mặc định để tránh late error
    _loadUserFavorites();
  }

  void _loadUserFavorites() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint('[FavPage] currentUser (auth_id) = ${currentUser?.id}');
    if (currentUser == null) {
      _favoritesFuture = Future.value([]);
      return;
    }

    // 🔹 Lấy user_id nội bộ từ bảng public.users dựa trên auth_id
    final userData = await Supabase.instance.client
        .from('users')
        .select('user_id')
        .eq('auth_id', currentUser.id)
        .maybeSingle();

    if (userData == null) {
      debugPrint('[FavPage] Không tìm thấy user ứng với auth_id');
      _favoritesFuture = Future.value([]);
      return;
    }

    final userId = userData['user_id'] as int;
    debugPrint('[FavPage] user_id nội bộ = $userId');

    setState(() {
      _favoritesFuture =
          FavoriteTourService.instance.fetchFavoritesByUser(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tour Yêu Thích",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff151111),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tour Yêu Thích",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xff151111),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<FavoriteTour>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Lỗi tải dữ liệu: ${snapshot.error}"),
                    );
                  }

                  final favorites = snapshot.data ?? [];
                  if (favorites.isEmpty) {
                    return const Center(
                      child: Text("Chưa có tour yêu thích nào "),
                    );
                  }

                  return GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final f = favorites[index];
                      return _buildFavoriteCard(
                        f.tourImage ?? "",
                        f.tourName ?? "Không có tên",
                        f.tourDescription ?? "Chưa có mô tả",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🖼 Widget hiển thị 1 tour yêu thích
  Widget _buildFavoriteCard(String img, String name, String desc) {
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
                img.isNotEmpty
                    ? Image.network(
                        img,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.favorite,
                          color: Colors.redAccent, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Tên + mô tả tour
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff151111),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

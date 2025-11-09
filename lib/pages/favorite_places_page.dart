import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritePlacesPage extends StatelessWidget {
  const FavoritePlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Danh sách mẫu: ảnh + tên + địa chỉ
    final List<Map<String, String>> places = [
      {
        "img": "splash1.png",
        "name": "Quán ăn 69",
        "address": "Tekergat, Sunamgnj"
      },
      {
        "img": "splash2.png",
        "name": "Home Stay",
        "address": "Av Damero, Mexico"
      },
      {
        "img": "splash3.png",
        "name": "Home Stay Dalat",
        "address": "Bastola, Islampur"
      },
      {
        "img": "splash4.png",
        "name": "Khách Sạn",
        "address": "Sylhet, Airport Road"
      },
      {"img": "splash5.png", "name": "Home Stay", "address": "Vellima, Island"},
      {
        "img": "splash6.png",
        "name": "Nhà Nghỉ",
        "address": "Shakartu, Pakistan"
      },
    ];

    return Scaffold(
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
          "Địa Điểm Yêu Thích",
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
              "Địa Điểm Yêu Thích",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xff151111),
              ),
            ),
            const SizedBox(height: 10),

            // Lưới hiển thị 2 cột
            Expanded(
              child: GridView.builder(
                itemCount: places.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cột
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final place = places[index];
                  return _buildPlaceCard(
                      place["img"]!, place["name"]!, place["address"]!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏞 Widget hiển thị từng ô
  Widget _buildPlaceCard(String img, String name, String address) {
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
          // Ảnh
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/$img',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
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

          // Tên + địa chỉ
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
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff151111),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
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

import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final Color primaryColor;
  final VoidCallback? onNotificationPressed;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHintText;

  const CustomHeader({
    super.key,
    this.primaryColor = const Color(0xFF2A4D69), // Warna default
    this.onNotificationPressed,
    this.searchController,
    this.onSearchChanged,
    this.searchHintText = 'Search for medicine',
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(180.0); // Tinggi total AppBar yang FIXED

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: preferredSize.height,
      child: Stack(
        children: [
          // Lapisan Bawah (Warna primaryColor)
          ClipPath(
            clipper: _HeaderClipperBottomLayer(),
            child: Container(
              color: primaryColor,
              height: preferredSize.height,
            ),
          ),
          // Lapisan Atas (Warna sedikit berbeda)
          ClipPath(
            clipper: _HeaderClipperTopLayer(),
            child: Container(
              color: Color.lerp(primaryColor, Colors.white,
                  0.1), // Sedikit lebih cerah dari primaryColor
              height: preferredSize.height -
                  10, // Sedikit lebih pendek untuk efek overlap
            ),
          ),

          // Konten Header: Ikon Notifikasi (kanan atas)
          Positioned(
            top: topPadding + 10,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 30),
              onPressed: onNotificationPressed,
            ),
          ),
          // Konten Header: Search Bar (tengah bawah)
          Positioned(
            top: topPadding + 80, // Sesuaikan posisi vertikal search bar
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: searchHintText,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 10.0),
                  ),
                ),
              ),
            ),
          ),
          // TIDAK ADA LOGO APAPUN DI KIRI ATAS
        ],
      ),
    );
  }
}

// Clippers (tidak ada perubahan dari sebelumnya, karena sudah berfungsi)
class _HeaderClipperBottomLayer extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width * 0.25, size.height - 10,
        size.width * 0.5, size.height - 40);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 70, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _HeaderClipperTopLayer extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width * 0.25, size.height - 20,
        size.width * 0.5, size.height - 50);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 80, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

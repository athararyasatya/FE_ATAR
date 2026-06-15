import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final double rating;
  final String soldCount;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.onTap,
    this.onAddToCart,
    this.rating = 4.5,
    this.soldCount = "234",
    this.imageUrl = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 110,
                            color: const Color(0xFF1E1E35),
                            child: const Center(
                              child: Icon(Icons.image, size: 40, color: Color(0xFF5C5878)),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 110,
                            color: const Color(0xFF1E1E35),
                            child: const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF9B5EFF),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 110,
                        color: const Color(0xFF1E1E35),
                        child: const Center(
                          child: Icon(Icons.image, size: 40, color: Color(0xFF5C5878)),
                        ),
                      ),
                // Rating Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 10, color: Color(0xFFFFB800)),
                        const SizedBox(width: 2),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Informasi Produk - Menggunakan Expanded agar button tetap di bawah
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk - Dengan tinggi maksimal tetap
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF0EAFF),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Harga
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9B5EFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Terjual
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 10, color: Color(0xFF5C5878)),
                      const SizedBox(width: 4),
                      Text(
                        "Terjual $soldCount",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF5C5878),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tombol Tambah - Posisi tetap di bawah
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B5EFF),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 14),
                          SizedBox(width: 6),
                          Text(
                            "Tambah",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
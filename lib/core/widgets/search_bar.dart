import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final Function(String)? onSearchChanged;

  const SearchBar({
    super.key,
    this.onFilterTap,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: TextField(
        style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: "Cari produk...",
          hintStyle: GoogleFonts.inter(color: const Color(0xFF5C5878), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8B8BA8), size: 20),
          suffixIcon: GestureDetector(
            onTap: onFilterTap,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B5EFF), Color(0xFF5B21B6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget {
  final double horizontalPadding;
  final String name;

  const Header({
    super.key,
    this.horizontalPadding = 0,
    this.name = "Athar",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF9B5EFF), Color(0xFF5B21B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat datang 👋",
                style: GoogleFonts.inter(
                  color: const Color(0xFF9B97B8),
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF0EAFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        // Notif button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF16162A),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF1E1E35), width: 1),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF8B8BA8),
            size: 22,
          ),
        ),
      ],
    );
  }
}
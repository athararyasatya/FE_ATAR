// lib/core/widgets/theme_toggle_button.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kanzza_sales_app_fe/core/theme/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final double size;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDark ? '🌞 Mode Terang' : '🌙 Mode Gelap',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: isDark ? Colors.grey.shade800 : const Color(0xFF9B5EFF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E35).withOpacity(0.5)
              : const Color(0xFFF5F5FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2D2D45)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: isDark ? const Color(0xFFFFD93D) : const Color(0xFF6B7280),
          size: size * 0.5,
        ),
      ),
    );
  }
}
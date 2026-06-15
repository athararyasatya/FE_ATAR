import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GradientNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: "Home"),
    _NavItem(icon: Icons.receipt_long_rounded, label: "Order"),
    _NavItem(icon: Icons.shopping_cart_rounded, label: "Cart"),
    _NavItem(icon: Icons.person_rounded, label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF110E1F), Color(0xFF0D0D12), Color(0xFF0D0D12)],
          stops: [0.0, 0.35, 1.0],
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF1E1A30), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x339B5EFF),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: sw > 400 ? 68 : 62,
          child: Row(
            children: List.generate(_items.length, (index) {
              final selected = currentIndex == index;
              final item = _items[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF9B5EFF).withValues(alpha: .18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selected
                            ? ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFE0BAFF), Color(0xFF9B5EFF)],
                                ).createShader(bounds),
                                child: Icon(item.icon, size: 22),
                              )
                            : Icon(item.icon, color: const Color(0xFF8B8BA8), size: 22),
                      ),
                      const SizedBox(height: 4),
                      selected
                          ? ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE0BAFF), Color(0xFF9B5EFF)],
                              ).createShader(bounds),
                              child: Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8B8BA8),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_cart_page.dart';
import '../../../widgets/product_card.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  // Backgrounds
  static const bg        = Color(0xFF0D0D12);
  static const surface   = Color(0xFF16162A);
  static const surfaceHi = Color(0xFF1E1E35);

  // Violet family
  static const violet    = Color(0xFF9B5EFF);
  static const violetDim = Color(0xFF6B3FBF);
  static const lavender  = Color(0xFFC4A0FF);
  static const lavSoft   = Color(0xFFE8D9FF);

  // Text
  static const textPrimary   = Color(0xFFF0EAFF);
  static const textSecondary = Color(0xFF9B97B8);
  static const textMuted     = Color(0xFF5C5878);

  // Nav icon states
  static const navIdle     = Color(0xFF8B8BA8); // terang tapi muted
  static const navSelected = Color(0xFFC4A0FF); // lavender

  // Gradients
  static const gradViolet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B5EFF), Color(0xFF5B21B6)],
  );
  static const gradDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF13102A), Color(0xFF0D0D12)],
  );
  // Nav background: hitam solid dengan hint ungu sangat halus di kiri
  static const gradNav = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF110E1F), Color(0xFF0D0D12), Color(0xFF0D0D12)],
    stops: [0.0, 0.35, 1.0],
  );
  // Gradient teks/icon saat selected
  static const gradSelected = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0BAFF), Color(0xFF9B5EFF)],
  );
}

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int currentIndex = 0;
  int selectedCategory = 0;

  final categories = [
    ("Semua",    Icons.apps_rounded),
    ("Snack",    Icons.cookie_rounded),
    ("Minuman",  Icons.local_drink_rounded),
    ("Frozen",   Icons.ac_unit_rounded),
    ("Sembako",  Icons.store_rounded),
    ("Buah",     Icons.energy_savings_leaf_rounded),
    ("Instan",   Icons.ramen_dining_rounded),
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      setState(() => currentIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerCartPage()),
      ).then((_) {
        if (mounted) setState(() => currentIndex = 0);
      });
      return;
    }
    if (index == 1 || index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            index == 1 ? "Halaman Order masih dibuat" : "Halaman Profile masih dibuat",
            style: GoogleFonts.inter(color: _C.textPrimary),
          ),
          backgroundColor: _C.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Status bar icons terang karena background gelap
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final sw = MediaQuery.of(context).size.width;
    final hPad = sw * 0.05; // 5% horizontal padding — responsif

    return Scaffold(
      backgroundColor: _C.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _C.gradDark),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: sw * 0.05),

                      // ─────────────────────────────
                      // HEADER
                      // ─────────────────────────────
                      _Header(hPad: hPad),

                      SizedBox(height: sw * 0.06),

                      // ─────────────────────────────
                      // SEARCH
                      // ─────────────────────────────
                      _SearchBar(),

                      SizedBox(height: sw * 0.06),

                      // ─────────────────────────────
                      // PROMO BANNER
                      // ─────────────────────────────
                      _PromoBanner(),

                      SizedBox(height: sw * 0.07),

                      // ─────────────────────────────
                      // SECTION TITLE: Kategori
                      // ─────────────────────────────
                      _SectionTitle(title: "Kategori"),
                    ],
                  ),
                ),
              ),

              // ─────────────────────────────
              // CATEGORY — horizontal scroll
              // tanpa terpotong (padding trick)
              // ─────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 86,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: hPad,
                      right: hPad,
                      top: 10,
                      bottom: 4,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final selected = selectedCategory == index;
                      final cat = categories[index];
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? _C.violet.withValues(alpha: .15) : _C.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? _C.violet.withValues(alpha: .6) : _C.surfaceHi,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              selected
                                ? ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (b) => _C.gradSelected.createShader(b),
                                    child: Icon(cat.$2, size: 20),
                                  )
                                : Icon(cat.$2, size: 20, color: _C.navIdle),
                              const SizedBox(height: 6),
                              selected
                                ? ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (b) => _C.gradSelected.createShader(b),
                                    child: Text(
                                      cat.$1,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                : Text(
                                    cat.$1,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _C.navIdle,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: sw * 0.05),
                      // ─────────────────────────────
                      // SECTION TITLE: Produk
                      // ─────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionTitle(title: "Produk Populer"),
                          GestureDetector(
                            onTap: () {},
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (b) => _C.gradSelected.createShader(b),
                              child: Text(
                                "Lihat Semua →",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sw * 0.04),
                    ],
                  ),
                ),
              ),

              // ─────────────────────────────
              // PRODUCT GRID — SliverGrid
              // ─────────────────────────────
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      name: "Produk ${index + 1}",
                      price: "Rp ${(index + 1) * 15000}",
                    ),
                    childCount: 6,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sw > 600 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _GradientNavBar(
        currentIndex: currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final double hPad;
  const _Header({required this.hPad});

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
                  color: _C.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Athar",
                style: GoogleFonts.poppins(
                  color: _C.textPrimary,
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
            color: _C.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _C.surfaceHi, width: 1),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: _C.navIdle,
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.surfaceHi, width: 1),
      ),
      child: TextField(
        style: GoogleFonts.inter(color: _C.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: "Cari produk...",
          hintStyle: GoogleFonts.inter(color: _C.textMuted, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _C.navIdle, size: 20),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: _C.gradViolet,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROMO BANNER
// ─────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF4C1D95), Color(0xFF1E0D40)],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: _C.violetDim.withValues(alpha: .45),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "🎉  Promo Minggu Ini",
                    style: GoogleFonts.inter(
                      color: _C.lavSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Diskon\nhingga 30%",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Untuk produk pilihan spesial.",
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: .6),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Lihat Promo",
                      style: GoogleFonts.inter(
                        color: _C.violetDim,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Decorative element kanan
          Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .15),
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.local_offer_rounded, color: Colors.white70, size: 32),
              ),
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .05),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .1),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: _C.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GRADIENT NAV BAR
// Background: hitam solid, hint ungu sangat halus
// Icon idle: terang-muted  |  Selected: gradient
// ─────────────────────────────────────────────
class _GradientNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GradientNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded,           label: "Home"),
    _NavItem(icon: Icons.receipt_long_rounded,   label: "Order"),
    _NavItem(icon: Icons.shopping_cart_rounded,  label: "Cart"),
    _NavItem(icon: Icons.person_rounded,         label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        gradient: _C.gradNav,
        border: Border(
          top: BorderSide(color: Color(0xFF1E1A30), width: 1),
        ),
        // Glow tipis di atas navbar
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
                      // Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: selected
                              ? _C.violet.withValues(alpha: .18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selected
                            ? ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (b) => _C.gradSelected.createShader(b),
                                child: Icon(item.icon, size: 22),
                              )
                            : Icon(item.icon, color: _C.navIdle, size: 22),
                      ),
                      const SizedBox(height: 4),
                      // Label
                      selected
                          ? ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (b) => _C.gradSelected.createShader(b),
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
                                color: _C.navIdle,
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
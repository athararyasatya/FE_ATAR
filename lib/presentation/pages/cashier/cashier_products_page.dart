// lib/presentation/pages/cashier/cashier_products_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kanzza_sales_app_fe/core/theme/theme_provider.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class CashierProductsPage extends StatefulWidget {
  const CashierProductsPage({super.key});

  @override
  State<CashierProductsPage> createState() => _CashierProductsPageState();
}

class _CashierProductsPageState extends State<CashierProductsPage> {
  String _searchQuery = "";
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Keripik Singkong Original',
      'price': 15000,
      'category': 'Snack',
      'stock': 45,
      'image': '',
      'popular': true,
    },
    {
      'id': 2,
      'name': 'Air Mineral 600ml',
      'price': 4000,
      'category': 'Minuman',
      'stock': 120,
      'image': '',
      'popular': true,
    },
    {
      'id': 3,
      'name': 'Es Krim Coklat',
      'price': 12000,
      'category': 'Frozen',
      'stock': 30,
      'image': '',
      'popular': false,
    },
    {
      'id': 4,
      'name': 'Beras Premium 5kg',
      'price': 65000,
      'category': 'Sembako',
      'stock': 15,
      'image': '',
      'popular': true,
    },
    {
      'id': 5,
      'name': 'Mie Instan Goreng',
      'price': 3500,
      'category': 'Instan',
      'stock': 200,
      'image': '',
      'popular': false,
    },
    {
      'id': 6,
      'name': 'Teh Botol 350ml',
      'price': 5000,
      'category': 'Minuman',
      'stock': 85,
      'image': '',
      'popular': false,
    },
    {
      'id': 7,
      'name': 'Keripik Singkong Balado',
      'price': 17000,
      'category': 'Snack',
      'stock': 28,
      'image': '',
      'popular': false,
    },
    {
      'id': 8,
      'name': 'Gula Pasir 1kg',
      'price': 18000,
      'category': 'Sembako',
      'stock': 40,
      'image': '',
      'popular': false,
    },
  ];

  final List<String> _categories = [
    "Semua",
    "Snack",
    "Minuman",
    "Frozen",
    "Sembako",
    "Instan",
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products;
    
    if (_selectedCategory != 0) {
      filtered = filtered
          .where((product) => product['category'] == _categories[_selectedCategory])
          .toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) => product['name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    return filtered;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showProductDetail(Map<String, dynamic> product) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE8E8F0),
          ),
        ),
        title: Text(
          product['name'],
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kategori",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
                Text(
                  product['category'],
                  style: GoogleFonts.inter(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Harga",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Rp ${_formatPrice(product['price'])}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9B5EFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stok",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: product['stock'] > 10
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: product['stock'] > 10
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    product['stock'] > 10
                        ? "${product['stock']} tersedia"
                        : "${product['stock']} (stok menipis)",
                    style: GoogleFonts.inter(
                      color: product['stock'] > 10
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.inter(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddToCartDialog(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Tambah ke Keranjang",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartDialog(Map<String, dynamic> product) {
    int quantity = 1;
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE8E8F0),
          ),
        ),
        title: Text(
          "Tambah ke Keranjang",
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product['name'],
                  style: GoogleFonts.inter(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Rp ${_formatPrice(product['price'])}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9B5EFF),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setStateDialog(() => quantity--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    Container(
                      width: 50,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E35)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2D2D45)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          quantity.toString(),
                          style: GoogleFonts.inter(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (quantity < product['stock']) {
                          setStateDialog(() => quantity++);
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: const Color(0xFF9B5EFF),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Stok tersedia: ${product['stock']}",
                  style: GoogleFonts.inter(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${quantity}x ${product['name']} ditambahkan ke keranjang",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF9B5EFF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Tambah",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final sw = MediaQuery.of(context).size.width;
    final hPad = sw * 0.04;
    final isTablet = sw > 600;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF13102A), const Color(0xFF0D0D12)]
                : [const Color(0xFFF5F5FA), const Color(0xFFE8E8F0)],
          ),
        ),
        child: Column(
          children: [
            // Header - Tanpa Toggle Theme
            Container(
              padding: EdgeInsets.only(
                left: hPad,
                right: hPad,
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF13102A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black12 : Colors.black12,
                    blurRadius: isDark ? 0 : 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isDark
                    ? const Border(bottom: BorderSide(color: Color(0xFF1E1E35)))
                    : null,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.cashierDashboard,
                        );
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF16162A)
                            : const Color(0xFFF5F5FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E1E35)
                              : const Color(0xFFE8E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? const Color(0xFFF0EAFF)
                            : const Color(0xFF1F2937),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Daftar Produk",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFFF0EAFF)
                            : const Color(0xFF1F2937),
                        fontSize: isTablet ? 26 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Hanya Notifikasi - Tanpa Toggle Theme
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF16162A)
                          : const Color(0xFFF5F5FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E1E35)
                            : const Color(0xFFE8E8F0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDark
                                ? const Color(0xFF9B97B8)
                                : const Color(0xFF4B5563),
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5252),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: GoogleFonts.inter(
                  color: isDark
                      ? const Color(0xFFF0EAFF)
                      : const Color(0xFF1F2937),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  hintStyle: GoogleFonts.inter(
                    color: isDark
                        ? const Color(0xFF5C5878)
                        : const Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark
                        ? const Color(0xFF9B97B8)
                        : const Color(0xFF6B7280),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF16162A)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Categories
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF9B5EFF)
                              : isDark
                                  ? const Color(0xFF16162A)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF9B5EFF)
                                : isDark
                                    ? const Color(0xFF1E1E35)
                                    : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : isDark
                                    ? const Color(0xFF9B97B8)
                                    : const Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Product Grid
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: isDark
                                ? const Color(0xFF5C5878)
                                : const Color(0xFF9CA3AF),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Produk tidak ditemukan",
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? const Color(0xFF9B97B8)
                                  : const Color(0xFF6B7280),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Coba gunakan kata kunci lain",
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? const Color(0xFF5C5878)
                                  : const Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _showProductDetail(product),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(color: const Color(0xFF1E1E35))
              : Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E35)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: isDark
                    ? const Color(0xFF5C5878)
                    : const Color(0xFF9CA3AF),
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            // Product Name
            Text(
              product['name'],
              style: GoogleFonts.inter(
                color: isDark
                    ? const Color(0xFFF0EAFF)
                    : const Color(0xFF1F2937),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Price
            Text(
              "Rp ${_formatPrice(product['price'])}",
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B5EFF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            // Stock & Popular
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: product['stock'] > 10
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product['stock'] > 10
                        ? "Tersedia"
                        : "Stok ${product['stock']}",
                    style: GoogleFonts.inter(
                      color: product['stock'] > 10
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (product['popular'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Populer",
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFF9800),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
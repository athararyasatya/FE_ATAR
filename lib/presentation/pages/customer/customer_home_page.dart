import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanzza_sales_app_fe/core/widgets/gradient_nav_bar.dart';
import 'package:kanzza_sales_app_fe/core/widgets/header.dart';
import 'package:kanzza_sales_app_fe/core/widgets/search_bar.dart';
import 'package:kanzza_sales_app_fe/core/widgets/promo_banner.dart';
import 'package:kanzza_sales_app_fe/core/widgets/section_title.dart';
import 'package:kanzza_sales_app_fe/core/widgets/product_card.dart';

import 'customer_cart_page.dart';
import 'customer_profile_page.dart';
import 'customer_orders_page.dart'; // ⬅️ TAMBAHKAN IMPORT ORDERS

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int currentIndex = 0;
  int selectedCategory = 0;

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Keripik Singkong Original',
      'price': 'Rp 15.000',
      'category': 'Snack',
      'rating': 4.8,
      'sold': '234',
      'image': '',
    },
    {
      'name': 'Air Mineral 600ml',
      'price': 'Rp 4.000',
      'category': 'Minuman',
      'rating': 4.9,
      'sold': '1.2k',
      'image': '',
    },
    {
      'name': 'Es Krim Coklat',
      'price': 'Rp 12.000',
      'category': 'Frozen',
      'rating': 4.7,
      'sold': '567',
      'image': '',
    },
    {
      'name': 'Beras Premium 5kg',
      'price': 'Rp 65.000',
      'category': 'Sembako',
      'rating': 4.9,
      'sold': '892',
      'image': '',
    },
    {
      'name': 'Mie Instan Goreng',
      'price': 'Rp 3.500',
      'category': 'Instan',
      'rating': 4.6,
      'sold': '3.4k',
      'image': '',
    },
    {
      'name': 'Teh Botol 350ml',
      'price': 'Rp 5.000',
      'category': 'Minuman',
      'rating': 4.7,
      'sold': '1.8k',
      'image': '',
    },
    {
      'name': 'Keripik Singkong Original Sangat Panjang Untuk Testing',
      'price': 'Rp 15.000',
      'category': 'Snack',
      'rating': 4.8,
      'sold': '234',
      'image': '',
    },
  ];

  final categories = [
    "Semua",
    "Snack",
    "Minuman",
    "Frozen",
    "Sembako",
    "Buah",
    "Instan",
  ];

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == 0) return products;
    return products
        .where((product) => product['category'] == categories[selectedCategory])
        .toList();
  }

  void _onNavTap(int index) {
    // Index 0: Home
    // Index 1: Orders
    // Index 2: Cart
    // Index 3: Profile
    
    if (index == 0) {
      // Home - scroll ke atas
      setState(() => currentIndex = 0);
      return;
    }
    
    if (index == 1) {
      // Orders - navigate ke halaman orders ⬅️ PERBAIKAN UTAMA
      setState(() => currentIndex = 1);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerOrdersPage()),
      ).then((_) {
        if (mounted) setState(() => currentIndex = 0);
      });
      return;
    }
    
    if (index == 2) {
      // Cart - navigate ke halaman keranjang
      setState(() => currentIndex = 2);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerCartPage()),
      ).then((_) {
        if (mounted) setState(() => currentIndex = 0);
      });
      return;
    }
    
    if (index == 3) {
      // Profile - navigate ke halaman profil
      setState(() => currentIndex = 3);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomerProfilePage()),
      ).then((_) {
        if (mounted) setState(() => currentIndex = 0);
      });
      return;
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${product['name']} ditambahkan ke keranjang",
          style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 12),
        ),
        backgroundColor: const Color(0xFF9B5EFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final sw = MediaQuery.of(context).size.width;
    final hPad = sw * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF13102A), Color(0xFF0D0D12)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Konten scrollable
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Header(),
                            const SizedBox(height: 20),
                            const SearchBar(),
                            const SizedBox(height: 20),
                            const PromoBanner(),
                            const SizedBox(height: 24),
                            const SectionTitle(title: "Kategori"),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      
                      // Category List
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final selected = selectedCategory == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(categories[index]),
                                selected: selected,
                                onSelected: (val) {
                                  setState(() {
                                    selectedCategory = index;
                                  });
                                },
                                backgroundColor: const Color(0xFF16162A),
                                selectedColor: const Color(0xFF9B5EFF).withOpacity(0.2),
                                checkmarkColor: const Color(0xFF9B5EFF),
                                labelStyle: GoogleFonts.inter(
                                  color: selected ? const Color(0xFF9B5EFF) : const Color(0xFF8B8BA8),
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                ),
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: selected ? const Color(0xFF9B5EFF) : const Color(0xFF1E1E35),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Product Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const SectionTitle(title: "Produk Populer"),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      
                      // Product Grid
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredProducts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: sw > 600 ? 3 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 285,
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              name: product['name'],
                              price: product['price'],
                              rating: product['rating'],
                              soldCount: product['sold'],
                              imageUrl: product['image'],
                              onAddToCart: () => _addToCart(product),
                              onTap: () {},
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Bottom Navigation Bar
              GradientNavBar(
                currentIndex: currentIndex,
                onTap: _onNavTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
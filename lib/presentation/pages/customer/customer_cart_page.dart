import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/cart_item.dart';
import 'customer_checkout_page.dart';

class CustomerCartPage extends StatefulWidget {
  const CustomerCartPage({super.key});

  @override
  State<CustomerCartPage> createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends State<CustomerCartPage> {
  List<CartItem> cartItems = [
    CartItem(
      id: 1,
      name: "Keripik Singkong Original",
      price: 15000,
      quantity: 2,
      imageUrl: "",
      rating: 4.8,
    ),
    CartItem(
      id: 2,
      name: "Air Mineral 600ml",
      price: 4000,
      quantity: 3,
      imageUrl: "",
      rating: 4.9,
    ),
    CartItem(
      id: 3,
      name: "Es Krim Coklat",
      price: 12000,
      quantity: 1,
      imageUrl: "",
      rating: 4.7,
    ),
    CartItem(
      id: 4,
      name: "Mie Instan Goreng",
      price: 3500,
      quantity: 5,
      imageUrl: "",
      rating: 4.6,
    ),
  ];

  int get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _updateQuantity(int id, int newQuantity) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        if (newQuantity <= 0) {
          cartItems.removeAt(index);
        } else {
          cartItems[index].quantity = newQuantity;
        }
      }
    });
  }

  void _removeItem(int id) {
    setState(() {
      cartItems.removeWhere((item) => item.id == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Item telah dihapus dari keranjang",
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _checkout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Keranjang Anda kosong",
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    
    // Navigasi ke halaman checkout
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerCheckoutPage(
          totalPrice: totalPrice,
          cartItems: cartItems,
        ),
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Hapus Semua Item?",
          style: GoogleFonts.poppins(
            color: const Color(0xFFF0EAFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus semua item dari keranjang?",
          style: GoogleFonts.inter(
            color: const Color(0xFF9B97B8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.inter(
                color: const Color(0xFF9B97B8),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                cartItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Semua item telah dihapus",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              "Hapus",
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hPad = sw * 0.04;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                child: Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16162A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFFF0EAFF),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Keranjang Belanja",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF0EAFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "$totalItems item • Rp ${_formatPrice(totalPrice)}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B97B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete all button
                    if (cartItems.isNotEmpty)
                      GestureDetector(
                        onTap: _showDeleteAllDialog,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Cart Items List
              Expanded(
                child: cartItems.isEmpty
                    ? _buildEmptyCart()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return _buildCartItem(item);
                        },
                      ),
              ),

              // Bottom Summary & Checkout Button
              if (cartItems.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(hPad),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(color: const Color(0xFF1E1E35), width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Belanja",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B97B8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Rp ${_formatPrice(totalPrice)}",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9B5EFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Biaya Pengiriman",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B97B8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Dihitung saat checkout",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF5C5878),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B5EFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart_checkout, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "Lanjutkan ke Pembayaran",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 30,
                color: Color(0xFF5C5878),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF0EAFF),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFFB800)),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9B97B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Rp ${_formatPrice(item.price)}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9B5EFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Quantity and Delete Row
                Row(
                  children: [
                    // Quantity Control
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _updateQuantity(item.id, item.quantity - 1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Color(0xFF9B97B8),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              item.quantity.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF0EAFF),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _updateQuantity(item.id, item.quantity + 1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Color(0xFF9B5EFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _removeItem(item.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Hapus",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF16162A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: Color(0xFF5C5878),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Keranjang Kosong",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF0EAFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Yuk, tambahkan produk favoritmu!",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9B97B8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Belanja Sekarang",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
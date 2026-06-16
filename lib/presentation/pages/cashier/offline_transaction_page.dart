// lib/presentation/pages/cashier/offline_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class OfflineTransactionPage extends StatefulWidget {
  const OfflineTransactionPage({super.key});

  @override
  State<OfflineTransactionPage> createState() => _OfflineTransactionPageState();
}

class _OfflineTransactionPageState extends State<OfflineTransactionPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  String _selectedCategory = "Semua";
  String _selectedPaymentMethod = "Cash";
  DateTime _selectedDate = DateTime.now();
  
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _savedTransactions = [];
  
  int _totalPrice = 0;

  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'Keripik Singkong Original', 'price': 15000, 'category': 'Snack', 'stock': 45},
    {'id': 2, 'name': 'Air Mineral 600ml', 'price': 4000, 'category': 'Minuman', 'stock': 120},
    {'id': 3, 'name': 'Es Krim Coklat', 'price': 12000, 'category': 'Frozen', 'stock': 30},
    {'id': 4, 'name': 'Beras Premium 5kg', 'price': 65000, 'category': 'Sembako', 'stock': 15},
    {'id': 5, 'name': 'Mie Instan Goreng', 'price': 3500, 'category': 'Instan', 'stock': 200},
    {'id': 6, 'name': 'Teh Botol 350ml', 'price': 5000, 'category': 'Minuman', 'stock': 85},
    {'id': 7, 'name': 'Keripik Singkong Balado', 'price': 17000, 'category': 'Snack', 'stock': 28},
    {'id': 8, 'name': 'Gula Pasir 1kg', 'price': 18000, 'category': 'Sembako', 'stock': 40},
    {'id': 9, 'name': 'Es Krim Vanila', 'price': 12000, 'category': 'Frozen', 'stock': 25},
    {'id': 10, 'name': 'Mie Instan Kuah', 'price': 3500, 'category': 'Instan', 'stock': 150},
  ];

  final List<String> _categories = ["Semua", "Snack", "Minuman", "Frozen", "Sembako", "Instan"];

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products;
    
    if (_selectedCategory != "Semua") {
      filtered = filtered.where((p) => p['category'] == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((p) => 
        p['name'].toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      int existingIndex = _cartItems.indexWhere((item) => item['id'] == product['id']);
      
      if (existingIndex != -1) {
        _cartItems[existingIndex]['quantity'] = (_cartItems[existingIndex]['quantity'] as int) + 1;
        _cartItems[existingIndex]['subtotal'] = (_cartItems[existingIndex]['quantity'] as int) * (_cartItems[existingIndex]['price'] as int);
      } else {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
          'subtotal': product['price'],
        });
      }
      
      _calculateTotal();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = newQuantity;
        _cartItems[index]['subtotal'] = (_cartItems[index]['quantity'] as int) * (_cartItems[index]['price'] as int);
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalPrice = 0;
    for (var item in _cartItems) {
      _totalPrice += item['subtotal'] as int;
    }
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalPrice = 0;
    });
  }

  // ⬇️ FIX: Panggil setState saat date berubah ⬇️
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9B5EFF),
              onPrimary: Colors.white,
              surface: Color(0xFF16162A),
              onSurface: Color(0xFFF0EAFF),
            ),
            dialogBackgroundColor: const Color(0xFF16162A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tambahkan produk terlebih dahulu!", style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final transaction = {
      'id': 'OFF-${DateFormat('yyyyMMdd').format(_selectedDate)}-${_savedTransactions.length + 1}',
      'date': DateFormat('dd MMM yyyy').format(_selectedDate),
      'customer': _customerNameController.text.isNotEmpty 
          ? _customerNameController.text 
          : 'Pelanggan Offline',
      'items': List.from(_cartItems),
      'total': _totalPrice,
      'paymentMethod': _selectedPaymentMethod,
      'status': 'Selesai',
      'type': 'Offline',
      'note': _noteController.text,
    };

    setState(() {
      _savedTransactions.insert(0, transaction);
    });

    _clearCart();
    _customerNameController.clear();
    _noteController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "✅ Transaksi offline berhasil disimpan!",
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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
    final isTablet = sw > 600;

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
                          color: const Color(0xFF16162A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF0EAFF), size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Catat Transaksi Offline",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF0EAFF),
                          fontSize: isTablet ? 26 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_cartItems.isNotEmpty)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade400.withOpacity(0.3)),
                        ),
                        child: IconButton(
                          onPressed: _clearCart,
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: isTablet
                    ? Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildProductPanel(hPad),
                          ),
                          const VerticalDivider(
                            color: Color(0xFF1E1E35),
                            width: 1,
                            thickness: 1,
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildCartPanel(),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: _buildProductPanel(hPad),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF16162A),
                              border: Border(
                                top: BorderSide(color: const Color(0xFF1E1E35), width: 1),
                              ),
                            ),
                            child: SafeArea(
                              child: GestureDetector(
                                onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, modalSetState) {
                                      return Container(
                                        height: MediaQuery.of(context).size.height * 0.75,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF16162A),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: _buildCartPanel(),
                                      );
                                    },
                                  );
                                },
);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            color: const Color(0xFF9B97B8),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${_cartItems.length} item",
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFFF0EAFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Rp ${_formatPrice(_totalPrice)}",
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF9B5EFF),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_upward,
                                            color: Color(0xFF9B97B8),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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

  Widget _buildProductPanel(double hPad) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.inter(
              color: const Color(0xFFF0EAFF),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: "Cari produk...",
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF5C5878),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF9B97B8), size: 20),
              filled: true,
              fillColor: const Color(0xFF16162A),
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
        const SizedBox(height: 12),

        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategory == _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF9B5EFF)
                          : const Color(0xFF16162A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF9B5EFF)
                            : const Color(0xFF1E1E35),
                      ),
                    ),
                    child: Text(
                      _categories[index],
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF9B97B8),
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

        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: const Color(0xFF5C5878),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Produk tidak ditemukan",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16162A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: const Color(0xFF5C5878),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product['name'],
                              style: GoogleFonts.inter(
                                color: const Color(0xFFF0EAFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Rp ${_formatPrice(product['price'])}",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF9B5EFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCartPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E35),
            border: Border(
              bottom: BorderSide(color: const Color(0xFF0D0D12), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🛒 Keranjang",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFF0EAFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_cartItems.isNotEmpty)
                GestureDetector(
                  onTap: _clearCart,
                  child: Text(
                    "Hapus Semua",
                    style: GoogleFonts.inter(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Cart Items
        Expanded(
          child: _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: const Color(0xFF5C5878),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Keranjang kosong",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Tambahkan produk dengan mengetuk produk",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF5C5878),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                   return Container(
                      key: ValueKey(item['id']),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFF0EAFF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Rp ${_formatPrice(item['price'])}",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF9B97B8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quantity Controls - OPTIMIZED
                          Row(
                            children: [
                              // Minus Button
                              InkWell(
                                onTap: () {
                                  _updateQuantity(index, (item['quantity'] as int) - 1);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A3A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Color(0xFF9B97B8),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Quantity Text
                              SizedBox(
                                width: 24,
                                child: Text(
                                  item['quantity'].toString(),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFF0EAFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Plus Button
                              InkWell(
                                onTap: () {
                                  _updateQuantity(index, (item['quantity'] as int) + 1);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9B5EFF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFF9B5EFF),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Trash Button - OPTIMIZED & INSTANT
                              InkWell(
                                onTap: () {
                                  _removeFromCart(index);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Footer Form - FIXED
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E35),
            border: Border(
              top: BorderSide(color: const Color(0xFF0D0D12), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Name
              TextField(
                controller: _customerNameController,
                style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Nama Pelanggan (Opsional)",
                  labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
                  hintText: "Kosongkan untuk pelanggan umum",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF5C5878), fontSize: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1E1E35), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D0D12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),

              // Row: Date & Payment - FIXED
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF9B97B8), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: GoogleFonts.inter(
                                color: const Color(0xFFF0EAFF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
  key: ValueKey(_selectedPaymentMethod),
  value: _selectedPaymentMethod,
                          dropdownColor: const Color(0xFF1E1E35),
                          style: GoogleFonts.inter(
                            color: const Color(0xFFF0EAFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9B97B8)),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: "Cash", child: Text("Cash")),
                            DropdownMenuItem(value: "Transfer", child: Text("Transfer")),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPaymentMethod = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Note
              TextField(
                controller: _noteController,
                style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 13),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Catatan (Opsional)",
                  labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 11),
                  hintText: "Tambahkan catatan untuk transaksi ini",
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF5C5878), fontSize: 11),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1E1E35), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D0D12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),

              // Total & Save Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Rp ${_formatPrice(_totalPrice)}",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9B5EFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed: _cartItems.isEmpty ? null : _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: const Color(0xFF5C5878),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "Simpan",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
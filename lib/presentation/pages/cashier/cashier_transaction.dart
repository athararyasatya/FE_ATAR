// lib/presentation/pages/cashier/cashier_transaction.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CashierTransactionPage extends StatefulWidget {
  const CashierTransactionPage({super.key});

  @override
  State<CashierTransactionPage> createState() => _CashierTransactionPageState();
}

class _CashierTransactionPageState extends State<CashierTransactionPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _paymentAmountController = TextEditingController();
  
  String _selectedPaymentMethod = "cod";
  String _selectedCategory = "Semua";
  
  List<Map<String, dynamic>> _cartItems = [];
  
  int _totalPrice = 0;
  int _paymentAmount = 0;
  int _changeAmount = 0;
  
  // Data transaksi offline
  List<Map<String, dynamic>> _offlineTransactions = [];
  bool _showOfflineHistory = false;

  // Daftar produk dummy
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
      _paymentAmount = 0;
      _changeAmount = 0;
      _paymentAmountController.clear();
    });
  }

  // ⬇️ SAVE OFFLINE TRANSACTION ⬇️
  void _saveOfflineTransaction() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Keranjang kosong!", style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final transaction = {
      'id': 'OFF-${DateFormat('yyyyMMdd').format(now)}-${_offlineTransactions.length + 1}',
      'date': DateFormat('dd MMM yyyy, HH:mm').format(now),
      'customer': _customerNameController.text.isNotEmpty 
          ? _customerNameController.text 
          : 'Pelanggan Offline',
      'items': List.from(_cartItems),
      'total': _totalPrice,
      'paymentMethod': _selectedPaymentMethod == "cod" ? "COD" : "Transfer",
      'status': 'Selesai',
      'type': 'Offline',
    };

    setState(() {
      _offlineTransactions.insert(0, transaction);
    });

    _clearCart();
    _customerNameController.clear();

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

  // ⬇️ SHOW PAYMENT DIALOG ⬇️
  void _showPaymentDialog() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Keranjang kosong! Tambahkan produk terlebih dahulu.",
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF16162A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF1E1E35)),
            ),
            title: Text(
              "Pembayaran",
              style: GoogleFonts.poppins(
                color: const Color(0xFFF0EAFF),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1E1E35), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E35),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                // Total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Pembayaran",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 14,
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
                ),
                const SizedBox(height: 16),
                // Payment Method
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Metode Pembayaran",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setStateDialog(() => _selectedPaymentMethod = "cod"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == "cod"
                                      ? const Color(0xFF9B5EFF).withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == "cod"
                                        ? const Color(0xFF9B5EFF)
                                        : const Color(0xFF1E1E35),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "COD",
                                    style: GoogleFonts.inter(
                                      color: _selectedPaymentMethod == "cod"
                                          ? const Color(0xFF9B5EFF)
                                          : const Color(0xFF9B97B8),
                                      fontSize: 13,
                                      fontWeight: _selectedPaymentMethod == "cod"
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setStateDialog(() => _selectedPaymentMethod = "transfer"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == "transfer"
                                      ? const Color(0xFF9B5EFF).withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == "transfer"
                                        ? const Color(0xFF9B5EFF)
                                        : const Color(0xFF1E1E35),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Transfer",
                                    style: GoogleFonts.inter(
                                      color: _selectedPaymentMethod == "transfer"
                                          ? const Color(0xFF9B5EFF)
                                          : const Color(0xFF9B97B8),
                                      fontSize: 13,
                                      fontWeight: _selectedPaymentMethod == "transfer"
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Payment Amount
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Jumlah Bayar",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _paymentAmountController,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFF0EAFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0",
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF5C5878),
                            fontSize: 16,
                          ),
                          prefixText: "Rp ",
                          prefixStyle: GoogleFonts.inter(
                            color: const Color(0xFF9B97B8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E1E35)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF1E1E35)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF9B5EFF)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0D0D12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setStateDialog(() {
                            _paymentAmount = int.tryParse(value.replaceAll('.', '')) ?? 0;
                            _changeAmount = _paymentAmount - _totalPrice;
                          });
                        },
                      ),
                      if (_changeAmount >= 0 && _paymentAmount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _changeAmount >= 0
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _changeAmount >= 0
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Kembalian",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9B97B8),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Rp ${_formatPrice(_changeAmount)}",
                                style: GoogleFonts.poppins(
                                  color: _changeAmount >= 0
                                      ? Colors.green.shade400
                                      : Colors.red.shade400,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
              ElevatedButton(
                onPressed: () {
                  if (_paymentAmount < _totalPrice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Jumlah bayar kurang dari total!",
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  _showSuccessDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B5EFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Bayar",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Transaksi Berhasil!",
              style: GoogleFonts.poppins(
                color: const Color(0xFFF0EAFF),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Total: Rp ${_formatPrice(_totalPrice)}",
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B5EFF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Metode: ${_selectedPaymentMethod == "cod" ? "COD" : "Transfer"}",
              style: GoogleFonts.inter(
                color: const Color(0xFF9B97B8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearCart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B5EFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Transaksi Baru",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _saveOfflineTransaction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Simpan Offline",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
                      onTap: () => Navigator.pop(context),
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
                        _showOfflineHistory ? "Riwayat Transaksi Offline" : "Transaksi Baru",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF0EAFF),
                          fontSize: isTablet ? 26 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Toggle History Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _showOfflineHistory 
                                ? const Color(0xFFFF9800).withOpacity(0.15)
                                : const Color(0xFF9B5EFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _showOfflineHistory 
                                  ? const Color(0xFFFF9800).withOpacity(0.3)
                                  : const Color(0xFF9B5EFF).withOpacity(0.3),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _showOfflineHistory = !_showOfflineHistory;
                              });
                            },
                            icon: Icon(
                              _showOfflineHistory ? Icons.add_shopping_cart : Icons.history,
                              color: _showOfflineHistory 
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFF9B5EFF),
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Clear Cart Button
                        if (!_showOfflineHistory && _cartItems.isNotEmpty)
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
                  ],
                ),
              ),

              // Body
              Expanded(
                child: _showOfflineHistory 
                    ? _buildOfflineHistory()
                    : _buildTransactionView(isTablet, hPad),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionView(bool isTablet, double hPad) {
    return Row(
      children: [
        // Left Panel - Products
        Expanded(
          flex: isTablet ? 3 : 2,
          child: Column(
            children: [
              // Search Bar
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

              // Categories
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

              // Product Grid
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
                          crossAxisCount: isTablet ? 4 : 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return GestureDetector(
                            onTap: () => _addToCart(product),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16162A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E35),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: const Color(0xFF5C5878),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                                      fontSize: 12,
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
          ),
        ),

        // Right Panel - Cart (Divider)
        if (isTablet) ...[
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
      ],
    );
  }

  Widget _buildCartPanel() {
    return Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(16),
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
                "Keranjang",
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
                  padding: const EdgeInsets.all(12),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
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
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _updateQuantity(index, (item['quantity'] as int) - 1);
                                },
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                color: const Color(0xFF9B97B8),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  item['quantity'].toString(),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFF0EAFF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _updateQuantity(index, (item['quantity'] as int) + 1);
                                },
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                color: const Color(0xFF9B5EFF),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                onPressed: () => _removeFromCart(index),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: Colors.red.shade400,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Cart Footer
        if (_cartItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E35),
              border: Border(
                top: BorderSide(color: const Color(0xFF0D0D12), width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFF0EAFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showPaymentDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B5EFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Bayar",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
    );
  }

  // ⬇️ BUILD OFFLINE HISTORY ⬇️
  Widget _buildOfflineHistory() {
    return Column(
      children: [
        // Header Info
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF16162A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E35), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.sync, color: Color(0xFFFF9800), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Transaksi Offline",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF0EAFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Total: ${_offlineTransactions.length} transaksi",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_offlineTransactions.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _offlineTransactions.clear();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Semua transaksi offline dihapus",
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
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
        const SizedBox(height: 16),

        // Transaction List
        Expanded(
          child: _offlineTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: const Color(0xFF5C5878),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada transaksi offline",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9B97B8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Lakukan transaksi dan simpan sebagai offline",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF5C5878),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showOfflineHistory = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B5EFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Mulai Transaksi",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _offlineTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _offlineTransactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16162A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    transaction['id'],
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFF0EAFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      transaction['status'],
                                      style: GoogleFonts.inter(
                                        color: Colors.green.shade400,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF9800).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "Offline",
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFF9800),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                transaction['date'],
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF5C5878),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Pelanggan: ${transaction['customer']}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF0EAFF),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${transaction['items'].length} item • ${transaction['paymentMethod']}",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9B97B8),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                "Rp ${_formatPrice(transaction['total'])}",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF9B5EFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
      ],
    );
  }
}
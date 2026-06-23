// lib/presentation/pages/cashier/offline_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kanzza_sales_app_fe/core/theme/theme_provider.dart';
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
  final TextEditingController _cashReceivedController = TextEditingController();
  
  String _selectedCategory = "Semua";
  String _selectedPaymentMethod = "Cash";
  DateTime _selectedDate = DateTime.now();
  
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _savedTransactions = [];
  
  int _totalPrice = 0;
  int _changeAmount = 0;

  // Variable untuk menyimpan data transaksi terakhir
  int _lastTotalPrice = 0;
  int _lastCashReceived = 0;
  String _lastPaymentMethod = "Cash";

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
      _calculateChange();
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
      _calculateTotal();
      _calculateChange();
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
      _calculateChange();
    });
  }

  void _calculateTotal() {
    _totalPrice = 0;
    for (var item in _cartItems) {
      _totalPrice += item['subtotal'] as int;
    }
  }

  void _calculateChange() {
    if (_cashReceivedController.text.isNotEmpty) {
      String cleanText = _cashReceivedController.text.replaceAll('.', '');
      int cashReceived = int.tryParse(cleanText) ?? 0;
      _changeAmount = cashReceived - _totalPrice;
      if (_changeAmount < 0) _changeAmount = 0;
    } else {
      _changeAmount = 0;
    }
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalPrice = 0;
      _changeAmount = 0;
      _cashReceivedController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF9B5EFF),
                    onPrimary: Colors.white,
                    surface: Color(0xFF16162A),
                    onSurface: Color(0xFFF0EAFF),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF9B5EFF),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1F2937),
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF16162A) : Colors.white,
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

  void _showSuccessDialog() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    // Gunakan data yang sudah disimpan di variable
    final totalPrice = _lastTotalPrice;
    final cashReceived = _lastCashReceived;
    final change = cashReceived - totalPrice;
    final hasChange = change > 0;
    final paymentMethod = _lastPaymentMethod;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16162A) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "✅ Transaksi Berhasil!",
                      style: GoogleFonts.poppins(
                        color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Transaksi offline telah disimpan",
                      style: GoogleFonts.inter(
                        color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Detail Transaksi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D0D12) : const Color(0xFFF5F5FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Total Belanja
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Belanja",
                                style: GoogleFonts.inter(
                                  color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Rp ${_formatPrice(totalPrice)}",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF9B5EFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          
                          if (paymentMethod == "Cash") ...[
                            const SizedBox(height: 8),
                            // Uang Diterima
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Uang Diterima",
                                  style: GoogleFonts.inter(
                                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Rp ${_formatPrice(cashReceived)}",
                                  style: GoogleFonts.poppins(
                                    color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            
                            if (hasChange) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.money_off,
                                          color: Colors.green.shade400,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Kembalian",
                                          style: GoogleFonts.inter(
                                            color: Colors.green.shade400,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Rp ${_formatPrice(change)}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.green.shade400,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            if (!hasChange && cashReceived > 0) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.blue.shade400,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Uang Pas",
                                          style: GoogleFonts.inter(
                                            color: Colors.blue.shade400,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Tidak ada kembalian",
                                      style: GoogleFonts.inter(
                                        color: Colors.blue.shade400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                          
                          if (paymentMethod == "Transfer") ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.purple.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Pembayaran via Transfer",
                                    style: GoogleFonts.inter(
                                      color: Colors.purple.shade400,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B5EFF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "OK",
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
              ),
            );
          },
        ),
      ),
    );
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

    // Simpan data transaksi terakhir ke variable sebelum di-clear
    _lastTotalPrice = _totalPrice;
    _lastPaymentMethod = _selectedPaymentMethod;
    
    String cleanText = _cashReceivedController.text.replaceAll('.', '');
    _lastCashReceived = int.tryParse(cleanText) ?? 0;

    // Validasi untuk pembayaran Cash
    if (_selectedPaymentMethod == "Cash") {
      if (_lastCashReceived < _totalPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Uang diterima kurang dari total belanja!",
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    final transaction = {
      'id': 'OFF-${DateFormat('yyyyMMdd').format(_selectedDate)}-${_savedTransactions.length + 1}',
      'date': DateFormat('dd MMM yyyy').format(_selectedDate),
      'customer': _customerNameController.text.isNotEmpty 
          ? _customerNameController.text 
          : 'Pelanggan Offline',
      'items': List.from(_cartItems),
      'total': _lastTotalPrice,
      'paymentMethod': _lastPaymentMethod,
      'cashReceived': _lastCashReceived,
      'change': _lastCashReceived - _lastTotalPrice,
      'status': 'Selesai',
      'type': 'Offline',
      'note': _noteController.text,
    };

    setState(() {
      _savedTransactions.insert(0, transaction);
    });

    // Clear data setelah transaksi
    _clearCart();
    _customerNameController.clear();
    _noteController.clear();
    _cashReceivedController.clear();

    // Tampilkan popup success
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _showSuccessDialog();
      }
    });
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Fungsi untuk format uang dengan titik
  String _formatMoney(String text) {
    if (text.isEmpty) return '';
    String cleanText = text.replaceAll('.', '');
    if (cleanText.isEmpty) return '';
    int value = int.tryParse(cleanText) ?? 0;
    return _formatPrice(value);
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
            // Header
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
                      "Catat Transaksi Offline",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFFF0EAFF)
                            : const Color(0xFF1F2937),
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
                          child: _buildProductPanel(hPad, isDark),
                        ),
                        VerticalDivider(
                          color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                          width: 1,
                          thickness: 1,
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildCartPanel(isDark),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: _buildProductPanel(hPad, isDark),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF16162A) : Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                          ),
                          child: SafeArea(
                            child: GestureDetector(
                              onTap: () {
                                _showCartBottomSheet(isDark);
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
                                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${_cartItems.length} item",
                                          style: GoogleFonts.inter(
                                            color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
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
                                        Icon(
                                          Icons.arrow_upward,
                                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
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
    );
  }

  void _showCartBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16162A) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: _buildCartPanelWithState(isDark, modalSetState),
            );
          },
        );
      },
    );
  }

  Widget _buildCartPanelWithState(bool isDark, StateSetter modalSetState) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFF3F4F6),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF0D0D12) : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🛒 Keranjang",
                style: GoogleFonts.poppins(
                  color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_cartItems.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _clearCart();
                    });
                    modalSetState(() {});
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

        // Cart Items
        Expanded(
          child: _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Keranjang kosong",
                        style: GoogleFonts.inter(
                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Tambahkan produk dengan mengetuk produk",
                        style: GoogleFonts.inter(
                          color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
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
                        color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFF3F4F6),
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
                                    color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Rp ${_formatPrice(item['price'])}",
                                  style: GoogleFonts.inter(
                                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _updateQuantity(index, (item['quantity'] as int) - 1);
                                  });
                                  modalSetState(() {});
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 24,
                                child: Text(
                                  item['quantity'].toString(),
                                  style: GoogleFonts.inter(
                                    color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _updateQuantity(index, (item['quantity'] as int) + 1);
                                  });
                                  modalSetState(() {});
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
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _removeFromCart(index);
                                  });
                                  modalSetState(() {});
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

        // Footer Form
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFF3F4F6),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF0D0D12) : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Name
              TextField(
                controller: _customerNameController,
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: "Nama Pelanggan (Opsional)",
                  labelStyle: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                  hintText: "Kosongkan untuk pelanggan umum",
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0D0D12) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),

              // Row: Date & Payment
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await _selectDate(context);
                        modalSetState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D0D12) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: GoogleFonts.inter(
                                color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
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
                        color: isDark ? const Color(0xFF0D0D12) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPaymentMethod,
                          dropdownColor: isDark ? const Color(0xFF1E1E35) : Colors.white,
                          style: GoogleFonts.inter(
                            color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: "Cash", child: Text("Cash")),
                            DropdownMenuItem(value: "Transfer", child: Text("Transfer")),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPaymentMethod = value;
                                if (value == "Transfer") {
                                  _cashReceivedController.clear();
                                  _changeAmount = 0;
                                }
                              });
                              modalSetState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Cash Received Field dengan Format Rupiah
              if (_selectedPaymentMethod == "Cash") ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _cashReceivedController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          String formatted = _formatMoney(value);
                          if (formatted != value) {
                            _cashReceivedController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                          setState(() {
                            _calculateChange();
                          });
                          modalSetState(() {});
                        },
                        style: GoogleFonts.inter(
                          color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: "Uang Diterima",
                          labelStyle: GoogleFonts.inter(
                            color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                          hintText: "Masukkan nominal uang",
                          hintStyle: GoogleFonts.inter(
                            color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                          prefixText: "Rp ",
                          prefixStyle: GoogleFonts.inter(
                            color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0D0D12) : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D0D12) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kembalian",
                              style: GoogleFonts.inter(
                                color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _changeAmount > 0
                                  ? "Rp ${_formatPrice(_changeAmount)}"
                                  : _cashReceivedController.text.isNotEmpty && _changeAmount == 0
                                      ? "Uang Pas"
                                      : "Rp 0",
                              style: GoogleFonts.poppins(
                                color: _changeAmount > 0
                                    ? Colors.green.shade400
                                    : isDark
                                        ? const Color(0xFFF0EAFF)
                                        : const Color(0xFF1F2937),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Note
              TextField(
                controller: _noteController,
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                  fontSize: 13,
                ),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Catatan (Opsional)",
                  labelStyle: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                  hintText: "Tambahkan catatan untuk transaksi ini",
                  hintStyle: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0D0D12) : Colors.white,
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
                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
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
                      onPressed: _cartItems.isEmpty ? null : () {
                        // Tutup bottom sheet dengan animasi
                        Navigator.pop(context);
                        // Simpan transaksi setelah bottom sheet tertutup
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            _saveTransaction();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: isDark ? const Color(0xFF5C5878) : const Color(0xFFD1D5DB),
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

  Widget _buildProductPanel(double hPad, bool isDark) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.inter(
              color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: "Cari produk...",
              hintStyle: GoogleFonts.inter(
                color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                size: 20,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF16162A) : Colors.white,
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
                          : isDark
                              ? const Color(0xFF16162A)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
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

        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Produk tidak ditemukan",
                        style: GoogleFonts.inter(
                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
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
                          color: isDark ? const Color(0xFF16162A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                          ),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product['name'],
                              style: GoogleFonts.inter(
                                color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
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

  Widget _buildCartPanel(bool isDark) {
    return _buildCartPanelWithState(isDark, setState);
  }
}
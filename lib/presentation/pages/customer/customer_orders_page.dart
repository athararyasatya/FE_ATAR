// lib/features/customer/presentation/pages/customer_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({super.key});

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  int _selectedTab = 0; // 0: Semua, 1: Diproses, 2: Dikirim, 3: Selesai

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'INV-2025-001',
      'date': '15 Juni 2025',
      'status': 'Diproses',
      'statusColor': const Color(0xFFFF9B5EFF),
      'items': [
        {'name': 'Keripik Singkong Original', 'qty': 2, 'price': 15000},
        {'name': 'Air Mineral 600ml', 'qty': 1, 'price': 4000},
      ],
      'total': 34000,
      'paymentMethod': 'COD',
      'deliveryMethod': 'Di Antar',
      'address': 'Jl. Raya PLP Curug No. 124, Legok, Tangerang',
    },
    {
      'id': 'INV-2025-002',
      'date': '14 Juni 2025',
      'status': 'Dikirim',
      'statusColor': const Color(0xFF4CAF50),
      'items': [
        {'name': 'Beras Premium 5kg', 'qty': 1, 'price': 65000},
        {'name': 'Mie Instan Goreng', 'qty': 3, 'price': 3500},
      ],
      'total': 75500,
      'paymentMethod': 'Transfer Bank',
      'deliveryMethod': 'Di Antar',
      'address': 'Jl. Citra Raya No. 45, Panongan, Tangerang',
    },
    {
      'id': 'INV-2025-003',
      'date': '13 Juni 2025',
      'status': 'Selesai',
      'statusColor': const Color(0xFF2196F3),
      'items': [
        {'name': 'Es Krim Coklat', 'qty': 2, 'price': 12000},
        {'name': 'Teh Botol 350ml', 'qty': 2, 'price': 5000},
      ],
      'total': 34000,
      'paymentMethod': 'COD',
      'deliveryMethod': 'Ambil di Toko',
      'address': 'Ambil di Toko',
    },
    {
      'id': 'INV-2025-004',
      'date': '12 Juni 2025',
      'status': 'Dibatalkan',
      'statusColor': const Color(0xFFFF5252),
      'items': [
        {'name': 'Keripik Singkong Original', 'qty': 1, 'price': 15000},
      ],
      'total': 15000,
      'paymentMethod': 'COD',
      'deliveryMethod': 'Di Antar',
      'address': 'Jl. Alam Sutera No. 12, Tangerang',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedTab == 0) return _orders;
    final statusMap = {
      1: 'Diproses',
      2: 'Dikirim',
      3: 'Selesai',
    };
    final filterStatus = statusMap[_selectedTab];
    if (filterStatus == null) return _orders;
    return _orders.where((order) => order['status'] == filterStatus).toList();
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
                        "Pesanan Saya",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF0EAFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Filter / Search Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16162A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // TODO: Implement filter
                        },
                        icon: const Icon(Icons.filter_list, color: Color(0xFF9B97B8), size: 22),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Row(
                  children: [
                    _buildTabButton("Semua", 0),
                    _buildTabButton("Diproses", 1),
                    _buildTabButton("Dikirim", 2),
                    _buildTabButton("Selesai", 3),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Order List
              Expanded(
                child: _filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return _buildOrderCard(order);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF9B5EFF) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFFF0EAFF) : const Color(0xFF9B97B8),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Order
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    order['id'],
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF0EAFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (order['statusColor'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (order['statusColor'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      order['status'],
                      style: GoogleFonts.inter(
                        color: order['statusColor'] as Color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                order['date'],
                style: GoogleFonts.inter(
                  color: const Color(0xFF9B97B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Items
          ...order['items'].map<Widget>((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${item['qty']}x ${item['name']}",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Rp ${_formatPrice(item['price'] * item['qty'])}",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF0EAFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(color: Color(0xFF1E1E35), height: 16),

          // Total & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Belanja",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "Rp ${_formatPrice(order['total'])}",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9B5EFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Detail Button
                  if (order['status'] != 'Dibatalkan')
                    TextButton(
                      onPressed: () {
                        _showOrderDetailDialog(order);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(
                        "Detail",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B5EFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (order['status'] == 'Diproses') ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        _showCancelOrderDialog(order);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(
                        "Batalkan",
                        style: GoogleFonts.inter(
                          color: Colors.red.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (order['status'] == 'Selesai')
                    TextButton(
                      onPressed: () {
                        _showReorderDialog(order);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF9B5EFF).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: const Color(0xFF9B5EFF).withOpacity(0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(
                        "Pesan Lagi",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B5EFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Delivery Info
          if (order['deliveryMethod'] == 'Di Antar')
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF9B97B8), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['address'],
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9B97B8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: Icon(
              Icons.receipt_long,
              color: const Color(0xFF5C5878),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Belum Ada Pesanan",
            style: GoogleFonts.poppins(
              color: const Color(0xFFF0EAFF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai belanja sekarang dan\nlihat pesanan Anda di sini",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF9B97B8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Mulai Belanja",
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

  void _showOrderDetailDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Detail Pesanan",
          style: GoogleFonts.poppins(
            color: const Color(0xFFF0EAFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ID Pesanan: ${order['id']}",
                style: GoogleFonts.inter(
                  color: const Color(0xFF9B97B8),
                  fontSize: 13,
                ),
              ),
              Text(
                "Tanggal: ${order['date']}",
                style: GoogleFonts.inter(
                  color: const Color(0xFF9B97B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order['items'].map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${item['qty']}x ${item['name']}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF0EAFF),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Rp ${_formatPrice(item['price'] * item['qty'])}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFFF0EAFF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF0EAFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Rp ${_formatPrice(order['total'])}",
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
                    "Metode Pembayaran",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    order['paymentMethod'],
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF0EAFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Metode Pengiriman",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    order['deliveryMethod'],
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF0EAFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (order['deliveryMethod'] == 'Di Antar') ...[
                const SizedBox(height: 4),
                Text(
                  "Alamat: ${order['address']}",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.inter(
                color: const Color(0xFF9B97B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Batalkan Pesanan",
          style: GoogleFonts.poppins(
            color: const Color(0xFFF0EAFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin membatalkan pesanan ${order['id']}?",
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Pesanan ${order['id']} berhasil dibatalkan",
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Ya, Batalkan",
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

  void _showReorderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Pesan Lagi",
          style: GoogleFonts.poppins(
            color: const Color(0xFFF0EAFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Tambahkan semua item dari pesanan ${order['id']} ke keranjang?",
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Item ditambahkan ke keranjang!",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF9B5EFF),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              "Tambahkan",
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
}
// lib/presentation/pages/driver/driver_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  int _selectedTab = 0; // 0: Semua, 1: Menunggu, 2: Diambil, 3: Dikirim
  
  final List<Map<String, dynamic>> _deliveries = [
    {
      'id': 'INV-2025-001',
      'customer': 'Ahmad Fauzi',
      'address': 'Jl. Raya PLP Curug No. 124, Legok, Tangerang',
      'total': 34000,
      'status': 'Menunggu',
      'statusColor': const Color(0xFFFF9B5EFF),
      'date': '15 Jun 2025, 14:30',
      'items': 2,
      'payment': 'COD',
      'distance': '4.2 km',
      'estimate': '15 min',
    },
    {
      'id': 'INV-2025-002',
      'customer': 'Siti Rahma',
      'address': 'Jl. Citra Raya No. 45, Panongan, Tangerang',
      'total': 75500,
      'status': 'Diambil',
      'statusColor': const Color(0xFF2196F3),
      'date': '15 Jun 2025, 13:15',
      'items': 3,
      'payment': 'Transfer',
      'distance': '6.8 km',
      'estimate': '20 min',
    },
    {
      'id': 'INV-2025-003',
      'customer': 'Budi Santoso',
      'address': 'Jl. Alam Sutera No. 12, Tangerang',
      'total': 34000,
      'status': 'Dikirim',
      'statusColor': const Color(0xFF4CAF50),
      'date': '15 Jun 2025, 11:45',
      'items': 2,
      'payment': 'COD',
      'distance': '8.1 km',
      'estimate': '25 min',
    },
    {
      'id': 'INV-2025-004',
      'customer': 'Dewi Lestari',
      'address': 'Jl. Gading Serpong No. 8, Tangerang',
      'total': 15000,
      'status': 'Menunggu',
      'statusColor': const Color(0xFFFF9B5EFF),
      'date': '15 Jun 2025, 10:20',
      'items': 1,
      'payment': 'COD',
      'distance': '5.3 km',
      'estimate': '18 min',
    },
  ];

  final List<Map<String, dynamic>> _deliveryStats = [
    {
      'title': 'Total Pengiriman',
      'value': '12',
      'icon': Icons.local_shipping_outlined,
      'color': const Color(0xFF9B5EFF),
      'change': '+2',
    },
    {
      'title': 'Selesai',
      'value': '8',
      'icon': Icons.check_circle_outline,
      'color': const Color(0xFF4CAF50),
      'change': '+4',
    },
    {
      'title': 'Dalam Perjalanan',
      'value': '3',
      'icon': Icons.directions_car_outlined,
      'color': const Color(0xFFFF9800),
      'change': '+1',
    },
    {
      'title': 'Menunggu',
      'value': '1',
      'icon': Icons.pending_outlined,
      'color': const Color(0xFFFF9B5EFF),
      'change': '-1',
    },
  ];

  List<Map<String, dynamic>> get _filteredDeliveries {
    if (_selectedTab == 0) return _deliveries;
    final statusMap = {
      1: 'Menunggu',
      2: 'Diambil',
      3: 'Dikirim',
    };
    final filterStatus = statusMap[_selectedTab];
    if (filterStatus == null) return _deliveries;
    return _deliveries.where((delivery) => delivery['status'] == filterStatus).toList();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Konfirmasi Logout",
          style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar?",
          style: GoogleFonts.inter(color: const Color(0xFF9B97B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Berhasil logout",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Logout", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeliveryDetail(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Detail Pengiriman",
          style: GoogleFonts.poppins(
            color: const Color(0xFFF0EAFF),
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
                  "ID Pesanan",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  delivery['id'],
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF0EAFF),
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
                  "Pelanggan",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  delivery['customer'],
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF0EAFF),
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
                  "Status",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (delivery['statusColor'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (delivery['statusColor'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    delivery['status'],
                    style: GoogleFonts.inter(
                      color: delivery['statusColor'] as Color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Rp ${_formatPrice(delivery['total'])}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9B5EFF),
                    fontSize: 14,
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
                  "Jarak",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  delivery['distance'],
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF0EAFF),
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
                  "Estimasi",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  delivery['estimate'],
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF0EAFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF9B97B8), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery['address'],
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9B97B8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (delivery['status'] == 'Menunggu')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateDeliveryStatus(delivery, 'Diambil');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Ambil Pesanan",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          if (delivery['status'] == 'Diambil')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateDeliveryStatus(delivery, 'Dikirim');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Tandai Dikirim",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          if (delivery['status'] == 'Dikirim')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateDeliveryStatus(delivery, 'Selesai');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Selesaikan",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
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

  void _updateDeliveryStatus(Map<String, dynamic> delivery, String newStatus) {
    setState(() {
      final index = _deliveries.indexWhere((d) => d['id'] == delivery['id']);
      if (index != -1) {
        _deliveries[index]['status'] = newStatus;
        // Update statusColor
        final statusColors = {
          'Menunggu': const Color(0xFFFF9B5EFF),
          'Diambil': const Color(0xFF2196F3),
          'Dikirim': const Color(0xFF4CAF50),
          'Selesai': const Color(0xFF4CAF50),
        };
        _deliveries[index]['statusColor'] = statusColors[newStatus] ?? const Color(0xFFFF9B5EFF);
        
        // Update stats
        _updateStats();
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Status pengiriman berhasil diperbarui!",
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateStats() {
    // Recalculate stats based on current deliveries
    // This is just a placeholder - in real app, you'd recalculate from data
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
              // Header - TANPA ICON BACK
              Container(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Dashboard Driver",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFF0EAFF),
                          fontSize: isTablet ? 26 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Notification Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16162A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E1E35), width: 1),
                          ),
                          child: Stack(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF9B97B8), size: 22),
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
                        const SizedBox(width: 8),
                        // Logout Button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.red.shade400.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade400.withOpacity(0.3)),
                          ),
                          child: IconButton(
                            onPressed: _logout,
                            icon: Icon(Icons.logout, color: Colors.red.shade400, size: 22),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(isTablet),
                      const SizedBox(height: 24),

                      // Stats Cards
                      _buildStatsCards(isTablet),
                      const SizedBox(height: 24),

                      // Delivery Tabs
                      _buildDeliveryTabs(),
                      const SizedBox(height: 16),

                      // Delivery List
                      _buildDeliveryList(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B5EFF), Color(0xFF6C3BD8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat Bekerja, Driver! 🚗",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total pengiriman hari ini: 12 pengiriman",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 16 : 13,
                  ),
                ),
                if (isTablet) ...[
                  const SizedBox(height: 8),
                  Text(
                    "📦 8 selesai | 🚚 3 dalam perjalanan | ⏳ 1 menunggu",
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: isTablet ? 60 : 44,
            height: isTablet ? 60 : 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delivery_dining, color: Colors.white, size: isTablet ? 32 : 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: _deliveryStats.length,
      itemBuilder: (context, index) {
        final stat = _deliveryStats[index];
        final color = stat['color'] as Color;
        final icon = stat['icon'] as IconData;
        final title = stat['title'] as String;
        final value = stat['value'] as String;
        final change = stat['change'] as String;
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16162A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E1E35), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: change.startsWith('+')
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      change,
                      style: GoogleFonts.inter(
                        color: change.startsWith('+')
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF0EAFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryTabs() {
    final tabs = ["Semua", "Menunggu", "Diambil", "Dikirim"];
    return Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final isSelected = _selectedTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9B5EFF) : const Color(0xFF16162A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFF9B5EFF) : const Color(0xFF1E1E35),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFF9B97B8),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryList() {
    final filtered = _filteredDeliveries;
    
    if (filtered.isEmpty) {
      return Center(
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
              "Tidak ada pengiriman",
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B97B8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Semua pengiriman telah selesai",
              style: GoogleFonts.inter(
                color: const Color(0xFF5C5878),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final delivery = filtered[index];
        final statusColor = delivery['statusColor'] as Color;
        final total = delivery['total'] as int;
        
        return GestureDetector(
          onTap: () => _showDeliveryDetail(delivery),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
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
                          delivery['id'],
                          style: GoogleFonts.inter(
                            color: const Color(0xFFF0EAFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            delivery['status'],
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      delivery['date'].split(',')[0],
                      style: GoogleFonts.inter(
                        color: const Color(0xFF5C5878),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  delivery['customer'],
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF0EAFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF9B97B8), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        delivery['address'],
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9B97B8),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "${delivery['items']} item",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B97B8),
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            delivery['payment'],
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B97B8),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.directions_car, color: Color(0xFF9B97B8), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          delivery['distance'],
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9B97B8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Rp ${_formatPrice(total)}",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF9B5EFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
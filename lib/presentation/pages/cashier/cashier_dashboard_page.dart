// lib/presentation/pages/cashier/cashier_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class CashierDashboardPage extends StatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  State<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends State<CashierDashboardPage> {
  // Statistik dummy
  final Map<String, dynamic> _stats = {
    'online': {
      'count': 45,
      'total': 3425000,
      'today': 12,
    },
    'offline': {
      'count': 8,
      'total': 125000,
      'today': 3,
    },
  };

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'id': 'TRX-2025-001',
      'customer': 'Ahmad Fauzi',
      'total': 34000,
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'date': '15 Jun 2025, 14:30',
      'items': 2,
      'payment': 'COD',
      'type': 'Online',
    },
    {
      'id': 'TRX-2025-002',
      'customer': 'Siti Rahma',
      'total': 75500,
      'status': 'Diproses',
      'statusColor': const Color(0xFFFF9B5EFF),
      'date': '15 Jun 2025, 13:15',
      'items': 3,
      'payment': 'Transfer',
      'type': 'Online',
    },
    {
      'id': 'OFF-2025-001',
      'customer': 'Pelanggan Offline',
      'total': 25000,
      'status': 'Selesai',
      'statusColor': const Color(0xFFFF9800),
      'date': '15 Jun 2025, 12:30',
      'items': 2,
      'payment': 'COD',
      'type': 'Offline',
    },
    {
      'id': 'TRX-2025-003',
      'customer': 'Budi Santoso',
      'total': 34000,
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'date': '15 Jun 2025, 11:45',
      'items': 2,
      'payment': 'COD',
      'type': 'Online',
    },
    {
      'id': 'OFF-2025-002',
      'customer': 'Warung Sembako',
      'total': 15000,
      'status': 'Selesai',
      'statusColor': const Color(0xFFFF9800),
      'date': '15 Jun 2025, 10:20',
      'items': 1,
      'payment': 'COD',
      'type': 'Offline',
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Catat Offline',
      'subtitle': 'Catat transaksi offline',
      'icon': Icons.sync,
      'color': const Color(0xFFFF9800),
      'route': AppRoutes.offlineTransaction,
    },
    {
      'title': 'Transaksi Online',
      'subtitle': 'Buat transaksi online',
      'icon': Icons.wifi,
      'color': const Color(0xFF9B5EFF),
      'route': AppRoutes.cashierTransaction,
    },
    {
      'title': 'Daftar Produk',
      'subtitle': 'Lihat dan kelola produk',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF4CAF50),
      'route': AppRoutes.cashierProducts,
    },
    {
      'title': 'Riwayat Offline',
      'subtitle': 'Lihat transaksi offline',
      'icon': Icons.history,
      'color': const Color(0xFFFF9800),
      'route': '/cashier-history', // ⬅️ Nanti tambahkan di routes.dart
    },
  ];

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
                        "Dashboard Kasir",
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

                      // Stats Cards - Online & Offline
                      _buildStatsCards(isTablet),
                      const SizedBox(height: 24),

                      // Quick Actions Menu
                      _buildSectionTitle("Aksi Cepat"),
                      const SizedBox(height: 12),
                      _buildMenuGrid(isTablet),
                      const SizedBox(height: 24),

                      // Recent Transactions
                      _buildSectionTitle("Transaksi Terbaru"),
                      const SizedBox(height: 12),
                      _buildRecentTransactions(),
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
                  "Selamat Bekerja, Kasir! 👋",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total transaksi hari ini: ${_stats['online']['today'] + _stats['offline']['today']} transaksi",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 16 : 13,
                  ),
                ),
                if (isTablet) ...[
                  const SizedBox(height: 8),
                  Text(
                    "💰 Online: Rp ${_formatPrice(_stats['online']['today'] * 50000)} | Offline: Rp ${_formatPrice(_stats['offline']['today'] * 15000)}",
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
            child: Icon(Icons.point_of_sale, color: Colors.white, size: isTablet ? 32 : 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isTablet) {
    final online = _stats['online'];
    final offline = _stats['offline'];
    
    final stats = [
      {
        'title': 'Online',
        'value': online['count'].toString(),
        'subValue': 'Rp ${_formatPrice(online['total'])}',
        'icon': Icons.wifi,
        'color': const Color(0xFF9B5EFF),
        'today': '+${online['today']} hari ini',
      },
      {
        'title': 'Offline',
        'value': offline['count'].toString(),
        'subValue': 'Rp ${_formatPrice(offline['total'])}',
        'icon': Icons.sync,
        'color': const Color(0xFFFF9800),
        'today': '+${offline['today']} hari ini',
      },
      {
        'title': 'Total Transaksi',
        'value': (online['count'] + offline['count']).toString(),
        'subValue': 'Rp ${_formatPrice(online['total'] + offline['total'])}',
        'icon': Icons.receipt_long,
        'color': const Color(0xFF4CAF50),
        'today': '+${online['today'] + offline['today']} hari ini',
      },
      {
        'title': 'Pelanggan',
        'value': '42',
        'subValue': '9 pelanggan baru',
        'icon': Icons.people_outline,
        'color': const Color(0xFF2196F3),
        'today': '+5 hari ini',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = stat['color'] as Color;
        final icon = stat['icon'] as IconData;
        final title = stat['title'] as String;
        final value = stat['value'] as String;
        final subValue = stat['subValue'] as String;
        final today = stat['today'] as String;
        
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      today,
                      style: GoogleFonts.inter(
                        color: color,
                        fontSize: 8,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subValue,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 9,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFFF0EAFF),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildMenuGrid(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        final title = item['title'] as String;
        final subtitle = item['subtitle'] as String;
        final route = item['route'] as String;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF16162A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E1E35), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFF0EAFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9B97B8),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _recentTransactions[index];
        final statusColor = transaction['statusColor'] as Color;
        final total = transaction['total'] as int;
        final isOffline = transaction['type'] == 'Offline';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16162A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E35), width: 1),
          ),
          child: Row(
            children: [
              // Type Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOffline 
                      ? const Color(0xFFFF9800).withOpacity(0.15)
                      : const Color(0xFF9B5EFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOffline ? Icons.sync : Icons.wifi,
                  color: isOffline ? const Color(0xFFFF9800) : const Color(0xFF9B5EFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            transaction['status'],
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isOffline 
                                ? const Color(0xFFFF9800).withOpacity(0.15)
                                : const Color(0xFF9B5EFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isOffline 
                                  ? const Color(0xFFFF9800).withOpacity(0.3)
                                  : const Color(0xFF9B5EFF).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            transaction['type'],
                            style: GoogleFonts.inter(
                              color: isOffline ? const Color(0xFFFF9800) : const Color(0xFF9B5EFF),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          transaction['customer'],
                          style: GoogleFonts.inter(
                            color: const Color(0xFF9B97B8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction['payment'],
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9B97B8),
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rp ${_formatPrice(total)}",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9B5EFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    transaction['date'],
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5C5878),
                      fontSize: 9,
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
// lib/presentation/pages/cashier/cashier_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kanzza_sales_app_fe/core/theme/theme_provider.dart';
import 'package:kanzza_sales_app_fe/core/widgets/theme_toggle_button.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class CashierDashboardPage extends StatefulWidget {
  const CashierDashboardPage({super.key});

  @override
  State<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends State<CashierDashboardPage> {
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
      'title': 'Daftar Produk',
      'subtitle': 'Lihat produk',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF4CAF50),
      'route': AppRoutes.cashierProducts,
    },
    {
      'title': 'Kelola Produk',
      'subtitle': 'Tambah & kelola',
      'icon': Icons.edit_note,
      'color': const Color(0xFF2196F3),
      'route': AppRoutes.manageProducts,
    },
    {
      'title': 'Riwayat',
      'subtitle': 'Lihat transaksi',
      'icon': Icons.history,
      'color': const Color(0xFF9B5EFF),
      'route': AppRoutes.transactionHistory,
    },
  ];

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
        
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE8E8F0),
            ),
          ),
          title: Text(
            "Konfirmasi Logout",
            style: GoogleFonts.poppins(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar?",
            style: GoogleFonts.inter(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.inter(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
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
                "Logout",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
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
                  Expanded(
                    child: Text(
                      "Dashboard Kasir",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFFF0EAFF)
                            : const Color(0xFF1F2937),
                        fontSize: isTablet ? 26 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const ThemeToggleButton(),
                      const SizedBox(width: 8),
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
                            width: 1,
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
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.red.shade400.withOpacity(0.15)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.red.shade400.withOpacity(0.3)
                                : Colors.red.shade200,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _logout,
                          icon: Icon(
                            Icons.logout,
                            color: isDark ? Colors.red.shade400 : Colors.red.shade400,
                            size: 22,
                          ),
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
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(isTablet, isDark),
                    const SizedBox(height: 24),
                    _buildStatsCards(isTablet, isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Aksi Cepat", isDark),
                    const SizedBox(height: 12),
                    _buildMenuGrid(isTablet, isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Transaksi Terbaru", isDark),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(isDark),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(bool isTablet, bool isDark) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B5EFF), Color(0xFF6C3BD8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B5EFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
            child: Icon(
              Icons.point_of_sale,
              color: Colors.white,
              size: isTablet ? 32 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isTablet, bool isDark) {
    final online = _stats['online'];
    final offline = _stats['offline'];
    final theme = Theme.of(context);

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
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: isDark ? Border.all(color: const Color(0xFF1E1E35)) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.2)),
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
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subValue,
                    style: GoogleFonts.inter(
                      color: theme.textTheme.bodySmall?.color,
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

  Widget _buildSectionTitle(String title, bool isDark) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: theme.textTheme.titleLarge?.color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildMenuGrid(bool isTablet, bool isDark) {
    final theme = Theme.of(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1, // DIPERBAIKI: dari 1.2 menjadi 1.1
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
            padding: const EdgeInsets.all(12), // DIPERBAIKI: dari 14 menjadi 12
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: isDark ? Border.all(color: const Color(0xFF1E1E35)) : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44, // DIPERBAIKI: dari 48 menjadi 44
                  height: 44, // DIPERBAIKI: dari 48 menjadi 44
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22), // DIPERBAIKI: dari 24 menjadi 22
                ),
                const SizedBox(height: 8), // DIPERBAIKI: dari 10 menjadi 8
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 12, // DIPERBAIKI: dari 13 menjadi 12
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
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 9, // DIPERBAIKI: dari 10 menjadi 9
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1, // DIPERBAIKI: dari 2 menjadi 1
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions(bool isDark) {
    final theme = Theme.of(context);
    
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
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: isDark ? Border.all(color: const Color(0xFF1E1E35)) : null,
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
          child: Row(
            children: [
              // Icon - Fixed width
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isOffline
                      ? const Color(0xFFFF9800).withOpacity(0.1)
                      : const Color(0xFF9B5EFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOffline ? Icons.sync : Icons.wifi,
                  color: isOffline ? const Color(0xFFFF9800) : const Color(0xFF9B5EFF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              
              // Middle Content - Expanded with constraints
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: ID, Status, Type
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          transaction['id'],
                          style: GoogleFonts.inter(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withOpacity(0.2),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOffline
                                ? const Color(0xFFFF9800).withOpacity(0.1)
                                : const Color(0xFF9B5EFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isOffline
                                  ? const Color(0xFFFF9800).withOpacity(0.2)
                                  : const Color(0xFF9B5EFF).withOpacity(0.2),
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
                    const SizedBox(height: 4),
                    
                    // Row 2: Customer and Payment
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          transaction['customer'],
                          style: GoogleFonts.inter(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E35)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction['payment'],
                            style: GoogleFonts.inter(
                              color: theme.textTheme.bodySmall?.color,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Right Content - Fixed width
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Rp ${_formatPrice(total)}",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF9B5EFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      transaction['date'],
                      style: GoogleFonts.inter(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 9,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
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
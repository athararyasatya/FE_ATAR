// lib/features/owner/presentation/pages/owner_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

// ⬇️ IMPORT HALAMAN ⬇️
import 'owner_products_page.dart';
import 'owner_reports_page.dart';
import 'owner_manage_role_page.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  int _selectedPeriod = 0;

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 'INV-2025-001',
      'customer': 'Ahmad Fauzi',
      'total': 34000,
      'status': 'Diproses',
      'statusColor': const Color(0xFFFF9B5EFF),
      'date': '15 Jun 2025',
      'items': 2,
    },
    {
      'id': 'INV-2025-002',
      'customer': 'Siti Rahma',
      'total': 75500,
      'status': 'Dikirim',
      'statusColor': const Color(0xFF4CAF50),
      'date': '14 Jun 2025',
      'items': 3,
    },
    {
      'id': 'INV-2025-003',
      'customer': 'Budi Santoso',
      'total': 34000,
      'status': 'Selesai',
      'statusColor': const Color(0xFF2196F3),
      'date': '13 Jun 2025',
      'items': 2,
    },
    {
      'id': 'INV-2025-004',
      'customer': 'Dewi Lestari',
      'total': 15000,
      'status': 'Dibatalkan',
      'statusColor': const Color(0xFFFF5252),
      'date': '12 Jun 2025',
      'items': 1,
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Kelola Produk',
      'subtitle': 'Tambah, edit, hapus produk',
      'icon': Icons.inventory_2_outlined,
      'color': const Color(0xFF9B5EFF),
      'page': const OwnerProductsPage(),
    },
    {
      'title': 'Laporan Penjualan',
      'subtitle': 'Lihat laporan dan analisis',
      'icon': Icons.assessment_outlined,
      'color': const Color(0xFF4CAF50),
      'page': const OwnerReportsPage(),
    },
    {
      'title': 'Manajemen User',
      'subtitle': 'Kelola akses karyawan',
      'icon': Icons.people_outline,
      'color': const Color(0xFF2196F3),
      'page': const OwnerManageRolePage(),
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
                    // HAPUS GestureDetector back button
                    // const SizedBox(width: 12), // HAPUS JUGA
                    Expanded(
                      child: Text(
                        "Dashboard Owner",
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

              // Content - Expanded dengan SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(isTablet),
                      const SizedBox(height: 20),
                      _buildPeriodSelector(),
                      const SizedBox(height: 16),
                      _buildStatsCards(isTablet),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Menu Manajemen"),
                      const SizedBox(height: 12),
                      _buildMenuGrid(isTablet),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Insight & Rekomendasi"),
                      const SizedBox(height: 12),
                      _buildInsightCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Grafik Penjualan"),
                      const SizedBox(height: 12),
                      _buildSalesChart(),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Pesanan Terbaru"),
                      const SizedBox(height: 12),
                      _buildRecentOrders(),
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
                  "Selamat Pagi, Owner! 👋",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total pendapatan hari ini: Rp 1.234.500",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 16 : 13,
                  ),
                ),
                if (isTablet) ...[
                  const SizedBox(height: 8),
                  Text(
                    "📈 Naik 12.5% dari kemarin | 🎯 Target: Rp 2.000.000",
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
            child: Icon(Icons.analytics, color: Colors.white, size: isTablet ? 32 : 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ["Hari Ini", "Minggu Ini", "Bulan Ini"];
    return Row(
      children: periods.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final isSelected = _selectedPeriod == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = index),
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

  Widget _buildStatsCards(bool isTablet) {
    final stats = [
      {
        'title': 'Pendapatan',
        'value': 'Rp 1.234.500',
        'icon': Icons.attach_money,
        'color': const Color(0xFF4CAF50),
        'change': '+12.5%',
      },
      {
        'title': 'Pesanan',
        'value': '45',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFF9B5EFF),
        'change': '+8.3%',
      },
      {
        'title': 'Pelanggan',
        'value': '128',
        'icon': Icons.people_outline,
        'color': const Color(0xFF2196F3),
        'change': '+5.2%',
      },
      {
        'title': 'Produk',
        'value': '67',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFFFF9800),
        'change': '-2.1%',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = stat['color'] as Color;
        final icon = stat['icon'] as IconData;
        final change = stat['change'] as String;
        final title = stat['title'] as String;
        final value = stat['value'] as String;
        
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
        crossAxisCount: isTablet ? 3 : 2,
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
        final page = item['page'] as Widget;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
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

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B5EFF).withOpacity(0.15),
            const Color(0xFF6C3BD8).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF9B5EFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B5EFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF9B5EFF),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Data-Driven Decision Making",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFF0EAFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInsightItem(
            icon: Icons.trending_up,
            color: Colors.green,
            title: "Peningkatan Penjualan",
            description: "Penjualan naik 12.5% dalam 7 hari. Produk terlaris: Keripik Singkong.",
          ),
          const SizedBox(height: 6),
          _buildInsightItem(
            icon: Icons.warning_amber,
            color: Colors.orange,
            title: "Stok Menipis",
            description: "Beras Premium 5kg tersisa 3 unit. Segera restock!",
          ),
          const SizedBox(height: 6),
          _buildInsightItem(
            icon: Icons.people,
            color: Colors.blue,
            title: "Pelanggan Baru",
            description: "5 pelanggan baru hari ini. Total: 128 pelanggan aktif.",
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF9B5EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF9B5EFF).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF9B5EFF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "🎯 Rekomendasi: Tingkatkan stok produk unggulan & optimalkan promosi.",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF0EAFF),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: const Color(0xFFF0EAFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: const Color(0xFF9B97B8),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFF1E1E35),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                  if (value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9B97B8),
                        fontSize: 10,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9B97B8),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 4),
                FlSpot(2, 3),
                FlSpot(3, 7),
                FlSpot(4, 5),
                FlSpot(5, 9),
                FlSpot(6, 6),
              ],
              isCurved: true,
              color: const Color(0xFF9B5EFF),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF9B5EFF).withOpacity(0.15),
              ),
            ),
          ],
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 10,
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentOrders.length,
      itemBuilder: (context, index) {
        final order = _recentOrders[index];
        final statusColor = order['statusColor'] as Color;
        final total = order['total'] as int;
        
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order['id'],
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
                            order['status'],
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['customer'],
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9B97B8),
                        fontSize: 11,
                      ),
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
                    order['date'],
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5C5878),
                      fontSize: 10,
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
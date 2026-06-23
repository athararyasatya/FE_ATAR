// lib/features/owner/presentation/pages/owner_reports_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kanzza_sales_app_fe/core/theme/theme_provider.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class OwnerReportsPage extends StatefulWidget {
  const OwnerReportsPage({super.key});

  @override
  State<OwnerReportsPage> createState() => _OwnerReportsPageState();
}

class _OwnerReportsPageState extends State<OwnerReportsPage> {
  // Filter
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedFilter = "Semua";
  bool _isLoading = false;

  // Data Laporan dengan tanggal saat ini
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _generateDummyData();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        // Tidak perlu request otomatis, nanti saat download baru request
      }
    }
  }

  void _generateDummyData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _transactions = [
      // Data Hari Ini
      {
        'id': 'TRX-${DateFormat('yyyyMMdd').format(today)}-001',
        'customer': 'Ahmad Fauzi',
        'products': [
          {'name': 'Keripik Singkong Original', 'qty': 2, 'price': 15000},
          {'name': 'Air Mineral 600ml', 'qty': 1, 'price': 4000},
        ],
        'total': 34000,
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'date': DateTime(today.year, today.month, today.day, 14, 30),
        'payment': 'COD',
        'type': 'Online',
        'items': 3,
      },
      {
        'id': 'TRX-${DateFormat('yyyyMMdd').format(today)}-002',
        'customer': 'Siti Rahma',
        'products': [
          {'name': 'Beras Premium 5kg', 'qty': 1, 'price': 65000},
          {'name': 'Es Krim Coklat', 'qty': 2, 'price': 12000},
          {'name': 'Teh Botol 350ml', 'qty': 2, 'price': 5000},
        ],
        'total': 99000,
        'status': 'Diproses',
        'statusColor': const Color(0xFFFF9B5EFF),
        'date': DateTime(today.year, today.month, today.day, 13, 15),
        'payment': 'Transfer',
        'type': 'Online',
        'items': 5,
      },
      {
        'id': 'OFF-${DateFormat('yyyyMMdd').format(today)}-001',
        'customer': 'Pelanggan Offline',
        'products': [
          {'name': 'Keripik Singkong Balado', 'qty': 1, 'price': 17000},
          {'name': 'Es Krim Vanila', 'qty': 2, 'price': 12000},
          {'name': 'Air Mineral 600ml', 'qty': 3, 'price': 4000},
        ],
        'total': 41000,
        'status': 'Selesai',
        'statusColor': const Color(0xFFFF9800),
        'date': DateTime(today.year, today.month, today.day, 12, 30),
        'payment': 'Cash',
        'type': 'Offline',
        'items': 6,
      },
      {
        'id': 'TRX-${DateFormat('yyyyMMdd').format(today)}-003',
        'customer': 'Budi Santoso',
        'products': [
          {'name': 'Mie Instan Goreng', 'qty': 4, 'price': 3500},
          {'name': 'Gula Pasir 1kg', 'qty': 2, 'price': 18000},
          {'name': 'Air Mineral 600ml', 'qty': 2, 'price': 4000},
          {'name': 'Keripik Singkong Original', 'qty': 1, 'price': 15000},
        ],
        'total': 68500,
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'date': DateTime(today.year, today.month, today.day, 11, 45),
        'payment': 'COD',
        'type': 'Online',
        'items': 9,
      },
      {
        'id': 'OFF-${DateFormat('yyyyMMdd').format(today)}-002',
        'customer': 'Warung Sembako',
        'products': [
          {'name': 'Beras Premium 5kg', 'qty': 2, 'price': 65000},
          {'name': 'Gula Pasir 1kg', 'qty': 3, 'price': 18000},
        ],
        'total': 184000,
        'status': 'Selesai',
        'statusColor': const Color(0xFFFF9800),
        'date': DateTime(today.year, today.month, today.day, 10, 20),
        'payment': 'Cash',
        'type': 'Offline',
        'items': 5,
      },
      {
        'id': 'TRX-${DateFormat('yyyyMMdd').format(today)}-004',
        'customer': 'Dewi Lestari',
        'products': [
          {'name': 'Es Krim Coklat', 'qty': 3, 'price': 12000},
          {'name': 'Es Krim Vanila', 'qty': 2, 'price': 12000},
          {'name': 'Keripik Singkong Original', 'qty': 2, 'price': 15000},
          {'name': 'Teh Botol 350ml', 'qty': 4, 'price': 5000},
        ],
        'total': 110000,
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'date': DateTime(today.year, today.month, today.day, 09, 30),
        'payment': 'Transfer',
        'type': 'Online',
        'items': 11,
      },
      {
        'id': 'OFF-${DateFormat('yyyyMMdd').format(today)}-003',
        'customer': 'Toko Makmur',
        'products': [
          {'name': 'Gula Pasir 1kg', 'qty': 2, 'price': 18000},
          {'name': 'Beras Premium 5kg', 'qty': 1, 'price': 65000},
          {'name': 'Mie Instan Goreng', 'qty': 5, 'price': 3500},
        ],
        'total': 118500,
        'status': 'Selesai',
        'statusColor': const Color(0xFFFF9800),
        'date': DateTime(today.year, today.month, today.day, 08, 15),
        'payment': 'Cash',
        'type': 'Offline',
        'items': 8,
      },
      // Data Kemarin
      {
        'id': 'TRX-${DateFormat('yyyyMMdd').format(today.subtract(const Duration(days: 1)))}-001',
        'customer': 'Rina Setiawan',
        'products': [
          {'name': 'Keripik Singkong Balado', 'qty': 2, 'price': 17000},
          {'name': 'Air Mineral 600ml', 'qty': 2, 'price': 4000},
        ],
        'total': 42000,
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'date': DateTime(today.year, today.month, today.day - 1, 16, 00),
        'payment': 'COD',
        'type': 'Online',
        'items': 4,
      },
      {
        'id': 'TRX-${DateFormat('yyyyMMdd').format(today.subtract(const Duration(days: 1)))}-002',
        'customer': 'Andi Wijaya',
        'products': [
          {'name': 'Beras Premium 5kg', 'qty': 1, 'price': 65000},
          {'name': 'Es Krim Vanila', 'qty': 1, 'price': 12000},
        ],
        'total': 77000,
        'status': 'Selesai',
        'statusColor': const Color(0xFF4CAF50),
        'date': DateTime(today.year, today.month, today.day - 1, 14, 45),
        'payment': 'Transfer',
        'type': 'Online',
        'items': 2,
      },
      {
        'id': 'OFF-${DateFormat('yyyyMMdd').format(today.subtract(const Duration(days: 1)))}-001',
        'customer': 'Pelanggan Offline',
        'products': [
          {'name': 'Mie Instan Goreng', 'qty': 3, 'price': 3500},
          {'name': 'Gula Pasir 1kg', 'qty': 1, 'price': 18000},
        ],
        'total': 28500,
        'status': 'Selesai',
        'statusColor': const Color(0xFFFF9800),
        'date': DateTime(today.year, today.month, today.day - 1, 12, 10),
        'payment': 'Cash',
        'type': 'Offline',
        'items': 4,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _transactions;

    if (_selectedFilter != "Semua") {
      filtered = filtered.where((t) => t['type'] == _selectedFilter).toList();
    }

    filtered = filtered.where((t) {
      final date = t['date'] as DateTime;
      return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return filtered;
  }

  int get _totalTransactions => _filteredTransactions.length;
  int get _totalIncome => _filteredTransactions.fold(0, (sum, t) => sum + (t['total'] as int));
  int get _totalOnline => _filteredTransactions.where((t) => t['type'] == 'Online').length;
  int get _totalOffline => _filteredTransactions.where((t) => t['type'] == 'Offline').length;
  int get _totalOnlineIncome => _filteredTransactions
      .where((t) => t['type'] == 'Online')
      .fold(0, (sum, t) => sum + (t['total'] as int));
  int get _totalOfflineIncome => _filteredTransactions
      .where((t) => t['type'] == 'Offline')
      .fold(0, (sum, t) => sum + (t['total'] as int));

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
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
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
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
    if (picked != null) {
      setState(() {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _startDate = _endDate;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = "Semua";
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
    });
  }

  // ============ FUNGSI DOWNLOAD ============

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Cek status izin
      final status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      // Jika belum pernah diminta, request
      if (status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        } else {
          _showSnackBar(
            "Izin penyimpanan diperlukan untuk menyimpan file. Buka Settings > Permissions > Storage > Allow",
            Colors.orange,
            isPermission: true,
          );
          return false;
        }
      }

      // Jika permanently denied, arahkan ke settings
      if (status.isPermanentlyDenied) {
        _showSnackBar(
          "Izin penyimpanan telah ditolak permanen. Buka Settings untuk mengizinkan.",
          Colors.red,
          isPermission: true,
        );
        return false;
      }

      return false;
    }
    return true;
  }

  // Generate laporan dalam format teks
  String _generateReportText() {
    final buffer = StringBuffer();
    final now = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    buffer.writeln('=' * 60);
    buffer.writeln('          LAPORAN PENJUALAN KANZZA FROZEN FOOD');
    buffer.writeln('=' * 60);
    buffer.writeln('Tanggal Laporan: $now');
    buffer.writeln(
        'Periode: ${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}');
    buffer.writeln('Tipe Transaksi: $_selectedFilter');
    buffer.writeln('-' * 60);
    buffer.writeln('');
    buffer.writeln('RINGKASAN:');
    buffer.writeln('  Total Transaksi: $_totalTransactions');
    buffer.writeln('  Total Pendapatan: Rp ${_formatPrice(_totalIncome)}');
    buffer.writeln('  Online: $_totalOnline transaksi (Rp ${_formatPrice(_totalOnlineIncome)})');
    buffer.writeln('  Offline: $_totalOffline transaksi (Rp ${_formatPrice(_totalOfflineIncome)})');
    buffer.writeln('');
    buffer.writeln('-' * 60);
    buffer.writeln('DETAIL TRANSAKSI:');
    buffer.writeln('');

    if (_filteredTransactions.isEmpty) {
      buffer.writeln('Tidak ada transaksi dalam periode ini.');
    } else {
      for (var i = 0; i < _filteredTransactions.length; i++) {
        final t = _filteredTransactions[i];
        buffer.writeln('${i + 1}. ${t['id']}');
        buffer.writeln('   Customer: ${t['customer']}');
        buffer.writeln(
            '   Tanggal: ${DateFormat('dd MMM yyyy HH:mm').format(t['date'] as DateTime)}');
        buffer.writeln('   Status: ${t['status']}');
        buffer.writeln('   Metode: ${t['payment']}');
        buffer.writeln('   Tipe: ${t['type']}');
        buffer.writeln('   Produk:');
        for (var p in t['products']) {
          buffer.writeln(
              '     - ${p['name']} x${p['qty']} = Rp ${_formatPrice(p['price'] * p['qty'])}');
        }
        buffer.writeln('   Total: Rp ${_formatPrice(t['total'])}');
        buffer.writeln('');
      }
    }

    buffer.writeln('=' * 60);
    buffer.writeln('* Laporan ini dibuat secara otomatis oleh sistem KANZZA');
    buffer.writeln('=' * 60);

    return buffer.toString();
  }

  Future<void> _downloadReport(String format) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request permission
      if (!await _requestPermission()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final reportText = _generateReportText();
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = 'Laporan_Penjualan_$timestamp.$format';
      final file = File('${output.path}/$fileName');

      await file.writeAsString(reportText);

      // Show success message with file path
      _showSnackBar(
        "✅ Laporan $format berhasil disimpan!\n📁 Lokasi: ${file.path}",
        Colors.green,
        isPermission: false,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("❌ Gagal membuat laporan: $e", Colors.red, isPermission: false);
    }
  }

  void _showDownloadDialog() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16162A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.download_outlined,
                  color: const Color(0xFF9B5EFF),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  "Download Laporan",
                  style: GoogleFonts.poppins(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Pilih format laporan yang ingin diunduh:",
              style: GoogleFonts.inter(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D0D12) : const Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    "Transaksi",
                    _totalTransactions.toString(),
                    const Color(0xFF9B5EFF),
                    isDark,
                  ),
                  _buildInfoItem(
                    "Total",
                    "Rp ${_formatPrice(_totalIncome)}",
                    const Color(0xFF4CAF50),
                    isDark,
                  ),
                  _buildInfoItem(
                    "Periode",
                    "${DateFormat('dd/MM').format(_startDate)} - ${DateFormat('dd/MM').format(_endDate)}",
                    const Color(0xFFFF9800),
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _downloadReport('txt');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.description,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "TXT",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _downloadReport('csv');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.table_chart,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "CSV",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Batal",
                    style: GoogleFonts.inter(
                      color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color color, {bool isPermission = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 5),
        action: isPermission
            ? SnackBarAction(
                label: 'Buka Settings',
                textColor: Colors.white,
                onPressed: () {
                  openAppSettings();
                },
              )
            : null,
      ),
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
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.ownerDashboard,
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
                      "Laporan Penjualan",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFFF0EAFF)
                            : const Color(0xFF1F2937),
                        fontSize: isTablet ? 26 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Tombol Download
                  GestureDetector(
                    onTap: _isLoading ? null : _showDownloadDialog,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B5EFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.download_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset Filter
                  GestureDetector(
                    onTap: _resetFilters,
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
                        Icons.refresh,
                        color: isDark
                            ? const Color(0xFF9B97B8)
                            : const Color(0xFF6B7280),
                        size: 22,
                      ),
                    ),
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
                    _buildFilterSection(isDark),
                    const SizedBox(height: 16),
                    _buildSummaryCards(isDark),
                    const SizedBox(height: 16),
                    _buildTransactionList(isDark),
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

  Widget _buildFilterSection(bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Type
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Tipe:",
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildFilterChip("Semua", isDark),
              _buildFilterChip("Online", isDark),
              _buildFilterChip("Offline", isDark),
            ],
          ),
          const SizedBox(height: 10),

          // Date Range dengan label "Dari" dan "Sampai" - FIXED
          Row(
            children: [
              // Label "Dari"
              SizedBox(
                width: 40,
                child: Text(
                  "Dari",
                  style: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Start Date
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectStartDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D0D12) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_startDate),
                            style: GoogleFonts.inter(
                              color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Label "Sampai"
              SizedBox(
                width: 55,
                child: Text(
                  "Sampai",
                  style: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // End Date
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectEndDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D0D12) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E35) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_endDate),
                            style: GoogleFonts.inter(
                              color: isDark ? const Color(0xFFF0EAFF) : const Color(0xFF1F2937),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          label,
          style: GoogleFonts.inter(
            color: isSelected
                ? Colors.white
                : isDark
                    ? const Color(0xFF9B97B8)
                    : const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Transaksi",
                  style: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _totalTransactions.toString(),
                  style: GoogleFonts.poppins(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildSummaryBadge(
                      "Online: $_totalOnline",
                      const Color(0xFF9B5EFF),
                      isDark,
                    ),
                    _buildSummaryBadge(
                      "Offline: $_totalOffline",
                      const Color(0xFFFF9800),
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Pendapatan",
                  style: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${_formatPrice(_totalIncome)}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9B5EFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildSummaryBadge(
                      "Online: Rp ${_formatPrice(_totalOnlineIncome)}",
                      const Color(0xFF9B5EFF),
                      isDark,
                    ),
                    _buildSummaryBadge(
                      "Offline: Rp ${_formatPrice(_totalOfflineIncome)}",
                      const Color(0xFFFF9800),
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTransactionList(bool isDark) {
    final theme = Theme.of(context);
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              "Tidak ada transaksi",
              style: GoogleFonts.inter(
                color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Coba ubah filter atau tanggal",
              style: GoogleFonts.inter(
                color: isDark ? const Color(0xFF5C5878) : const Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final statusColor = transaction['statusColor'] as Color;
        final total = transaction['total'] as int;
        final isOffline = transaction['type'] == 'Offline';
        final date = transaction['date'] as DateTime;
        final id = transaction['id']?.toString() ?? '';
        final status = transaction['status']?.toString() ?? '';
        final customer = transaction['customer']?.toString() ?? '';
        final payment = transaction['payment']?.toString() ?? '';
        final type = transaction['type']?.toString() ?? '';
        final products = transaction['products'] as List<dynamic>? ?? [];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: ID, Status, Type, Total, Date
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            id,
                            style: GoogleFonts.inter(
                              color: theme.textTheme.titleLarge?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: statusColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                            type,
                            style: GoogleFonts.inter(
                              color: isOffline ? const Color(0xFFFF9800) : const Color(0xFF9B5EFF),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp ${_formatPrice(total)}",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9B5EFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM HH:mm').format(date),
                        style: GoogleFonts.inter(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Row 2: Customer & Payment
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: theme.textTheme.bodySmall?.color,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            customer,
                            style: GoogleFonts.inter(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E35)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              payment == 'Cash' || payment == 'COD'
                                  ? Icons.attach_money
                                  : Icons.account_balance_wallet,
                              color: theme.textTheme.bodySmall?.color,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              payment,
                              style: GoogleFonts.inter(
                                color: theme.textTheme.bodySmall?.color,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${products.length} item',
                        style: GoogleFonts.inter(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Row 3: Products
              if (products.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: products.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E35)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${p['name']} (${p['qty']}x)',
                        style: GoogleFonts.inter(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 8,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
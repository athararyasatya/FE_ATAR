// lib/presentation/pages/cashier/transaction_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kanzza_sales_app_fe/core/theme/theme_provider.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = "Semua"; // Semua, Online, Offline
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  final List<Map<String, dynamic>> _allTransactions = [
    // Data Online
    {
      'id': 'TRX-2025-001',
      'customer': 'Ahmad Fauzi',
      'total': 34000,
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'date': DateTime(2025, 6, 15, 14, 30),
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
      'date': DateTime(2025, 6, 15, 13, 15),
      'items': 3,
      'payment': 'Transfer',
      'type': 'Online',
    },
    {
      'id': 'TRX-2025-003',
      'customer': 'Budi Santoso',
      'total': 34000,
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'date': DateTime(2025, 6, 14, 11, 45),
      'items': 2,
      'payment': 'COD',
      'type': 'Online',
    },
    {
      'id': 'TRX-2025-004',
      'customer': 'Dewi Lestari',
      'total': 125000,
      'status': 'Selesai',
      'statusColor': const Color(0xFF4CAF50),
      'date': DateTime(2025, 6, 13, 16, 20),
      'items': 5,
      'payment': 'Transfer',
      'type': 'Online',
    },
    // Data Offline
    {
      'id': 'OFF-2025-001',
      'customer': 'Pelanggan Offline',
      'total': 25000,
      'status': 'Selesai',
      'statusColor': const Color(0xFFFF9800),
      'date': DateTime(2025, 6, 15, 12, 30),
      'items': 2,
      'payment': 'Cash',
      'type': 'Offline',
    },
    {
      'id': 'OFF-2025-002',
      'customer': 'Warung Sembako',
      'total': 15000,
      'status': 'Selesai',
      'statusColor': const Color(0xFFFF9800),
      'date': DateTime(2025, 6, 14, 10, 20),
      'items': 1,
      'payment': 'Cash',
      'type': 'Offline',
    },
    {
      'id': 'OFF-2025-003',
      'customer': 'Toko Makmur',
      'total': 45000,
      'status': 'Selesai',
      'statusColor': const Color(0xFFFF9800),
      'date': DateTime(2025, 6, 12, 09, 15),
      'items': 3,
      'payment': 'Cash',
      'type': 'Offline',
    },
    {
      'id': 'OFF-2025-004',
      'customer': 'Pelanggan Offline',
      'total': 12000,
      'status': 'Selesai',
      'statusColor': const Color(0xFFFF9800),
      'date': DateTime(2025, 6, 11, 14, 00),
      'items': 1,
      'payment': 'Cash',
      'type': 'Offline',
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _allTransactions;
    
    // Filter by type
    if (_selectedFilter != "Semua") {
      filtered = filtered.where((t) => t['type'] == _selectedFilter).toList();
    }
    
    // Filter by date range
    filtered = filtered.where((t) {
      final date = t['date'] as DateTime;
      return date.isAfter(_startDate.subtract(const Duration(days: 1))) && 
             date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
    
    // Sort by date (newest first)
    filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    return filtered;
  }

  int get _totalTransactions => _filteredTransactions.length;
  int get _totalIncome => _filteredTransactions.fold(0, (sum, t) => sum + (t['total'] as int));

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
                      "Riwayat Transaksi",
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? const Color(0xFFF0EAFF)
                            : const Color(0xFF1F2937),
                        fontSize: isTablet ? 26 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Reset Filter Button
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
                    // Summary Cards
                    _buildSummaryCards(isDark),
                    const SizedBox(height: 16),

                    // Filter Section
                    _buildFilterSection(isDark),
                    const SizedBox(height: 16),

                    // Transaction List
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

  Widget _buildSummaryCards(bool isDark) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Container(
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
                Text(
                  "Total Transaksi",
                  style: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _totalTransactions.toString(),
                  style: GoogleFonts.poppins(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
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
                Text(
                  "Total Pendapatan",
                  style: GoogleFonts.inter(
                    color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${_formatPrice(_totalIncome)}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9B5EFF),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
          Row(
            children: [
              Text(
                "Tipe:",
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("Semua", isDark),
                      const SizedBox(width: 6),
                      _buildFilterChip("Online", isDark),
                      const SizedBox(width: 6),
                      _buildFilterChip("Offline", isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Date Range
          Row(
            children: [
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "s/d",
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF9B97B8) : const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
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
              Icons.history,
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
              // Type Icon
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
              
              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          transaction['id'],
                          style: GoogleFonts.inter(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
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
                        const SizedBox(width: 6),
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
                    Row(
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
                        const SizedBox(width: 8),
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
              
              // Right Content
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
                      DateFormat('dd/MM/yyyy HH:mm').format(date),
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
}
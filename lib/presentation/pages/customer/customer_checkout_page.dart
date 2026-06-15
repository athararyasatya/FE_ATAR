import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import '../../../data/models/cart_item.dart';
import '../../../data/models/location_model.dart';

class CustomerCheckoutPage extends StatefulWidget {
  final int totalPrice;
  final List<CartItem> cartItems;

  const CustomerCheckoutPage({
    super.key,
    required this.totalPrice,
    required this.cartItems,
  });

  @override
  State<CustomerCheckoutPage> createState() => _CustomerCheckoutPageState();
}

class _CustomerCheckoutPageState extends State<CustomerCheckoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  
  late final LatLng _storeLocation;
  
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  
  double _distance = 0;
  int _shippingCost = 0;
  bool _isCalculating = false;
  String _statusMessage = "";
  
  String _deliveryMethod = "delivery";
  String _paymentMethod = "cod";

  // Daftar koordinat terkenal untuk testing (fallback)
  final Map<String, LatLng> _knownLocations = {
    "universitas esa unggul": LatLng(-6.3195, 106.6158),
    "alam sutera": LatLng(-6.2336, 106.6545),
    "bsd city": LatLng(-6.3056, 106.6530),
    "gading serpong": LatLng(-6.2387, 106.6177),
    "panongan": LatLng(-6.2511, 106.5158),
    "tangerang": LatLng(-6.1783, 106.6319),
    "citra raya": LatLng(-6.3195, 106.6158),
  };

  @override
  void initState() {
    super.initState();
    _storeLocation = LatLng(StoreLocation.latitude, StoreLocation.longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // Konversi alamat ke koordinat menggunakan Nominatim API
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    try {
      String encodedAddress = Uri.encodeComponent("$address, Indonesia");
      
      final url = "https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1";
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'KanzzaSalesApp/1.0'},
      );
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          print("📍 Alamat ditemukan: $address -> lat: $lat, lon: $lon");
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      print("Error geocoding: $e");
    }
    return null;
  }

  LatLng? _checkKnownLocation(String address) {
    String lowerAddress = address.toLowerCase();
    for (var entry in _knownLocations.entries) {
      if (lowerAddress.contains(entry.key)) {
        print("📍 Menggunakan koordinat preset untuk: ${entry.key}");
        return entry.value;
      }
    }
    return null;
  }

  Future<List<LatLng>> _getRouteFromOSRM(LatLng start, LatLng end) async {
    try {
      final url = "https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson";
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          
          List<LatLng> routePoints = [];
          for (var coord in coordinates) {
            routePoints.add(LatLng(coord[1], coord[0]));
          }
          
          final distanceInMeters = (data['routes'][0]['distance'] as num).toDouble();
          final distanceInKm = distanceInMeters / 1000;
          
          setState(() {
            _distance = double.parse(distanceInKm.toStringAsFixed(2));
            _shippingCost = (distanceInKm * 5000).round();
          });
          
          return routePoints;
        }
      }
    } catch (e) {
      print("OSRM error: $e");
    }
    return [];
  }

  double _calculateStraightDistance(LatLng start, LatLng end) {
    const double R = 6371;
    double dLat = _toRadians(end.latitude - start.latitude);
    double dLon = _toRadians(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(start.latitude)) * cos(_toRadians(end.latitude)) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c;
    return double.parse(distance.toStringAsFixed(2));
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> _checkLocationAndRoute() async {
    if (_addressController.text.isEmpty) {
      _showErrorSnackBar("Masukkan alamat lengkap terlebih dahulu");
      return;
    }
    
    setState(() {
      _isCalculating = true;
      _statusMessage = "🔍 Mencari lokasi dari alamat...";
      _routePoints = [];
    });
    
    try {
      String fullAddress = _addressController.text.trim();
      if (_detailAddressController.text.trim().isNotEmpty) {
        fullAddress = "${_addressController.text.trim()}, ${_detailAddressController.text.trim()}";
      }
      
      LatLng? userLocation;
      
      userLocation = _checkKnownLocation(fullAddress.toLowerCase());
      
      if (userLocation == null) {
        setState(() {
          _statusMessage = "🌐 Mencari koordinat alamat...";
        });
        userLocation = await _getCoordinatesFromAddress(fullAddress);
      }
      
      if (userLocation == null) {
        setState(() {
          _isCalculating = false;
          _statusMessage = "";
        });
        _showErrorSnackBar("Alamat tidak ditemukan.\nCoba: Nama Jalan, Kecamatan, Kota");
        return;
      }
      
      setState(() {
        _userLocation = userLocation;
        _statusMessage = "🗺️ Mendapatkan rute perjalanan...";
      });
      
      List<LatLng> routePoints = await _getRouteFromOSRM(_storeLocation, userLocation);
      
      if (routePoints.isNotEmpty) {
        setState(() {
          _routePoints = routePoints;
          _statusMessage = "";
          _isCalculating = false;
        });
        _showSuccessSnackBar("✅ Rute ditemukan! Jarak: ${_distance.toStringAsFixed(2)} km | Ongkir: Rp ${_formatPrice(_shippingCost)}");
      } else {
        double distance = _calculateStraightDistance(_storeLocation, userLocation);
        setState(() {
          _distance = distance;
          _shippingCost = (distance * 5000).round();
          // Fix: Gunakan userLocation yang sudah dipastikan tidak null
          if (userLocation != null) {
            _routePoints = [_storeLocation, userLocation];
          }
          _statusMessage = "";
          _isCalculating = false;
        });
        _showSuccessSnackBar("⚠️ Jarak perkiraan: ${distance.toStringAsFixed(2)} km | Ongkir: Rp ${_formatPrice(_shippingCost)}");
      }
      
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isCalculating = false;
        _statusMessage = "";
      });
      _showErrorSnackBar("Terjadi kesalahan. Periksa koneksi internet Anda.");
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  int get _totalWithShipping {
    if (_deliveryMethod == "pickup") return widget.totalPrice;
    return widget.totalPrice + _shippingCost;
  }

  void _proceedToPayment() {
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar("Nama lengkap harus diisi");
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar("Nomor telepon harus diisi");
      return;
    }
    if (_deliveryMethod == "delivery" && _addressController.text.isEmpty) {
      _showErrorSnackBar("Alamat harus diisi");
      return;
    }
    if (_deliveryMethod == "delivery" && _userLocation == null) {
      _showErrorSnackBar("Klik 'Cek Ongkir & Rute' terlebih dahulu");
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Konfirmasi Pesanan",
          style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${_nameController.text}", style: GoogleFonts.inter(color: const Color(0xFFF0EAFF))),
            const SizedBox(height: 4),
            Text("Alamat: ${_addressController.text}", style: GoogleFonts.inter(color: const Color(0xFFF0EAFF))),
            if (_detailAddressController.text.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text("Detail: ${_detailAddressController.text}", style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Text("Metode Pengiriman: ${_deliveryMethod == "delivery" ? "Di Antar" : "Ambil di Toko"}",
                style: GoogleFonts.inter(color: const Color(0xFFF0EAFF))),
            const SizedBox(height: 8),
            Text("Metode Pembayaran: ${_paymentMethod == "cod" ? "Bayar di Tempat" : "Transfer Bank"}",
                style: GoogleFonts.inter(color: const Color(0xFFF0EAFF))),
            const SizedBox(height: 8),
            Text("Jarak: ${_distance.toStringAsFixed(2)} km", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
            Text("Ongkir: Rp ${_formatPrice(_shippingCost)}", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
            const SizedBox(height: 8),
            Text("Total: Rp ${_formatPrice(_totalWithShipping)}",
                style: GoogleFonts.poppins(color: const Color(0xFF9B5EFF), fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Pesanan berhasil dibuat!",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Konfirmasi", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
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
                        "Checkout",
                        style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Method Section
                      _buildSectionTitle("Metode Pengiriman"),
                      const SizedBox(height: 12),
                      _buildDeliveryMethodCard(),
                      const SizedBox(height: 24),

                      // Delivery Address Section
                      if (_deliveryMethod == "delivery") ...[
                        _buildSectionTitle("Informasi Penerima"),
                        const SizedBox(height: 12),
                        _buildAddressForm(),
                        const SizedBox(height: 16),
                        
                        _buildSectionTitle("Alamat Pengiriman"),
                        const SizedBox(height: 12),
                        _buildAlamatForm(),
                        const SizedBox(height: 16),
                        
                        _buildCheckButton(),
                        const SizedBox(height: 16),
                        
                        if (_statusMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B5EFF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9B5EFF)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (_userLocation != null && _routePoints.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSectionTitle("Visualisasi Rute"),
                          const SizedBox(height: 8),
                          Text(
                            "📍 Toko (Orange) | 📍 Alamat Tujuan (Merah) | 🟣 Rute Perjalanan",
                            style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 11),
                          ),
                          const SizedBox(height: 12),
                          _buildMapCard(),
                          const SizedBox(height: 16),
                          
                          _buildSectionTitle("Informasi Pengiriman"),
                          const SizedBox(height: 12),
                          _buildShippingInfoCard(),
                          const SizedBox(height: 24),
                        ],
                      ],

                      if (_deliveryMethod == "pickup") ...[
                        _buildSectionTitle("Informasi Pengambilan"),
                        const SizedBox(height: 12),
                        _buildPickupInfoCard(),
                        const SizedBox(height: 24),
                      ],

                      _buildSectionTitle("Metode Pembayaran"),
                      const SizedBox(height: 12),
                      _buildPaymentMethodCard(),
                      const SizedBox(height: 24),

                      _buildSectionTitle("Ringkasan Pesanan"),
                      const SizedBox(height: 12),
                      _buildOrderSummaryCard(),
                      const SizedBox(height: 30),

                      _buildCheckoutButton(),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildCheckButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCalculating ? null : _checkLocationAndRoute,
        icon: _isCalculating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.route, size: 18),
        label: Text(
          _isCalculating ? "Memproses..." : "Cek Ongkir & Tampilkan Rute",
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9B5EFF),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          _buildRadioOption(
            title: "Di Antar ke Alamat",
            subtitle: "Pesanan akan diantar ke alamat Anda",
            value: "delivery",
            groupValue: _deliveryMethod,
            icon: Icons.delivery_dining,
          ),
          const Divider(color: Color(0xFF1E1E35), height: 16),
          _buildRadioOption(
            title: "Ambil di Toko",
            subtitle: "Ambil pesanan langsung di toko kami",
            value: "pickup",
            groupValue: _deliveryMethod,
            icon: Icons.storefront,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: (val) => setState(() => _deliveryMethod = val!),
            activeColor: const Color(0xFF9B5EFF),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF9B5EFF), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
            decoration: InputDecoration(
              labelText: "Nama Lengkap",
              labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
              hintText: "Masukkan nama lengkap Anda",
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
          TextField(
            controller: _phoneController,
            style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Nomor Telepon",
              labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
              hintText: "Contoh: 081234567890",
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
        ],
      ),
    );
  }

  Widget _buildAlamatForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          TextField(
            controller: _addressController,
            style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Alamat Lengkap",
              labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
              hintText: "Contoh: Universitas Esa Unggul, Jalan Citra Raya, Panongan, Tangerang",
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
          TextField(
            controller: _detailAddressController,
            style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
            decoration: InputDecoration(
              labelText: "Detail Alamat (Opsional)",
              labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
              hintText: "Nama gedung, nomor rumah, RT/RW, dll",
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
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    if (_userLocation == null) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF16162A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E35), width: 1),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: Color(0xFF5C5878), size: 48),
              SizedBox(height: 12),
              Text("Masukkan alamat dan klik 'Cek Ongkir & Rute'", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9B97B8), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    double centerLat = (_storeLocation.latitude + _userLocation!.latitude) / 2;
    double centerLng = (_storeLocation.longitude + _userLocation!.longitude) / 2;
    
    double zoomLevel = 12.0;
    if (_distance < 5) zoomLevel = 13.0;
    if (_distance < 2) zoomLevel = 14.0;
    if (_distance < 1) zoomLevel = 15.0;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(centerLat, centerLng),
            initialZoom: zoomLevel,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.kanzza.sales.app",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 45,
                  height: 45,
                  point: _storeLocation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 24),
                  ),
                ),
                Marker(
                  width: 45,
                  height: 45,
                  point: _userLocation!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
            if (_routePoints.isNotEmpty && _routePoints.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: const Color(0xFF9B5EFF),
                    strokeWidth: 4,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.route, color: Color(0xFF9B5EFF), size: 16),
                const SizedBox(width: 4),
                Text("Jarak Tempuh", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
              ]),
              Text("${_distance.toStringAsFixed(2)} km", 
                  style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.motorcycle, color: Color(0xFF9B5EFF), size: 16),
                const SizedBox(width: 4),
                Text("Ongkos Kirim (Rp5.000/km)", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
              ]),
              Text("Rp ${_formatPrice(_shippingCost)}", 
                  style: GoogleFonts.poppins(color: const Color(0xFF9B5EFF), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF9B5EFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF9B5EFF).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF9B5EFF), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Rute mengikuti jalur jalan raya. Ongkir dihitung berdasarkan jarak tempuh sebenarnya.",
                    style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront, color: Color(0xFF9B5EFF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(StoreLocation.storeName, style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(StoreLocation.address, style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12)),
                const SizedBox(height: 4),
                Text("Telp: ${StoreLocation.phone}", style: GoogleFonts.inter(color: const Color(0xFF5C5878), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          _buildPaymentRadioOption(
            title: "Bayar di Tempat (COD)",
            subtitle: "Bayar saat pesanan sampai",
            value: "cod",
            groupValue: _paymentMethod,
            icon: Icons.money,
          ),
          const Divider(color: Color(0xFF1E1E35), height: 16),
          _buildPaymentRadioOption(
            title: "Transfer Bank",
            subtitle: "Bayar via transfer bank",
            value: "transfer",
            groupValue: _paymentMethod,
            icon: Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRadioOption({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: (val) => setState(() => _paymentMethod = val!),
            activeColor: const Color(0xFF9B5EFF),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF9B5EFF), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Belanja", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
              Text("Rp ${_formatPrice(widget.totalPrice)}", style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600)),
            ],
          ),
          if (_deliveryMethod == "delivery" && _shippingCost > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ongkos Kirim", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
                Text("Rp ${_formatPrice(_shippingCost)}", style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          const Divider(color: Color(0xFF1E1E35), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pembayaran", style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600)),
              Text("Rp ${_formatPrice(_totalWithShipping)}", 
                  style: GoogleFonts.poppins(color: const Color(0xFF9B5EFF), fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9B5EFF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          "Lanjutkan ke Pembayaran",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
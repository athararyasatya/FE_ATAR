// lib/presentation/pages/customer/customer_checkout_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/location_model.dart';

class CustomerCheckoutPage extends StatefulWidget {
  final int totalPrice;
  final List<CartItem> cartItems;

  const CustomerCheckoutPage({
    super.key,
    this.totalPrice = 0,
    this.cartItems = const [],
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
  bool _isGettingLocation = false;
  String _statusMessage = "";
  String _errorMessage = "";
  String _currentAddress = "";
  
  String _deliveryMethod = "delivery";
  String _paymentMethod = "cod";
  
  final MapController _mapController = MapController();
  
  // FLAG: Untuk menandai apakah map sudah siap
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _storeLocation = LatLng(StoreLocation.latitude, StoreLocation.longitude);
    print("📍 Store Location: ${_storeLocation.latitude}, ${_storeLocation.longitude}");
    
    // Cek dan minta izin lokasi saat halaman dibuka
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // ⬇️ CEK IZIN LOKASI ⬇️
  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.location.request();
      if (result.isGranted) {
        print("✅ Izin lokasi diberikan");
        await _getCurrentLocation();
      } else {
        setState(() {
          _errorMessage = "Izin lokasi diperlukan untuk menampilkan rute pengiriman.\n\nSilakan aktifkan izin lokasi di pengaturan perangkat Anda.";
        });
      }
    } else if (status.isGranted) {
      print("✅ Izin lokasi sudah ada");
      await _getCurrentLocation();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = "Izin lokasi ditolak permanen.\n\nSilakan aktifkan izin lokasi di pengaturan perangkat Anda.";
      });
      await openAppSettings();
    }
  }

  // ⬇️ GET CURRENT LOCATION USING GPS ⬇️
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _statusMessage = "📍 Mendapatkan lokasi Anda...";
      _errorMessage = "";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
          _statusMessage = "";
          _errorMessage = "GPS tidak aktif.\n\nSilakan aktifkan GPS di pengaturan perangkat Anda.";
        });
        _showRetryLocationDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print("📍 Lokasi GPS didapatkan:");
      print("   Latitude: ${position.latitude}");
      print("   Longitude: ${position.longitude}");

      LatLng userLocation = LatLng(position.latitude, position.longitude);
      
      String address = await _getAddressFromCoordinates(userLocation);
      
      setState(() {
        _userLocation = userLocation;
        _currentAddress = address;
        _addressController.text = address;
        _isGettingLocation = false;
        _statusMessage = "✅ Lokasi ditemukan!";
        _errorMessage = "";
      });

      _showSuccessSnackBar("✅ Lokasi berhasil didapatkan!\nAlamat: $address");

      // PERBAIKAN: Pindahkan peta hanya jika map sudah siap
      if (_isMapReady) {
        _mapController.move(userLocation, 16.0);
      } else {
        print("⏳ Map belum siap, akan dipindahkan nanti");
        // Tunggu sejenak lalu coba lagi
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isMapReady && mounted) {
            _mapController.move(userLocation, 16.0);
          }
        });
      }

      await _checkRoute();

    } catch (e) {
      print("❌ Error getting location: $e");
      setState(() {
        _isGettingLocation = false;
        _statusMessage = "";
        _errorMessage = "Gagal mendapatkan lokasi.\n\nPastikan GPS aktif dan coba lagi.\n\nError: $e";
      });
      
      if (_userLocation == null) {
        _showRetryLocationDialog();
      }
    }
  }

  // ⬇️ REVERSE GEOCODING ⬇️
  Future<String> _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final url = "https://nominatim.openstreetmap.org/reverse?"
          "lat=${coordinates.latitude}"
          "&lon=${coordinates.longitude}"
          "&format=json"
          "&addressdetails=1"
          "&accept-language=id";
      
      print("🔍 Reverse Geocoding URL: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'KanzzaSalesApp/1.0',
          'Accept-Language': 'id,en',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        String address = "Lokasi saat ini";
        
        if (data['display_name'] != null && data['display_name'].toString().isNotEmpty) {
          address = data['display_name'];
        } else if (data['address'] != null) {
          final addr = data['address'];
          List<String> parts = [];
          if (addr['road'] != null && addr['road'].toString().isNotEmpty) parts.add(addr['road']);
          if (addr['village'] != null && addr['village'].toString().isNotEmpty) parts.add(addr['village']);
          if (addr['town'] != null && addr['town'].toString().isNotEmpty) parts.add(addr['town']);
          if (addr['city'] != null && addr['city'].toString().isNotEmpty) parts.add(addr['city']);
          if (parts.isNotEmpty) address = parts.join(', ');
        }
        
        print("✅ Reverse geocoding success: $address");
        return address;
      } else {
        print("⚠️ Reverse geocoding status: ${response.statusCode}");
        return "Lokasi saat ini (${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)})";
      }
    } catch (e) {
      print("❌ Reverse geocoding error: $e");
      return "Lokasi saat ini (${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)})";
    }
  }

  // ⬇️ TAMPILKAN DIALOG RETRY LOKASI ⬇️
  void _showRetryLocationDialog() {
    if (_userLocation != null) {
      print("✅ Lokasi sudah ada, tidak perlu menampilkan dialog error");
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Gagal Mendapatkan Lokasi",
          style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tidak dapat mendapatkan lokasi Anda. Pastikan:",
              style: GoogleFonts.inter(color: const Color(0xFF9B97B8)),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF9B5EFF), size: 16),
                SizedBox(width: 8),
                Text("GPS aktif", style: TextStyle(color: Color(0xFFF0EAFF), fontSize: 13)),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF9B5EFF), size: 16),
                SizedBox(width: 8),
                Text("Izin lokasi diberikan", style: TextStyle(color: Color(0xFFF0EAFF), fontSize: 13)),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF9B5EFF), size: 16),
                SizedBox(width: 8),
                Text("Berada di luar ruangan", style: TextStyle(color: Color(0xFFF0EAFF), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Anda juga bisa memasukkan alamat secara manual jika tetap gagal.",
              style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _errorMessage = "Silakan masukkan alamat secara manual";
              });
            },
            child: Text("Masukkan Manual", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Coba Lagi", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ⬇️ ROUTING - DAPATKAN RUTE DARI OSRM ⬇️
  Future<List<LatLng>> _getRouteFromOSRM(LatLng start, LatLng end) async {
    try {
      final url = "https://router.project-osrm.org/route/v1/driving/"
          "${start.longitude},${start.latitude};${end.longitude},${end.latitude}"
          "?overview=full&geometries=geojson&steps=false&alternatives=false";
      
      print("🗺️ OSRM URL: $url");
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 20),
      );
      
      print("📡 OSRM Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          print("📍 Route points: ${coordinates.length}");
          
          List<LatLng> routePoints = [];
          for (var coord in coordinates) {
            routePoints.add(LatLng(coord[1], coord[0]));
          }
          
          final distanceInMeters = (route['distance'] as num).toDouble();
          final distanceInKm = distanceInMeters / 1000;
          
          print("📏 Distance: ${distanceInKm.toStringAsFixed(2)} km");
          
          setState(() {
            _distance = double.parse(distanceInKm.toStringAsFixed(2));
            _shippingCost = (distanceInKm * 5000).round();
          });
          
          return routePoints;
        }
      }
    } catch (e) {
      print("❌ OSRM error: $e");
    }
    return [];
  }

  // ⬇️ CALCULATE STRAIGHT DISTANCE ⬇️
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

  // ⬇️ MAIN FUNCTION - CEK RUTE ⬇️
  Future<void> _checkRoute() async {
    if (_userLocation == null) {
      _showErrorSnackBar("Lokasi tidak ditemukan. Klik 'Cek Lokasi' terlebih dahulu.");
      return;
    }
    
    setState(() {
      _isCalculating = true;
      _statusMessage = "🗺️ Mendapatkan rute perjalanan...";
      _errorMessage = "";
      _routePoints = [];
    });
    
    try {
      print("📍 Store: ${_storeLocation.latitude}, ${_storeLocation.longitude}");
      print("📍 User: ${_userLocation!.latitude}, ${_userLocation!.longitude}");
      
      double distanceCheck = _calculateStraightDistance(_storeLocation, _userLocation!);
      print("📏 Distance check: ${distanceCheck.toStringAsFixed(3)} km");
      
      if (distanceCheck < 0.01) {
        setState(() {
          _errorMessage = "Lokasi terlalu dekat dengan toko.";
          _isCalculating = false;
          _statusMessage = "";
        });
        _showErrorSnackBar("Lokasi terlalu dekat dengan toko.");
        return;
      }
      
      List<LatLng> routePoints = await _getRouteFromOSRM(_storeLocation, _userLocation!);
      
      if (routePoints.isNotEmpty && routePoints.length > 1) {
        setState(() {
          _routePoints = routePoints;
          _statusMessage = "✅ Rute ditemukan!";
          _isCalculating = false;
        });
        
        _zoomToRoute();
        
        _showSuccessSnackBar(
          "✅ Rute ditemukan!\n"
          "Jarak: ${_distance.toStringAsFixed(2)} km | "
          "Ongkir: Rp ${_formatPrice(_shippingCost)}"
        );
      } else {
        double distance = _calculateStraightDistance(_storeLocation, _userLocation!);
        setState(() {
          _distance = distance;
          _shippingCost = (distance * 5000).round();
          _routePoints = [_storeLocation, _userLocation!];
          _statusMessage = "⚠️ Menggunakan estimasi garis lurus";
          _isCalculating = false;
        });
        
        _zoomToRoute();
        
        _showSuccessSnackBar(
          "⚠️ Rute tidak tersedia (estimasi garis lurus)\n"
          "Jarak: ${distance.toStringAsFixed(2)} km | "
          "Ongkir: Rp ${_formatPrice(_shippingCost)}"
        );
      }
      
    } catch (e) {
      print("❌ Error checking route: $e");
      setState(() {
        _isCalculating = false;
        _statusMessage = "";
        _errorMessage = "Gagal mendapatkan rute.\n\nPeriksa koneksi internet Anda.";
      });
      _showErrorSnackBar("Gagal mendapatkan rute. Periksa koneksi internet.");
      
      if (_userLocation != null) {
        setState(() {
          _routePoints = [_storeLocation, _userLocation!];
          double distance = _calculateStraightDistance(_storeLocation, _userLocation!);
          _distance = distance;
          _shippingCost = (distance * 5000).round();
        });
        _zoomToRoute();
      }
    }
  }

  // ⬇️ ZOOM TO RUTE ⬇️
  void _zoomToRoute() {
    if (_routePoints.isEmpty || _userLocation == null) {
      print("⚠️ Tidak ada route points untuk di-zoom");
      return;
    }
    
    // PERBAIKAN: Cek apakah map sudah siap
    if (!_isMapReady) {
      print("⏳ Map belum siap, akan di-zoom nanti");
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isMapReady && mounted) {
          _zoomToRoute();
        }
      });
      return;
    }
    
    try {
      double minLat = _storeLocation.latitude;
      double maxLat = _storeLocation.latitude;
      double minLng = _storeLocation.longitude;
      double maxLng = _storeLocation.longitude;
      
      for (var point in _routePoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
      
      if (minLat == maxLat && minLng == maxLng) {
        _mapController.move(_userLocation!, 15.0);
        return;
      }
      
      final latPadding = (maxLat - minLat) * 0.3;
      final lngPadding = (maxLng - minLng) * 0.3;
      
      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;
      
      final latDiff = maxLat - minLat + latPadding * 2;
      final lngDiff = maxLng - minLng + lngPadding * 2;
      final maxDiff = max(latDiff, lngDiff);
      
      double zoom = 12.0;
      if (maxDiff > 0.5) zoom = 10.0;
      else if (maxDiff > 0.2) zoom = 12.0;
      else if (maxDiff > 0.05) zoom = 14.0;
      else zoom = 15.0;
      
      print("📍 Zooming to: center=($centerLat, $centerLng), zoom=$zoom");
      _mapController.move(LatLng(centerLat, centerLng), zoom);
    } catch (e) {
      print("❌ Error zooming: $e");
      try {
        _mapController.move(_userLocation!, 14.0);
      } catch (e2) {
        print("❌ Error fallback zoom: $e2");
      }
    }
  }

  // ⬇️ GET LOCATION BUTTON HANDLER ⬇️
  Future<void> _handleGetLocation() async {
    await _getCurrentLocation();
  }

  // ⬇️ SNACKBARS ⬇️
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
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
    if (_deliveryMethod == "delivery" && _userLocation == null) {
      _showErrorSnackBar("Klik 'Cek Lokasi' terlebih dahulu");
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
                      _buildDeliveryMethodCard(),
                      const SizedBox(height: 24),

                      if (_deliveryMethod == "delivery") ...[
                        _buildAddressForm(),
                        const SizedBox(height: 16),
                        _buildLocationButton(),
                        const SizedBox(height: 16),
                        
                        if (_statusMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _statusMessage.contains("✅") 
                                  ? Colors.green.withOpacity(0.1)
                                  : _statusMessage.contains("⚠️")
                                      ? Colors.orange.withOpacity(0.1)
                                      : const Color(0xFF9B5EFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _statusMessage.contains("✅")
                                    ? Colors.green.withOpacity(0.3)
                                    : _statusMessage.contains("⚠️")
                                        ? Colors.orange.withOpacity(0.3)
                                        : const Color(0xFF9B5EFF).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _statusMessage.contains("✅") 
                                      ? Icons.check_circle
                                      : _statusMessage.contains("⚠️")
                                          ? Icons.warning_amber_rounded
                                          : Icons.location_searching,
                                  color: _statusMessage.contains("✅")
                                      ? Colors.green
                                      : _statusMessage.contains("⚠️")
                                          ? Colors.orange
                                          : const Color(0xFF9B5EFF),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: GoogleFonts.inter(
                                      color: _statusMessage.contains("✅")
                                          ? Colors.green.shade300
                                          : _statusMessage.contains("⚠️")
                                              ? Colors.orange.shade300
                                              : const Color(0xFF9B97B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.inter(
                                      color: Colors.red.shade300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (_userLocation != null && _routePoints.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildMapCard(),
                          const SizedBox(height: 16),
                          _buildShippingInfoCard(),
                          const SizedBox(height: 24),
                        ],
                      ],

                      if (_deliveryMethod == "pickup") ...[
                        _buildPickupInfoCard(),
                        const SizedBox(height: 24),
                      ],

                      _buildPaymentMethodCard(),
                      const SizedBox(height: 24),
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

  // ⬇️ BUILD WIDGETS ⬇️
  
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
            subtitle: "Pesanan akan diantar ke lokasi Anda",
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
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
            maxLines: 2,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Alamat (Otomatis dari GPS)",
              labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
              hintText: "Klik 'Cek Lokasi' untuk mendapatkan alamat",
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

  Widget _buildLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGettingLocation ? null : _handleGetLocation,
        icon: _isGettingLocation
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.my_location, size: 18),
        label: Text(
          _isGettingLocation ? "Mendapatkan lokasi..." : "📍 Cek Lokasi & Tampilkan Rute",
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

  Widget _buildMapCard() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _userLocation ?? _storeLocation,
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.kanzza.sales.app",
              tileProvider: NetworkTileProvider(),
            ),
            // Store Marker
            MarkerLayer(
              markers: [
                Marker(
                  width: 45,
                  height: 45,
                  point: _storeLocation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade500,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 24),
                  ),
                ),
                // User Marker
                if (_userLocation != null)
                  Marker(
                    width: 45,
                    height: 45,
                    point: _userLocation!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                    ),
                  ),
              ],
            ),
            // Route Polyline
            if (_routePoints.isNotEmpty && _routePoints.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: const Color(0xFF9B5EFF),
                    strokeWidth: 5,
                    borderColor: Colors.white.withOpacity(0.2),
                    borderStrokeWidth: 1,
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
              color: const Color(0xFF9B5EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF9B5EFF).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF9B5EFF), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lokasi diambil dari GPS perangkat Anda. Rute mengikuti jalur jalan raya.",
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
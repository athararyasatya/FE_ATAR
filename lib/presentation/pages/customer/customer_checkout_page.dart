// lib/presentation/pages/customer/customer_checkout_page.dart

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
    this.totalPrice = 0,        // ⬅️ BERI DEFAULT VALUE
    this.cartItems = const [], // ⬅️ BERI DEFAULT VALUE
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
  String _errorMessage = "";
  
  String _deliveryMethod = "delivery";
  String _paymentMethod = "cod";
  
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _storeLocation = LatLng(StoreLocation.latitude, StoreLocation.longitude);
    print("📍 Store Location: ${_storeLocation.latitude}, ${_storeLocation.longitude}");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  // ⬇️ CLEAN ADDRESS - HAPUS RT/RW ⬇️
  String _cleanAddressForGeocoding(String address) {
    String cleaned = address;
    
    // Hapus RT/RW
    cleaned = cleaned.replaceAll(RegExp(r'RT\s*\d+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'RW\s*\d+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'RT\.\s*\d+', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'RW\.\s*\d+', caseSensitive: false), '');
    
    // Hapus "KP." (kampung)
    cleaned = cleaned.replaceAll(RegExp(r'KP\.?\s*', caseSensitive: false), '');
    
    // Hapus "BLOK"
    cleaned = cleaned.replaceAll(RegExp(r'BLOK\s*', caseSensitive: false), '');
    
    // Ganti "/" dengan ", "
    cleaned = cleaned.replaceAll('/', ', ');
    
    // Bersihkan extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();
    
    print("🧹 Original: $address");
    print("🧹 Cleaned: $cleaned");
    
    return cleaned;
  }

  // ⬇️ GEOCODING - NOMINATIM ⬇️
  Future<LatLng?> _geocodeWithNominatim(String address) async {
    try {
      String cleanAddress = _cleanAddressForGeocoding(address);
      
      // Format alamat yang lebih lengkap
      final List<String> addressFormats = [
        "$cleanAddress, Legok, Tangerang, Banten, Indonesia",
        "$cleanAddress, Kecamatan Legok, Kabupaten Tangerang, Banten, Indonesia",
        "$cleanAddress, Tangerang, Indonesia",
        "PLP Curug, Legok, Tangerang, Indonesia",
      ];
      
      for (String format in addressFormats) {
        String encodedAddress = Uri.encodeComponent(format);
        
        final url = "https://nominatim.openstreetmap.org/search?"
            "q=$encodedAddress"
            "&format=json"
            "&limit=5"
            "&countrycodes=id"
            "&addressdetails=1"
            "&namedetails=1"
            "&viewbox=106.4500,-6.1500,106.7000,-6.4000"
            "&bounded=1"
            "&accept-language=id";
        
        print("🔍 Nominatim URL: $url");
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'KanzzaSalesApp/1.0',
            'Accept-Language': 'id,en',
          },
        ).timeout(const Duration(seconds: 15));
        
        print("📡 Nominatim Status: ${response.statusCode}");
        
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          print("📊 Nominatim Results: ${data.length}");
          
          if (data.isNotEmpty) {
            // Cetak semua hasil untuk debugging
            for (int i = 0; i < data.length; i++) {
              final item = data[i];
              print("   Result $i: ${item['display_name']} -> lat=${item['lat']}, lon=${item['lon']}");
            }
            
            // Prioritaskan hasil yang mengandung "Legok" atau "Curug" atau "PLP"
            LatLng? bestResult;
            for (var item in data) {
              final displayName = item['display_name'] ?? '';
              final lat = double.parse(item['lat']);
              final lon = double.parse(item['lon']);
              
              // Cek apakah hasil berada di area Legok/Curug
              if (displayName.contains('Legok') || 
                  displayName.contains('Curug') || 
                  displayName.contains('PLP') ||
                  displayName.contains('Bambu')) {
                bestResult = LatLng(lat, lon);
                print("✅ Nominatim found (prioritized): $displayName");
                print("📍 Coordinates: lat=$lat, lon=$lon");
                break;
              }
            }
            
            if (bestResult != null) return bestResult;
            
            // Jika tidak ada yang diprioritaskan, ambil yang pertama
            final lat = double.parse(data[0]['lat']);
            final lon = double.parse(data[0]['lon']);
            print("✅ Nominatim found (first): ${data[0]['display_name']}");
            print("📍 Coordinates: lat=$lat, lon=$lon");
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      print("❌ Nominatim error: $e");
    }
    return null;
  }

  // ⬇️ GEOCODING - PHOTON (ALTERNATIF) ⬇️
  Future<LatLng?> _geocodeWithPhoton(String address) async {
    try {
      String cleanAddress = _cleanAddressForGeocoding(address);
      String encodedAddress = Uri.encodeComponent("$cleanAddress, Legok, Tangerang");
      
      final url = "https://photon.komoot.io/api/"
          "?q=$encodedAddress"
          "&limit=5"
          "&lang=id"
          "&lon=${_storeLocation.longitude}"
          "&lat=${_storeLocation.latitude}";
      
      print("🔍 Photon URL: $url");
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 15));
      
      print("📡 Photon Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List?;
        
        if (features != null && features.isNotEmpty) {
          // Cetak semua hasil
          for (int i = 0; i < features.length; i++) {
            final feature = features[i];
            final props = feature['properties'] ?? {};
            final coords = feature['geometry']['coordinates'] as List;
            print("   Photon $i: ${props['name'] ?? 'unknown'} -> lat=${coords[1]}, lon=${coords[0]}");
          }
          
          // Prioritaskan hasil yang mengandung "Legok" atau "Curug"
          LatLng? bestResult;
          for (var feature in features) {
            final props = feature['properties'] ?? {};
            final coords = feature['geometry']['coordinates'] as List;
            final name = props['name'] ?? '';
            final city = props['city'] ?? '';
            final state = props['state'] ?? '';
            
            final fullName = "$name $city $state".toLowerCase();
            
            if (fullName.contains('legok') || 
                fullName.contains('curug') || 
                fullName.contains('plp')) {
              bestResult = LatLng(coords[1], coords[0]);
              print("✅ Photon found (prioritized): $name, $city");
              break;
            }
          }
          
          if (bestResult != null) return bestResult;
          
          // Ambil yang pertama
          final coords = features[0]['geometry']['coordinates'] as List;
          print("✅ Photon found (first): ${coords[1]}, ${coords[0]}");
          return LatLng(coords[1], coords[0]);
        }
      }
    } catch (e) {
      print("❌ Photon error: $e");
    }
    return null;
  }

  // ⬇️ MAIN GEOCODING FUNCTION ⬇️
  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    print("📍 ===== SEARCHING FOR ADDRESS =====");
    print("📍 Address: $address");
    
    // 1. Coba Nominatim
    LatLng? result = await _geocodeWithNominatim(address);
    if (result != null) {
      print("✅ FINAL: Using Nominatim result");
      return result;
    }
    
    // 2. Coba Photon (fallback)
    result = await _geocodeWithPhoton(address);
    if (result != null) {
      print("✅ FINAL: Using Photon result");
      return result;
    }
    
    // 3. Jika semua gagal, coba dengan alamat yang lebih sederhana
    try {
      String cleanAddress = _cleanAddressForGeocoding(address);
      final words = cleanAddress.split(RegExp(r'[\s,]+'));
      // Ambil kata-kata penting (jalan + kelurahan)
      String simpleAddress = "";
      for (var word in words) {
        if (word.length > 3 && 
            !word.contains('RT') && 
            !word.contains('RW') && 
            !word.contains('KP') &&
            !word.contains('BLOK')) {
          simpleAddress += word + " ";
        }
      }
      simpleAddress = "$simpleAddress, Legok, Tangerang";
      print("🔄 Trying simple address: $simpleAddress");
      
      result = await _geocodeWithNominatim(simpleAddress);
      if (result != null) {
        print("✅ FINAL: Using simple address result");
        return result;
      }
    } catch (e) {
      print("❌ Simple address error: $e");
    }
    
    print("❌ All geocoding methods failed");
    return null;
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

  // ⬇️ CALCULATE STRAIGHT DISTANCE (FALLBACK) ⬇️
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

  // ⬇️ MAIN FUNCTION - CEK LOKASI DAN RUTE ⬇️
  Future<void> _checkLocationAndRoute() async {
    if (_addressController.text.isEmpty) {
      _showErrorSnackBar("Masukkan alamat lengkap terlebih dahulu");
      return;
    }
    
    setState(() {
      _isCalculating = true;
      _statusMessage = "🔍 Mencari lokasi dari alamat...";
      _errorMessage = "";
      _routePoints = [];
      _userLocation = null;
    });
    
    try {
      String fullAddress = _addressController.text.trim();
      if (_detailAddressController.text.trim().isNotEmpty) {
        fullAddress = "${_addressController.text.trim()}, ${_detailAddressController.text.trim()}";
      }
      
      print("📍 ===== CHECKOUT LOCATION SEARCH =====");
      print("📍 Full Address: $fullAddress");
      
      setState(() {
        _statusMessage = "🌐 Mencari koordinat alamat...";
      });
      
      LatLng? userLocation = await _getCoordinatesFromAddress(fullAddress);
      
      if (userLocation == null) {
        setState(() {
          _isCalculating = false;
          _statusMessage = "";
          _errorMessage = "Alamat tidak ditemukan.\n\nTips:\n1. Gunakan format: Nama Jalan, Kecamatan, Kota\n2. Contoh: Jalan Raya PLP Curug, Legok, Tangerang\n3. Pastikan alamat lengkap dan benar";
        });
        _showErrorSnackBar("Alamat tidak ditemukan.\nCoba format: Nama Jalan, Kecamatan, Kota");
        return;
      }
      
      setState(() {
        _userLocation = userLocation;
        _statusMessage = "🗺️ Mendapatkan rute perjalanan...";
      });
      
      print("📍 Store: ${_storeLocation.latitude}, ${_storeLocation.longitude}");
      print("📍 User: ${userLocation.latitude}, ${userLocation.longitude}");
      
      // Cek jarak antara toko dan user
      double distanceCheck = _calculateStraightDistance(_storeLocation, userLocation);
      print("📏 Distance check: ${distanceCheck.toStringAsFixed(3)} km");
      
      if (distanceCheck < 0.01) {
        // Jika jarak terlalu dekat, gunakan koordinat area lain
        setState(() {
          _errorMessage = "Alamat terlalu dekat dengan toko.\nGunakan alamat yang lebih spesifik.";
          _isCalculating = false;
          _statusMessage = "";
        });
        _showErrorSnackBar("Alamat terlalu dekat dengan toko. Gunakan alamat yang lebih spesifik.");
        return;
      }
      
      List<LatLng> routePoints = await _getRouteFromOSRM(_storeLocation, userLocation);
      
      if (routePoints.isNotEmpty && routePoints.length > 1) {
        setState(() {
          _routePoints = routePoints;
          _statusMessage = "";
          _isCalculating = false;
        });
        
        _zoomToRoute();
        
        _showSuccessSnackBar(
          "✅ Rute ditemukan!\n"
          "Jarak: ${_distance.toStringAsFixed(2)} km | "
          "Ongkir: Rp ${_formatPrice(_shippingCost)}"
        );
      } else {
        double distance = _calculateStraightDistance(_storeLocation, userLocation);
        setState(() {
          _distance = distance;
          _shippingCost = (distance * 5000).round();
          _routePoints = [_storeLocation, userLocation];
          _statusMessage = "";
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
      print("❌ Error: $e");
      setState(() {
        _isCalculating = false;
        _statusMessage = "";
        _errorMessage = "Terjadi kesalahan. Periksa koneksi internet Anda.";
      });
      _showErrorSnackBar("Terjadi kesalahan. Periksa koneksi internet Anda.");
    }
  }

  // ⬇️ ZOOM TO RUTE ⬇️
  void _zoomToRoute() {
    if (_routePoints.isEmpty || _userLocation == null) return;
    
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
      
      _mapController.move(LatLng(centerLat, centerLng), zoom);
    } catch (e) {
      print("Error zooming: $e");
    }
  }

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
                      _buildDeliveryMethodCard(),
                      const SizedBox(height: 24),

                      if (_deliveryMethod == "delivery") ...[
                        _buildAddressForm(),
                        const SizedBox(height: 16),
                        _buildAlamatForm(),
                        const SizedBox(height: 16),
                        _buildCheckButton(),
                        const SizedBox(height: 16),
                        
                        if (_statusMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B5EFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF9B5EFF),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF9B97B8),
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
              hintText: "Contoh: Jalan Raya PLP Curug, Legok, Tangerang",
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

  Widget _buildMapCard() {
    if (_userLocation == null || _routePoints.isEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF16162A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E35), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, color: Color(0xFF5C5878), size: 48),
              const SizedBox(height: 12),
              Text(
                "Masukkan alamat dan klik 'Cek Ongkir & Rute'",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

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
            initialCenter: _userLocation!,
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
            MarkerLayer(
              markers: [
                // Store Marker - Orange
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
                // User Marker - Red
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
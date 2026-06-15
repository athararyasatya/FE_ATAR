class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final double distance; // in km
  final int shippingCost;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distance,
    required this.shippingCost,
  });
}

class StoreLocation {
  // Ganti dengan koordinat toko Anda yang sebenarnya
  static const double latitude = -6.200000;  // Contoh: -6.200000 (Jakarta)
  static const double longitude = 106.816666; // Contoh: 106.816666
  
  // Informasi toko
  static const String storeName = "Kanzza Frozen Food";
  static const String address = "Jl. Contoh No. 123, Jakarta, Indonesia";
  static const String phone = "+62 812-3456-7890";
  static const String email = "info@kanzza.com";
}
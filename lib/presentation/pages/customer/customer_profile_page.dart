// lib/presentation/pages/customer/customer_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanzza_sales_app_fe/routes.dart'; // ⬅️ TAMBAHKAN IMPORT ROUTES

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    _nameController.text = "Ahmad Fauzi";
    _emailController.text = "ahmad.fauzi@email.com";
    _phoneController.text = "081234567890";
    _addressController.text = "Jl. Raya PLP Curug No. 124, Legok, Tangerang";
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      _showSnackBar("Profil berhasil diperbarui!", Colors.green.shade400);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar("Gagal menyimpan profil", Colors.red.shade400);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E1E35)),
        ),
        title: Text(
          "Ubah Password",
          style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
              decoration: InputDecoration(
                labelText: "Password Lama",
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
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
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
              decoration: InputDecoration(
                labelText: "Password Baru",
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
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
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14),
              decoration: InputDecoration(
                labelText: "Konfirmasi Password Baru",
                labelStyle: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.inter(color: const Color(0xFF9B97B8))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar("Password berhasil diubah!", Colors.green.shade400);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B5EFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Simpan", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ⬇️ FUNGSI LOGOUT - NAVIGASI KE LOGIN ⬇️
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
              Navigator.pop(context); // Tutup dialog
              // ⬇️ NAVIGASI KE HALAMAN LOGIN ⬇️
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false, // Hapus semua route sebelumnya
              );
              _showSnackBar("Berhasil logout", Colors.green.shade400);
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
                        "Profil Saya",
                        style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (_isEditing)
                      TextButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9B5EFF)),
                              )
                            : Text(
                                "Simpan",
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF9B5EFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
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
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar Section
                      _buildAvatarSection(),
                      const SizedBox(height: 24),

                      // Informasi Profil
                      _buildSectionTitle("Informasi Profil"),
                      const SizedBox(height: 12),
                      _buildProfileForm(),
                      const SizedBox(height: 24),

                      // Menu Lainnya
                      _buildSectionTitle("Pengaturan"),
                      const SizedBox(height: 12),
                      _buildSettingsMenu(),
                      const SizedBox(height: 30),

                      // Logout Button
                      _buildLogoutButton(),
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

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9B5EFF), Color(0xFF6C3BD8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B5EFF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B5EFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D0D12), width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty ? "Nama Pengguna" : _nameController.text,
            style: GoogleFonts.poppins(
              color: const Color(0xFFF0EAFF),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            _emailController.text.isEmpty ? "email@domain.com" : _emailController.text,
            style: GoogleFonts.inter(
              color: const Color(0xFF9B97B8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (!_isEditing)
            GestureDetector(
              onTap: () => setState(() => _isEditing = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B5EFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF9B5EFF).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit, color: Color(0xFF9B5EFF), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "Edit Profil",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9B5EFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(color: const Color(0xFFF0EAFF), fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          _buildProfileTextField(
            controller: _nameController,
            label: "Nama Lengkap",
            icon: Icons.person_outline,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildProfileTextField(
            controller: _emailController,
            label: "Email",
            icon: Icons.email_outlined,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildProfileTextField(
            controller: _phoneController,
            label: "Nomor Telepon",
            icon: Icons.phone_outlined,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildProfileTextField(
            controller: _addressController,
            label: "Alamat",
            icon: Icons.location_on_outlined,
            enabled: _isEditing,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: GoogleFonts.inter(
        color: enabled ? const Color(0xFFF0EAFF) : const Color(0xFF9B97B8),
        fontSize: 14,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: enabled ? const Color(0xFF9B97B8) : const Color(0xFF5C5878),
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9B5EFF), size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E1E35), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9B5EFF), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E1E35), width: 1),
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFF1E1E35) : const Color(0xFF13102A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E35), width: 1),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: "Ubah Password",
            subtitle: "Ganti password akun Anda",
            onTap: _showChangePasswordDialog,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: "Notifikasi",
            subtitle: "Pengaturan notifikasi",
            onTap: () {
              _showSnackBar("Fitur notifikasi akan segera hadir", const Color(0xFF9B5EFF));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: "Privasi & Keamanan",
            subtitle: "Kelola data privasi Anda",
            onTap: () {
              _showSnackBar("Fitur privasi akan segera hadir", const Color(0xFF9B5EFF));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: "Bantuan",
            subtitle: "Pusat bantuan & FAQ",
            onTap: () {
              _showSnackBar("Fitur bantuan akan segera hadir", const Color(0xFF9B5EFF));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF9B5EFF), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(color: const Color(0xFFF0EAFF), fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: const Color(0xFF9B97B8), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF5C5878), size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      splashColor: const Color(0xFF9B5EFF).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF1E1E35),
      height: 4,
      indent: 56,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logout, // ⬅️ PAKAI FUNGSI _logout
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: Colors.red.shade400.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 8),
            Text(
              "Logout",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
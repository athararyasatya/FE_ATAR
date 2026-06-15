import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/dummy_data.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String selectedRole = "customer";
  
  final List<String> roles = ["customer", "cashier", "driver"];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    // Validasi field kosong
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmController.text.trim().isEmpty) {
      _showErrorSnackBar("Semua field wajib diisi");
      return;
    }

    // Validasi email format
    if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
      _showErrorSnackBar("Email tidak valid");
      return;
    }

    // Validasi password minimal 6 karakter
    if (passwordController.text.length < 6) {
      _showErrorSnackBar("Password minimal 6 karakter");
      return;
    }

    // Validasi password cocok
    if (passwordController.text != confirmController.text) {
      _showErrorSnackBar("Password tidak cocok");
      return;
    }

    // Cek apakah email sudah terdaftar
    final emailExists = DummyData.users.any(
      (user) => user.email.toLowerCase() == emailController.text.trim().toLowerCase(),
    );

    if (emailExists) {
      _showErrorSnackBar("Email sudah terdaftar");
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulasi proses registrasi
    await Future.delayed(const Duration(milliseconds: 800));

    // Buat user baru (simpan ke DummyData)
    // Catatan: Karena DummyData.users adalah const list, untuk demo kita hanya simulasi
    // Di production, Anda perlu mengubah ke List yang mutable atau menggunakan state management
    
    setState(() {
      isLoading = false;
    });

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Registrasi berhasil! Silakan login.",
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Kembali ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.35, 0.7, 1.0],
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF5B21B6),
                  Color(0xFF312E81),
                  Color(0xFF111827),
                ],
              ),
            ),
          ),

          // Decorative Orbs
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -100,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        "Create Account",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isTablet ? 48 : 38,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        "Join Kanzza Sales Apps\nand start managing your business.",
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Register Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Registration",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Fill your information below",
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Full Name Field
                            AppTextField(
                              controller: nameController,
                              hintText: "Full Name",
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            AppTextField(
                              controller: emailController,
                              hintText: "Email",
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            AppTextField(
                              controller: passwordController,
                              hintText: "Password",
                              obscureText: obscurePassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            AppTextField(
                              controller: confirmController,
                              hintText: "Confirm Password",
                              obscureText: obscureConfirmPassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword = !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => register(),
                            ),
                            const SizedBox(height: 16),

                            // Role Selection
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedRole,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  isExpanded: true,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF1F2937),
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRole = newValue!;
                                    });
                                  },
                                  items: roles.map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                value == "customer"
                                                    ? Icons.person_outline
                                                    : value == "cashier"
                                                        ? Icons.point_of_sale_outlined
                                                        : Icons.delivery_dining_outlined,
                                                size: 18,
                                                color: const Color(0xFF7132F5),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                value.toUpperCase(),
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Info text for role
                            Text(
                              "Note: Admin approval may be required for cashier/driver roles",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Register Button
                            AppButton(
                              text: "Create Account",
                              onPressed: register,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 12),

                            // Login Link
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Already have an account? Login",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF7132F5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer
                      Center(
                        child: Text(
                          "© 2026 Kanzza Sales Apps",
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
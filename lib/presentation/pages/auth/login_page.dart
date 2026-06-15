import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/dummy_data.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../pages/customer/customer_home_page.dart';
import '../cashier/cashier_dashboard_page.dart';
import '../driver/driver_dashboard_page.dart';
import '../owner/owner_dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // Validate input
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar("Email tidak boleh kosong");
      return;
    }
    
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Password tidak boleh kosong");
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Cari user berdasarkan email dan password
    final user = DummyData.users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      orElse: () => null as dynamic,
    );

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("Email atau Password salah");
      return;
    }

    final role = user.role.trim().toLowerCase();
    print("LOGIN ROLE = $role");

    setState(() {
      isLoading = false;
    });

    // Navigate based on role
    Widget destination;
    switch (role) {
      case "customer":
        destination = const CustomerHomePage();
        break;
      case "cashier":
        destination = const CashierDashboardPage();
        break;
      case "driver":
        destination = const DriverDashboardPage();
        break;
      case "owner":
        destination = const OwnerDashboardPage();
        break;
      default:
        _showErrorSnackBar("Role '$role' tidak dikenali");
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
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
    
    // Set status bar color to light
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

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
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo / Title
                            Text(
                              "KANZZA",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: isTablet ? 52 : 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              "FROZEN FOOD",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isTablet ? 24 : 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Manage sales, inventory,\ndelivery and business insights.",
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: isTablet ? 16 : 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Login Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.98),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome Back",
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Login to continue",
                                    style: GoogleFonts.inter(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Email Field
                                  AppTextField(
                                    controller: emailController,
                                    hintText: "Email",
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 18),

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
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => login(),
                                  ),
                                  const SizedBox(height: 30),

                                  // Login Button
                                  AppButton(
                                    text: "Login",
                                    onPressed: login,
                                    isLoading: isLoading,
                                  ),
                                  const SizedBox(height: 14),

                                  // Register Link
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Create New Account",
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF7132F5),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
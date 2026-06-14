import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/dummy_data.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';

import '../customer/customer_home_page.dart';
import '../cashier/cashier_dashboard_page.dart';
import '../driver/driver_dashboard_page.dart';
import '../owner/owner_dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
  final email =
      emailController.text.trim();

  final password =
      passwordController.text.trim();

  final user =
      DummyData.users.where(
    (u) =>
        u.email == email &&
        u.password == password,
  );

  if (user.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.red.shade400,
        behavior:
            SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        content: const Text(
          "Email atau Password salah",
        ),
      ),
    );
    return;
  }

  final role =
      user.first.role.trim().toLowerCase();

  print("LOGIN ROLE = $role");

  if (role == "customer") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CustomerHomePage(),
      ),
    );
  } else if (role == "cashier") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CashierDashboardPage(),
      ),
    );
  } else if (role == "driver") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const DriverDashboardPage(),
      ),
    );
  } else if (role == "owner") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const OwnerDashboardPage(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.orange.shade400,
        content: Text(
          "Role '$role' tidak dikenali",
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >
            600;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // BACKGROUND
          Container(
            width: double.infinity,
            height: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.0,
                  0.35,
                  0.7,
                  1.0,
                ],
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF5B21B6),
                  Color(0xFF312E81),
                  Color(0xFF111827),
                ],
              ),
            ),
          ),

          // ORB ATAS
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(
                        0.06),
              ),
            ),
          ),

          // ORB BAWAH
          Positioned(
            bottom: -60,
            left: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(
                        0.04),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder:
                  (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 500,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "KANZZA FROZEN FOOD",
                            style:
                                GoogleFonts.poppins(
                              color:
                                  Colors.white,
                              fontSize:
                                  isTablet
                                      ? 52
                                      : 40,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              letterSpacing:
                                  1.2,
                            ),
                          ),

                          const SizedBox(
                              height: 12),

                          Text(
                            "Manage sales, inventory,\ndelivery and business insights.",
                            style:
                                GoogleFonts.inter(
                              color:
                                  Colors.white70,
                              fontSize:
                                  isTablet
                                      ? 18
                                      : 15,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(
                              height: 40),

                          Container(
                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets.all(
                                    28),

                            decoration:
                                BoxDecoration(
                              color: Colors
                                  .white
                                  .withOpacity(
                                      .96),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          32),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                          .15),
                                  blurRadius:
                                      40,
                                  offset:
                                      const Offset(
                                    0,
                                    20,
                                  ),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "Welcome Back",
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize:
                                        26,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        6),

                                Text(
                                  "Login to continue",
                                  style:
                                      GoogleFonts.inter(
                                    color: Colors
                                        .grey,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        28),

                                AppTextField(
                                  controller:
                                      emailController,
                                  hint:
                                      "Email",
                                  prefixIcon:
                                      Icons.email_outlined,
                                ),

                                const SizedBox(
                                    height:
                                        18),

                                AppTextField(
                                  controller:
                                      passwordController,
                                  hint:
                                      "Password",
                                  obscureText:
                                      true,
                                  prefixIcon:
                                      Icons.lock_outline,
                                ),

                                const SizedBox(
                                    height:
                                        30),

                                AppButton(
                                  text:
                                      "Login",
                                  onPressed:
                                      login,
                                ),

                                const SizedBox(
                                    height:
                                        14),

                                Center(
                                  child:
                                      TextButton(
                                    onPressed:
                                        () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child:
                                        Text(
                                      "Create New Account",
                                      style:
                                          GoogleFonts.inter(
                                        color:
                                            const Color(
                                          0xFF7132F5,
                                        ),
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          Center(
                            child: Text(
                              "© 2026 Kanzza Sales Apps",
                              style:
                                  GoogleFonts.inter(
                                color:
                                    Colors.white60,
                                fontSize:
                                    12,
                              ),
                            ),
                          ),
                        ],
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
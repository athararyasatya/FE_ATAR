import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/app_button.dart';
import '../../../widgets/app_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void register() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.orange.shade400,
          content: const Text(
            "Semua field wajib diisi",
          ),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.red.shade400,
          content: const Text(
            "Password tidak cocok",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.green.shade500,
        content: const Text(
          "Registrasi berhasil",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >
            600;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
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

          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withValues(
                  alpha: 0.06,
                ),
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
                color:
                    Colors.white.withValues(
                  alpha: 0.04,
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                              context);
                        },
                        icon: const Icon(
                          Icons
                              .arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Create Account",
                        style:
                            GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize:
                              isTablet
                                  ? 48
                                  : 38,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Join Kanzza Sales Apps\nand start managing your business.",
                        style:
                            GoogleFonts.inter(
                          color:
                              Colors.white70,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets.all(
                                28),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.96,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 40,
                              offset:
                                  const Offset(
                                      0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              "Registration",
                              style:
                                  GoogleFonts
                                      .poppins(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),

                            const SizedBox(
                                height: 6),

                            Text(
                              "Fill your information below",
                              style:
                                  GoogleFonts
                                      .inter(
                                color:
                                    Colors.grey,
                              ),
                            ),

                            const SizedBox(
                                height: 24),

                            AppTextField(
                              controller:
                                  nameController,
                              hint:
                                  "Full Name",
                              prefixIcon: Icons
                                  .person_outline,
                            ),

                            const SizedBox(
                                height: 16),

                            AppTextField(
                              controller:
                                  emailController,
                              hint: "Email",
                              prefixIcon: Icons
                                  .email_outlined,
                            ),

                            const SizedBox(
                                height: 16),

                            AppTextField(
                              controller:
                                  passwordController,
                              hint:
                                  "Password",
                              obscureText:
                                  true,
                              prefixIcon: Icons
                                  .lock_outline,
                            ),

                            const SizedBox(
                                height: 16),

                            AppTextField(
                              controller:
                                  confirmController,
                              hint:
                                  "Confirm Password",
                              obscureText:
                                  true,
                              prefixIcon: Icons
                                  .lock_outline,
                            ),

                            const SizedBox(
                                height: 30),

                            AppButton(
                              text:
                                  "Create Account",
                              onPressed:
                                  register,
                            ),

                            const SizedBox(
                                height: 12),

                            Center(
                              child:
                                  TextButton(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                      context);
                                },
                                child: Text(
                                  "Already have an account?",
                                  style:
                                      GoogleFonts.inter(
                                    color:
                                        const Color(
                                      0xFF7132F5,
                                    ),
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          "© 2026 Kanzza Sales Apps",
                          style:
                              GoogleFonts.inter(
                            color:
                                Colors.white60,
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
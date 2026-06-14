import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Athar",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "athar@email.com",
              style: GoogleFonts.inter(),
            ),

            const SizedBox(height: 30),

            ListTile(
              leading:
                  const Icon(Icons.settings),
              title:
                  const Text("Pengaturan"),
              onTap: () {},
            ),

          ListTile(
  leading: const Icon(Icons.logout),
  title: const Text("Logout"),
  onTap: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  },
),
          ],
        ),
      ),
    );
  }
}
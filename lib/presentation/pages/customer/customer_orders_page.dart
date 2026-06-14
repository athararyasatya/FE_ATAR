import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Pesanan Saya",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.local_shipping),
                      title: Text("ORD-001"),
                      subtitle:
                          Text("Sedang Dikirim"),
                      trailing: Text("Rp68.000"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CashierProducts extends StatelessWidget {
  const CashierProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: const Center(
        child: Text('Products Page - Coming Soon'),
      ),
    );
  }
}
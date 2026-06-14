import 'package:flutter/material.dart';

class OwnerProducts extends StatelessWidget {
  const OwnerProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: const Center(
        child: Text('Product Management Page - Coming Soon'),
      ),
    );
  }
}
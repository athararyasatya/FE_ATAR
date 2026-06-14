import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';


import 'presentation/pages/customer/customer_home_page.dart';

void main() {
  runApp(const KanzzaSalesApp());
}

class KanzzaSalesApp extends StatelessWidget {
  const KanzzaSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanzza Sales',

      theme: AppTheme.lightTheme,

      home: const CustomerHomePage(),
    );
  }
}
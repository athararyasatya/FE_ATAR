// lib/main.dart

import 'package:flutter/material.dart';
import 'package:kanzza_sales_app_fe/core/theme/app_theme.dart';
import 'package:kanzza_sales_app_fe/routes.dart';

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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      // ⬇️ TAMBAHKAN INI ⬇️
      navigatorKey: navigatorKey,
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
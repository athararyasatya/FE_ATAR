// lib/routes.dart

import 'package:flutter/material.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/auth/login_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/auth/register_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/customer/customer_home_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/customer/customer_cart_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/customer/customer_checkout_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/customer/customer_orders_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/customer/customer_profile_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/cashier/cashier_dashboard_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/cashier/cashier_products_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/cashier/cashier_transaction.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/cashier/offline_transaction_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/driver/driver_dashboard_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/owner/owner_dashboard_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/owner/owner_products_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/owner/owner_reports_page.dart';
import 'package:kanzza_sales_app_fe/presentation/pages/owner/owner_manage_role_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static const String customerHome = '/customer-home';
  static const String customerCart = '/customer-cart';
  static const String customerCheckout = '/customer-checkout';
  static const String customerOrders = '/customer-orders';
  static const String customerProfile = '/customer-profile';

  static const String cashierDashboard = '/cashier-dashboard';
  static const String cashierProducts = '/cashier-products';
  static const String cashierTransaction = '/cashier-transaction';
  static const String offlineTransaction = '/offline-transaction';

  static const String driverDelivery = '/driver-delivery';

  static const String ownerDashboard = '/owner-dashboard';
  static const String ownerProducts = '/owner-products';
  static const String ownerReports = '/owner-reports';
  static const String ownerManageRole = '/owner-manage-role';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginPage(),
        register: (context) => const RegisterPage(),
        customerHome: (context) => const CustomerHomePage(),
        customerCart: (context) => const CustomerCartPage(),
        customerCheckout: (context) => const CustomerCheckoutPage(),
        customerOrders: (context) => const CustomerOrdersPage(),
        customerProfile: (context) => const CustomerProfilePage(),
        cashierDashboard: (context) => const CashierDashboardPage(),
        offlineTransaction: (context) => const OfflineTransactionPage(), // ⬅️ TAMBAHKAN KOMA
        cashierProducts: (context) => const CashierProductsPage(),
        cashierTransaction: (context) => const CashierTransactionPage(),
        driverDelivery: (context) => const DriverDashboardPage(),
        ownerDashboard: (context) => const OwnerDashboardPage(),
        ownerProducts: (context) => const OwnerProductsPage(),
        ownerReports: (context) => const OwnerReportsPage(),
        ownerManageRole: (context) => const OwnerManageRolePage(),
      };
}
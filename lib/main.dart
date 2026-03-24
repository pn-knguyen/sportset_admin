import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/firebase_options.dart';
import 'package:sportset_admin/screens/auth/login_screen.dart';
import 'package:sportset_admin/screens/main_screen.dart';
import 'package:sportset_admin/screens/account/account_screen.dart';
import 'package:sportset_admin/screens/management/management_screen.dart';
import 'package:sportset_admin/screens/management/facility/facility_list_screen.dart';
import 'package:sportset_admin/screens/management/facility/facility_detail_screen.dart';
import 'package:sportset_admin/screens/management/facility/facility_create_screen.dart';
import 'package:sportset_admin/screens/management/facility/facility_edit_screen.dart';
import 'package:sportset_admin/screens/management/court/court_list_screen.dart';
import 'package:sportset_admin/screens/management/court/court_detail_screen.dart';
import 'package:sportset_admin/screens/management/court/court_create_screen.dart';
import 'package:sportset_admin/screens/management/court/court_edit_screen.dart';
import 'package:sportset_admin/screens/management/sport/sport_list_screen.dart';
import 'package:sportset_admin/screens/management/sport/sport_detail_screen.dart';
import 'package:sportset_admin/screens/management/sport/sport_create_screen.dart';
import 'package:sportset_admin/screens/management/sport/sport_edit_screen.dart';
import 'package:sportset_admin/screens/management/voucher/voucher_list_screen.dart';
import 'package:sportset_admin/screens/management/voucher/voucher_detail_screen.dart';
import 'package:sportset_admin/screens/management/voucher/voucher_create_screen.dart';
import 'package:sportset_admin/screens/management/voucher/voucher_edit_screen.dart';
import 'package:sportset_admin/screens/management/staff/staff_list_screen.dart';
import 'package:sportset_admin/screens/management/staff/staff_detail_screen.dart';
import 'package:sportset_admin/screens/management/staff/staff_create_screen.dart';
import 'package:sportset_admin/screens/management/staff/staff_edit_screen.dart';
import 'package:sportset_admin/screens/management/permission/permission_list_screen.dart';
import 'package:sportset_admin/screens/management/permission/permission_create_screen.dart';
import 'package:sportset_admin/screens/management/permission/permission_edit_screen.dart';
import 'package:sportset_admin/screens/management/permission/permission_delete_screen.dart';
import 'package:sportset_admin/screens/management/revenue/revenue_screen.dart';
import 'package:sportset_admin/screens/management/customer/customer_list_screen.dart';
import 'package:sportset_admin/screens/management/customer/customer_detail_screen.dart';
import 'package:sportset_admin/screens/management/review/review_list_screen.dart';
import 'package:sportset_admin/screens/management/review/review_detail_screen.dart';
import 'package:sportset_admin/screens/booking/booking_list_screen.dart';
import 'package:sportset_admin/screens/booking/booking_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportSet Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        // Auth
        AppRoutes.login: (context) => const LoginScreen(),

        // Main
        AppRoutes.home: (context) => const MainScreen(),
        AppRoutes.account: (context) => const AccountScreen(),
        AppRoutes.management: (context) => const ManagementScreen(),

        // Management - Facilities
        AppRoutes.facilities: (context) => const FacilityListScreen(),
        AppRoutes.facilityDetail: (context) => const FacilityDetailScreen(),
        AppRoutes.facilityCreate: (context) => const FacilityCreateScreen(),
        AppRoutes.facilityEdit: (context) => const FacilityEditScreen(),

        // Management - Courts
        AppRoutes.courts: (context) => const CourtListScreen(),
        AppRoutes.courtDetail: (context) => const CourtDetailScreen(),
        AppRoutes.courtCreate: (context) => const CourtCreateScreen(),
        AppRoutes.courtEdit: (context) => const CourtEditScreen(),

        // Management - Sports
        AppRoutes.sports: (context) => const SportListScreen(),
        AppRoutes.sportDetail: (context) => const SportDetailScreen(),
        AppRoutes.sportCreate: (context) => const SportCreateScreen(),
        AppRoutes.sportEdit: (context) => const SportEditScreen(),

        // Management - Vouchers
        AppRoutes.vouchers: (context) => const VoucherListScreen(),
        AppRoutes.voucherDetail: (context) => const VoucherDetailScreen(),
        AppRoutes.voucherCreate: (context) => const VoucherCreateScreen(),
        AppRoutes.voucherEdit: (context) => const VoucherEditScreen(),

        // Management - Staff & Permissions
        AppRoutes.staff: (context) => const StaffListScreen(),
        AppRoutes.staffDetail: (context) => const StaffDetailScreen(),
        AppRoutes.staffCreate: (context) => const StaffCreateScreen(),
        AppRoutes.staffEdit: (context) => const StaffEditScreen(),
        AppRoutes.permissions: (context) => const PermissionListScreen(),
        AppRoutes.permissionCreate: (context) => const PermissionCreateScreen(),
        AppRoutes.permissionEdit: (context) => const PermissionEditScreen(),
        AppRoutes.permissionDelete: (context) => const PermissionDeleteScreen(),

        // Management - Revenue
        AppRoutes.revenue: (context) => const RevenueScreen(),

        // Management - Customers
        AppRoutes.customers: (context) => const CustomerListScreen(),
        AppRoutes.customerDetail: (context) => const CustomerDetailScreen(),

        // Management - Reviews
        AppRoutes.reviews: (context) => const ReviewListScreen(),
        AppRoutes.reviewDetail: (context) => const ReviewDetailScreen(),

        // Bookings
        AppRoutes.bookings: (context) => const BookingListScreen(),
        AppRoutes.bookingDetail: (context) => const BookingDetailScreen(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

class CommonBottomNav extends StatelessWidget {
  final int currentIndex;
  final Color navyColor;
  final Color orangeColor;

  const CommonBottomNav({
    super.key,
    required this.currentIndex,
    this.navyColor = const Color(0xFF0C1C46),
    this.orangeColor = const Color(0xFFFF9800),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.home, 'Trang chủ', AppRoutes.home),
          _buildNavItem(context, 1, Icons.view_list, 'Quản lý', AppRoutes.management),
          _buildNavItem(context, 2, Icons.calendar_month, 'Đơn đặt', AppRoutes.bookings),
          _buildNavItem(context, 3, Icons.person, 'Tài khoản', AppRoutes.account),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    final isActive = currentIndex == index;
    final color = isActive ? orangeColor : Colors.grey[400];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            // Navigate to the main screen with the selected tab
            Navigator.pushNamedAndRemoveUntil(
              context,
              route,
              (route) => false,
            );
          }
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


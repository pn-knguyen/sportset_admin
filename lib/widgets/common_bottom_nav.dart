import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

const _primary = Color(0xFF4CAF50);
const _inactive = Color(0xFF9E9E9E);

class CommonBottomNav extends StatelessWidget {
  final int currentIndex;

  const CommonBottomNav({
    super.key,
    required this.currentIndex,
    // Legacy params kept for backward compat — unused
    @Deprecated('') Color navyColor = const Color(0xFF0C1C46),
    @Deprecated('') Color orangeColor = const Color(0xFFFF9800),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, Icons.home_outlined, 'Trang chủ', AppRoutes.home),
              _buildNavItem(context, 1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Quản lý', AppRoutes.management),
              _buildNavItem(context, 2, Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Đơn đặt', AppRoutes.bookings),
              _buildNavItem(context, 3, Icons.person_rounded, Icons.person_outline_rounded, 'Tài khoản', AppRoutes.account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData activeIcon,
      IconData inactiveIcon, String label, String route) {
    final isActive = currentIndex == index;
    final color = isActive ? _primary : _inactive;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
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
              Icon(isActive ? activeIcon : inactiveIcon, size: 26, color: color),
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

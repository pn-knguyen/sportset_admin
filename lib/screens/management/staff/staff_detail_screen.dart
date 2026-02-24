import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class StaffDetailScreen extends StatefulWidget {
  const StaffDetailScreen({super.key});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  final Map<String, dynamic> _staffData = {
    'name': 'Nguyễn Minh Quân',
    'position': 'Quản lý cơ sở',
    'avatar': 'https://i.pravatar.cc/150?img=8',
    'phone': '090 123 4567',
    'email': 'quan.nguyen@sportset.com',
    'workplace': 'SPORTSET Quận 7 - CN1',
    'joinDate': '15 Tháng 03, 2023',
    'isActive': true,
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'description': 'Đã xác nhận đơn đặt sân ',
      'highlight': '#SP12390',
      'time': '10 phút trước',
      'isRecent': true,
    },
    {
      'description': 'Cập nhật trạng thái sân số 4',
      'highlight': '',
      'time': 'Hôm qua, 14:30',
      'isRecent': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildContactInfoSection(),
                  const SizedBox(height: 24),
                  _buildRecentActivitiesSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: _navyColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Chi Tiết Nhân Viên',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                  border: Border.all(color: Colors.orange[100]!, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    _staffData['avatar'] as String,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green[500],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _staffData['name'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (_staffData['position'] as String).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _orangeColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'THÔNG TIN LIÊN LẠC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _navyColor.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.call,
                label: 'Số điện thoại',
                value: _staffData['phone'] as String,
                showBorder: true,
              ),
              _buildInfoRow(
                icon: Icons.mail,
                label: 'Email',
                value: _staffData['email'] as String,
                showBorder: true,
              ),
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Cơ sở làm việc',
                value: _staffData['workplace'] as String,
                showBorder: true,
              ),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Ngày tham gia hệ thống',
                value: _staffData['joinDate'] as String,
                showBorder: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool showBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.05)))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _orangeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'HOẠT ĐỘNG GẦN ĐÂY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _navyColor.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: List.generate(_recentActivities.length, (index) {
              final activity = _recentActivities[index];
              final isLast = index == _recentActivities.length - 1;
              return _buildActivityItem(
                activity: activity,
                showLine: !isLast,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required Map<String, dynamic> activity,
    required bool showLine,
  }) {
    final isRecent = activity['isRecent'] as bool;
    return Padding(
      padding: EdgeInsets.only(bottom: showLine ? 24 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Stack(
              children: [
                if (showLine)
                  Positioned(
                    left: 11,
                    top: 24,
                    bottom: -24,
                    child: Container(
                      width: 2,
                      color: Colors.grey[100],
                    ),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isRecent ? Colors.orange[100] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isRecent ? _orangeColor : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: activity['description'] as String),
                      if ((activity['highlight'] as String).isNotEmpty)
                        TextSpan(
                          text: activity['highlight'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[500]!, width: 2),
            ),
            child: TextButton(
              onPressed: () {
                _showDisableDialog();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Vô hiệu hóa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[500],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.staffEdit);
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Chỉnh sửa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDisableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Vô hiệu hóa nhân viên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn vô hiệu hóa tài khoản của "${_staffData['name']}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã vô hiệu hóa "${_staffData['name']}"'),
                  ),
                );
              },
              child: const Text(
                'Vô hiệu hóa',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}


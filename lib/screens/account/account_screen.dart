import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/common_bottom_nav.dart';

const _primary = Color(0xFF4CAF50);
const _secondary = Color(0xFF18A5A7);
const _darkGreen = Color(0xFF2E7D32);
const _lightGreen = Color(0xFFE8F5E9);
const _onSurface = Color(0xFF1A1C1C);
const _onSurfaceVariant = Color(0xFF5C615A);

class AccountScreen extends StatefulWidget {
  final bool showBottomNav;

  const AccountScreen({super.key, this.showBottomNav = true});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightGreen, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfile(),
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 28),
                _buildSectionLabel('CÁ NHÂN'),
                const SizedBox(height: 10),
                _buildMenuGroup([
                  _buildMenuItem(Icons.edit_note, 'Chỉnh sửa thông tin', true, () {}),
                  _buildMenuItem(Icons.lock_reset, 'Đổi mật khẩu', false, () {}),
                ]),
                const SizedBox(height: 24),
                _buildSectionLabel('KINH DOANH'),
                const SizedBox(height: 10),
                _buildMenuGroup([
                  _buildMenuItem(Icons.storefront, 'Thông tin cơ sở', true, () {}),
                  _buildMenuItem(Icons.account_balance_wallet, 'Quản lý ví tiền', false, () {}),
                ]),
                const SizedBox(height: 24),
                _buildSectionLabel('HỆ THỐNG'),
                const SizedBox(height: 10),
                _buildMenuGroup([
                  _buildMenuItem(Icons.notifications, 'Thông báo', true, () {}),
                  _buildMenuItem(Icons.settings, 'Cài đặt ứng dụng', true, () {}),
                  _buildMenuItem(Icons.help, 'Hỗ trợ', false, () {}),
                ]),
                const SizedBox(height: 32),
                _buildLogoutButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? const CommonBottomNav(currentIndex: 3)
          : null,
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _primary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCz8DIGdH3n_97IozV_bEJiGiu2QjkXP8VdbuExJ3684S-JLskBia7QtkIbTdCyp4OrOMTzQpb7o8zBHw8MTduvUL6pb3fvC1lNzjXvplR_XGbIlgwG3VCxWfRiI3qI-Dbjh9sXksK1emtVEECamJZaUCL5sh2mg77HCNwnZyw36l4XXOannNZSD5jCQnkOLp9a_Qg4ykhIz6ht_F_fkP4bLH3jJovt9h96t9Xn_Nrg-yXSmL2xwseLYNCotR-Z4GpF4edVYV4MW7c',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: _lightGreen,
                  child: const Icon(Icons.person, color: _primary, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Nguyễn Văn Nam',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _onSurface,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Chủ cơ sở',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F8E9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'TRUNG TÂM THỂ THAO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'SPORTSET Tân Bình',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _onSurface,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'ID ĐỐI TÁC',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: const Text(
                  'SP-8821',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9CA3AF),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, bool showDivider, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF3F4F6)),
                ),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 23, color: _secondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE4E6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBA1A1A).withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFBA1A1A), size: 22),
            SizedBox(width: 10),
            Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBA1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _onSurface,
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            style: TextStyle(
              fontSize: 14,
              color: _onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _onSurfaceVariant,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFBA1A1A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performLogout();
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đăng xuất thành công'),
            backgroundColor: _darkGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng xuất: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
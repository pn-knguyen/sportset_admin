import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AccountDeleteScreen extends StatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isDeleting = false;

  Future<void> _handleDelete(String uid) async {
    setState(() => _isDeleting = true);

    try {
      await _firestore.collection('admin_accounts').doc(uid).delete();
      await _firestore.collection('users').doc(uid).delete();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa tài khoản khỏi hệ thống'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa tài khoản: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final uid = (args?['uid'] as String?) ?? '';
    final username = (args?['username'] as String?) ?? 'Tài khoản';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildContent(username, uid),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF0C1C46),
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Xóa tài khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C1C46),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String username, String uid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Xác nhận xóa tài khoản',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0C1C46),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bạn có chắc muốn xóa tài khoản "$username" không?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dữ liệu sẽ bị xóa vĩnh viễn:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Tài khoản admin trong hệ thống\n• Thông tin người dùng liên kết\n• Tất cả dữ liệu liên quan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isDeleting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isDeleting || uid.isEmpty ? null : () => _handleDelete(uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.red.withValues(alpha: 0.5),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Xóa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

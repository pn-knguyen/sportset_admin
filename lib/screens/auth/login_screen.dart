import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportset_admin/routes/app_routes.dart';

// Design tokens matching the HTML theme
class _C {
  static const primary = Color(0xFF1F7D34);
  static const onPrimary = Colors.white;
  static const onSurface = Color(0xFF1A1C1C);
  static const onSurfaceVariant = Color(0xFF3F4A3C);
  static const surfaceContainerLow = Color(0xFFF3F3F3);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    // ── Center Content ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: Column(
                          children: [
                            // ── Branding ──
                            Column(
                              children: [
                                const Icon(
                                  Icons.sports_soccer_outlined,
                                  size: 64,
                                  color: _C.primary,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'SPORTSET',
                                  style: TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: _C.primary,
                                    letterSpacing: 2,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cổng Quản trị & Vận hành',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _C.onSurface.withValues(alpha: 0.70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // ── Login Card ──
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _C.primary.withValues(alpha: 0.05),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email field
                                  _FieldLabel('Email hoặc Tên đăng nhập'),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: _C.onSurface,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'admin@arenaos.vn',
                                      hintStyle: TextStyle(
                                        color: _C.onSurfaceVariant.withValues(alpha: 0.40),
                                        fontSize: 15,
                                      ),
                                      filled: true,
                                      fillColor: _C.surfaceContainerLow,
                                      suffixIcon: const Icon(
                                        Icons.person,
                                        color: Color(0x663F4A3C),
                                        size: 20,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _C.primary.withValues(alpha: 0.50),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Password field
                                  _FieldLabel('Mật khẩu'),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    style: const TextStyle(
                                      color: _C.onSurface,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: TextStyle(
                                        color: _C.onSurfaceVariant.withValues(alpha: 0.40),
                                        fontSize: 15,
                                      ),
                                      filled: true,
                                      fillColor: _C.surfaceContainerLow,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: const Color(0x663F4A3C),
                                          size: 20,
                                        ),
                                        onPressed: () => setState(
                                          () => _isPasswordVisible = !_isPasswordVisible,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: _C.primary.withValues(alpha: 0.50),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _C.primary,
                                        foregroundColor: _C.onPrimary,
                                        disabledBackgroundColor:
                                            _C.primary.withValues(alpha: 0.6),
                                        elevation: 6,
                                        shadowColor: _C.primary.withValues(alpha: 0.40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.login, size: 22),
                                      label: _isLoading
                                          ? const SizedBox.shrink()
                                          : const Text(
                                              'Đăng nhập hệ thống',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Forgot Password
                                  Center(
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Quên mật khẩu quản trị?',
                                        style: TextStyle(
                                          color: _C.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 64), 
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final loginInput = _emailController.text.trim();
    final password = _passwordController.text;

    if (loginInput.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập tài khoản và mật khẩu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authEmail = _toAuthEmail(loginInput);
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        _showError('Không lấy được thông tin người dùng');
        return;
      }

      final adminDoc = await _firestore.collection('admin_accounts').doc(uid).get();
      if (!adminDoc.exists) {
        await _firebaseAuth.signOut();
        _showError('Tài khoản không có quyền quản trị');
        return;
      }

      final adminData = adminDoc.data() ?? <String, dynamic>{};
      if (adminData['isActive'] != true) {
        await _firebaseAuth.signOut();
        _showError('Tài khoản quản trị đã bị khóa');
        return;
      }

      final permissionGroupId = (adminData['permissionGroupId'] as String?)?.trim();
      if (permissionGroupId == null || permissionGroupId.isEmpty) {
        await _firebaseAuth.signOut();
        _showError('Tài khoản chưa được gán nhóm quyền');
        return;
      }

      final permissionDoc =
          await _firestore.collection('permissions').doc(permissionGroupId).get();
      if (!permissionDoc.exists) {
        await _firebaseAuth.signOut();
        _showError('Nhóm quyền không tồn tại');
        return;
      }

      final permissionData = permissionDoc.data() ?? <String, dynamic>{};
      final permissionMap = permissionData['permissions'];
      final hasAnyAccess =
          permissionMap is Map<String, dynamic> && _hasAnyAccess(permissionMap);

      if (!hasAnyAccess) {
        await _firebaseAuth.signOut();
        _showError('Tài khoản chưa được cấu hình quyền truy cập');
        return;
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      _showError(_mapLoginError(e));
    } catch (e) {
      _showError('Đăng nhập thất bại: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _toAuthEmail(String input) {
    if (input.contains('@')) {
      return input.toLowerCase();
    }

    final normalized = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '');

    return '$normalized@sportset.local';
  }

  bool _hasAnyAccess(Map<String, dynamic> permissions) {
    for (final moduleEntry in permissions.entries) {
      final actionMap = moduleEntry.value;
      if (actionMap is! Map<String, dynamic>) {
        continue;
      }

      for (final actionEntry in actionMap.entries) {
        if (actionEntry.value == true) {
          return true;
        }
      }
    }
    return false;
  }

  String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'Sai tài khoản hoặc mật khẩu';
      case 'wrong-password':
        return 'Sai mật khẩu';
      case 'too-many-requests':
        return 'Bạn thử quá nhiều lần, vui lòng thử lại sau';
      default:
        return 'Lỗi đăng nhập: ${e.code}';
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ── Private helper widgets ──────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0x993F4A3C),
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _C.onSurface.withValues(alpha: opacity),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0x991A1C1C),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}


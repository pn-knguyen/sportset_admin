import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportset_admin/routes/app_routes.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF221110) : const Color(0xFFFFF8F6),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Column(
                  children: [
                    // Gradient Icon Logo
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // App Name
                    Text(
                      'SPORTSET',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1C0E0D),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Cổng Quản Trị & Vận Hành',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blue[100] : const Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Login Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Email/Username Field
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email hoặc Tên đăng nhập',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF9800),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C0E0D),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Mật khẩu',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF9800),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1C0E0D),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      // Login Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _isLoading ? null : _handleLogin,
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Đăng nhập hệ thống',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Forgot Password & Footer
                      Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: Text(
                              'Quên mật khẩu quản trị?',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFFF8A80)
                                    : const Color(0xFFF44336),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Version Tag
                          Opacity(
                            opacity: 0.4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'v2.4.0 - Internal Use Only',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1C0E0D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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


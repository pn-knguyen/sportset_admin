import 'package:flutter/material.dart';

// Trang thêm mới nhóm quyền
class PermissionCreateScreen extends StatefulWidget {
  const PermissionCreateScreen({super.key});

  @override
  State<PermissionCreateScreen> createState() => _PermissionCreateScreenState();
}

class _PermissionCreateScreenState extends State<PermissionCreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm nhóm quyền mới'),
      ),
      body: const Center(
        child: Text('Permission Create Screen - Paste your UI code here'),
      ),
    );
  }
}


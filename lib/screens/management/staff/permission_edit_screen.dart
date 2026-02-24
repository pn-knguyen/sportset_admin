import 'package:flutter/material.dart';

// Trang chỉnh sửa nhóm quyền
class PermissionEditScreen extends StatefulWidget {
  const PermissionEditScreen({super.key});

  @override
  State<PermissionEditScreen> createState() => _PermissionEditScreenState();
}

class _PermissionEditScreenState extends State<PermissionEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa nhóm quyền'),
      ),
      body: const Center(
        child: Text('Permission Edit Screen - Paste your UI code here'),
      ),
    );
  }
}


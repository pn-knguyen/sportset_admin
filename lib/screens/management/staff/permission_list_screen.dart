import 'package:flutter/material.dart';

// 3.5. Trang quản lý nhóm quyền
class PermissionListScreen extends StatefulWidget {
  const PermissionListScreen({super.key});

  @override
  State<PermissionListScreen> createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhóm quyền'),
      ),
      body: const Center(
        child: Text('Permission List Screen - Paste your UI code here'),
      ),
    );
  }
}


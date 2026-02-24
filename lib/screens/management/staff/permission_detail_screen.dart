import 'package:flutter/material.dart';

// 3.5. Chi tiết nhóm quyền (Create/Update)
class PermissionDetailScreen extends StatefulWidget {
  const PermissionDetailScreen({super.key});

  @override
  State<PermissionDetailScreen> createState() => _PermissionDetailScreenState();
}

class _PermissionDetailScreenState extends State<PermissionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhóm quyền'),
      ),
      body: const Center(
        child: Text('Permission Detail Screen - Paste your UI code here'),
      ),
    );
  }
}


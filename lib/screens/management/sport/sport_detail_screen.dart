import 'package:flutter/material.dart';

// 3.3. Chi tiết môn thể thao (Create/Update)
class SportDetailScreen extends StatefulWidget {
  const SportDetailScreen({super.key});

  @override
  State<SportDetailScreen> createState() => _SportDetailScreenState();
}

class _SportDetailScreenState extends State<SportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết môn thể thao'),
      ),
      body: const Center(
        child: Text('Sport Detail Screen - Paste your UI code here'),
      ),
    );
  }
}


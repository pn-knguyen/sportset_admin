import 'package:flutter/material.dart';

// 3.8. Chi tiết đánh giá
class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({super.key});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đánh giá'),
      ),
      body: const Center(
        child: Text('Review Detail Screen - Paste your UI code here'),
      ),
    );
  }
}


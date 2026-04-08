import 'package:flutter/material.dart';
import '../../../widgets/common_bottom_nav.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  late TabController _tabController;

  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Nguyễn Minh Quân',
      'avatar': 'https://i.pravatar.cc/150?img=11',
      'rating': 5,
      'timeAgo': '2 giờ trước',
      'comment':
          'Sân cỏ rất đẹp và mới, đèn chiếu sáng cực tốt cho các trận đá đêm. Nhân viên hỗ trợ nhiệt tình, giá cả hợp lý so với chất lượng. Sẽ quay lại nhiều lần!',
      'facility': 'Sân Chảo Lửa - Sân A1',
      'replied': false,
      'reply': null,
    },
    {
      'name': 'Lê Thị Thu Thảo',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'rating': 4,
      'timeAgo': 'Hôm qua',
      'comment':
          'Khu vực khán đài hơi bụi một chút, nhưng chất lượng mặt sân thì không có gì để chê. Mong sân cải thiện thêm phần vệ sinh xung quanh.',
      'facility': 'Sân Chảo Lửa - Sân B2',
      'replied': false,
      'reply': null,
    },
    {
      'name': 'Trần Hoàng Long',
      'avatar': 'https://i.pravatar.cc/150?img=15',
      'rating': 5,
      'timeAgo': '2 ngày trước',
      'comment':
          'Tuyệt vời! Sân vận hành chuyên nghiệp nhất khu vực Tân Bình.',
      'facility': 'Sân Chảo Lửa - Sân A2',
      'replied': true,
      'reply': 'Cảm ơn anh Long đã tin tưởng và ủng hộ hệ thống sân Chảo Lửa ạ!',
    },
  ];

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 1) {
      return _reviews.where((r) => r['replied'] == false).toList();
    } else if (_selectedTab == 2) {
      return _reviews.where((r) => r['replied'] == true).toList();
    }
    return _reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightGreen, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: _primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Đánh giá & Nhận xét',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  ..._filtered.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildReviewCard(r),
                      )),
                  if (_filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          'Không có đánh giá nào',
                          style: TextStyle(
                            fontSize: 14,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }
  Widget _buildTabBar() {
    const tabs = ['Tất cả', 'Chưa phản hồi', 'Đã phản hồi'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(i);
                setState(() => _selectedTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.w500,
                    color: active ? Colors.white : _onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Trung bình', 'value': '4.8', 'color': _primary, 'star': true},
      {'label': 'Tổng số', 'value': '1.248', 'color': _onSurface, 'star': false},
      {'label': 'Mới nhất', 'value': '12', 'color': _secondary, 'star': false},
      {'label': 'Tỉ lệ phản hồi', 'value': '92%', 'color': _primary, 'star': false},
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['label'] as String,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      s['value'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: s['color'] as Color,
                      ),
                    ),
                    if (s['star'] == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: Icon(Icons.star,
                            size: 13, color: Color(0xFFFFB300)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as int;
    final replied = review['replied'] as bool;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      review['avatar'] as String,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 48,
                        height: 48,
                        color: _lightGreen,
                        child: const Icon(Icons.person, color: _primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        review['timeAgo'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: const Color(0xFFFFB300),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review['comment'] as String,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_soccer,
                    size: 14, color: _secondary),
                const SizedBox(width: 6),
                Text(
                  review['facility'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _secondary,
                  ),
                ),
              ],
            ),
          ),
          if (replied) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _lightGreen.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                    left: BorderSide(color: _primary, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PHẢN HỒI CỦA BẠN:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review['reply'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _showDeleteDialog,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 20, color: Color(0xFFEF4444)),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: replied
                        ? null
                        : const LinearGradient(
                            colors: [_primary, _darkGreen],
                          ),
                    color: replied ? const Color(0xFFF0F0F0) : null,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: replied
                        ? null
                        : [
                            BoxShadow(
                              color: _primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Text(
                    replied ? 'Chỉnh sửa' : 'Phản hồi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: replied ? _onSurface : Colors.white,
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Xóa đánh giá',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: _onSurface),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa đánh giá này không?',
          style: TextStyle(color: _onSurfaceVariant, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: _onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa đánh giá')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../models/review.dart';
import '../../../services/review_service.dart';
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
  int _selectedTab = 0;

  final ReviewService _reviewService = ReviewService();

  String? _editingReviewId;
  TextEditingController? _activeReplyController;
  bool _savingReply = false;

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
    _activeReplyController?.dispose();
    super.dispose();
  }

  List<Review> _filterReviews(List<Review> all) {
    if (_selectedTab == 1) return all.where((r) => !r.replied).toList();
    if (_selectedTab == 2) return all.where((r) => r.replied).toList();
    return all;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  double _avgRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (acc, r) => acc + r.rating);
    return sum / reviews.length;
  }

  void _startEditing(Review review) {
    _activeReplyController?.dispose();
    _activeReplyController =
        TextEditingController(text: review.reply ?? '');
    setState(() => _editingReviewId = review.id);
  }

  void _cancelEditing() {
    _activeReplyController?.dispose();
    _activeReplyController = null;
    setState(() {
      _editingReviewId = null;
      _savingReply = false;
    });
  }

  Future<void> _saveReply(Review review) async {
    final text = _activeReplyController?.text.trim() ?? '';
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vui lòng nhập nội dung phản hồi')),
        );
      }
      return;
    }
    setState(() => _savingReply = true);
    try {
      await _reviewService.submitReply(review.id, text);
      if (mounted) {
        _activeReplyController?.dispose();
        _activeReplyController = null;
        setState(() {
          _savingReply = false;
          _editingReviewId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu phản hồi thành công'),
            backgroundColor: _primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingReply = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                      icon: const Icon(Icons.arrow_back, color: _primary),
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
              child: StreamBuilder<List<Review>>(
                stream: _reviewService.getAllReviewsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi tải dữ liệu: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final allReviews = snapshot.data ?? [];
                  final filtered = _filterReviews(allReviews);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      _buildTabBar(),
                      const SizedBox(height: 20),
                      _buildStatsRow(allReviews),
                      const SizedBox(height: 24),
                      ...filtered.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildReviewCard(r),
                          )),
                      if (filtered.isEmpty)
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
                  );
                },
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

  Widget _buildStatsRow(List<Review> reviews) {
    final avg = _avgRating(reviews);
    final total = reviews.length;
    final repliedCount = reviews.where((r) => r.replied).length;
    final replyRate = total == 0 ? 0 : (repliedCount * 100 ~/ total);
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final newCount = reviews.where((r) => r.createdAt.isAfter(weekAgo)).length;
    final stats = [
      {'label': 'Trung bình', 'value': total == 0 ? '–' : avg.toStringAsFixed(1), 'color': _primary, 'star': true},
      {'label': 'Tổng số', 'value': '$total', 'color': _onSurface, 'star': false},
      {'label': 'Mới (7 ngày)', 'value': '$newCount', 'color': _secondary, 'star': false},
      {'label': 'Tỉ lệ phản hồi', 'value': '$replyRate%', 'color': _primary, 'star': false},
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

  Widget _buildReviewCard(Review review) {
    final userName = review.userName;
    final avatarUrl = review.userAvatar;
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
              Expanded(
                child: Row(
                  children: [
                    ClipOval(
                      child: avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: _lightGreen,
                                child: const Icon(Icons.person, color: _primary),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: _lightGreen,
                              child: const Icon(Icons.person, color: _primary),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _timeAgo(review.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: const Color(0xFFFFB300),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review.review,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: _onSurface,
            ),
          ),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = review.images[index];
                  return GestureDetector(
                    onTap: () => _showImageDialog(url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          color: _lightGreen,
                          child: const Icon(Icons.broken_image,
                              color: _primary, size: 28),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
                const Icon(Icons.sports_tennis,
                    size: 14, color: _secondary),
                const SizedBox(width: 6),
                Text(
                  review.fieldName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _secondary,
                  ),
                ),
              ],
            ),
          ),
          if (review.replied && _editingReviewId != review.id) ...[
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
                    'PHẢN HỒI CỦA ADMIN:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.reply!,
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
          if (_editingReviewId == review.id)
            _buildInlineReplyEditor(review)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _showDeleteDialog(review),
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
                  onTap: () => _startEditing(review),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: review.replied
                          ? null
                          : const LinearGradient(
                              colors: [_primary, _darkGreen],
                            ),
                      color: review.replied ? const Color(0xFFF0F0F0) : null,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: review.replied
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
                      review.replied ? 'Chỉnh sửa' : 'Phản hồi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: review.replied ? _onSurface : Colors.white,
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

  void _showImageDialog(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image,
                      color: Colors.white, size: 48),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineReplyEditor(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NỘI DUNG PHẢN HỒI',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _onSurfaceVariant,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _activeReplyController,
          maxLines: 4,
          autofocus: true,
          style: const TextStyle(fontSize: 14, color: _onSurface),
          decoration: InputDecoration(
            hintText: 'Nhập phản hồi của bạn...',
            hintStyle:
                TextStyle(color: _onSurfaceVariant.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _primary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _savingReply ? null : _cancelEditing,
              child: const Text('Hủy',
                  style: TextStyle(color: _onSurfaceVariant)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed:
                  _savingReply ? null : () => _saveReply(review),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _savingReply
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog(Review review) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool deleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Xóa đánh giá',
              style: TextStyle(fontWeight: FontWeight.bold, color: _onSurface),
            ),
            content: const Text(
              'Bạn có chắc chắn muốn xóa đánh giá này không? Hành động này không thể hoàn tác.',
              style: TextStyle(color: _onSurfaceVariant, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: deleting ? null : () => Navigator.pop(ctx),
                child: const Text('Hủy',
                    style: TextStyle(color: _onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: deleting
                    ? null
                    : () async {
                        setDialogState(() => deleting = true);
                        try {
                          await _reviewService.deleteReview(review.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa đánh giá'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => deleting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: deleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Xóa'),
              ),
            ],
          ),
        );
      },
    );
  }
}
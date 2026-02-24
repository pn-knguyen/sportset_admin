import 'package:flutter/material.dart';
import '../../../widgets/common_bottom_nav.dart';

// 3.8. Trang quản lý đánh giá
class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewList(),
                _buildReviewList(),
                _buildReviewList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: SizedBox(
        height: 40,
        child: Stack(
          children: [
            Positioned(
              left: -8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0C1C46),
                    size: 24,
                  ),
                ),
              ),
            ),
            const Center(
              child: Text(
                'Quản Lý Đánh Giá',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C1C46),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFFFF8F6),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildTab('Tất cả', 0),
            _buildTab('Chưa phản hồi', 1),
            _buildTab('Đã phản hồi', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF0C1C46) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
      children: [
        _buildReviewCard(
          name: 'Lê Minh Anh',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAa6ogy6_V5b8NcsjkE0McJ3udKYYawJOjapLA_W0x64MJrPDoJHOBzn5O7S-dmCml_pUHIm7IkzV0o99fPtQAknyKZmv7acQeQgQ5_j15fXj1R8a3YhcJlCkhidDgbdFATWjfiD3-I7hiBTZMSLsl0FCzjeeQagV3FxJWammWD16KrRBpx0-ZZNBYCGu8BhBn99PK0B_rFYlLkMyyJwu4mw_j2sMt-AG4rvjDOiPXZ38bGPoueIjrP1CUMmIbx6iK389p-zhfjf0v_',
          rating: 5,
          time: '10:30',
          date: '20/10/2023',
          comment: 'Sân đẹp, ánh sáng tốt, mặt cỏ êm ái. Nhân viên phục vụ nhiệt tình. Sẽ quay lại ủng hộ dài dài!',
          facility: 'Sân Chảo Lửa - Sân A1',
          icon: Icons.stadium,
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Trần Văn Bảo',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD2WbmxaxJh1iIt0YZ6H_RShn1eZVGkyP4D3tmgkbiilB55g1sKqb43b-ctuOtJhJinv3fKvdaeZ_6Ya8zBiL-rDAJ6DRExsrkp1pVFgdGP4FUF70zYJg4-kkXxjY-ziHfmR_1WsCoNKaM1vSrYf1x420L08KGlpjmnkRVASv3oTtEo0YubtHVq85Wuz2yV-N97sHXa8blsxZ-8tdPJE32poxV43Gg4mRILIe3oXG8pi3PSEUaDcKcMrMXPQHgk61VXEYv59buvn_w2',
          rating: 4,
          time: '09:15',
          date: '19/10/2023',
          comment: 'Chất lượng mặt sân khá ổn, tuy nhiên khu vực để xe hơi chật chội vào giờ cao điểm. Mong ban quản lý cải thiện.',
          facility: 'Sân K34 - Sân 7',
          icon: Icons.sports_soccer,
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Nguyễn Thu Hà',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApPrDcjBKqE3W-m475GdytKSSl7Jpq_aoAXwqlpWS9XxzWE-Dr_MNEkqhQvnwGa_pdQQkz3f4uXHc-a6QwypEVjnQPqYED3hPRMVfGC71BOr07oPPQYiLeIGF3VjC-Io2Cad3nDM_ptbkUCFgRLjVtxma39s0Qb9YpK-35cJyS9nGfG-8dKMAXh65289WZUNk045k4krGNdlT4CQhrr2BnO0BUg72andzMaz5-5rv_MRyqnzKvpouTwAaKg7Kx3h0Bqv9UxNpZojAK',
          rating: 5,
          time: '18:45',
          date: '18/10/2023',
          comment: 'Dịch vụ tuyệt vời! Mình quên đồ ở sân mà các bạn nhân viên giữ giúp rất cẩn thận. Cảm ơn team SPORTSET nhiều! ❤️',
          facility: 'Sân Tennis T2',
          icon: Icons.sports_tennis,
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Phạm Tuấn Hùng',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDbi376epVpD3GuPWMN57YjvCYAvXpWpqn49zVvEVETrfPcbfLLfno34qEQ00bAFuy-UP90b_a9UFz2wj3RspiZW1NpAsZ4wMfvpc3UiMSJkvRFjuyFF_cJEWi4HPdF9dldp7NPfc2RgGQsRoy4zZ-apgdKQvxe8BOBq7bTgyHGYNwYF2yOrQCEqF_Hj9hGkQ6wtql-26aQzRlw-fz1fgcAb54FrV95ahhD4UCCO_AaEgR-6BqhxEdouV89nXnzuAfRs7VF-SSPzgHk',
          rating: 5,
          time: '14:20',
          date: '17/10/2023',
          comment: 'Mọi thứ đều ổn, giá cả hợp lý so với mặt bằng chung.',
          facility: 'Sân Cầu Lông C1',
          icon: Icons.sports_volleyball,
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String avatar,
    required int rating,
    required String time,
    required String date,
    required String comment,
    required String facility,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Icon(Icons.person, color: Colors.white),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0C1C46),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                size: 16,
                                color: index < rating ? const Color(0xFFFF9800) : const Color(0xFFD1D5DB),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  facility,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF9FAFB), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFF87171)),
                    onPressed: () {
                      _showDeleteDialog();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.reply, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Phản hồi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xóa đánh giá',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C1C46),
            ),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn xóa đánh giá này không?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa đánh giá'),
                      backgroundColor: Color(0xFF0C1C46),
                    ),
                  );
                },
                child: const Text(
                  'Xóa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


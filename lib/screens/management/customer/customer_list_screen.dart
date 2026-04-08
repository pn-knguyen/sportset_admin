import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  static const _outline = Color(0xFF6F7A6B);
  static const _outlineVariant = Color(0xFFBECAB9);
  static const _surfaceContainerLow = Color(0xFFF3F3F3);

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _customers = [
    {
      'name': 'Lê Minh Anh',
      'phone': '0987 654 321',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'tier': 'gold',
      'tierLabel': 'Vàng',
      'orders': 12,
      'totalSpent': '2.400.000đ',
    },
    {
      'name': 'Trần Văn Nam',
      'phone': '0912 345 678',
      'avatar': 'https://i.pravatar.cc/150?img=13',
      'tier': 'silver',
      'tierLabel': 'Bạc',
      'orders': 5,
      'totalSpent': '850.000đ',
    },
    {
      'name': 'Nguyễn Thu Hà',
      'phone': '0909 888 777',
      'avatar': 'https://i.pravatar.cc/150?img=9',
      'tier': 'diamond',
      'tierLabel': 'Kim cương',
      'orders': 48,
      'totalSpent': '15.200.000đ',
    },
    {
      'name': 'Phạm Quốc Hưng',
      'phone': '0933 111 222',
      'avatar': '',
      'initials': 'PQ',
      'tier': 'bronze',
      'tierLabel': 'Đồng',
      'orders': 2,
      'totalSpent': '300.000đ',
    },
    {
      'name': 'Vũ Thị Mai',
      'phone': '0945 666 999',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'tier': 'silver',
      'tierLabel': 'Bạc',
      'orders': 8,
      'totalSpent': '1.250.000đ',
    },
  ];
  List<Map<String, dynamic>> get _filtered {
    final query = _searchController.text.toLowerCase();
    return _customers.where((c) {
      final matchFilter =
          _selectedFilter == 'all' || c['tier'] == _selectedFilter;
      final matchQuery = query.isEmpty ||
          (c['name'] as String).toLowerCase().contains(query) ||
          (c['phone'] as String).contains(query);
      return matchFilter && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: _darkGreen,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Danh Sách Khách Hàng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  ..._filtered.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCustomerCard(c),
                      )),
                  if (_filtered.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Text(
                          'Không tìm thấy khách hàng',
                          style: TextStyle(
                            fontSize: 14,
                            color: _onSurfaceVariant.withValues(alpha: 0.7),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tên hoặc SĐT khách hàng...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: _outline.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(Icons.search, color: _outline, size: 22),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: const TextStyle(fontSize: 14, color: _onSurface),
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = [
      ('all', 'Tất cả'),
      ('diamond', 'Kim cương'),
      ('gold', 'Vàng'),
      ('silver', 'Bạc'),
      ('bronze', 'Đồng'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final active = _selectedFilter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? _primary : const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : _onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final tier = customer['tier'] as String;
    final tierLabel = customer['tierLabel'] as String;
    final avatar = customer['avatar'] as String? ?? '';
    final initials = customer['initials'] as String? ??
        (customer['name'] as String)
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s[0])
            .join()
            .toUpperCase();

    final tierStyle = _getTierStyle(tier);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.customerDetail),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _primary.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: avatar.isNotEmpty
                        ? Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildInitialsAvatar(initials),
                          )
                        : _buildInitialsAvatar(initials),
                  ),
                ),
                if (tier == 'diamond')
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF994700),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tierStyle['bg'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tierLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: tierStyle['text'] as Color,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    customer['phone'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStat('Đơn: ${customer['orders']}'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '|',
                          style: TextStyle(
                              color: _outlineVariant.withValues(alpha: 0.6)),
                        ),
                      ),
                      _buildStat(customer['totalSpent'] as String),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: _outlineVariant,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: _lightGreen,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _darkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _outline,
        ),
      ),
    );
  }

  Map<String, Color> _getTierStyle(String tier) {
    switch (tier) {
      case 'diamond':
        return {
          'bg': const Color(0xFFE5F1FF),
          'text': const Color(0xFF0061A4),
        };
      case 'gold':
        return {
          'bg': const Color(0xFFFFF3CD),
          'text': const Color(0xFF994700),
        };
      case 'silver':
        return {
          'bg': const Color(0xFFE2E2E2),
          'text': _onSurfaceVariant,
        };
      case 'bronze':
        return {
          'bg': const Color(0xFFFFDBC8),
          'text': const Color(0xFF753400),
        };
      default:
        return {
          'bg': const Color(0xFFE2E2E2),
          'text': _onSurfaceVariant,
        };
    }
  }
}
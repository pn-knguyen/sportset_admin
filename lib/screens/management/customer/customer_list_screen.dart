import 'package:flutter/material.dart';
import 'package:sportset_admin/models/customer.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/customer_service.dart';
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

  final TextEditingController _searchController = TextEditingController();
  final CustomerService _customerService = CustomerService();

  List<Customer> _filter(List<Customer> all) {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return all;
    return all.where((c) {
      return c.fullName.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          c.phone.contains(query);
    }).toList();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 365) return '${diff.inDays ~/ 365} năm trước';
    if (diff.inDays >= 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7} tuần trước';
    if (diff.inDays >= 1) return '${diff.inDays} ngày trước';
    if (diff.inHours >= 1) return '${diff.inHours} giờ trước';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} phút trước';
    return 'Vừa đăng ký';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: StreamBuilder<List<Customer>>(
                stream: _customerService.getAllCustomersStream(),
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
                  final all = snapshot.data ?? [];
                  final filtered = _filter(all);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _buildStatsRow(all),
                      const SizedBox(height: 16),
                      ...filtered.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCustomerCard(c),
                          )),
                      if (filtered.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 48),
                            child: Text(
                              'Không tìm thấy khách hàng',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    _onSurfaceVariant.withValues(alpha: 0.7),
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
          hintText: 'Tìm kiếm tên, email hoặc số điện thoại...',
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

  Widget _buildStatsRow(List<Customer> all) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final newCount = all.where((c) => c.createdAt.isAfter(weekAgo)).length;
    return Row(
      children: [
        _buildStatCard('Tổng khách', '${all.length}', Icons.people_outline, _primary),
        const SizedBox(width: 12),
        _buildStatCard('Mới (7 ngày)', '$newCount', Icons.person_add_outlined, const Color(0xFF18A5A7)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.customerDetail,
        arguments: customer.uid,
      ),
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
            ClipOval(
              child: customer.photoUrl.isNotEmpty
                  ? Image.network(
                      customer.photoUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildInitialsAvatar(customer.initials),
                    )
                  : _buildInitialsAvatar(customer.initials),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (customer.email.isNotEmpty)
                    Text(
                      customer.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (customer.phone.isNotEmpty) ...[
                        const Icon(Icons.phone_outlined,
                            size: 13, color: _outline),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.access_time_outlined,
                          size: 13, color: _outlineVariant),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(customer.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: _outlineVariant,
                        ),
                      ),
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
      width: 52,
      height: 52,
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
}

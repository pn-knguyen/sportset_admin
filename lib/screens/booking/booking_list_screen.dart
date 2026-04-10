import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';

// Design tokens
const _primary = Color(0xFF4CAF50);
const _secondary = Color(0xFF18A5A7);
const _darkGreen = Color(0xFF2E7D32);
const _lightGreen = Color(0xFFE8F5E9);
const _onSurface = Color(0xFF1A1C1C);
const _onSurfaceVariant = Color(0xFF5C615A);
const _systemGray = Color(0xFF9E9E9E);

class BookingListScreen extends StatefulWidget {
  final bool showBottomNav;

  const BookingListScreen({super.key, this.showBottomNav = true});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  int _currentNavIndex = 2;
  late DateTime _selectedDate;
  int _selectedTabIndex = 0;
  final Map<String, Map<String, String>> _customerCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<DateTime> get _weekDates {
    final today = DateTime.now();
    return List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));
  }

  String get _tabStatus {
    switch (_selectedTabIndex) {
      case 0:
        return 'pending';
      case 1:
        return 'confirmed';
      default:
        return 'cancelled';
    }
  }

  bool _matchesSelectedDate(Map<String, dynamic> booking) {
    final raw = booking['selectedDate'];
    if (raw is! Map) return false;
    final bookingDay = int.tryParse(raw['date']?.toString() ?? '');
    final bookingMonth = int.tryParse(raw['month']?.toString() ?? '');
    final bookingYear = int.tryParse(raw['year']?.toString() ?? '');
    return bookingDay == _selectedDate.day &&
        bookingMonth == _selectedDate.month &&
        (bookingYear == null || bookingYear == _selectedDate.year);
  }

  Future<Map<String, String>> _getCustomerInfo(String userId) async {
    if (_customerCache.containsKey(userId)) return _customerCache[userId]!;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();
      final data = doc.data() ?? {};
      final info = {
        'name': data['fullName']?.toString() ?? 'Khách hàng',
        'phone': data['phone']?.toString() ?? '',
      };
      _customerCache[userId] = info;
      return info;
    } catch (_) {
      return {'name': 'Khách hàng', 'phone': ''};
    }
  }

  String _formatCurrency(dynamic value) {
    final int amount = value is int
        ? value
        : (value is num
            ? value.toInt()
            : int.tryParse(value?.toString() ?? '') ?? 0);
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }
    return '${buffer.toString()}đ';
  }

  String _dayLabel(DateTime date) {
    const labels = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
    return labels[date.weekday % 7];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;

  Future<void> _confirmBooking(String docId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update({'status': 'confirmed'});
  }

  Future<void> _cancelBooking(String docId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update({'status': 'cancelled'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNav() : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('status', isEqualTo: _tabStatus)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Không tải được dữ liệu.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filtered = docs
                      .where((doc) => _matchesSelectedDate(doc.data()))
                      .toList()
                    ..sort((a, b) {
                      final aTs = a.data()['createdAt'];
                      final bTs = b.data()['createdAt'];
                      if (aTs is Timestamp && bTs is Timestamp) {
                        return bTs.compareTo(aTs);
                      }
                      return 0;
                    });

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildBookingCard(doc.id, doc.data()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: _darkGreen),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Text(
                      'Quản lý Đơn đặt',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _darkGreen,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: _darkGreen),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: _darkGreen),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _weekDates.length,
                itemBuilder: (context, index) {
                  final date = _weekDates[index];
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, DateTime.now());
                  return Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _primary
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? _primary
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _primary.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isToday ? 'HN' : _dayLabel(date),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : _onSurfaceVariant,
                                letterSpacing: isSelected ? 0.5 : 0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 18,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                color: isSelected ? Colors.white : _onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTab(0, 'Chờ xác nhận'),
                  _buildTab(1, 'Đã xác nhận'),
                  _buildTab(2, 'Lịch sử'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? _primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _primary : _onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(String docId, Map<String, dynamic> data) {
    final userId = data['userId']?.toString() ?? '';
    final courtName = data['courtName']?.toString() ?? 'Sân thể thao';
    final subCourtName = data['subCourtName']?.toString() ?? '';
    final totalPrice = data['totalPrice'];
    final duration = data['duration']?.toString() ?? '';
    final slot = data['selectedSlot'];
    final startTime = (slot is Map) ? slot['startTime']?.toString() ?? '' : '';
    final endTime = (slot is Map) ? slot['endTime']?.toString() ?? '' : '';
    final timeText = (startTime.isNotEmpty && endTime.isNotEmpty)
        ? '$startTime - $endTime'
        : '';
    final selectedDateMap = data['selectedDate'];
    final dateText = (selectedDateMap is Map)
        ? '${selectedDateMap['day'] ?? ''}, ${selectedDateMap['date'] ?? ''}/${selectedDateMap['month'] ?? ''}'
        : '';
    final createdAt = data['createdAt'];
    final isNew = createdAt is Timestamp &&
        DateTime.now().difference(createdAt.toDate()).inHours < 2;
    final isPending = _selectedTabIndex == 0;

    return FutureBuilder<Map<String, String>>(
      future: userId.isNotEmpty
          ? _getCustomerInfo(userId)
          : Future.value({'name': 'Khách hàng', 'phone': ''}),
      builder: (context, snap) {
        final customerName = snap.data?['name'] ?? 'Khách hàng';
        final phone = snap.data?['phone'] ?? '';

        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.bookingDetail,
            arguments: {
              'bookingId': docId,
              'bookingData': data,
              'customerName': customerName,
              'customerPhone': phone,
            },
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: _lightGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 24,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                              ),
                            ),
                            if (phone.isNotEmpty)
                              Text(
                                phone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.sports_soccer_rounded,
                            'Sân: ',
                            subCourtName.isNotEmpty
                                ? '$courtName - $subCourtName'
                                : courtName,
                          ),
                          if (timeText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.schedule_rounded,
                              'Thời gian: ',
                              duration.isNotEmpty
                                  ? '$timeText  ($duration)'
                                  : timeText,
                            ),
                          ],
                          if (dateText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              Icons.calendar_today_rounded,
                              'Ngày: ',
                              dateText,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng thanh toán:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _formatCurrency(totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                    if (isPending) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _cancelBooking(docId),
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE8E8E8).withValues(alpha: 0.8),
                                foregroundColor: _onSurface,
                                side: BorderSide.none,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Hủy đơn',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_darkGreen, _primary],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primary.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _confirmBooking(docId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Xác nhận',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (isNew)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'MỚI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _darkGreen,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _secondary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    const labels = ['Chờ xác nhận', 'Đã xác nhận', 'Lịch sử'];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: _lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có đơn ${labels[_selectedTabIndex].toLowerCase()}',
            style: const TextStyle(
              fontSize: 15,
              color: _onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'trong ngày ${_selectedDate.day}/${_selectedDate.month}',
            style: const TextStyle(fontSize: 13, color: _onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined,
                  'Trang chủ', AppRoutes.home),
              _buildNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined,
                  'Quản lý', AppRoutes.management),
              _buildNavItem(
                  2,
                  Icons.confirmation_number_rounded,
                  Icons.confirmation_number_outlined,
                  'Đơn đặt',
                  AppRoutes.bookings),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded,
                  'Tài khoản', AppRoutes.account),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon,
      String label, String route) {
    final isActive = _currentNavIndex == index;
    final color = isActive ? _primary : _systemGray;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isActive) return;
          setState(() => _currentNavIndex = index);
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, size: 26, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
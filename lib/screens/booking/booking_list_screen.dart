import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class BookingListScreen extends StatefulWidget {
  final bool showBottomNav;

  const BookingListScreen({super.key, this.showBottomNav = true});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  static const Color _navyColor = Color(0xFF0C1C46);
  static const Color _orangeColor = Color(0xFFFF9800);
  final int _currentNavIndex = 2;

  late DateTime _selectedDate;
  int _selectedTabIndex = 0; // 0: confirmed, 1: cancelled

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

  String get _tabStatus => _selectedTabIndex == 0 ? 'confirmed' : 'cancelled';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
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
                    child: CircularProgressIndicator(color: _orangeColor),
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
      bottomNavigationBar:
          widget.showBottomNav ? CommonBottomNav(currentIndex: _currentNavIndex) : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Quản Lý Đơn Đặt',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            // Date selector
            SizedBox(
              height: 84,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: _weekDates.length,
                itemBuilder: (context, index) {
                  final date = _weekDates[index];
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, DateTime.now());

                  return Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 64,
                        decoration: BoxDecoration(
                          color: isSelected ? _navyColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? _navyColor
                                : Colors.grey.withValues(alpha: 0.1),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _navyColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
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
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey[600],
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
            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Đã xác nhận'),
                  _buildTab(1, 'Đã hủy'),
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
                color: isSelected ? _orangeColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? _orangeColor : Colors.grey[400],
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Customer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: _navyColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 20, color: _navyColor),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (phone.isNotEmpty)
                              Text(
                                phone,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _orangeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'MỚI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _orangeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Booking details
                Column(
                  children: [
                    _buildDetailRow(
                      Icons.stadium,
                      subCourtName.isNotEmpty ? '$courtName - $subCourtName' : courtName,
                    ),
                    if (timeText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.schedule,
                        duration.isNotEmpty ? '$timeText  |  $duration' : timeText,
                      ),
                    ],
                    if (dateText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.calendar_today, dateText),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 16),
                // Price + arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng thanh toán',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _orangeColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final labels = ['Đã xác nhận', 'Đã hủy'];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Không có đơn ${labels[_selectedTabIndex].toLowerCase()}',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'trong ngày ${_selectedDate.day}/${_selectedDate.month}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
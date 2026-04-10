import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF18A5A7);
  static const _tertiary = Color(0xFF994700);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF3F4A3C);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatCurrency(dynamic value) {
    final int amount = value is int
        ? value
        : (value is num
            ? value.toInt()
            : int.tryParse(value?.toString() ?? '') ?? 0);
    if (amount == 0) return '0đ';
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '$bufferđ';
  }

  String _formatShortCurrency(dynamic value) {
    final int amount = value is int
        ? value
        : (value is num
            ? value.toInt()
            : int.tryParse(value?.toString() ?? '') ?? 0);
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}Mđ';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(0)}Kđ';
    }
    return '$amountđ';
  }

  String _initials(String fullName) {
    final parts =
        fullName.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<Map<String, dynamic>> _loadAll(String uid) async {
    final customerFuture =
        _firestore.collection('customers').doc(uid).get();
    final bookingsFuture = _firestore
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .get();

    final results = await Future.wait([customerFuture, bookingsFuture]);
    final customerDoc =
        results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final bookingsSnap =
        results[1] as QuerySnapshot<Map<String, dynamic>>;

    final customer = customerDoc.data() ?? {};
    final bookings = bookingsSnap.docs.map((d) {
      final data = d.data();
      data['_id'] = d.id;
      return data;
    }).toList()
      ..sort((a, b) {
        final aTs = a['createdAt'];
        final bTs = b['createdAt'];
        if (aTs is Timestamp && bTs is Timestamp) {
          return bTs.compareTo(aTs);
        }
        return 0;
      });

    final completed = bookings
        .where((b) =>
            b['status'] == 'completed' || b['status'] == 'confirmed')
        .toList();
    final totalSpent = completed.fold<int>(
        0,
        (acc, b) =>
            acc +
            (b['totalPrice'] is int
                ? b['totalPrice'] as int
                : (b['totalPrice'] is num
                    ? (b['totalPrice'] as num).toInt()
                    : int.tryParse(
                            b['totalPrice']?.toString() ?? '') ??
                        0)));

    return {
      'customer': customer,
      'bookings': bookings,
      'totalSpent': totalSpent,
      'totalOrders': bookings.length,
      'completed': completed.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final uid =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadAll(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi tải dữ liệu: ${snapshot.error}',
                style:
                    const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            );
          }
          final data = snapshot.data ?? {};
          final customer = data['customer'] as Map<String, dynamic>? ?? {};
          final bookings =
              data['bookings'] as List<Map<String, dynamic>>? ?? [];
          final totalSpent = data['totalSpent'] as int? ?? 0;
          final totalOrders = data['totalOrders'] as int? ?? 0;
          final completed = data['completed'] as int? ?? 0;
          final name =
              customer['fullName']?.toString() ?? 'Khách hàng';
          final phone = customer['phone']?.toString() ?? '';
          final email = customer['email']?.toString() ?? '';
          final photoUrl = customer['photoUrl']?.toString() ?? '';

          return Stack(
            children: [
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_lightGreen, Colors.white],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: 64, left: 24, right: 24, bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(
                          name, phone, email, photoUrl),
                      const SizedBox(height: 32),
                      _buildStatsSection(
                          totalSpent, totalOrders, completed),
                      const SizedBox(height: 40),
                      _buildBookingHistorySection(bookings),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF006E1C)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Chi Tiết Khách Hàng',
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
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildContactButton(phone),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
      String name, String phone, String email, String photoUrl) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? Image.network(
                          photoUrl,
                          width: 128,
                          height: 128,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _buildInitialsWidget(name),
                        )
                      : _buildInitialsWidget(name),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.verified,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _onSurface,
              letterSpacing: -0.5,
            ),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phone,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onSurfaceVariant,
              ),
            ),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              style: TextStyle(
                fontSize: 12,
                color: _onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialsWidget(String name) {
    return Container(
      width: 128,
      height: 128,
      color: _lightGreen,
      child: Center(
        child: Text(
          _initials(name),
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: _darkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      int totalSpent, int totalOrders, int completed) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Chi tiêu',
            value: _formatShortCurrency(totalSpent),
            valueColor: _primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Đơn đặt',
            value: '$totalOrders đơn',
            valueColor: _secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Hoàn thành',
            value: '$completed',
            valueColor: _tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistorySection(List<Map<String, dynamic>> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lịch sử đặt sân',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _onSurface,
              ),
            ),
            Text(
              '${bookings.length} đơn',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (bookings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'Chưa có lịch đặt sân nào',
                style: TextStyle(
                    fontSize: 14,
                    color: _onSurfaceVariant.withValues(alpha: 0.7)),
              ),
            ),
          )
        else
          ...bookings.map((booking) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildBookingCard(booking),
              )),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status']?.toString() ?? '';
    final isCompleted =
        status == 'completed' || status == 'confirmed';
    final isCancelled = status == 'cancelled';

    final courtName =
        booking['courtName']?.toString() ?? 'Sân thể thao';
    final subCourtName =
        booking['subCourtName']?.toString() ?? '';
    final displayName = subCourtName.isNotEmpty
        ? '$courtName - $subCourtName'
        : courtName;

    final slot = booking['selectedSlot'];
    final startTime =
        (slot is Map) ? slot['startTime']?.toString() ?? '' : '';
    final endTime =
        (slot is Map) ? slot['endTime']?.toString() ?? '' : '';
    final timeText = (startTime.isNotEmpty && endTime.isNotEmpty)
        ? '$startTime - $endTime'
        : '';

    final selectedDateMap = booking['selectedDate'];
    final dateText = (selectedDateMap is Map)
        ? '${selectedDateMap['date'] ?? ''}/${selectedDateMap['month'] ?? ''}'
        : '';

    final timeDate = [timeText, dateText]
        .where((s) => s.isNotEmpty)
        .join(', ');

    String statusLabel;
    Color statusBg;
    Color statusText;
    if (isCompleted) {
      statusLabel = 'Hoàn thành';
      statusBg = const Color(0xFF94F990).withValues(alpha: 0.3);
      statusText = const Color(0xFF005313);
    } else if (isCancelled) {
      statusLabel = 'Đã hủy';
      statusBg = const Color(0xFFFFDAD6).withValues(alpha: 0.5);
      statusText = const Color(0xFF93000A);
    } else {
      statusLabel = 'Chờ xác nhận';
      statusBg = const Color(0xFFFFF3CD);
      statusText = _tertiary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports, color: _primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusText,
                        ),
                      ),
                    ),
                  ],
                ),
                if (timeDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    timeDate,
                    style: const TextStyle(
                        fontSize: 12, color: _onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(booking['totalPrice']),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isCompleted ? _primary : _onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(String phone) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primary, _darkGreen],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(phone.isNotEmpty
                      ? 'Đang gọi cho $phone...'
                      : 'Khách hàng chưa có số điện thoại'),
                ),
              );
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon:
                const Icon(Icons.phone, color: Colors.white, size: 20),
            label: const Text(
              'Liên hệ khách hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


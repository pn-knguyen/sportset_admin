import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/models/voucher.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/voucher_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class VoucherDetailScreen extends StatefulWidget {
  const VoucherDetailScreen({super.key});

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final VoucherService _voucherService = VoucherService();
  final AccessControlService _accessControlService = AccessControlService();
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  static const _secondary = Color(0xFF00696B);

  String? _voucherId;
  bool _didReadArgs = false;
  bool _canEdit = false;
  List<Map<String, dynamic>> _usageHistory = [];
  bool _historyLoading = false;
  int? _totalUsedCount;
  StreamSubscription<QuerySnapshot>? _bookingsCountSub;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    setState(() {
      _canEdit = _accessControlService.can(permissionMap, 'vouchers', 'update');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) {
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    _voucherId = arguments?['id'] as String?;
    _didReadArgs = true;
    if (_voucherId != null) {
      _loadUsageHistory(_voucherId!);
      _subscribeToBookingsCount(_voucherId!);
    }
  }

  void _subscribeToBookingsCount(String voucherId) {
    _bookingsCountSub?.cancel();
    _bookingsCountSub = FirebaseFirestore.instance
        .collection('bookings')
        .where('voucherId', isEqualTo: voucherId)
        .snapshots()
        .listen((snap) {
      if (mounted) {
        final count = snap.docs
            .where((d) => d.data()['status'] != 'cancelled')
            .length;
        setState(() => _totalUsedCount = count);
      }
    });
  }

  @override
  void dispose() {
    _bookingsCountSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUsageHistory(String voucherId) async {
    if (!mounted) return;
    setState(() => _historyLoading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('voucherId', isEqualTo: voucherId)
          .get();

      final items = snap.docs
          .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
          .where((item) => item['status'] != 'cancelled')
          .toList();
      items.sort((a, b) {
        final aT = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bT = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bT.compareTo(aT);
      });
      final totalCount = items.length;
      final recent = items.take(20).toList();

      final cache = <String, String>{};
      for (final item in recent) {
        final userId = item['userId']?.toString() ?? '';
        if (userId.isNotEmpty) {
          if (!cache.containsKey(userId)) {
            final doc = await FirebaseFirestore.instance
                .collection('customers')
                .doc(userId)
                .get();
            cache[userId] =
                doc.data()?['fullName']?.toString() ?? 'Kh\u00e1ch h\u00e0ng';
          }
          item['customerName'] = cache[userId]!;
        } else {
          item['customerName'] = 'Kh\u00e1ch h\u00e0ng';
        }
      }
      if (mounted) {
        setState(() {
          _usageHistory = recent;
          _totalUsedCount = totalCount;
          _historyLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  String _statusText(Voucher voucher) {
    switch (voucher.status) {
      case 'active':
        return 'Đang hoạt động';
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ended':
        return 'Đã kết thúc';
      default:
        return 'Không xác định';
    }
  }

  String _formatCompactMoney(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    Widget header = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 20, 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  size: 22, color: _onSurfaceVariant),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Chi Tiết Voucher',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkGreen,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );

    Widget bg = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lightGreen, Colors.white],
        ),
      ),
    );

    if (_voucherId == null) {
      return Scaffold(
        body: Stack(
          children: [
            bg,
            Column(children: [
              header,
              const Expanded(child: Center(
                child: Text('Không tìm thấy voucher'),
              )),
            ]),
          ],
        ),
        bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
      );
    }

    return StreamBuilder<Voucher?>(
      stream: _voucherService.getVoucherByIdStream(_voucherId!),
      builder: (context, snapshot) {
        return Scaffold(
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
                header,
                Expanded(child: _buildBody(snapshot)),
              ],
            ),
          ),
          bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<Voucher?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Lỗi tải dữ liệu: ${snapshot.error}',
          textAlign: TextAlign.center,
        ),
      );
    }

    final voucher = snapshot.data;
    if (voucher == null) {
      return const Center(
        child: Text('Voucher không tồn tại'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(voucher),
          const SizedBox(height: 20),
          _buildInfoCard(voucher),
          const SizedBox(height: 24),
          _buildUsageSection(),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _darkGreen],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _canEdit
                  ? () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.voucherEdit,
                        arguments: {'id': voucher.id},
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: _canEdit
                    ? Colors.transparent
                    : Colors.grey.withValues(alpha: 0.5),
                foregroundColor:
                    _canEdit ? Colors.white : Colors.grey[400],
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                Icons.edit,
                size: 22,
                color: _canEdit ? Colors.white : Colors.grey[400],
              ),
              label: Text(
                'Chỉnh sửa voucher',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _canEdit ? Colors.white : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Voucher voucher) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MÃ CODE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      voucher.code,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: _darkGreen,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voucher.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusText(voucher),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: Colors.grey[100]),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Đã dùng',
                  '${_totalUsedCount ?? voucher.usedQuantity}',
                  suffix: 'lần',
                  valueColor: _onSurface,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: Colors.grey[100],
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              Expanded(
                child: _buildMetric(
                  'Tổng giảm',
                  voucher.discountType == 'percent'
                      ? '${voucher.discountValue.toStringAsFixed(0)}%'
                      : _formatCompactMoney(
                          (_totalUsedCount ?? voucher.usedQuantity) *
                              voucher.discountValue),
                  suffix: voucher.discountType == 'percent' ? '/đơn' : 'đ',
                  valueColor: _secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    String label,
    String value, {
    String? suffix,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(Voucher voucher) {
    final discountTypeLabel = voucher.discountType == 'percent'
        ? 'Theo phần trăm'
        : 'Số tiền cố định';
    final discountValueText = voucher.discountType == 'percent'
        ? '${voucher.discountValue.toStringAsFixed(0)}%'
        : _formatFullMoney(voucher.discountValue);
    String df(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.label_outline, 'Tên chương trình', voucher.title),
          _buildDivider(),
          _buildInfoRow(Icons.discount_outlined, 'Loại giảm giá', discountTypeLabel),
          _buildDivider(),
          _buildInfoRow(
            Icons.sell_outlined,
            'Giá trị giảm',
            discountValueText,
            highlight: true,
            highlightColor: const Color(0xFFBA1A1A),
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.shopping_cart_outlined,
            'Đơn tối thiểu',
            _formatFullMoney(voucher.minOrderValue),
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.date_range_outlined,
            'Thời gian áp dụng',
            '${df(voucher.startDate)}\n→ ${df(voucher.endDate)}',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.confirmation_number_outlined,
            'Giới hạn sử dụng',
            '${_totalUsedCount ?? voucher.usedQuantity}/${voucher.totalQuantity} lần',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.person_outline,
            'Giới hạn/người dùng',
            '${voucher.maxPerUser} lần',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.store_outlined,
            'Cơ sở áp dụng',
            voucher.facilityName.isEmpty ? 'Tất cả cơ sở' : voucher.facilityName,
          ),
          _buildDivider(),
          _buildInfoRow(
            voucher.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            'Trạng thái',
            voucher.isActive ? 'Kích hoạt' : 'Vô hiệu',
            highlight: true,
            highlightColor: voucher.isActive ? _primary : Colors.red,
          ),
        ],
      ),
    );
  }

  String _formatFullMoney(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}đ';
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
    Color highlightColor = _secondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: _onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _onSurfaceVariant,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: highlight ? highlightColor : _onSurface,
                height: 1.4,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: _darkGreen,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'S\u1eed d\u1ee5ng g\u1ea7n \u0111\u00e2y',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_historyLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: _primary),
            ),
          )
        else if (_usageHistory.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.history_rounded, size: 36, color: Color(0xFFB0BEC5)),
                SizedBox(height: 8),
                Text(
                  'Ch\u01b0a c\u00f3 l\u1ea7n s\u1eed d\u1ee5ng n\u00e0o',
                  style: TextStyle(color: _onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          )
        else
          ...(_usageHistory.map(_buildUsageItem)),
      ],
    );
  }

  Widget _buildUsageItem(Map<String, dynamic> item) {
    final customerName =
        item['customerName']?.toString() ?? 'Kh\u00e1ch h\u00e0ng';
    final createdAt = item['createdAt'];
    String timeText = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      timeText =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
    final bookingId = item['id']?.toString() ?? '';
    final shortId = bookingId.length > 8
        ? '#${bookingId.substring(0, 8).toUpperCase()}'
        : '#${bookingId.toUpperCase()}';
    final parts = customerName.trim().split(' ');
    final initials = parts.length == 1
        ? (customerName.length >= 2
            ? customerName.substring(0, 2).toUpperCase()
            : customerName.toUpperCase())
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _lightGreen,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeText.isNotEmpty ? '$shortId  \u2022  $timeText' : shortId,
                  style: TextStyle(
                    fontSize: 11,
                    color: _onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.grey[100]);
}

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
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _bgColor = const Color(0xFFFFF8F6);

  String? _voucherId;
  bool _didReadArgs = false;
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    setState(() {
      _canEdit = _accessControlService.can(permissionMap, 'vouchers', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'vouchers', 'delete');
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

  Color _statusColor(Voucher voucher) {
    switch (voucher.status) {
      case 'active':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'ended':
        return Colors.grey;
      default:
        return Colors.grey;
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

  String _discountDisplay(Voucher voucher) {
    if (voucher.discountType == 'percent') {
      return '-${voucher.discountValue.toStringAsFixed(0)}%';
    }
    return '-${_formatCompactMoney(voucher.discountValue)}';
  }

  String _totalReducedDisplay(Voucher voucher) {
    if (voucher.discountType == 'fixed') {
      final totalReduced = voucher.usedQuantity * voucher.discountValue;
      return _formatCompactMoney(totalReduced);
    }
    return '${voucher.discountValue.toStringAsFixed(0)}%/đơn';
  }

  List<_UsageHistoryItem> _buildFakeHistory(Voucher voucher) {
    final now = DateTime.now();
    return [
      _UsageHistoryItem(
        customerName: 'Hoàng Minh',
        orderCode: '#ORD-9921',
        timeLabel: '10:30 Hôm nay',
        avatarBg: Colors.blue.shade50,
        avatarFg: Colors.blue.shade600,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Thùy Linh',
        orderCode: '#ORD-9882',
        timeLabel: '14:15 Hôm qua',
        avatarBg: Colors.pink.shade50,
        avatarFg: Colors.pink.shade600,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Tuấn Anh',
        orderCode: '#ORD-9755',
        timeLabel: '09:20 ${now.day}/${now.month}',
        avatarBg: Colors.orange.shade50,
        avatarFg: Colors.orange.shade600,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Khánh Vân',
        orderCode: '#ORD-9630',
        timeLabel: '18:45 ${now.day - 2}/${now.month}',
        avatarBg: Colors.purple.shade50,
        avatarFg: Colors.purple.shade600,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Đức Huy',
        orderCode: '#ORD-9512',
        timeLabel: '08:00 ${now.day - 3}/${now.month}',
        avatarBg: Colors.teal.shade50,
        avatarFg: Colors.teal.shade600,
        reducedText: _discountDisplay(voucher),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_voucherId == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _bgColor,
          elevation: 0,
          scrolledUnderElevation: 2,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _navyColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Chi tiết voucher',
            style: TextStyle(
              color: _navyColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: false,
        ),
        body: const Center(
          child: Text('Không tìm thấy voucher'),
        ),
      );
    }

    return StreamBuilder<Voucher?>(
      stream: _voucherService.getVoucherByIdStream(_voucherId!),
      builder: (context, snapshot) {
        final voucher = snapshot.data;

        return Scaffold(
          backgroundColor: _bgColor,
          appBar: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            scrolledUnderElevation: 2,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: _navyColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Chi tiết voucher',
              style: TextStyle(
                color: _navyColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            centerTitle: false,
          ),
          body: _buildBody(snapshot),
          bottomNavigationBar: CommonBottomNav(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<Voucher?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(color: _orangeColor),
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

    final fakeHistory = _buildFakeHistory(voucher);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(voucher),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _navyColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Lịch sử sử dụng',
                style: TextStyle(
                  color: _navyColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...fakeHistory.map(_buildHistoryItem),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _orangeColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                backgroundColor: _canEdit ? Colors.transparent : Colors.grey.withValues(alpha: 0.5),
                foregroundColor: _canEdit ? Colors.white : Colors.grey[400],
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(Icons.edit_square, size: 22, color: _canEdit ? Colors.white : Colors.grey[400]),
              label: Text(
                'Chỉnh sửa voucher',
                style: TextStyle(
                  fontSize: 16,
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
    final statusColor = _statusColor(voucher);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    Text(
                      'Mã code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[400],
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          color: _orangeColor,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            voucher.code,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: _navyColor,
                              height: 1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _statusText(voucher),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey[100]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Đã dùng',
                  '${voucher.usedQuantity}',
                  suffix: 'lần',
                  valueColor: _navyColor,
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
                  _totalReducedDisplay(voucher),
                  valueColor: _orangeColor,
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

  Widget _buildHistoryItem(_UsageHistoryItem item) {
    final initials = _nameToInitials(item.customerName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.avatarBg,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: item.avatarFg,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.customerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.orderCode,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.timeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.reducedText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Giảm giá',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nameToInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class _UsageHistoryItem {
  final String customerName;
  final String orderCode;
  final String timeLabel;
  final Color avatarBg;
  final Color avatarFg;
  final String reducedText;

  const _UsageHistoryItem({
    required this.customerName,
    required this.orderCode,
    required this.timeLabel,
    required this.avatarBg,
    required this.avatarFg,
    required this.reducedText,
  });
}

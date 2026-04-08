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
        timeLabel: '14:30 - 24/05',
        avatarBg: _lightGreen,
        avatarFg: _darkGreen,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Thùy Linh',
        orderCode: '#ORD-9918',
        timeLabel: '10:15 - 24/05',
        avatarBg: Colors.teal.shade50,
        avatarFg: _secondary,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Tuấn Anh',
        orderCode: '#ORD-9915',
        timeLabel: '08:45 - 24/05',
        avatarBg: _lightGreen,
        avatarFg: _darkGreen,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Quang Huy',
        orderCode: '#ORD-9910',
        timeLabel: '19:20 - ${now.day - 1}/${now.month}',
        avatarBg: Colors.teal.shade50,
        avatarFg: _secondary,
        reducedText: _discountDisplay(voucher),
      ),
      _UsageHistoryItem(
        customerName: 'Minh Ngọc',
        orderCode: '#ORD-9905',
        timeLabel: '16:10 - ${now.day - 1}/${now.month}',
        avatarBg: _lightGreen,
        avatarFg: _darkGreen,
        reducedText: _discountDisplay(voucher),
      ),
    ];
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
                  color: _darkGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Lịch sử sử dụng',
                style: TextStyle(
                  color: _darkGreen,
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
                  '${voucher.usedQuantity}',
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
                  _totalReducedDisplay(voucher),
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

  Widget _buildHistoryItem(_UsageHistoryItem item) {
    final initials = _nameToInitials(item.customerName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.orderCode} • ${item.timeLabel}',
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
          const SizedBox(width: 12),
          Text(
            item.reducedText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFBA1A1A),
            ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Design tokens
const _primary = Color(0xFF4CAF50);
const _darkGreen = Color(0xFF2E7D32);
const _lightGreen = Color(0xFFE8F5E9);
const _onSurface = Color(0xFF1A1C1C);
const _onSurfaceVariant = Color(0xFF5C615A);
const _tertiary = Color(0xFF994700);
const _tertiaryFixed = Color(0xFFFFDBC8);

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late String _bookingId;
  late Map<String, dynamic> _bookingData;
  String _customerName = '';
  String _customerPhone = '';
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _bookingId = args['bookingId'] as String? ?? '';
      _bookingData = Map<String, dynamic>.from(
          args['bookingData'] as Map<String, dynamic>? ?? {});
      _customerName = args['customerName'] as String? ?? 'Khách hàng';
      _customerPhone = args['customerPhone'] as String? ?? '';
      if (_customerName == 'Khách hàng' || _customerName.isEmpty) {
        _fetchCustomerInfo();
      }
    }
  }

  Future<void> _fetchCustomerInfo() async {
    final userId = _bookingData['userId']?.toString() ?? '';
    if (userId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();
      final data = doc.data() ?? {};
      if (mounted) {
        setState(() {
          _customerName = data['fullName']?.toString() ?? 'Khách hàng';
          _customerPhone = data['phone']?.toString() ?? '';
        });
      }
    } catch (_) {}
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

  String get _status => _bookingData['status']?.toString() ?? 'pending';

  Map<String, dynamic> _statusConfig(String status) {
    switch (status) {
      case 'confirmed':
        return {
          'label': 'ĐÃ XÁC NHẬN',
          'color': _darkGreen,
          'bg': _lightGreen,
          'icon': Icons.check_circle_rounded,
        };
      case 'cancelled':
        return {
          'label': 'ĐÃ HỦY',
          'color': const Color(0xFFBA1A1A),
          'bg': const Color(0xFFFFDAD6),
          'icon': Icons.cancel_rounded,
        };
      default:
        return {
          'label': 'CHỜ XÁC NHẬN',
          'color': _tertiary,
          'bg': _tertiaryFixed,
          'icon': Icons.pending_rounded,
        };
    }
  }

  Future<void> _doConfirm() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(_bookingId)
          .update({
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _bookingData['status'] = 'confirmed';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã xác nhận đơn đặt'),
            backgroundColor: _darkGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _doCancel() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(_bookingId)
          .update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _bookingData['status'] = 'cancelled';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn đặt'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Xác nhận đơn đặt',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Xác nhận đơn đặt của $_customerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _doConfirm();
            },
            child: const Text('Xác nhận',
                style: TextStyle(
                    color: _primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hủy đơn đặt',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn hủy đơn đặt của $_customerName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _doCancel();
            },
            child: const Text('Hủy đơn',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(_status);
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    child: Column(
                      children: [
                        _buildStatusBadge(config),
                        const SizedBox(height: 24),
                        _buildCustomerCard(),
                        const SizedBox(height: 16),
                        _buildBookingInfoCard(),
                        const SizedBox(height: 16),
                        _buildPaymentCard(),
                        if (_status == 'pending') ...[
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: _darkGreen, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Chi Tiết Đơn Đặt',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _darkGreen,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> config) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: config['bg'] as Color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config['icon'] as IconData,
                color: config['color'] as Color, size: 18),
            const SizedBox(width: 8),
            Text(
              config['label'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: config['color'] as Color,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: _lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                size: 28, color: _primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customerName.isNotEmpty ? _customerName : 'Khách hàng',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
                if (_customerPhone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _customerPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_customerPhone.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri(
                    scheme: 'tel',
                    path: _customerPhone
                        .replaceAll(RegExp(r'[^\d+]'), ''));
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.call_rounded,
                    size: 22, color: _primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    final courtName =
        _bookingData['courtName']?.toString() ?? 'Sân thể thao';
    final subCourtName = _bookingData['subCourtName']?.toString() ?? '';
    final selectedDateMap = _bookingData['selectedDate'];
    final dateText = (selectedDateMap is Map)
        ? '${selectedDateMap['day'] ?? ''}, ${selectedDateMap['date'] ?? ''}/${selectedDateMap['month'] ?? ''}'
        : '';
    final slot = _bookingData['selectedSlot'];
    final startTime =
        (slot is Map) ? slot['startTime']?.toString() ?? '' : '';
    final endTime =
        (slot is Map) ? slot['endTime']?.toString() ?? '' : '';
    final timeText = (startTime.isNotEmpty && endTime.isNotEmpty)
        ? '$startTime - $endTime'
        : '';
    final duration = _bookingData['duration']?.toString() ?? '';
    final createdAt = _bookingData['createdAt'];
    String createdText = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      createdText =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -24,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _tertiary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_soccer_rounded,
                      color: _tertiary, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Thông tin đặt sân',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoEntry('Cơ sở',
                  subCourtName.isNotEmpty
                      ? '$courtName - $subCourtName'
                      : courtName),
              if (dateText.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoEntry('Ngày đặt', dateText),
              ],
              if (timeText.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoEntry(
                  'Thời gian',
                  timeText,
                  sub:
                      duration.isNotEmpty ? '($duration)' : null,
                ),
              ],
              if (createdText.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoEntry('Đặt lúc', createdText),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final totalPrice = _bookingData['totalPrice'];
    final discountAmount = _bookingData['discountAmount'];
    final voucherId = _bookingData['voucherId']?.toString() ?? '';
    final paymentMethod =
        _bookingData['paymentMethod']?.toString() ?? '';

    final basePrice = (totalPrice is num && discountAmount is num)
        ? totalPrice + discountAmount
        : totalPrice;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -24,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _tertiary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded,
                      color: _tertiary, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPaymentRow('Giá sân', _formatCurrency(basePrice)),
              const SizedBox(height: 12),
              (voucherId.isNotEmpty &&
                      discountAmount is num &&
                      discountAmount > 0)
                  ? _buildPaymentRow('Giảm giá (voucher)',
                      '- ${_formatCurrency(discountAmount)}',
                      isDiscount: true)
                  : _buildPaymentRow(
                      'Mã giảm giá', 'Không có',
                      isItalic: true),
              const SizedBox(height: 12),
              _buildPaymentRow('Phí dịch vụ', '0đ'),
              const SizedBox(height: 20),
              Divider(
                  color: const Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                  Text(
                    _formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (paymentMethod.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildPaymentMethodCard(paymentMethod),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String method) {
    final isMoMo = method.toLowerCase().contains('momo') ||
        method.toLowerCase().contains('mo mo');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMoMo ? const Color(0xFFA50064) : _darkGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isMoMo
                ? const Center(
                    child: Text('MOMO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 8,
                          letterSpacing: 0.5,
                        )))
                : const Icon(Icons.account_balance_wallet,
                    size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PHƯƠNG THỨC',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  method,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_user_rounded,
              color: _primary, size: 22),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _showCancelDialog,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              foregroundColor: _darkGreen,
              side: const BorderSide(color: Color(0xFFD6F0D8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Hủy đơn',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _showConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Xác nhận đơn',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoEntry(String label, String value, {String? sub}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
              if (sub != null)
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isDiscount = false, bool isItalic = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount ? _primary : _onSurface,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  static const Color _navyColor = Color(0xFF0C1C46);
  static const Color _orangeColor = Color(0xFFFF9800);
  final int _currentNavIndex = 2;

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
      // If customer info wasn't passed, fetch it
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

  // ── Helpers ──────────────────────────────────────────────────────────────

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
          'color': Colors.green,
          'bg': Colors.green.withValues(alpha: 0.1),
          'icon': Icons.check_circle_outline,
        };
      case 'cancelled':
        return {
          'label': 'ĐÃ HỦY',
          'color': Colors.red,
          'bg': Colors.red.withValues(alpha: 0.1),
          'icon': Icons.cancel_outlined,
        };
      default: // pending
        return {
          'label': 'CHỜ XÁC NHẬN',
          'color': _orangeColor,
          'bg': _orangeColor.withValues(alpha: 0.1),
          'icon': Icons.hourglass_empty,
        };
    }
  }

  // ── Firebase actions ──────────────────────────────────────────────────────

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
          const SnackBar(
            content: Text('Đã xác nhận đơn đặt'),
            backgroundColor: Colors.green,
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

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận đơn đặt',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('Xác nhận đơn đặt của $_customerName?'),
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
            child: Text('Xác nhận',
                style: TextStyle(
                    color: _orangeColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(_status);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    children: [
                      _buildStatusBadge(config),
                      const SizedBox(height: 24),
                      _buildCustomerInfo(),
                      const SizedBox(height: 20),
                      _buildBookingInfo(),
                      const SizedBox(height: 20),
                      _buildPaymentInfo(),
                      if (_status == 'pending') ...[
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: _orangeColor),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 24, color: _navyColor),
                  ),
                ),
              ),
              const Text(
                'Chi Tiết Đơn Đặt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> config) {
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: config['bg'] as Color,
          borderRadius: BorderRadius.circular(24),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: config['color'] as Color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: _navyColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 24, color: _navyColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _customerName.isNotEmpty ? _customerName : 'Khách hàng',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_customerPhone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _customerPhone,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (_customerPhone.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri(
                    scheme: 'tel',
                    path: _customerPhone.replaceAll(RegExp(r'[^\d+]'), ''));
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _orangeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.call, size: 20, color: _orangeColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    final courtName =
        _bookingData['courtName']?.toString() ?? 'Sân thể thao';
    final subCourtName =
        _bookingData['subCourtName']?.toString() ?? '';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thông tin đặt sân'),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.stadium, 'Cơ sở / Sân',
              subCourtName.isNotEmpty
                  ? '$courtName - $subCourtName'
                  : courtName),
          if (dateText.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today, 'Ngày đặt', dateText),
          ],
          if (timeText.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.schedule,
              'Thời gian',
              duration.isNotEmpty ? '$timeText  |  $duration' : timeText,
              highlight: true,
            ),
          ],
          if (createdText.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.access_time, 'Đặt lúc', createdText),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    final totalPrice = _bookingData['totalPrice'];
    final discountAmount = _bookingData['discountAmount'];
    final voucherId = _bookingData['voucherId']?.toString() ?? '';
    final paymentMethod =
        _bookingData['paymentMethod']?.toString() ?? '';

    final basePrice = (totalPrice is num && discountAmount is num)
        ? totalPrice + discountAmount
        : totalPrice;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Chi tiết thanh toán'),
          const SizedBox(height: 20),
          _buildPaymentRow('Giá sân', _formatCurrency(basePrice)),
          if (voucherId.isNotEmpty && discountAmount is num && discountAmount > 0) ...[
            const SizedBox(height: 12),
            _buildPaymentRow(
              'Giảm giá (voucher)',
              '- ${_formatCurrency(discountAmount)}',
              isDiscount: true,
            ),
          ] else ...[
            const SizedBox(height: 12),
            _buildPaymentRow('Mã giảm giá', 'Không có', isDiscount: true),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _orangeColor,
                ),
              ),
            ],
          ),
          if (paymentMethod.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: _navyColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHƯƠNG THỨC THANH TOÁN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        paymentMethod,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: TextButton(
              onPressed: _showCancelDialog,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Hủy đơn',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600])),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_orangeColor, Color(0xFFFF5722)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _orangeColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _showConfirmDialog,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Xác nhận đơn',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _orangeColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _navyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[400]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400])),
              const SizedBox(height: 2),
              highlight
                  ? Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _orangeColor,
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.green[600] : Colors.black87,
            fontStyle: FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
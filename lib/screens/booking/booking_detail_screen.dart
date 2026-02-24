import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Chi tiết đơn đặt
class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final int _currentNavIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  _buildStatusBadge(),
                  const SizedBox(height: 24),
                  _buildCustomerInfo(),
                  const SizedBox(height: 20),
                  _buildBookingInfo(),
                  const SizedBox(height: 20),
                  _buildPaymentInfo(),
                  const SizedBox(height: 24),
                  _buildBottomButtons(),
                ],
              ),
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
                    child: Icon(Icons.arrow_back_ios_new, size: 24, color: _navyColor),
                  ),
                ),
              ),
              Text(
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

  Widget _buildStatusBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: _orangeColor.withValues(alpha: 0.1),
          border: Border.all(color: _orangeColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _orangeColor.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          'CHỜ XÁC NHẬN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _orangeColor,
            letterSpacing: 0.5,
          ),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                ),
                child: const Icon(
                  Icons.person,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anh Hoàng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '0908.123.456',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: '0908123456');
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              }
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: _orangeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.call,
                size: 20,
                color: _orangeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
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
          Row(
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
                'Thông tin đặt sân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.stadium, 'Cơ sở', 'Sân Chảo Lửa'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.sports_soccer, 'Sân bóng', 'Sân A1 (Sân 5)'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Ngày đặt', 'Thứ 2, 15/11/2023'),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.schedule, 'Thời gian', '18:00 - 19:30  |  1.5h', hasHighlight: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool hasHighlight = false}) {
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 2),
              hasHighlight
                  ? RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: '18:00 - 19:30  '),
                          TextSpan(
                            text: '|  ',
                            style: TextStyle(color: Colors.grey[300]),
                          ),
                          TextSpan(
                            text: '1.5h',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _orangeColor,
                            ),
                          ),
                        ],
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

  Widget _buildPaymentInfo() {
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
          Row(
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
                'Chi tiết thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Payment details
          _buildPaymentRow('Giá sân', '450.000đ'),
          const SizedBox(height: 12),
          _buildPaymentRow('Mã giảm giá', 'Không có', isDiscount: true),
          const SizedBox(height: 12),
          _buildPaymentRow('Phí dịch vụ', '0đ'),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Total
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
                '450.000đ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _orangeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Payment method
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
                    color: const Color(0xFFA50064),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 16,
                    color: Colors.white,
                  ),
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
                    const Text(
                      'Ví MoMo',
                      style: TextStyle(
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
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.grey[400] : Colors.black87,
            fontStyle: isDiscount ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                _showCancelDialog();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hủy đơn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_orangeColor, const Color(0xFFFF5722)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _orangeColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                _confirmBooking();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Xác nhận đơn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hủy đơn đặt',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn hủy đơn đặt này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy đơn đặt')),
                );
              },
              child: const Text(
                'Hủy đơn',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmBooking() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xác nhận đơn đặt',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn xác nhận đơn đặt này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xác nhận đơn đặt')),
                );
              },
              child: Text(
                'Xác nhận',
                style: TextStyle(color: _orangeColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

}


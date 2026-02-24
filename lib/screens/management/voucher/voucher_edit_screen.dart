import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang chỉnh sửa voucher
class VoucherEditScreen extends StatefulWidget {
  const VoucherEditScreen({super.key});

  @override
  State<VoucherEditScreen> createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends State<VoucherEditScreen> {
  final TextEditingController _codeController = TextEditingController(text: 'SPORTSET2024');
  final TextEditingController _valueController = TextEditingController(text: '50.000');
  final TextEditingController _quantityController = TextEditingController(text: '120');
  
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  
  DateTime _expiryDate = DateTime(2024, 12, 31);
  bool _isActive = true;

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCodeField(),
                  const SizedBox(height: 24),
                  _buildValueField(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildExpiryField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildQuantityField()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActivateCard(),
                  const SizedBox(height: 32),
                  _buildUpdateButton(),
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
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, size: 24, color: Colors.grey),
                  ),
                ),
              ),
              Text(
                'Chỉnh Sửa Voucher',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(width: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tên Voucher / Mã',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: _codeController,
            decoration: InputDecoration(
              hintText: 'Nhập mã voucher',
              hintStyle: TextStyle(color: Colors.grey[300]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.sell,
                  color: _orangeColor,
                  size: 24,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 52),
            ),
            style: TextStyle(
              color: _navyColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Giá trị giảm (VND)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: _valueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Nhập giá trị',
              hintStyle: TextStyle(color: Colors.grey[300]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.payments,
                  color: _orangeColor,
                  size: 24,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 52),
            ),
            style: TextStyle(
              color: _navyColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Hạn sử dụng',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _expiryDate,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              setState(() {
                _expiryDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              '${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: _navyColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Số lượng còn lại',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey[300]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.inventory_2,
                  color: _orangeColor,
                  size: 24,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 52),
            ),
            style: TextStyle(
              color: _navyColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt,
              color: Color(0xFFFF9800),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kích hoạt ngay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hiển thị voucher cho người dùng',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeThumbColor: _orangeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          if (_codeController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng nhập mã voucher')),
            );
            return;
          }
          if (_valueController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vui lòng nhập giá trị giảm')),
            );
            return;
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật voucher thành công')),
          );
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.update,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Cập nhật thay đổi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


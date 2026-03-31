import 'package:flutter/material.dart';
import 'package:sportset_admin/models/facility.dart';
import 'package:sportset_admin/models/voucher.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/voucher_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'dart:math';

class VoucherCreateScreen extends StatefulWidget {
  const VoucherCreateScreen({super.key});

  @override
  State<VoucherCreateScreen> createState() => _VoucherCreateScreenState();
}

class _VoucherCreateScreenState extends State<VoucherCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _quantityController = TextEditingController();

  String _discountType = 'fixed'; // 'fixed' or 'percent'
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedFacilityId;
  List<Facility> _facilities = [];
  bool _isLoading = false;
  bool _isFacilitiesLoading = true;

  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _bgColor = const Color(0xFFFFF8F6);

  late VoucherService _voucherService;
  late FacilityService _facilityService;
  late AccessControlService _accessControlService;

  @override
  void initState() {
    super.initState();
    _voucherService = VoucherService();
    _facilityService = FacilityService();
    _accessControlService = AccessControlService();
    _checkCreatePermission();
    _loadFacilities();
  }
  
  Future<void> _checkCreatePermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'vouchers', 'create');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền tạo voucher'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _discountValueController.dispose();
    _minOrderController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _facilityService.getAllFacilities();
      if (mounted) {
        setState(() {
          _facilities = facilities;
          _isFacilitiesLoading = false;
          if (facilities.isNotEmpty) {
            _selectedFacilityId = facilities[0].id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFacilitiesLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải cơ sở: $e')),
        );
      }
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createVoucher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày bắt đầu phải trước ngày kết thúc')),
      );
      return;
    }

    if (_selectedFacilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn cơ sở')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final facility = _facilities.firstWhere((f) => f.id == _selectedFacilityId);
      final now = DateTime.now();
      
      final voucher = Voucher(
        id: '',
        title: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text),
        minOrderValue: double.parse(_minOrderController.text),
        totalQuantity: int.parse(_quantityController.text),
        usedQuantity: 0,
        isActive: true,
        facilityId: _selectedFacilityId!,
        facilityName: facility.name,
        startDate: _startDate!,
        endDate: _endDate!,
        createdAt: now,
        updatedAt: now,
      );

      await _voucherService.createVoucher(voucher);

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Phát hành voucher thành công')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Thêm Voucher Mới',
          style: TextStyle(
            color: _navyColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: _isFacilitiesLoading
          ? Center(
              child: CircularProgressIndicator(color: _orangeColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên chương trình
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tên chương trình',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'VD: Khuyến mãi mùa hè 2024',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[100]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[100]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _orangeColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập tên chương trình';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Mã Voucher
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mã Voucher',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              hintText: 'SUMMER2024',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[100]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[100]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _orangeColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _codeController.text =
                                          _generateRandomCode();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[50],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Tạo ngẫu nhiên',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _orangeColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Vui lòng nhập mã voucher';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Loại giảm giá
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loại giảm giá',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[100]!,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _discountType = 'fixed';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _discountType == 'fixed'
                                            ? Colors.orange[50]
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: _discountType == 'fixed'
                                            ? Border.all(
                                                color: Colors.orange[100]!,
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            size: 18,
                                            color: _discountType == 'fixed'
                                                ? _orangeColor
                                                : Colors.grey[500],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Số tiền cố định',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _discountType == 'fixed'
                                                  ? _orangeColor
                                                  : Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _discountType = 'percent';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _discountType == 'percent'
                                            ? Colors.orange[50]
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: _discountType == 'percent'
                                            ? Border.all(
                                                color: Colors.orange[100]!,
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.percent,
                                            size: 18,
                                            color: _discountType == 'percent'
                                                ? _orangeColor
                                                : Colors.grey[500],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Phần trăm',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _discountType == 'percent'
                                                  ? _orangeColor
                                                  : Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Discount value and min order
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giá trị giảm',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _discountValueController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    suffixText:
                                        _discountType == 'percent' ? '%' : 'đ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _orangeColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Bắt buộc';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đơn hàng tối thiểu',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _minOrderController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    suffixText: 'đ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _orangeColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Bắt buộc';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Thời gian áp dụng
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thời gian áp dụng',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(true),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ngày bắt đầu',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _startDate != null
                                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                              : 'Chọn ngày',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(false),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[100]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ngày kết thúc',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _endDate != null
                                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                              : 'Chọn ngày',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Giới hạn
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giới hạn',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[100]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue[50],
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Số lượng mã phát hành',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tổng số voucher có thể dùng',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 70,
                                  child: TextFormField(
                                    controller: _quantityController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '∞',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: _orangeColor,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Bắt buộc';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Áp dụng cho
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Áp dụng cho',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[100]!,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: DropdownButton<String>(
                              value: _selectedFacilityId,
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              icon: Icon(
                                Icons.expand_more,
                                color: Colors.grey[400],
                              ),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFacilityId = value;
                                  });
                                }
                              },
                              items: _facilities
                                  .map((facility) => DropdownMenuItem(
                                        value: facility.id,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.domain,
                                              size: 18,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              facility.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_orangeColor, Colors.red[700]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _orangeColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createVoucher,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.rocket_launch,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Phát hành Voucher',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.view_list),
          label: 'Quản lý',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Đơn đặt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}

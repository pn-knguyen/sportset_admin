import 'package:flutter/material.dart';
import 'package:sportset_admin/models/facility.dart';
import 'package:sportset_admin/models/voucher.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/voucher_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';
import 'dart:math';

class VoucherEditScreen extends StatefulWidget {
  const VoucherEditScreen({super.key});

  @override
  State<VoucherEditScreen> createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends State<VoucherEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _quantityController = TextEditingController();

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  String? _voucherId;
  Voucher? _voucher;
  bool _didReadArgs = false;

  String _discountType = 'fixed';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  String? _selectedFacilityId;
  List<Facility> _facilities = [];

  bool _isLoading = true;
  bool _isFacilitiesLoading = true;
  bool _isSaving = false;

  final VoucherService _voucherService = VoucherService();
  final FacilityService _facilityService = FacilityService();
  final AccessControlService _accessControlService = AccessControlService();

  @override
  void initState() {
    super.initState();
    _checkEditPermission();
    _loadFacilities();
  }

  Future<void> _checkEditPermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission =
        _accessControlService.can(permissionMap, 'vouchers', 'update');
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền chỉnh sửa voucher'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _voucherId = args?['id'] as String?;
    _didReadArgs = true;
    _loadVoucher();
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFacilitiesLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi tải cơ sở: $e')));
      }
    }
  }

  Future<void> _loadVoucher() async {
    final id = _voucherId;
    if (id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final voucher = await _voucherService.getVoucherByIdFuture(id);
      if (!mounted) return;
      if (voucher == null) {
        setState(() => _isLoading = false);
        return;
      }
      setState(() {
        _voucher = voucher;
        _nameController.text = voucher.title;
        _codeController.text = voucher.code;
        _discountType = voucher.discountType;
        _discountValueController.text =
            voucher.discountValue.toStringAsFixed(0);
        _minOrderController.text = voucher.minOrderValue.toStringAsFixed(0);
        _quantityController.text = voucher.totalQuantity.toString();
        _startDate = voucher.startDate;
        _endDate = voucher.endDate;
        _isActive = voucher.isActive;
        _selectedFacilityId =
            voucher.facilityId.isNotEmpty ? voucher.facilityId : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải voucher: $e')));
    }
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
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

    final voucher = _voucher;
    if (voucher == null || _voucherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiếu dữ liệu để cập nhật')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final facility =
          _facilities.firstWhere((f) => f.id == _selectedFacilityId);

      await _voucherService.updateVoucher(_voucherId!, {
        'title': _nameController.text.trim(),
        'code': _codeController.text.trim().toUpperCase(),
        'discountType': _discountType,
        'discountValue': double.parse(_discountValueController.text),
        'minOrderValue': double.parse(_minOrderController.text),
        'totalQuantity': int.parse(_quantityController.text),
        'maxPerUser': 1,
        'startDate': _startDate,
        'endDate': _endDate,
        'isActive': _isActive,
        'facilityId': _selectedFacilityId,
        'facilityName': facility.name,
        'updatedAt': DateTime.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật voucher thành công')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _onSurface,
          ),
        ),
      );

  Widget _smallLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _onSurface,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDataLoading = _isLoading || _isFacilitiesLoading;

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
            SafeArea(
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
                        'Chỉnh Sửa Voucher',
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
            ),
            Expanded(
              child: isDataLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary))
                  : _voucher == null
                      ? const Center(child: Text('Không tìm thấy voucher'))
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Tên chương trình'),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: _inputDecoration(
                                      hint: 'VD: Khuyến mãi mùa hè 2024'),
                                  validator: (v) => (v?.isEmpty ?? true)
                                      ? 'Vui lòng nhập tên chương trình'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                _label('Mã Voucher'),
                                TextFormField(
                                  controller: _codeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  decoration: _inputDecoration(
                                    hint: 'SUMMER2024',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () => setState(() =>
                                            _codeController.text =
                                                _generateRandomCode()),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _lightGreen,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                        child: const Text(
                                          'Tạo ngẫu nhiên',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _primary),
                                        ),
                                      ),
                                    ),
                                  ),
                                  validator: (v) => (v?.isEmpty ?? true)
                                      ? 'Vui lòng nhập mã voucher'
                                      : null,
                                ),
                                const SizedBox(height: 24),

                                _label('Loại giảm giá'),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      _discountTypeOption(
                                          'fixed',
                                          Icons.attach_money,
                                          'Số tiền cố định'),
                                      const SizedBox(width: 2),
                                      _discountTypeOption(
                                          'percent', Icons.percent, 'Phần trăm'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _smallLabel('Giá trị giảm'),
                                          TextFormField(
                                            controller:
                                                _discountValueController,
                                            keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                                    decimal: true),
                                            decoration: _inputDecoration(
                                              hint: '0',
                                              suffixText:
                                                  _discountType == 'percent'
                                                      ? '%'
                                                      : 'đ',
                                            ),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                            validator: (v) =>
                                                (v?.isEmpty ?? true)
                                                    ? 'Bắt buộc'
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _smallLabel('Đơn hàng tối thiểu'),
                                          TextFormField(
                                            controller: _minOrderController,
                                            keyboardType:
                                                const TextInputType
                                                    .numberWithOptions(
                                                    decimal: true),
                                            decoration: _inputDecoration(
                                              hint: '0',
                                              suffixText: 'đ',
                                            ),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                            validator: (v) =>
                                                (v?.isEmpty ?? true)
                                                    ? 'Bắt buộc'
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                _label('Thời gian áp dụng'),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _datePicker(
                                            'Ngày bắt đầu', _startDate,
                                            () => _selectDate(true))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _datePicker(
                                            'Ngày kết thúc', _endDate,
                                            () => _selectDate(false))),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                _label('Giới hạn'),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _lightGreen,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.inventory_2,
                                            color: _primary, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Số lượng mã phát hành',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _onSurface,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Tổng số voucher có thể dùng',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: _onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 72,
                                        child: TextFormField(
                                          controller: _quantityController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            hintText: '∞',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  color: _primary, width: 2),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 12),
                                          ),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          validator: (v) =>
                                              (v?.isEmpty ?? true)
                                                  ? 'Bắt buộc'
                                                  : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                _label('Áp dụng cho'),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: DropdownButton<String>(
                                    value: _selectedFacilityId,
                                    isExpanded: true,
                                    underline: const SizedBox.shrink(),
                                    icon: Icon(Icons.expand_more,
                                        color: Colors.grey[400]),
                                    hint: Text('Chọn cơ sở',
                                        style: TextStyle(
                                            color: Colors.grey[400])),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(
                                            () => _selectedFacilityId = value);
                                      }
                                    },
                                    items: _facilities
                                        .map((f) => DropdownMenuItem(
                                              value: f.id,
                                              child: Row(
                                                children: [
                                                  Icon(Icons.domain,
                                                      size: 18,
                                                      color: Colors.grey[400]),
                                                  const SizedBox(width: 8),
                                                  Text(f.name,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _onSurface)),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: _lightGreen,
                                        ),
                                        child: const Icon(Icons.bolt,
                                            color: _primary, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Kích hoạt ngay',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: _onSurface)),
                                            const SizedBox(height: 2),
                                            Text(
                                                'Hiển thị voucher cho người dùng',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: _isActive,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: _primary,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: Colors.grey[300],
                                        onChanged: (v) =>
                                            setState(() => _isActive = v),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_primary, _darkGreen],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
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
                                  child: ElevatedButton(
                                    onPressed:
                                        _isSaving ? null : _submitUpdate,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.update,
                                                  color: Colors.white,
                                                  size: 24),
                                              SizedBox(width: 12),
                                              Text(
                                                'Cập nhật Voucher',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _discountTypeOption(String type, IconData icon, String label) {
    final isSelected = _discountType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _discountType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _lightGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? _primary : Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _primary : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Chon ngay',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _onSurface),
                ),
              ],
            ),
            const Icon(Icons.calendar_today,
                size: 18, color: _onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
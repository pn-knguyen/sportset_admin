import 'package:flutter/material.dart';
import 'package:sportset_admin/models/voucher.dart';
import 'package:sportset_admin/services/voucher_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class VoucherEditScreen extends StatefulWidget {
  const VoucherEditScreen({super.key});

  @override
  State<VoucherEditScreen> createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends State<VoucherEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _voucherAndCodeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _remainingController = TextEditingController();

  final VoucherService _voucherService = VoucherService();
  final AccessControlService _accessControlService = AccessControlService();

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  String? _voucherId;
  Voucher? _voucher;
  DateTime? _expiryDate;
  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _didReadArgs = false;

  @override
  void initState() {
    super.initState();
    _checkEditPermission();
  }
  
  Future<void> _checkEditPermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'vouchers', 'update');
    
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
    if (_didReadArgs) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _voucherId = args?['id'] as String?;
    _didReadArgs = true;
    _loadVoucher();
  }

  @override
  void dispose() {
    _voucherAndCodeController.dispose();
    _discountValueController.dispose();
    _remainingController.dispose();
    super.dispose();
  }

  Future<void> _loadVoucher() async {
    final id = _voucherId;
    if (id == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final voucher = await _voucherService.getVoucherByIdFuture(id);

      if (!mounted) {
        return;
      }

      if (voucher == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final remaining =
          (voucher.totalQuantity - voucher.usedQuantity).clamp(0, 999999);

      setState(() {
        _voucher = voucher;
        _voucherAndCodeController.text = voucher.code;
        _discountValueController.text = voucher.discountValue.toStringAsFixed(0);
        _remainingController.text = remaining.toString();
        _expiryDate = voucher.endDate;
        _isActive = voucher.isActive;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải voucher: $e')),
      );
    }
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null && mounted) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  String _formatDateInput(DateTime? date) {
    if (date == null) {
      return 'YYYY-MM-DD';
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  double? _parseMoney(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return null;
    }
    return double.tryParse(cleaned);
  }

  int? _parseInt(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) {
      return null;
    }
    return int.tryParse(cleaned);
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final voucher = _voucher;
    if (voucher == null || _voucherId == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiếu dữ liệu để cập nhật')),
      );
      return;
    }

    final discountValue = _parseMoney(_discountValueController.text);
    final remaining = _parseInt(_remainingController.text);

    if (discountValue == null || remaining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giá trị nhập không hợp lệ')),
      );
      return;
    }

    final updatedTotalQuantity = voucher.usedQuantity + remaining;

    setState(() {
      _isSaving = true;
    });

    try {
      await _voucherService.updateVoucher(_voucherId!, {
        'title': _voucherAndCodeController.text.trim().isEmpty
            ? voucher.title
            : _voucherAndCodeController.text.trim(),
        'code': _voucherAndCodeController.text.trim().toUpperCase(),
        'discountValue': discountValue,
        'totalQuantity': updatedTotalQuantity,
        'endDate': _expiryDate,
        'isActive': _isActive,
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật voucher thành công')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primary),
                    )
                  : _voucher == null
                      ? const Center(
                          child: Text('Không tìm thấy voucher'),
                        )
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(20, 20, 20, 100),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabeledInput(
                                  label: 'Tên voucher / Mã',
                                  icon: Icons.sell,
                                  controller: _voucherAndCodeController,
                                  hint: 'SPORTSET2024',
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Vui lòng nhập mã voucher';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildLabeledInput(
                                  label: 'Giá trị giảm (VND)',
                                  icon: Icons.payments,
                                  controller: _discountValueController,
                                  hint: '50000',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final parsed =
                                        _parseMoney(value ?? '');
                                    if (parsed == null || parsed <= 0) {
                                      return 'Giá trị giảm không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateField(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildLabeledInput(
                                        label: 'Số lượng còn lại',
                                        icon: Icons.inventory_2,
                                        controller: _remainingController,
                                        hint: '120',
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          final parsed =
                                              _parseInt(value ?? '');
                                          if (parsed == null ||
                                              parsed < 0) {
                                            return 'Không hợp lệ';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
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
                                        child: const Icon(
                                          Icons.bolt,
                                          color: _primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Kích hoạt ngay',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Hiển thị voucher cho người dùng',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: _isActive,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: _primary,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: Colors.grey[300],
                                        onChanged: (value) {
                                          setState(() {
                                            _isActive = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  width: double.infinity,
                                  height: 60,
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
                                    onPressed:
                                        _isSaving ? null : _submitUpdate,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 60),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.update),
                                    label: Text(
                                      _isSaving
                                          ? 'Đang cập nhật...'
                                          : 'Cập nhật thay đổi',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Hạn sử dụng',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickExpiryDate,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
            child: Text(
              _formatDateInput(_expiryDate),
              style: const TextStyle(
                color: _onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: _onSurface,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[300]),
              prefixIcon: Icon(icon, color: _primary, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 18,
              ),
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
                borderSide: const BorderSide(
                  color: _primary,
                  width: 1.5,
                ),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

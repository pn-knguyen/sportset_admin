import 'package:flutter/material.dart';
import 'package:sportset_admin/models/voucher.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/voucher_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({super.key});

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final VoucherService _voucherService = VoucherService();
  final AccessControlService _accessControlService = AccessControlService();
  
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Tất cả', 'Đang chạy', 'Sắp tới', 'Kết thúc'];
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _bgColor = const Color(0xFFFFF8F6);
  
  bool _canCreate = false;
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
      _canCreate = _accessControlService.can(permissionMap, 'vouchers', 'create');
      _canEdit = _accessControlService.can(permissionMap, 'vouchers', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'vouchers', 'delete');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Voucher> _applyFilters(List<Voucher> vouchers) {
    final query = _searchController.text.trim().toLowerCase();
    
    // Filter by tab
    var filtered = vouchers.where((v) {
      if (_selectedTabIndex == 0) return true;
      if (_selectedTabIndex == 1) return v.status == 'active';
      if (_selectedTabIndex == 2) return v.status == 'upcoming';
      return v.status == 'ended';
    }).toList();

    // Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered
          .where((v) =>
              v.title.toLowerCase().contains(query) ||
              v.code.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  String _formatDiscountDisplay(Voucher voucher) {
    if (voucher.discountType == 'percent') {
      return '-${voucher.discountValue.toStringAsFixed(0)}%';
    }
    return '-${(voucher.discountValue / 1000).toStringAsFixed(0)}K';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Đang chạy';
      case 'upcoming':
        return 'Sắp tới';
      case 'ended':
        return 'Kết thúc';
      default:
        return '';
    }
  }

  void _showDeleteDialog(BuildContext context, String voucherId, String title) {
    final messenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa voucher'),
          content: Text('Bạn có chắc chắn muốn xóa voucher "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await _voucherService.deleteVoucher(voucherId);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Xóa voucher thành công')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final usagePercentage = voucher.totalQuantity > 0
        ? (voucher.usedQuantity / voucher.totalQuantity) * 100
        : 0.0;
    final isEnded = voucher.status == 'ended';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEnded ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
        boxShadow: [
          if (!isEnded)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Voucher info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    voucher.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isEnded ? Colors.grey[600] : _navyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Code and Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: Text(
                          voucher.code,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: isEnded ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(voucher.status),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(voucher.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(voucher.status),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Usage progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã dùng',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '${voucher.usedQuantity}/${voucher.totalQuantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isEnded ? Colors.grey[600] : _navyColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: usagePercentage / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isEnded ? Colors.grey[500]! : _orangeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Separator - ticket cutout
          Container(
            width: 1,
            height: 120,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey[200]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -8,
                  left: -5,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  left: -5,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right side - Discount and actions
          Container(
            width: 112,
            color: isEnded
                ? Colors.grey[100]
                : Colors.orange.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        _formatDiscountDisplay(voucher),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isEnded ? Colors.grey[500] : _orangeColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'HSD: ${_formatDate(voucher.endDate)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (isEnded || !_canEdit)
                              ? null
                              : () async {
                                  await Navigator.pushNamed(
                                    context,
                                    AppRoutes.voucherEdit,
                                    arguments: {'id': voucher.id},
                                  );
                                  setState(() {});
                                },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey[100]!,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: (isEnded || !_canEdit)
                                  ? Colors.grey[400]
                                  : Colors.blue[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: !_canDelete
                              ? null
                              : () {
                                  _showDeleteDialog(
                                      context, voucher.id, voucher.title);
                                },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey[100]!,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 16,
                              color: !_canDelete
                                  ? Colors.grey[400]
                                  : (isEnded ? Colors.grey[400] : Colors.red[500]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          'Quản Lý Voucher',
          style: TextStyle(
            color: _navyColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Tìm mã voucher...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: _orangeColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Tabs
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _navyColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Colors.grey[100]!,
                                width: 1,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _navyColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                )
                              ],
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Voucher list
          Expanded(
            child: StreamBuilder<List<Voucher>>(
              stream: _voucherService.getAllVouchersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: _orangeColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lỗi tải dữ liệu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final vouchers = snapshot.data ?? [];
                final filtered = _applyFilters(vouchers);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không có voucher nào',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          AppRoutes.voucherDetail,
                          arguments: {'id': filtered[index].id},
                        );
                        setState(() {});
                      },
                      child: _buildVoucherCard(filtered[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_canCreate) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bạn không có quyền tạo voucher'),
                  backgroundColor: _orangeColor,
                ),
              );
            }
            return;
          }
          await Navigator.pushNamed(context, AppRoutes.voucherCreate);
          setState(() {});
        },
        backgroundColor: _orangeColor,
        elevation: 8,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: 1),
    );
  }
}

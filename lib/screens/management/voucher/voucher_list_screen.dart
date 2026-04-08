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
  
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Tất cả', 'Đang chạy', 'Sắp tới', 'Kết thúc'];

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
        ? (voucher.usedQuantity / voucher.totalQuantity)
        : 0.0;
    final isEnded = voucher.status == 'ended';
    final isUpcoming = voucher.status == 'upcoming';
    final Color progressColor = isEnded
        ? Colors.grey
        : (isUpcoming ? const Color(0xFF18A5A7) : _primary);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnded ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: isEnded
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEnded ? Colors.grey[200] : _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.confirmation_number,
                  color: isEnded ? Colors.grey[500] : _primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isEnded
                            ? _onSurface.withValues(alpha: 0.5)
                            : _onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEnded ? Colors.grey[100] : _lightGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        voucher.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isEnded ? Colors.grey[500] : _primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(
                        minWidth: 36, minHeight: 36),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.edit, size: 18),
                    color: (isEnded || !_canEdit)
                        ? Colors.grey[400]
                        : const Color(0xFF18A5A7),
                    onPressed: (isEnded || !_canEdit)
                        ? null
                        : () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.voucherEdit,
                              arguments: {'id': voucher.id},
                            );
                            setState(() {});
                          },
                  ),
                  IconButton(
                    constraints: const BoxConstraints(
                        minWidth: 36, minHeight: 36),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: !_canDelete
                        ? Colors.grey[400]
                        : const Color(0xFFBA1A1A),
                    onPressed: !_canDelete
                        ? null
                        : () => _showDeleteDialog(
                            context, voucher.id, voucher.title),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(voucher.status),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(voucher.status).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(voucher.status),
                  letterSpacing: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child:
                    Text('•', style: TextStyle(color: Colors.grey[400])),
              ),
              Text(
                _formatDiscountDisplay(voucher),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnded
                      ? Colors.grey[500]
                      : const Color(0xFF994700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child:
                    Text('•', style: TextStyle(color: Colors.grey[400])),
              ),
              Text(
                'Hết hạn ${_formatDate(voucher.endDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã sử dụng',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                '${voucher.usedQuantity}/${voucher.totalQuantity}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isEnded ? Colors.grey[500] : _onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usagePercentage,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
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
                    Expanded(
                      child: Text(
                        'Quản lý Voucher',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: _primary, width: 2),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedTabIndex == index;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? _primary : Colors.white,
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
                                    color: _primary.withValues(
                                        alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.03),
                                    blurRadius: 4,
                                  )
                                ],
                        ),
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[500],
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
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: _primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Lỗi tải dữ liệu',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14),
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
                          Icon(Icons.card_giftcard_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Không có voucher nào',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(0, 8, 0, 16),
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
                        child:
                            _buildVoucherCard(filtered[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_canCreate) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bạn không có quyền tạo voucher'),
                  backgroundColor: _primary,
                ),
              );
            }
            return;
          }
          await Navigator.pushNamed(context, AppRoutes.voucherCreate);
          setState(() {});
        },
        backgroundColor: _primary,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: 1),
    );
  }
}


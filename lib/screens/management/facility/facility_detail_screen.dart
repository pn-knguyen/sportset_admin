import 'package:flutter/material.dart';
import 'package:sportset_admin/models/court.dart';
import 'package:sportset_admin/models/facility.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/court_service.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// 3.1. Chi tiết cơ sở (Create/Update)
class FacilityDetailScreen extends StatefulWidget {
  const FacilityDetailScreen({super.key});

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  final int _currentNavIndex = 1; // Active on Management tab
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeLightColor = const Color(0xFFFFB366);
  final Color _orangeBrandColor = const Color(0xFFFF5722);
  final CourtService _courtService = CourtService();
  final FacilityService _facilityService = FacilityService();
  final AccessControlService _accessControlService = AccessControlService();
  
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
      _canEdit = _accessControlService.can(permissionMap, 'facilities', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'facilities', 'delete');
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final facilityId = routeArgs is Map ? routeArgs['id'] as String? : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: facilityId == null || facilityId.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy thông tin cơ sở'),
                    )
                  : StreamBuilder<Facility?>(
                      stream: _facilityService.getFacilityByIdStream(facilityId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Không thể tải dữ liệu cơ sở',
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          );
                        }

                        final facility = snapshot.data;
                        if (facility == null) {
                          return const Center(
                            child: Text('Cơ sở không tồn tại hoặc đã bị xóa'),
                          );
                        }

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageGallery(facility),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFacilityInfo(facility),
                                    const SizedBox(height: 24),
                                    _buildAmenities(facility),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildCourtsList(facility.id),
                              const SizedBox(height: 32),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _buildActionButtons(facility.id, facility.name),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ],
        ),
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.chevron_left, size: 28, color: _navyColor),
            ),
          ),
          Text(
            'Chi Tiết Cơ Sở',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _navyColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Facility facility) {
    final imageUrl = facility.imageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _orangeBrandColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: imageUrl == null || imageUrl.isEmpty
                  ? Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityInfo(Facility facility) {
    final isOpen = facility.status == 'open';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  facility.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _navyColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? 'ĐANG MỞ' : 'ĐANG ĐÓNG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.green : Colors.red,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on,
            facility.address,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.call, facility.hotline),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.schedule,
            '${facility.openTime} - ${facility.closeTime}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _orangeLightColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: icon == Icons.location_on ? Colors.grey[700] : _navyColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities(Facility facility) {
    final amenities = facility.amenities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIỆN ÍCH CƠ SỞ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: _navyColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        amenities.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Chưa cập nhật tiện ích cho cơ sở này',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 360;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isNarrow ? 3 : 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isNarrow ? 0.9 : 0.85,
                    ),
                    itemCount: amenities.length,
                    itemBuilder: (context, index) {
                      final amenityLabel = amenities[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _amenityIcon(amenityLabel),
                              color: _orangeLightColor,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              amenityLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                  ),
      ],
    );
  }

  Widget _buildCourtsList(String facilityId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SÂN BÃI THUỘC CƠ SỞ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.courts);
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _orangeBrandColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Court>>(
          stream: _courtService.getCourtsByFacilityIdStream(facilityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Không thể tải danh sách sân',
                  style: TextStyle(color: Colors.red[400]),
                ),
              );
            }

            final courts = snapshot.data ?? <Court>[];
            if (courts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Cơ sở này chưa có sân nào',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: courts.map((court) => _buildCourtCard(court)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCourtCard(Court court) {
    final isAvailable = court.status == 'available';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _courtIconForSport(court.sportType),
              color: _orangeLightColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _navyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  court.sportType,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAvailable ? 'Sẵn sàng' : 'Bảo trì',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAvailable ? Colors.green[600] : Colors.red[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _courtIconForSport(String sportType) {
    final normalized = sportType.toLowerCase();
    if (normalized.contains('cầu lông') || normalized.contains('badminton')) {
      return Icons.sports_tennis;
    }
    if (normalized.contains('tennis')) {
      return Icons.sports_tennis;
    }
    if (normalized.contains('pickleball')) {
      return Icons.sports_tennis;
    }
    return Icons.sports_soccer;
  }

  IconData _amenityIcon(String amenityLabel) {
    final normalized = amenityLabel.toLowerCase();
    if (normalized.contains('wifi')) {
      return Icons.wifi;
    }
    if (normalized.contains('gửi xe') || normalized.contains('parking')) {
      return Icons.local_parking;
    }
    if (normalized.contains('canteen') || normalized.contains('căn tin')) {
      return Icons.restaurant;
    }
    if (normalized.contains('tắm')) {
      return Icons.shower;
    }
    if (normalized.contains('nước')) {
      return Icons.water_drop;
    }
    if (normalized.contains('đèn')) {
      return Icons.lightbulb;
    }
    if (normalized.contains('y tế')) {
      return Icons.medical_services;
    }
    return Icons.check_circle_outline;
  }

  Widget _buildActionButtons(String facilityId, String facilityName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _canDelete
                    ? () {
                        _showDeleteDialog(facilityId, facilityName);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _canDelete ? Colors.red : Colors.grey,
                  side: BorderSide(
                    color: _canDelete ? Colors.red : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Xóa cơ sở',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _canDelete ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _canEdit
                      ? [const Color(0xFFFF9500), const Color(0xFFF44336)]
                      : [Colors.grey.withValues(alpha: 0.5), Colors.grey.withValues(alpha: 0.5)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _canEdit
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.transparent,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _canEdit
                      ? () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.facilityEdit,
                            arguments: {'id': facilityId},
                          );
                        }
                      : null,
                  child: Center(
                    child: Text(
                      'Chỉnh sửa cơ sở',
                      style: TextStyle(
                        color: _canEdit ? Colors.white : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String facilityId, String facilityName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa cơ sở "$facilityName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await _facilityService.deleteFacility(facilityId);
                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa cơ sở "$facilityName"'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } on StateError catch (e) {
                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.message ??
                            'Không thể xóa cơ sở do còn sân trực thuộc',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}

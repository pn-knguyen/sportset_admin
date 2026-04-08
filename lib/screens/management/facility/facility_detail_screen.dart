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

  static const _primary = Color(0xFF4CAF50);
  static const _secondary = Color(0xFF18A5A7);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

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
      backgroundColor: _lightGreen,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightGreen, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: facilityId == null || facilityId.isEmpty
                    ? const Center(
                        child: Text('Kh\xf4ng t\xecm th\u1ea5y th\xf4ng tin c\u01a1 s\u1edf'),
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
                                'Kh\xf4ng th\u1ec3 t\u1ea3i d\u1eef li\u1ec7u c\u01a1 s\u1edf',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                            );
                          }

                          final facility = snapshot.data;
                          if (facility == null) {
                            return const Center(
                              child: Text('C\u01a1 s\u1edf kh\xf4ng t\u1ed3n t\u1ea1i ho\u1eb7c \u0111\xe3 b\u1ecb x\xf3a'),
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
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: _darkGreen),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              'Chi ti\u1ebft c\u01a1 s\u1edf',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkGreen,
                letterSpacing: -0.5,
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[500]),
              onPressed: null,
            ),
          ],
        ),
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
                  color: _primary.withValues(alpha: 0.06),
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
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _onSurface,
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
                      ? const Color(0xFF94F990)
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
                        color: isOpen ? _primary : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOpen ? '\u0110ANG M\u1eDE' : '\u0110ANG \u0110\xd3NG',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOpen ? _darkGreen : Colors.red,
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _secondary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onSurfaceVariant,
                height: 1.4,
              ),
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
          'TI\u1ec6N \xcdCH C\u01a0 S\u1eDE',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _onSurface,
            letterSpacing: -0.3,
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
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
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
                              color: _secondary,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              amenityLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _onSurfaceVariant,
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
                'S\xc2N B\xc3I THU\u1ed8C C\u01a0 S\u1eDE',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.courts);
                },
                child: const Text(
                  'Xem t\u1ea5t c\u1ea3',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _secondary,
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
              color: _lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _courtIconForSport(court.sportType),
              color: _primary,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _onSurface,
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
                  foregroundColor: _canDelete ? _primary : Colors.grey,
                  side: BorderSide(
                    color: _canDelete ? _primary : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'X\xf3a c\u01a1 s\u1edf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _canDelete ? _primary : Colors.grey,
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
                      ? [_primary, _darkGreen]
                      : [Colors.grey.withValues(alpha: 0.5), Colors.grey.withValues(alpha: 0.5)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _canEdit
                        ? _primary.withValues(alpha: 0.25)
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
                        e.message.isEmpty
                            ? 'Không thể xóa cơ sở do còn sân trực thuộc'
                            : e.message,
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

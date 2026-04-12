import 'package:flutter/material.dart';
import 'package:sportset_admin/models/court.dart';
import 'package:sportset_admin/routes/app_routes.dart';
import 'package:sportset_admin/services/court_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Chi tiết sân
class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  static const _tertiary = Color(0xFF994700);
  final int _currentNavIndex = 1;
  final CourtService _courtService = CourtService();
  final AccessControlService _accessControlService = AccessControlService();
  
  bool _isStatusUpdating = false;
  int _currentImageIndex = 0;
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
      _canEdit = _accessControlService.can(permissionMap, 'courts', 'update');
      _canDelete = _accessControlService.can(permissionMap, 'courts', 'delete');
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final courtId = args is Map ? args['id'] as String? : null;

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
        child: Stack(
          children: [
            courtId == null || courtId.isEmpty
                ? const Center(child: Text('Kh\u00f4ng t\u00ecm th\u1ea5y m\u00e3 s\u00e2n'))
                : StreamBuilder<Court?>(
                    stream: _courtService.getCourtByIdStream(courtId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: _primary));
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Kh\u00f4ng th\u1ec3 t\u1ea3i d\u1eef li\u1ec7u s\u00e2n',
                            style: TextStyle(color: Colors.red[400]),
                          ),
                        );
                      }
                      final court = snapshot.data;
                      if (court == null) {
                        return const Center(
                          child: Text('S\u00e2n kh\u00f4ng t\u1ed3n t\u1ea1i ho\u1eb7c \u0111\u00e3 b\u1ecb x\u00f3a'),
                        );
                      }
                      final images = _imageList(court);
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageCarousel(images),
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: _buildCourtInfoSection(court),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSubCourtsSection(court),
                                    const SizedBox(height: 32),
                                    _buildPricingSection(court),
                                    const SizedBox(height: 32),
                                    _buildAmenitiesSection(court),
                                    const SizedBox(height: 32),
                                    _buildActionButtons(court),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            _buildHeader(),
          ],
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
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: _darkGreen),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: const Text(
                'Chi ti\u1ebft S\u00e2n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: _darkGreen),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 256,
          child: PageView.builder(
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (images.isEmpty) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              }
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              );
            },
          ),
        ),
        // Gradient overlay bottom: black/40 → transparent
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 128,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x66000000), Colors.transparent],
              ),
            ),
          ),
        ),
        // Page indicators
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _currentImageIndex ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _currentImageIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildCourtInfoSection(Court court) {
    final isActive = court.status == 'available';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + location
          Text(
            court.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _onSurface,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: _onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  court.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.business, size: 16, color: _primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  court.facilityName.isNotEmpty ? court.facilityName : 'Chưa xác định',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _lightGreen.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  court.sportType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _darkGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF80F5F6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00696B).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Ngo\u00e0i tr\u1eddi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF004F50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Status row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: _primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TR\u1ea0NG TH\u00c1I CHUNG',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive ? '\u0110ang ho\u1ea1t \u0111\u1ed9ng' : '\u0110ang b\u1ea3o tr\u00ec',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isActive ? _primary : _tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom toggle
                GestureDetector(
                  onTap: _isStatusUpdating
                      ? null
                      : () => _toggleCourtStatus(court, !isActive),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive ? _primary : Colors.grey[300],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Align(
                      alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCourtsSection(Court court) {
    final subCourts = court.subCourts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh s\u00e1ch s\u00e2n con (${subCourts.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: subCourts.length,
          itemBuilder: (context, index) {
            final subCourt = subCourts[index];
            final isAvailable = (subCourt['status'] ?? 'available') == 'available';
            final name = (subCourt['name'] ?? '').toString();
            final fullName = name.isEmpty ? 'S\u00e2n ${index + 1}' : name;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFBECAB9).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isAvailable ? _onSurface : _onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.fiber_manual_record,
                        size: 14,
                        color: isAvailable ? _primary : _tertiary,
                      ),
                    ],
                  ),
                  Text(
                    isAvailable ? 'S\u1eb5n s\u00e0ng' : 'B\u1ea3o tr\u00ec',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? _primary : _tertiary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection(Court court) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'B\u1ea3ng gi\u00e1 ni\u00eam y\u1ebft',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Weekday pricing card
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBECAB9).withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(color: _primary.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: const Text(
                    'TH\u1ee8 2 - TH\u1ee8 6',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: court.weekdayPricing.isEmpty
                        ? [_buildPricingRow('Ch\u01b0a c\u00f3 khung gi\u1edd', '0\u0111', false)]
                        : court.weekdayPricing.map((item) {
                            final start = (item['startTime'] ?? '').toString();
                            final end = (item['endTime'] ?? '').toString();
                            final priceValue = (item['price'] as num?)?.toInt() ?? 0;
                            final timeText = start.isEmpty || end.isEmpty
                                ? 'To\u00e0n th\u1eddi gian'
                                : '$start - $end';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildPricingRow(
                                timeText,
                                '${_formatCurrency(priceValue)}\u0111',
                                false,
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Weekend pricing card
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _tertiary.withValues(alpha: 0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _tertiary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(color: _tertiary.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CU\u1ed0I TU\u1ea6N',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _tertiary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _tertiary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: court.weekendPricing.isEmpty
                        ? [_buildPricingRow('Ch\u01b0a c\u00f3 khung gi\u1edd', '0\u0111', true)]
                        : court.weekendPricing.map((item) {
                            final start = (item['startTime'] ?? '').toString();
                            final end = (item['endTime'] ?? '').toString();
                            final priceValue = (item['price'] as num?)?.toInt() ?? 0;
                            final timeText = start.isEmpty || end.isEmpty
                                ? 'To\u00e0n th\u1eddi gian'
                                : '$start - $end';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildPricingRow(
                                timeText,
                                '${_formatCurrency(priceValue)}\u0111',
                                true,
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingRow(String time, String price, bool isWeekend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            color: _onSurfaceVariant,
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isWeekend ? _tertiary : _onSurface,
            ),
            children: [
              TextSpan(text: price),
              TextSpan(
                text: '/gi\u1edd',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(Court court) {
    // Debug: Print amenities count and list
    print('===== AMENITIES DEBUG =====');
    print('Total amenities count: ${court.amenities.length}');
    print('Amenities list: ${court.amenities}');
    print('===========================');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tiện ích & Mô tả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _onSurface,
              ),
            ),
            if (court.amenities.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${court.amenities.length} tiện ích',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Amenities horizontal scroll
        court.amenities.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chưa có tiện ích nào',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              )
            : SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: court.amenities.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final amenity = court.amenities[index];
                    return Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _amenityIcon(amenity),
                            size: 24,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 52,
                          child: Text(
                            amenity.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
        const SizedBox(height: 16),
        // Description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBECAB9).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            court.description.isEmpty
                ? 'Chưa có mô tả cho sân này.'
                : '“${court.description}”',
            style: const TextStyle(
              fontSize: 13,
              color: _onSurfaceVariant,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Court court) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _canDelete ? () => _showDeleteDialog(court) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _onSurfaceVariant,
                shadowColor: Colors.transparent,
                elevation: 0,
                side: const BorderSide(color: Color(0xFFBECAB9), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Xóa sân',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_darkGreen, _primary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _canEdit
                  ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.courtEdit,
                        arguments: {'id': court.id},
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Chỉnh sửa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleCourtStatus(Court court, bool isActive) async {
    setState(() {
      _isStatusUpdating = true;
    });

    try {
      await _courtService.updateCourt(
        id: court.id,
        facilityId: court.facilityId,
        name: court.name,
        facilityName: court.facilityName,
        sportType: court.sportType,
        address: court.address,
        pricePerHour: court.pricePerHour,
        status: isActive ? 'available' : 'maintenance',
        imageUrl: court.imageUrl,
        description: court.description,
        amenities: court.amenities,
        subCourts: court.subCourts,
        weekdayPricing: court.weekdayPricing,
        weekendPricing: court.weekendPricing,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể cập nhật trạng thái sân'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStatusUpdating = false;
        });
      }
    }
  }

  void _showDeleteDialog(Court court) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Bạn có chắc chắn muốn xóa sân "${court.name}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await _courtService.deleteCourt(court.id);
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa sân thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } catch (_) {
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Xóa sân thất bại, vui lòng thử lại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<String> _imageList(Court court) {
    if (court.imageUrl == null || court.imageUrl!.isEmpty) {
      return const <String>[];
    }
    return <String>[court.imageUrl!];
  }

  IconData _amenityIcon(String amenity) {
    final normalized = amenity.toLowerCase();
    if (normalized.contains('wifi')) {
      return Icons.wifi;
    }
    if (normalized.contains('gửi xe') || normalized.contains('parking')) {
      return Icons.local_parking;
    }
    if (normalized.contains('nước')) {
      return Icons.water_drop;
    }
    if (normalized.contains('đèn')) {
      return Icons.lightbulb;
    }
    if (normalized.contains('canteen') || normalized.contains('căn tin')) {
      return Icons.restaurant;
    }
    if (normalized.contains('tắm')) {
      return Icons.shower;
    }
    if (normalized.contains('khán đài') || normalized.contains('khan dai')) {
      return Icons.stadium;
    }
    if (normalized.contains('y tế') ||
        normalized.contains('y te') ||
        normalized.contains('first aid')) {
      return Icons.medical_services;
    }
    return Icons.check_circle_outline;
  }

  String _formatCurrency(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}

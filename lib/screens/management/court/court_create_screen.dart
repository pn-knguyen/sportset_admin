import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:sportset_admin/models/facility.dart';
import 'package:sportset_admin/models/sport.dart';
import 'package:sportset_admin/services/court_service.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/sport_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang thêm mới sân
class CourtCreateScreen extends StatefulWidget {
  const CourtCreateScreen({super.key});

  @override
  State<CourtCreateScreen> createState() => _CourtCreateScreenState();
}

class _CourtCreateScreenState extends State<CourtCreateScreen> {
  final TextEditingController _courtNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subCourtNameController = TextEditingController();

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  int _selectedPricingTab = 0;
  final int _currentNavIndex = 1;
  final CourtService _courtService = CourtService();
  final FacilityService _facilityService = FacilityService();
  final SportService _sportService = SportService();
  final AccessControlService _accessControlService = AccessControlService();
  
  bool _isSaving = false;
  bool _isLoadingFacilities = true;
  bool _isLoadingSports = true;
  bool _isUploadingImage = false;

  List<Facility> _facilities = <Facility>[];
  List<Sport> _sports = <Sport>[];
  String? _selectedFacilityId;
  File? _selectedImageFile;
  String? _uploadedImageUrl;

  String _selectedSport = '';

  final List<Map<String, dynamic>> _subCourts = [];

  final List<String> _selectedAmenities = [];

  final List<Map<String, dynamic>> _weekdayPricing = [];
  final List<TextEditingController> _weekdayPriceControllers = [];

  final List<Map<String, dynamic>> _weekendPricing = [];
  final List<TextEditingController> _weekendPriceControllers = [];

  @override
  void initState() {
    super.initState();
    _checkCreatePermission();
    _loadSports();
    _loadFacilities();
  }
  
  Future<void> _checkCreatePermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'courts', 'create');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền tạo sân'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _loadSports() async {
    try {
      final sports = await _sportService.getAllSports();
      if (!mounted) {
        return;
      }

      setState(() {
        _sports = sports.where((sport) => sport.isVisible).toList();
        if (_sports.isNotEmpty) {
          _selectedSport = _sports.first.name;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSports = false;
        });
      }
    }
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _facilityService.getAllFacilities();
      if (!mounted) {
        return;
      }

      setState(() {
        _facilities = facilities;
        if (_facilities.isNotEmpty) {
          _selectedFacilityId = _facilities.first.id;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFacilities = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1440,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImageFile == null) {
      return null;
    }

    try {
      setState(() {
        _isUploadingImage = true;
      });

      final fileName = 'courts/${DateTime.now().millisecondsSinceEpoch}_${_selectedImageFile!.path.split('/').last}';
      final Reference ref = FirebaseStorage.instance.ref().child(fileName);

      final UploadTask uploadTask = ref.putFile(_selectedImageFile!);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _courtNameController.dispose();
    _descriptionController.dispose();
    _subCourtNameController.dispose();
    for (final c in _weekdayPriceControllers) {
      c.dispose();
    }
    for (final c in _weekendPriceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildFacilitySelector(),
                    const SizedBox(height: 24),
                    _buildImageUploadSection(),
                    const SizedBox(height: 24),
                    _buildCourtInfoSection(),
                    const SizedBox(height: 32),
                    _buildSubCourtsSection(),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),
                    _buildAmenitiesSection(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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
              child: Text(
                'Th\u00eam S\u00e2n M\u1edbi',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitySelector() {
    if (_isLoadingFacilities) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Cơ sở chủ quản',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedFacilityId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            icon: const Icon(Icons.expand_more, color: Colors.grey),
            dropdownColor: Colors.white,
            items: _facilities.map((facility) {
                  return DropdownMenuItem(
                    value: facility.id,
                    child: Text(facility.name),
                  );
                })
                .toList(),
            onChanged: _facilities.isEmpty
                ? null
                : (value) {
                    final selected = _facilities.firstWhere(
                      (facility) => facility.id == value,
                    );
                    setState(() {
                      _selectedFacilityId = selected.id;
                    });
                  },
          ),
        ),
      ],
    );
  }

  Facility? _currentFacility() {
    if (_selectedFacilityId == null) {
      return null;
    }

    for (final facility in _facilities) {
      if (facility.id == _selectedFacilityId) {
        return facility;
      }
    }
    return null;
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _selectedImageFile != null ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _selectedImageFile != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _selectedImageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  if (_isUploadingImage)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 32, color: _primary),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chọn ảnh khác',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_a_photo, size: 32, color: _primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tải ảnh thực tế sân bãi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCourtInfoSection() {
    return Column(
      children: [
        // Tên cụm sân
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Tên cụm sân',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                  letterSpacing: 0.5,
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _courtNameController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Khu sân cỏ nhân tạo',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Loại môn thể thao
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Loại môn thể thao',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                  letterSpacing: 0.5,
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoadingSports
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedSport.isEmpty ? null : _selectedSport,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.sports_soccer, color: _primary),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        hintText: _sports.isEmpty
                            ? 'Chưa có danh mục môn thể thao'
                            : 'Chọn môn thể thao',
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      icon: const Icon(Icons.expand_more, color: Colors.grey),
                      dropdownColor: Colors.white,
                      items: _sports
                          .map(
                            (sport) => DropdownMenuItem(
                              value: sport.name,
                              child: Text(sport.name),
                            ),
                          )
                          .toList(),
                      onChanged: _sports.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _selectedSport = value ?? '';
                              });
                            },
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubCourtsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh s\u00e1ch s\u00e2n con',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 8),
        // Add sub-court input row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _subCourtNameController,
                  decoration: InputDecoration(
                    hintText: 'Nh\u1eadp t\u00ean s\u00e2n (A1, A2...)',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _primary, width: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_subCourtNameController.text.isNotEmpty) {
                  setState(() {
                    _subCourts.add({
                      'name': _subCourtNameController.text,
                      'isActive': true,
                    });
                    _subCourtNameController.clear();
                  });
                }
              },
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        if (_subCourts.isNotEmpty) const SizedBox(height: 12),
        // Sub-courts list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _subCourts.length,
          itemBuilder: (context, index) {
            final court = _subCourts[index];
            final isActive = court['isActive'] as bool;
            final label = (court['name'] as String).length <= 3
                ? court['name'] as String
                : (court['name'] as String).substring(0, 2);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _primary.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive
                            ? _primary.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? _primary : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Text(
                        court['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    // Status toggle chip
                    GestureDetector(
                      onTap: () => setState(
                          () => court['isActive'] = !(court['isActive'] as bool)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? _primary.withValues(alpha: 0.12)
                              : const Color(0xFFBA1A1A).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? _primary : const Color(0xFFBA1A1A),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isActive ? Icons.check_circle : Icons.build_circle,
                              size: 13,
                              color: isActive ? _primary : const Color(0xFFBA1A1A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isActive ? 'Ho\u1ea1t \u0111\u1ed9ng' : 'B\u1ea3o tr\u00ec',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isActive ? _primary : const Color(0xFFBA1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 20),
                      onPressed: () => setState(() => _subCourts.removeAt(index)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    final pricingList = _selectedPricingTab == 0 ? _weekdayPricing : _weekendPricing;
    final priceControllers = _selectedPricingTab == 0 ? _weekdayPriceControllers : _weekendPriceControllers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'B\u1ea3ng gi\u00e1 theo khung gi\u1edd',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _onSurface),
          ),
        ),
        // Tab switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildPricingTab('Ng\u00e0y th\u01b0\u1eddng', 0),
              _buildPricingTab('Cu\u1ed1i tu\u1ea7n', 1),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Slot rows
        ...List.generate(pricingList.length, (index) {
          final pricing = pricingList[index];
          final timeText = '${pricing['startTime']} - ${pricing['endTime']}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Time card (flex 5) - tappable
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    onTap: () => _pickPricingTime(pricingList, index),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF5F5F5)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              timeText,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _onSurfaceVariant),
                            ),
                          ),
                          const Icon(Icons.edit, size: 16, color: _primary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Price card (flex 5) - editable
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF5F5F5)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceControllers[index],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _onSurface),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: '0',
                            ),
                            onChanged: (v) {
                              pricing['price'] = int.tryParse(v) ?? 0;
                            },
                          ),
                        ),
                        const Icon(Icons.payments, size: 16, color: _primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete (flex 2)
                SizedBox(
                  width: 36,
                  child: IconButton(
                    onPressed: () => setState(() {
                      priceControllers[index].dispose();
                      priceControllers.removeAt(index);
                      pricingList.removeAt(index);
                    }),
                    icon: const Icon(Icons.close, color: Color(0xFF6F7A6B)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Add slot button
        GestureDetector(
          onTap: () {
            final facility = _currentFacility();
            final startTime = facility?.openTime ?? '06:00';
            final endTime = facility?.closeTime ?? '22:00';
            setState(() {
              pricingList.add({'startTime': startTime, 'endTime': endTime, 'price': 0});
              priceControllers.add(TextEditingController(text: '0'));
            });
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: _primary.withValues(alpha: 0.3), width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: _primary),
                SizedBox(width: 8),
                Text('Th\u00eam khung gi\u1edd', style: TextStyle(fontWeight: FontWeight.bold, color: _primary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Add pricing group text button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.library_add, color: _primary, size: 20),
            label: const Text(
              'TH\u00caM NH\u00d3M B\u1ea2NG GI\u00c1 M\u1edaI',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _primary, letterSpacing: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingTab(String label, int tabIndex) {
    final isActive = _selectedPricingTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPricingTab = tabIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? _primary : _onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _timeInRange(TimeOfDay t, TimeOfDay open, TimeOfDay close) {
    final tMins = t.hour * 60 + t.minute;
    final oMins = open.hour * 60 + open.minute;
    final cMins = close.hour * 60 + close.minute;
    return tMins >= oMins && tMins <= cMins;
  }

  Future<void> _pickPricingTime(
      List<Map<String, dynamic>> pricingList, int index) async {
    final facility = _currentFacility();
    final open = _parseTime(facility?.openTime ?? '06:00');
    final close = _parseTime(facility?.closeTime ?? '22:00');

    final currentStart = _parseTime(pricingList[index]['startTime'] as String);
    final pickedStart = await showTimePicker(
      context: context,
      initialTime: currentStart,
      helpText: 'Chọn giờ bắt đầu',
    );
    if (pickedStart == null || !mounted) return;
    if (!_timeInRange(pickedStart, open, close)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Giờ bắt đầu phải trong khoảng ${_formatTime(open)} - ${_formatTime(close)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentEnd = _parseTime(pricingList[index]['endTime'] as String);
    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: currentEnd,
      helpText: 'Chọn giờ kết thúc',
    );
    if (pickedEnd == null || !mounted) return;
    if (!_timeInRange(pickedEnd, open, close)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Giờ kết thúc phải trong khoảng ${_formatTime(open)} - ${_formatTime(close)}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final startMins = pickedStart.hour * 60 + pickedStart.minute;
    final endMins = pickedEnd.hour * 60 + pickedEnd.minute;
    if (endMins <= startMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giờ kết thúc phải sau giờ bắt đầu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      pricingList[index]['startTime'] = _formatTime(pickedStart);
      pricingList[index]['endTime'] = _formatTime(pickedEnd);
    });
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Mô tả chi tiết',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariant,
              letterSpacing: 0.5,
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
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Nhập mô tả về tiện ích, mặt sân, lưu ý...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = [
      {'icon': Icons.wifi, 'name': 'Wifi'},
      {'icon': Icons.local_parking, 'name': 'G\u1eedi xe'},
      {'icon': Icons.water_drop, 'name': 'N\u01b0\u1edbc'},
      {'icon': Icons.shower, 'name': 'T\u1eafm r\u1eeda'},
      {'icon': Icons.lightbulb, 'name': '\u0110\u00e8n \u0111\u00eam'},
      {'icon': Icons.stadium, 'name': 'Kh\u00e1n \u0111\u00e0i'},
      {'icon': Icons.restaurant, 'name': 'Canteen'},
      {'icon': Icons.medical_services, 'name': 'Y t\u1ebf'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Ti\u1ec7n \u00edch \u0111i k\u00e8m',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _onSurface,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: amenities.length,
          itemBuilder: (context, index) {
            final amenity = amenities[index];
            final isSelected = _selectedAmenities.contains(amenity['name']);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAmenities.remove(amenity['name']);
                  } else {
                    _selectedAmenities.add(amenity['name'] as String);
                  }
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? _primary : Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      amenity['icon'] as IconData,
                      size: 24,
                      color: isSelected ? Colors.white : const Color(0xFF6F7A6B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    amenity['name'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _primary : _onSurfaceVariant,
                      letterSpacing: 0.3,
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

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _darkGreen],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveCourt,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSaving)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.save, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _isSaving ? 'Đang lưu...' : 'Lưu Thông Tin',
              style: const TextStyle(
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

  Future<void> _saveCourt() async {
    if (_selectedFacilityId == null || _selectedFacilityId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn cơ sở chủ quản'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_courtNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên cụm sân'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn danh mục môn thể thao'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedFacility = _currentFacility();
    if (selectedFacility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin cơ sở đã chọn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final int price =
        (_weekdayPricing.isNotEmpty
                ? (_weekdayPricing.first['price'] as num?)
                : 0)
            ?.toInt() ??
        0;

    final hasActiveSubCourt = _subCourts.any(
      (court) => court['isActive'] == true,
    );

    try {
      // Upload image if selected
      if (_selectedImageFile != null) {
        final imageUrl = await _uploadImageToFirebase();
        if (imageUrl != null) {
          setState(() {
            _uploadedImageUrl = imageUrl;
          });
        }
      }

      await _courtService.createCourt(
        facilityId: selectedFacility.id,
        name: _courtNameController.text.trim(),
        facilityName: selectedFacility.name,
        sportType: _selectedSport,
        address: selectedFacility.address,
        pricePerHour: price,
        status: hasActiveSubCourt ? 'available' : 'maintenance',
        description: _descriptionController.text.trim(),
        amenities: List<String>.from(_selectedAmenities),
        imageUrl: _uploadedImageUrl,
        subCourts: _subCourts
            .map(
              (court) => {
                'name': court['name'],
                'status': (court['isActive'] == true)
                    ? 'available'
                    : 'maintenance',
              },
            )
            .toList(),
        weekdayPricing: _weekdayPricing
            .map(
              (item) => {
                'startTime': item['startTime'],
                'endTime': item['endTime'],
                'price': item['price'],
              },
            )
            .toList(),
        weekendPricing: _weekendPricing
            .map(
              (item) => {
                'startTime': item['startTime'],
                'endTime': item['endTime'],
                'price': item['price'],
              },
            )
            .toList(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo sân thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo sân thất bại, vui lòng thử lại'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

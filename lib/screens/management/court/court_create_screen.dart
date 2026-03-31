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

  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF5722);
  final int _currentNavIndex = 1;
  final CourtService _courtService = CourtService();
  final FacilityService _facilityService = FacilityService();
  final SportService _sportService = SportService();
  final AccessControlService _accessControlService = AccessControlService();
  
  bool _isSaving = false;
  bool _isLoadingFacilities = true;
  bool _isLoadingSports = true;
  bool _hasCreatePermission = true;
  bool _isUploadingImage = false;

  List<Facility> _facilities = <Facility>[];
  List<Sport> _sports = <Sport>[];
  String? _selectedFacilityId;
  File? _selectedImageFile;
  String? _uploadedImageUrl;

  String _selectedSport = '';

  final List<Map<String, dynamic>> _subCourts = [
    {'name': 'Sân A1', 'isActive': true},
    {'name': 'Sân A2', 'isActive': true},
    {'name': 'Sân A3', 'isActive': false},
    {'name': 'Sân A4', 'isActive': true},
  ];

  final List<String> _selectedAmenities = ['Wifi', 'Gửi xe'];

  final List<Map<String, dynamic>> _weekdayPricing = [
    {'startTime': '05:00', 'endTime': '16:00', 'price': 150000},
    {'startTime': '17:00', 'endTime': '22:00', 'price': 250000},
  ];

  final List<Map<String, dynamic>> _weekendPricing = [
    {'startTime': '05:00', 'endTime': '22:00', 'price': 300000},
  ];

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
    
    setState(() => _hasCreatePermission = hasPermission);
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
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: _navyColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Thêm Sân Mới',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navyColor,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 32),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
            color: _orangeColor.withValues(alpha: 0.3),
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
                          child: Icon(Icons.edit, size: 32, color: _orangeColor),
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
                      color: _orangeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_a_photo, size: 32, color: _orangeColor),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
                    borderSide: BorderSide(color: _orangeColor, width: 2),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
                        prefixIcon: Icon(Icons.sports_soccer, color: _orangeColor),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: _orangeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Danh sách sân con',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Add sub-court input
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _subCourtNameController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên sân (A1, A2...)',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _orangeColor, width: 2),
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
                    color: _orangeColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _orangeColor.withValues(alpha: 0.3),
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
          const SizedBox(height: 16),
          // Sub-courts list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subCourts.length,
            itemBuilder: (context, index) {
              final court = _subCourts[index];
              final isActive = court['isActive'] as bool;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFF8F6)
                        : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          court['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                        ),
                      ),
                      // Toggle switch
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              _subCourts[index]['isActive'] = value;
                            });
                          },
                          activeThumbColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          isActive ? 'Sẵn sàng' : 'Đang bảo trì',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.green[700]
                                : Colors.red[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _subCourts.removeAt(index);
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Info message
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'Cho phép '),
                        TextSpan(
                          text: '${_subCourts.length} khách',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _navyColor,
                          ),
                        ),
                        const TextSpan(text: ' đặt cùng lúc trong khung giờ.'),
                      ],
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

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Bảng giá theo khung giờ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        // Weekday pricing
        _buildPricingCard(
          title: 'Ngày thường',
          selectedDays: [true, true, true, true, true, false, false],
          pricingList: _weekdayPricing,
        ),
        const SizedBox(height: 24),
        // Weekend pricing
        _buildPricingCard(
          title: 'Cuối tuần',
          selectedDays: [false, false, false, false, false, true, true],
          pricingList: _weekendPricing,
        ),
        const SizedBox(height: 16),
        // Add new pricing group button
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: _orangeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _orangeColor.withValues(alpha: 0.3),
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
          child: TextButton(
            onPressed: () {
              // TODO: Add new pricing group
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_add, size: 22, color: _orangeColor),
                const SizedBox(width: 8),
                Text(
                  'Thêm nhóm bảng giá mới',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _orangeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required List<bool> selectedDays,
    required List<Map<String, dynamic>> pricingList,
  }) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
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
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.grey[400],
                onPressed: () {
                  // TODO: Delete pricing group
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Days selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isSelected = selectedDays[index];
              return GestureDetector(
                onTap: () {
                  // TODO: Toggle day selection
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? _orangeColor : Colors.grey[50],
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _orangeColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Time slots
          ...pricingList.asMap().entries.map((entry) {
            final pricing = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Time range
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeDropdown(pricing['startTime']),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Colors.grey[300],
                          ),
                        ),
                        Expanded(child: _buildTimeDropdown(pricing['endTime'])),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // TODO: Remove time slot
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.payments,
                            color: Colors.grey,
                          ),
                          suffixText: 'VNĐ',
                          suffixStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                          hintText: 'Nhập giá',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        controller: TextEditingController(
                          text: pricing['price'].toString(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Add time slot button
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: _orangeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _orangeColor.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: TextButton(
              onPressed: () {
                // TODO: Add time slot
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 18, color: _orangeColor),
                  const SizedBox(width: 4),
                  Text(
                    'Thêm khung giờ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _orangeColor,
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

  Widget _buildTimeDropdown(String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        icon: Icon(Icons.expand_more, size: 18, color: Colors.grey[400]),
        dropdownColor: Colors.white,
        items:
            [
              '05:00',
              '06:00',
              '07:00',
              '08:00',
              '09:00',
              '10:00',
              '11:00',
              '12:00',
              '13:00',
              '14:00',
              '15:00',
              '16:00',
              '17:00',
              '18:00',
              '19:00',
              '20:00',
              '21:00',
              '22:00',
              '23:00',
            ].map((time) {
              return DropdownMenuItem(value: time, child: Text(time));
            }).toList(),
        onChanged: (value) {
          // TODO: Update time
        },
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Mô tả chi tiết',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
                borderSide: BorderSide(color: _orangeColor, width: 2),
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
      {'icon': Icons.local_parking, 'name': 'Gửi xe'},
      {'icon': Icons.water_drop, 'name': 'Nước uống'},
      {'icon': Icons.shower, 'name': 'Tắm rửa'},
      {'icon': Icons.lightbulb, 'name': 'Đèn đêm'},
      {'icon': Icons.chair, 'name': 'Khán đài'},
      {'icon': Icons.local_cafe, 'name': 'Canteen'},
      {'icon': Icons.medical_services, 'name': 'Y tế'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 2),
          child: Text(
            'Tiện ích đi kèm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _navyColor,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.95,
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
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? _orangeColor.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? _orangeColor
                        : Colors.grey.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _orangeColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      size: 26,
                      color: isSelected ? _orangeColor : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      amenity['name'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? _orangeColor : Colors.grey[600],
                      ),
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

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFD32F2F)],
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

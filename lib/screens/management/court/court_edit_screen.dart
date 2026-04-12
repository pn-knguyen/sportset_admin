import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportset_admin/models/court.dart';
import 'package:sportset_admin/models/facility.dart';
import 'package:sportset_admin/models/sport.dart';
import 'package:sportset_admin/services/court_service.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/sport_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

// Trang chỉnh sửa sân
class CourtEditScreen extends StatefulWidget {
  const CourtEditScreen({super.key});

  @override
  State<CourtEditScreen> createState() => _CourtEditScreenState();
}

class _CourtEditScreenState extends State<CourtEditScreen> {
  final TextEditingController _courtNameController = TextEditingController(
    text: 'Sân Bóng Đá K300',
  );
  final TextEditingController _descriptionController = TextEditingController(
    text:
        'Sân mới nâng cấp mặt cỏ, hệ thống đèn chiếu sáng tiêu chuẩn. Có canteen phục vụ nước giải khát.',
  );
  final TextEditingController _subCourtNameController = TextEditingController();

  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  static const _tertiary = Color(0xFF994700);

  int _selectedPricingTab = 0;
  final int _currentNavIndex = 1;
  final CourtService _courtService = CourtService();
  final FacilityService _facilityService = FacilityService();
  final SportService _sportService = SportService();
  final AccessControlService _accessControlService = AccessControlService();
  
  String? _courtId;
  bool _didLoadInitialData = false;
  bool _isSaving = false;
  bool _isLoadingFacilities = true;

  List<Facility> _facilities = <Facility>[];
  List<Sport> _sports = <Sport>[];
  String? _selectedFacilityId;

  String _selectedFacility = '';
  String _selectedSport = '';

  final List<Map<String, dynamic>> _subCourts = [
    {'name': 'Sân A1', 'isActive': true},
    {'name': 'Sân A2', 'isActive': true},
    {'name': 'Sân A3', 'isActive': false},
    {'name': 'Sân A4', 'isActive': true},
  ];

  final List<String> _selectedAmenities = ['Wifi', 'Gửi xe', 'Canteen'];

  String _existingImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBimKqI_K3ErU0fFiygQjiFvtQuimeAaux_Cg2sGwexIKAmqiz6rjscATpgV0yUpnAE0hqg_UBnBirUkOn2dyeAw_WNKTL490x7sbdkiwYtiGQTBdNz3lzzlw_vY_5yIDTkWigcdfjnlZnhEfA_4c8PztUf70ixOUCk2o_md8bggUsKef12TEtfnJGe1kWRUYaxtyc9T3Za6A-XllgsL76O26pfZ_1n5_6-D3da3HGP5RNTTVEjitmGnQJWXLLwAZ-_LCUtr5IP3tHy';

  File? _selectedImageFile;
  bool _isUploadingImage = false;

  final List<Map<String, dynamic>> _weekdayPricing = [
    {'startTime': '05:00', 'endTime': '16:00', 'price': 150000},
    {'startTime': '17:00', 'endTime': '22:00', 'price': 250000},
  ];
  final List<TextEditingController> _weekdayPriceControllers = [];

  final List<Map<String, dynamic>> _weekendPricing = [
    {'startTime': '05:00', 'endTime': '22:00', 'price': 300000},
  ];
  final List<TextEditingController> _weekendPriceControllers = [];

  @override
  void initState() {
    super.initState();
    _checkEditPermission();
    _loadFacilities();
    _loadSports();
    
    // Initialize price controllers for default pricing data
    for (final item in _weekdayPricing) {
      _weekdayPriceControllers.add(
        TextEditingController(text: item['price'].toString()),
      );
    }
    for (final item in _weekendPricing) {
      _weekendPriceControllers.add(
        TextEditingController(text: item['price'].toString()),
      );
    }
  }
  
  Future<void> _checkEditPermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'courts', 'update');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền chỉnh sửa sân'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialData) {
      return;
    }

    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map && routeArgs['id'] is String) {
      final id = routeArgs['id'] as String;
      if (id.isNotEmpty) {
        _courtId = id;
        _didLoadInitialData = true;
        _loadCourtData(id);
      }
    }
  }

  Future<void> _loadCourtData(String id) async {
    try {
      final Court? court = await _courtService
          .getCourtById(id)
          .timeout(const Duration(seconds: 10));
      if (!mounted || court == null) {
        return;
      }

      setState(() {
        _courtNameController.text = court.name;
        _descriptionController.text = court.description;
        _selectedFacilityId = court.facilityId;
        _selectedFacility = court.facilityName.isNotEmpty
            ? court.facilityName
            : _selectedFacility;
        _selectedSport = court.sportType.isNotEmpty
            ? court.sportType
            : _selectedSport;
        _existingImage = court.imageUrl ?? _existingImage;

        _selectedAmenities
          ..clear()
          ..addAll(court.amenities);

        _subCourts
          ..clear()
          ..addAll(
            court.subCourts.map(
              (item) => {
                'name': item['name'] ?? '',
                'isActive': (item['status'] ?? 'available') == 'available',
              },
            ),
          );

        // Clear old controllers
        for (final c in _weekdayPriceControllers) {
          c.dispose();
        }
        for (final c in _weekendPriceControllers) {
          c.dispose();
        }
        _weekdayPriceControllers.clear();
        _weekendPriceControllers.clear();

        _weekdayPricing
          ..clear()
          ..addAll(court.weekdayPricing);

        _weekendPricing
          ..clear()
          ..addAll(court.weekendPricing);

        // Initialize controllers for pricing
        for (final item in _weekdayPricing) {
          _weekdayPriceControllers.add(
            TextEditingController(text: item['price'].toString()),
          );
        }
        for (final item in _weekendPricing) {
          _weekendPriceControllers.add(
            TextEditingController(text: item['price'].toString()),
          );
        }
      });

      _syncSelectedFacilityFromList();
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kết nối quá chậm, vui lòng thử lại'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải dữ liệu sân'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _facilityService.getAllFacilities();
      final uniqueFacilities = <Facility>[];
      final seenFacilityIds = <String>{};
      for (final facility in facilities) {
        if (seenFacilityIds.add(facility.id)) {
          uniqueFacilities.add(facility);
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _facilities = uniqueFacilities;
        if (_facilities.isEmpty) {
          _selectedFacilityId = null;
          _selectedFacility = '';
          return;
        }

        final hasCurrentSelection =
            _selectedFacilityId != null &&
            _facilities.any((facility) => facility.id == _selectedFacilityId);

        if (!hasCurrentSelection) {
          _selectedFacilityId = _facilities.first.id;
          _selectedFacility = _facilities.first.name;
        }
      });

      _syncSelectedFacilityFromList();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFacilities = false;
        });
      }
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
        final hasCurrentSelection =
            _selectedSport.isNotEmpty &&
            _sports.any((sport) => sport.name == _selectedSport);

        if (!hasCurrentSelection && _sports.isNotEmpty) {
          _selectedSport = _sports.first.name;
        } else if (_sports.isEmpty) {
          _selectedSport = '';
        }
      });
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _syncSelectedFacilityFromList() {
    if (_selectedFacilityId == null || _facilities.isEmpty) {
      return;
    }

    for (final facility in _facilities) {
      if (facility.id == _selectedFacilityId) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedFacility = facility.name;
        });
        return;
      }
    }
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

  String? _validatedFacilitySelection() {
    if (_selectedFacilityId == null || _selectedFacilityId!.isEmpty) {
      return null;
    }

    final matches = _facilities
        .where((facility) => facility.id == _selectedFacilityId)
        .length;
    return matches == 1 ? _selectedFacilityId : null;
  }

  List<String> _uniqueSportNames() {
    final uniqueNames = <String>[];
    final seenNames = <String>{};
    for (final sport in _sports) {
      if (sport.name.isEmpty) {
        continue;
      }
      if (seenNames.add(sport.name)) {
        uniqueNames.add(sport.name);
      }
    }
    return uniqueNames;
  }

  String? _validatedSportSelection(List<String> sportNames) {
    if (_selectedSport.isEmpty) {
      return null;
    }

    return sportNames.contains(_selectedSport) ? _selectedSport : null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1440,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImageFile == null) {
      return null;
    }

    try {
      setState(() => _isUploadingImage = true);

      final fileName =
          'courts/${DateTime.now().millisecondsSinceEpoch}_${_selectedImageFile!.path.split('/').last}';
      final uploadTask = FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(_selectedImageFile!);

      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() => _isUploadingImage = false);
      }

      return downloadUrl;
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildFacilitySelector(),
                    const SizedBox(height: 24),
                    _buildImageSection(),
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
                    const SizedBox(height: 32),
                    _buildUpdateButton(),
                    const SizedBox(height: 32),
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: _darkGreen),
            ),
            Expanded(
              child: Text(
                'Chỉnh sửa Sân',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen,
                  letterSpacing: -0.3,
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Cơ sở chủ quản',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _onSurfaceVariant),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _validatedFacilitySelection(),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurface,
            ),
            icon: const Icon(Icons.expand_more, color: _onSurfaceVariant),
            dropdownColor: Colors.white,
            items: _facilities.map((facility) {
              return DropdownMenuItem(value: facility.id, child: Text(facility.name));
            }).toList(),
            onChanged: _facilities.isEmpty
                ? null
                : (value) {
                    final selected = _facilities.firstWhere((f) => f.id == value);
                    setState(() {
                      _selectedFacilityId = selected.id;
                      _selectedFacility = selected.name;
                    });
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Hình ảnh thực tế',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _onSurfaceVariant),
          ),
        ),
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickImage,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBECAB9), width: 2),
                color: Colors.white.withValues(alpha: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_selectedImageFile != null)
                      Image.file(_selectedImageFile!, fit: BoxFit.cover)
                    else
                      Image.network(
                        _existingImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 60, color: Colors.grey),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: _isUploadingImage
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.photo_camera, color: _primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Thay đổi ảnh',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: _onSurface),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtInfoSection() {
    final sportNames = _uniqueSportNames();

    return Column(
      children: [
        // Tên cụm sân
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Tên cụm sân',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _onSurfaceVariant),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _courtNameController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Khu sân cỏ nhân tạo',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: _primary, width: 2),
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Loại môn thể thao
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Loại môn thể thao',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _onSurfaceVariant),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _validatedSportSelection(sportNames),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.sports_soccer, color: _primary),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  hintText: 'Chọn môn thể thao',
                ),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _onSurface),
                icon: const Icon(Icons.expand_more, color: _onSurfaceVariant),
                dropdownColor: Colors.white,
                items: sportNames
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: sportNames.isEmpty
                    ? null
                    : (value) => setState(() => _selectedSport = value ?? ''),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildSubCourtsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách sân con',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface),
        ),
        if (_subCourts.isNotEmpty) const SizedBox(height: 12),
        // Add input row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
                ),
                child: TextField(
                  controller: _subCourtNameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên sân (A5, A6...)',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    _subCourts.add({'name': _subCourtNameController.text, 'isActive': true});
                    _subCourtNameController.clear();
                  });
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
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
            final name = court['name'] as String;
            // Extract short label from name (e.g. "Sân A1" → "A1")
            final raw = name.startsWith('Sân ') ? name.substring(4) : name;
            final label = raw.split(' ').first;
            final shortLabel = label.length <= 3 ? label : label.substring(0, 2).toUpperCase();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isActive
                            ? _primary.withValues(alpha: 0.1)
                            : _tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          shortLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isActive ? _primary : _tertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: _onSurface)),
                    ),
                    // Status toggle chip
                    GestureDetector(
                      onTap: () => setState(() => court['isActive'] = !(court['isActive'] as bool)),
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
                              isActive ? 'Hoạt động' : 'Bảo trì',
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
                      onPressed: () => setState(() => _subCourts.removeAt(index)),
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A), size: 20),
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

    // Ensure controllers match pricing list
    while (priceControllers.length < pricingList.length) {
      priceControllers.add(
        TextEditingController(text: pricingList[priceControllers.length]['price'].toString()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Bảng giá theo khung giờ',
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
              _buildPricingTab('Ngày thường', 0),
              _buildPricingTab('Cuối tuần', 1),
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
                            controller: _weekdayPriceControllers[index],
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
                Text('Thêm khung giờ', style: TextStyle(fontWeight: FontWeight.bold, color: _primary)),
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
              'THÊM NHÓM BẢNG GIÁ MỚI',
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
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 2),
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
      {'icon': Icons.water_drop, 'name': 'Nước'},
      {'icon': Icons.shower, 'name': 'Tắm rửa'},
      {'icon': Icons.lightbulb, 'name': 'Đèn đêm'},
      {'icon': Icons.stadium, 'name': 'Khán đài'},
      {'icon': Icons.restaurant, 'name': 'Canteen'},
      {'icon': Icons.medical_services, 'name': 'Y tế'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ti\u1ec7n \u00edch \u0111i k\u00e8m',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _onSurface),
        ),
        const SizedBox(height: 16),
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
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: isSelected
                          ? [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Icon(
                      amenity['icon'] as IconData,
                      size: 24,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (amenity['name'] as String).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? _primary : _onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _darkGreen],
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
        onPressed: _isSaving ? null : _updateCourt,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Cập nhật thông tin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _updateCourt() async {
    if (_courtId == null || _courtId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy mã sân để cập nhật'),
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

    if (_selectedFacilityId == null || _selectedFacilityId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn cơ sở chủ quản'),
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
      String imageUrl = _existingImage;
      
      // Upload new image if selected
      if (_selectedImageFile != null) {
        final uploadedUrl = await _uploadImageToFirebase();
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
          _existingImage = uploadedUrl;
        }
      }

      await _courtService.updateCourt(
        id: _courtId!,
        facilityId: selectedFacility.id,
        name: _courtNameController.text.trim(),
        facilityName: selectedFacility.name,
        sportType: _selectedSport,
        address: selectedFacility.address,
        pricePerHour: price,
        status: hasActiveSubCourt ? 'available' : 'maintenance',
        imageUrl: imageUrl,
        description: _descriptionController.text.trim(),
        amenities: List<String>.from(_selectedAmenities),
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
        weekdayPricing: _weekdayPricing,
        weekendPricing: _weekendPricing,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật sân thành công'),
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
          content: Text('Cập nhật sân thất bại, vui lòng thử lại'),
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

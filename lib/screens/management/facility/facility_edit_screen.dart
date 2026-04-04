import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/screens/management/facility/map_picker_screen.dart';

// Trang chỉnh sửa cơ sở
class FacilityEditScreen extends StatefulWidget {
  const FacilityEditScreen({super.key});

  @override
  State<FacilityEditScreen> createState() => _FacilityEditScreenState();
}

class _FacilityEditScreenState extends State<FacilityEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _hotlineController;
  late TextEditingController _addressController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _descriptionController;

  String? _facilityId;
  bool _didLoadInitialData = false;
  final FacilityService _facilityService = FacilityService();
  final AccessControlService _accessControlService = AccessControlService();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImageFile;
  LatLng? _pickedLocation;

  final int _currentNavIndex = 1; // Active on Management tab
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);

  String _currentImage = '';

  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.wifi, 'label': 'Wifi', 'selected': true},
    {'icon': Icons.local_parking, 'label': 'Gửi xe', 'selected': true},
    {'icon': Icons.shower, 'label': 'Phòng tắm', 'selected': false},
    {'icon': Icons.restaurant, 'label': 'Căn tin', 'selected': true},
    {'icon': Icons.medical_services, 'label': 'Y tế', 'selected': false},
    {'icon': Icons.ac_unit, 'label': 'Máy lạnh', 'selected': true},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hotlineController = TextEditingController();
    _addressController = TextEditingController();
    _openTimeController = TextEditingController();
    _closeTimeController = TextEditingController();
    _descriptionController = TextEditingController();
    _checkEditPermission();
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
        _facilityId = id;
        _didLoadInitialData = true;
        _loadFacilityData(id);
      }
    }
  }

  Future<void> _loadFacilityData(String id) async {
    try {
      final facility = await _facilityService
          .getFacilityById(id)
          .timeout(const Duration(seconds: 10));
      if (facility != null && mounted) {
        setState(() {
          _nameController.text = facility.name;
          _hotlineController.text = facility.hotline;
          _addressController.text = facility.address;
          _openTimeController.text = facility.openTime;
          _closeTimeController.text = facility.closeTime;
          _descriptionController.text = facility.description;
          _currentImage = facility.imageUrl ?? '';
          _updateAmenities(facility.amenities);
          if (facility.latitude != null && facility.longitude != null) {
            _pickedLocation = LatLng(facility.latitude!, facility.longitude!);
          }
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy dữ liệu cơ sở'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kết nối Firebase quá chậm, vui lòng thử lại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateAmenities(List<String> selectedAmenities) {
    for (var i = 0; i < _amenities.length; i++) {
      _amenities[i]['selected'] = selectedAmenities.contains(
        _amenities[i]['label'],
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hotlineController.dispose();
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _checkEditPermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'facilities', 'update');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền chỉnh sửa cơ sở'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
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
                  const SizedBox(height: 16),
                  _buildImageSection(),
                  const SizedBox(height: 32),
                  _buildFormFields(),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
      ),
      child: SafeArea(
        bottom: false,
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Icon(Icons.chevron_left, size: 28, color: _navyColor),
              ),
            ),
            Text(
              'Chỉnh Sửa Cơ Sở',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _navyColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
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

      final fileName = 'facilities/${DateTime.now().millisecondsSinceEpoch}_${_selectedImageFile!.path.split('/').last}';
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

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 224,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _selectedImageFile != null
                ? Image.file(
                    _selectedImageFile!,
                    fit: BoxFit.cover,
                  )
                : (_currentImage.isEmpty
                    ? Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : Image.network(
                        _currentImage,
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
                      )),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.black.withValues(alpha: 0.2),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isUploadingImage ? null : _pickImage,
                icon: const Icon(Icons.photo_camera, size: 20),
                label: const Text(
                  'Thay đổi ảnh',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orangeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(label: 'Họ tên cơ sở', controller: _nameController),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Hotline',
          controller: _hotlineController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTextArea(
          label: 'Địa chỉ',
          controller: _addressController,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        _buildMapPickerEdit(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Giờ mở cửa',
                controller: _openTimeController,
                suffixIcon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Giờ đóng cửa',
                controller: _closeTimeController,
                suffixIcon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextArea(
          label: 'Mô tả',
          controller: _descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: 28),
        _buildAmenities(),
        const SizedBox(height: 32),
        _buildUpdateButton(),
      ],
    );
  }

  Widget _buildMapPickerEdit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (_) => MapPickerScreen(
                  initialLocation: _pickedLocation,
                  initialAddress: _addressController.text,
                ),
              ),
            );
            if (result != null) {
              setState(() => _pickedLocation = result['location'] as LatLng);
              final address = result['address'] as String;
              if (address.isNotEmpty) {
                _addressController.text = address;
              }
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _pickedLocation != null
                    ? _orangeColor.withValues(alpha: 0.6)
                    : Colors.grey.withValues(alpha: 0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _pickedLocation != null
                      ? Icons.location_on
                      : Icons.add_location_alt_outlined,
                  size: 20,
                  color: _pickedLocation != null ? _orangeColor : Colors.grey[400],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _pickedLocation != null
                        ? 'Đã chọn: ${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}'
                        : 'Chọn vị trí trên Google Maps',
                    style: TextStyle(
                      fontSize: 13,
                      color: _pickedLocation != null ? _navyColor : Colors.grey[400],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        if (_pickedLocation != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 160,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pickedLocation!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('preview'),
                        position: _pickedLocation!,
                      ),
                    },
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    liteModeEnabled: true,
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapPickerScreen(
                              initialLocation: _pickedLocation,
                              initialAddress: _addressController.text,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() => _pickedLocation = result['location'] as LatLng);
                          final address = result['address'] as String;
                          if (address.isNotEmpty) {
                            _addressController.text = address;
                          }
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedLocation = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _navyColor,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _orangeColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: Colors.grey[400], size: 20)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _navyColor,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _orangeColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 0),
          child: Text(
            'TIỆN ÍCH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _amenities.length,
          itemBuilder: (context, index) {
            final amenity = _amenities[index];
            final isSelected = amenity['selected'] as bool;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _amenities[index]['selected'] = !isSelected;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? _orangeColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _orangeColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      color: isSelected ? _orangeColor : Colors.grey[400],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      amenity['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? _orangeColor : Colors.grey[400],
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

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_orangeColor, const Color(0xFFF44336)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading
              ? null
              : () {
                  _updateFacility();
                },
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Cập nhật thay đổi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _updateFacility() {
    // Validation
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên cơ sở'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hotlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập hotline liên hệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ chi tiết'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get selected amenities
    final amenitiesList = _amenities
        .where((a) => a['selected'] as bool)
        .map((a) => a['label'] as String)
        .toList();

    _submitUpdate(amenitiesList);
  }

  Future<void> _submitUpdate(List<String> amenities) async {
    if (_facilityId == null || _facilityId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy mã cơ sở để cập nhật'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image if selected
      if (_selectedImageFile != null) {
        final imageUrl = await _uploadImageToFirebase();
        if (imageUrl != null) {
          setState(() {
            _currentImage = imageUrl;
          });
        }
      }

      await _facilityService.updateFacility(
        id: _facilityId!,
        name: _nameController.text.trim(),
        hotline: _hotlineController.text.trim(),
        address: _addressController.text.trim(),
        openTime: _openTimeController.text.trim(),
        closeTime: _closeTimeController.text.trim(),
        description: _descriptionController.text.trim(),
        amenities: amenities,
        imageUrl: _currentImage,
        latitude: _pickedLocation?.latitude,
        longitude: _pickedLocation?.longitude,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật cơ sở thành công'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

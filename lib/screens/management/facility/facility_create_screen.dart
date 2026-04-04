import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';
import 'package:sportset_admin/services/facility_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/screens/management/facility/map_picker_screen.dart';

// Trang thêm mới cơ sở
class FacilityCreateScreen extends StatefulWidget {
  const FacilityCreateScreen({super.key});

  @override
  State<FacilityCreateScreen> createState() => _FacilityCreateScreenState();
}

class _FacilityCreateScreenState extends State<FacilityCreateScreen> {
  final _nameController = TextEditingController();
  final _hotlineController = TextEditingController();
  final _addressController = TextEditingController();
  final _openTimeController = TextEditingController(text: '06:00');
  final _closeTimeController = TextEditingController(text: '22:00');
  final _descriptionController = TextEditingController();

  final int _currentNavIndex = 1; // Active on Management tab
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  final Color _redColor = const Color(0xFFF44336);

  final FacilityService _facilityService = FacilityService();
  final AccessControlService _accessControlService = AccessControlService();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImageFile;
  String? _uploadedImageUrl;
  LatLng? _pickedLocation;

  final List<Map<String, dynamic>> _amenities = [
    {'icon': Icons.local_parking, 'label': 'Gửi xe', 'selected': true},
    {'icon': Icons.wifi, 'label': 'Wifi', 'selected': true},
    {'icon': Icons.restaurant, 'label': 'Căn tin', 'selected': false},
    {'icon': Icons.checkroom, 'label': 'Phòng thay đồ', 'selected': true},
    {'icon': Icons.shower, 'label': 'Phòng tắm', 'selected': false},
    {'icon': Icons.lock_open, 'label': 'Tủ đồ', 'selected': false},
    {'icon': Icons.local_drink, 'label': 'Nước uống', 'selected': true},
    {'icon': Icons.sports_tennis, 'label': 'Thuê dụng cụ', 'selected': false},
    {'icon': Icons.medical_services, 'label': 'Y tế', 'selected': false},
  ];

  Future<void> _uploadImageToFirebase() async {
    if (_selectedImageFile == null) {
      return;
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
      setState(() {
        _uploadedImageUrl = downloadUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
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

  @override
  void initState() {
    super.initState();
    _checkCreatePermission();
  }
  
  Future<void> _checkCreatePermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'facilities', 'create');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền tạo cơ sở'),
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
              padding: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildImageUpload(),
                    const SizedBox(height: 32),
                    _buildFormFields(),
                    const SizedBox(height: 32),
                    _buildAmenities(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
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
                alignment: Alignment.centerLeft,
                child: Icon(Icons.chevron_left, size: 28, color: _navyColor),
              ),
            ),
            Text(
              'Thêm Cơ Sở Mới',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _navyColor,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _selectedImageFile != null ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImageFile != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
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
                      borderRadius: BorderRadius.circular(22),
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
                          child: Icon(Icons.photo_camera, size: 32, color: _orangeColor),
                        ),
                        const SizedBox(height: 8),
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
                    child: Icon(Icons.photo_camera, size: 32, color: _orangeColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tải ảnh thực tế',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Tên cơ sở',
          controller: _nameController,
          placeholder: 'Nhập tên cơ sở thể thao',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Hotline liên hệ',
          controller: _hotlineController,
          placeholder: '0xxx xxx xxx',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Địa chỉ chi tiết',
          controller: _addressController,
          placeholder: 'Số nhà, tên đường, phường/xã...',
        ),
        const SizedBox(height: 8),
        _buildMapPicker(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Giờ mở cửa',
                controller: _openTimeController,
                prefixIcon: Icons.schedule,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Giờ đóng cửa',
                controller: _closeTimeController,
                prefixIcon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextArea(
          label: 'Mô tả cơ sở',
          controller: _descriptionController,
          placeholder: 'Giới thiệu đôi nét về cơ sở của bạn...',
        ),
      ],
    );
  }

  Widget _buildMapPicker() {
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
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (_pickedLocation != null) ...
          [
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
    String? placeholder,
    IconData? prefixIcon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 20, color: Colors.grey[400])
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, size: 20, color: _orangeColor)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _orangeColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: _navyColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _orangeColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: _navyColor, fontSize: 14),
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
          padding: const EdgeInsets.only(left: 4, bottom: 2),
          child: Text(
            'Tiện ích chung',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _navyColor,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _orangeColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      size: 28,
                      color: isSelected ? _orangeColor : Colors.grey[400],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amenity['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? _orangeColor : Colors.grey[500],
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
        gradient: LinearGradient(colors: [_orangeColor, _redColor]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.2),
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
                  _saveFacility();
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
                    'Lưu Cơ Sở',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _saveFacility() {
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

    _createFacility(amenitiesList);
  }

  Future<void> _createFacility(List<String> amenities) async {
    setState(() => _isLoading = true);

    try {
      // Upload image if selected
      if (_selectedImageFile != null) {
        await _uploadImageToFirebase();
      }

      await _facilityService.createFacility(
        name: _nameController.text.trim(),
        hotline: _hotlineController.text.trim(),
        address: _addressController.text.trim(),
        openTime: _openTimeController.text.trim(),
        closeTime: _closeTimeController.text.trim(),
        description: _descriptionController.text.trim(),
        amenities: amenities,
        imageUrl: _uploadedImageUrl,
        latitude: _pickedLocation?.latitude,
        longitude: _pickedLocation?.longitude,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu cơ sở thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back after saving
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

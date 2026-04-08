import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportset_admin/models/staff.dart';
import 'package:sportset_admin/services/staff_service.dart';
import 'package:sportset_admin/services/access_control_service.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';
import 'dart:typed_data';

class StaffEditScreen extends StatefulWidget {
  const StaffEditScreen({super.key});

  @override
  State<StaffEditScreen> createState() => _StaffEditScreenState();
}

class _StaffEditScreenState extends State<StaffEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final StaffService _staffService = StaffService();
  final AccessControlService _accessControlService = AccessControlService();
  final ImagePicker _imagePicker = ImagePicker();
  
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);
  static const _iconTeal = Color(0xFF18A5A7);

  String? _staffId;
  String? _selectedPosition;
  String? _selectedWorkplace;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarFileName;
  bool _isLoading = false;
  bool _isActive = true;
  bool _initialized = false;

  final List<Map<String, String>> _positions = [
    {'value': 'admin', 'label': 'Quản trị viên'},
    {'value': 'manager', 'label': 'Quản lý cơ sở'},
    {'value': 'staff', 'label': 'Nhân viên vận hành'},
    {'value': 'coach', 'label': 'Huấn luyện viên'},
    {'value': 'receptionist', 'label': 'Lễ tân'},
  ];

  @override
  void initState() {
    super.initState();
    _checkEditPermission();
  }
  
  Future<void> _checkEditPermission() async {
    final permissionMap = await _accessControlService.getCurrentPermissionMap();
    final hasPermission = _accessControlService.can(permissionMap, 'staff', 'update');
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền chỉnh sửa nhân viên'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    _staffId = arguments?['id'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_staffId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh Sửa Nhân Viên')),
        body: const Center(child: Text('Không tìm thấy nhân viên')),
      );
    }

    return StreamBuilder<Staff?>(
      stream: _staffService.getStaffByIdStream(_staffId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_lightGreen, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_lightGreen, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(child: Text('Không tìm thấy nhân viên')),
            ),
          );
        }

        final staff = snapshot.data!;
        
        if (!_initialized) {
          _initialized = true;
          _nameController.text = staff.name;
          _phoneController.text = staff.phone;
          _emailController.text = staff.email;
          _selectedPosition = staff.position;
          _selectedWorkplace = staff.facilityId;
          _isActive = staff.status == 'active';
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_lightGreen, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: _darkGreen),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Chỉnh sửa nhân viên',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _darkGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildAvatarSection(staff),
                          const SizedBox(height: 32),
                          _buildFormFields(),
                          const SizedBox(height: 32),
                          _buildSaveButton(),
                          const SizedBox(height: 16),
                          _buildDeleteButton(staff),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildAvatarSection(Staff staff) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _selectedAvatarBytes != null
                ? Image.memory(_selectedAvatarBytes!, fit: BoxFit.cover)
                : staff.avatar != null
                    ? Image.network(
                        staff.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) => Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.grey[300],
                      ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isLoading ? null : _showImageSourceDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (pickedImage == null) {
        return;
      }

      final bytes = await pickedImage.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedAvatarBytes = bytes;
        _selectedAvatarFileName = pickedImage.name;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _inferImageContentType(String fileName) {
    final lowercase = fileName.toLowerCase();
    if (lowercase.endsWith('.png')) {
      return 'image/png';
    }
    if (lowercase.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  Future<String?> _uploadAvatarIfNeeded() async {
    if (_selectedAvatarBytes == null) {
      return null;
    }

    final safeFileName =
        (_selectedAvatarFileName ?? 'avatar.jpg').replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final filePath =
        'staff_avatars/${_staffId ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}_$safeFileName';
    final storageRef = FirebaseStorage.instance.ref().child(filePath);

    final metadata = SettableMetadata(
      contentType: _inferImageContentType(safeFileName),
    );
    final uploadTask = storageRef.putData(_selectedAvatarBytes!, metadata);
    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Họ và tên',
          controller: _nameController,
          icon: Icons.person,
          placeholder: 'Họ và tên',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.mail,
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Số điện thoại',
          controller: _phoneController,
          icon: Icons.phone,
          placeholder: 'Số điện thoại',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          label: 'Vị trí làm việc',
          icon: Icons.shield,
          placeholder: 'Chọn vị trí làm việc',
          value: _selectedPosition,
          items: _positions,
          onChanged: (value) => setState(() => _selectedPosition = value),
        ),
        const SizedBox(height: 20),
        _buildFacilityDropdown(),
        const SizedBox(height: 20),
        _buildStatusToggle(),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái hoạt động',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cho phép nhân viên đăng nhập',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.white,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.white,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? _primary
                  : Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String placeholder,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariant,
              letterSpacing: 1.2,
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
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: _iconTeal, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
            style: const TextStyle(fontSize: 14, color: _onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String placeholder,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedCount =
        items.where((item) => item['value'] == value).length;
    final safeSelectedValue = selectedCount == 1 ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariant,
              letterSpacing: 1.2,
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
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: safeSelectedValue,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: _iconTeal, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
            icon: const Icon(Icons.expand_more, color: _onSurfaceVariant),
            style: const TextStyle(fontSize: 14, color: _onSurface),
            dropdownColor: Colors.white,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'C\u01a0 S\u1eee L\u00c0M VI\u1ec6C',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('facilities')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                height: 58,
                child: const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: _primary, strokeWidth: 2),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: const Text('L\u1ed7i t\u1ea3i d\u1eef li\u1ec7u'),
              );
            }

            final facilities = snapshot.data?.docs ?? [];
            final selectedFacilityCount = facilities
                .where((facility) => facility.id == _selectedWorkplace)
                .length;
            final safeSelectedWorkplace =
                selectedFacilityCount == 1 ? _selectedWorkplace : null;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                initialValue: safeSelectedWorkplace,
                decoration: InputDecoration(
                  hintText: 'Ch\u1ecdn c\u01a1 s\u1edf l\u00e0m vi\u1ec7c',
                  hintStyle:
                      TextStyle(fontSize: 14, color: Colors.grey[400]),
                  prefixIcon: const Icon(
                      Icons.location_on, color: _iconTeal, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: _primary, width: 1.5),
                  ),
                ),
                icon:
                    const Icon(Icons.expand_more, color: _onSurfaceVariant),
                style: const TextStyle(fontSize: 14, color: _onSurface),
                dropdownColor: Colors.white,
                items: facilities.map((facility) {
                  final id = facility.id;
                  final name = facility['name'] ?? 'Unknown';
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedWorkplace = value),
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
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _darkGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _isLoading ? null : _handleUpdate,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Lưu thay đổi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedPosition == null ||
        _selectedWorkplace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final avatarUrl = await _uploadAvatarIfNeeded();

      // Get facility name from selected ID
      final facilityDoc = await FirebaseFirestore.instance
          .collection('facilities')
          .doc(_selectedWorkplace)
          .get();
      final facilityName = facilityDoc['name'] ?? _selectedWorkplace ?? '';

      final updateData = <String, dynamic>{
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'position': _selectedPosition,
        'facilityId': _selectedWorkplace,
        'facilityName': facilityName,
        'status': _isActive ? 'active' : 'inactive',
      };

      if (avatarUrl != null) {
        updateData['avatar'] = avatarUrl;
      }

      await _staffService.updateStaff(_staffId!, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật thông tin nhân viên'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDeleteButton(Staff staff) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: () {
          _showDeleteDialog(staff);
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Xóa nhân viên này',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red[500],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Staff staff) {
    final scaffoldContext = context; // Save outer context reference
    showDialog(
      context: scaffoldContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Xóa nhân viên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa nhân viên "${staff.name}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final messenger = ScaffoldMessenger.of(scaffoldContext);
                final navigator = Navigator.of(scaffoldContext);
                try {
                  await _staffService.deleteStaff(staff.id);
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa "${staff.name}"'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    navigator.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
}


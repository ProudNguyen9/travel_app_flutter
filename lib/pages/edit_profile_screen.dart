import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:travel_app/utils/extensions.dart';
import '../data/models/user_model.dart';
import '../data/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color accentBlue = const Color(0xFF24BAEC);
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  String? _localImagePath;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final profile = await ProfileService().getCurrentUserProfile();
    if (mounted) {
      setState(() {
        user = profile;
        _nameController.text = profile?.name ?? '';
        _phoneController.text = profile?.phone ?? '';
        _addressController.text = profile?.address ?? '';
        isLoading = false;
      });
    }
  }

  /// 🔹 Chọn ảnh từ thiết bị (Android/iOS), kiểm tra định dạng & upload lên Supabase
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      // ✅ Chỉ gọi pickImage khi context còn mounted
      if (!mounted) return;

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90, // giảm kích thước upload
      );

      if (picked == null) return; // người dùng bấm hủy

      final ext = path.extension(picked.path).toLowerCase();
      const allowed = ['.jpg', '.jpeg', '.png'];

      if (!allowed.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Chỉ chấp nhận ảnh JPG, JPEG hoặc PNG'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Hiển thị ảnh tạm thời trước
      setState(() => _localImagePath = picked.path);

      // ✅ Upload lên Supabase
      final url = await ProfileService().uploadAvatar(picked.path);

      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Không thể tải ảnh lên. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Cập nhật thông tin người dùng
      setState(() {
        user = user?.copyWith(profileImage: url);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ảnh đại diện đã được cập nhật!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, s) {
      debugPrint('🔥 Lỗi khi chọn ảnh: $e');
      debugPrintStack(stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Lỗi khi chọn ảnh: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ProfileService().updateUserProfile({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Cập nhật thông tin thành công!'
              : '❌ Có lỗi xảy ra. Vui lòng thử lại.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 390).clamp(0.8, 1.4);

    // if (isLoading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '     Chỉnh sửa hồ sơ cá nhân',
          style: GoogleFonts.lato(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20 * scale,
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: 26 * scale, vertical: 16 * scale),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10 * scale),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48 * scale,
                      backgroundImage: _localImagePath != null
                          ? FileImage(File(_localImagePath!))
                          : (user?.profileImage != null
                              ? NetworkImage(user!.profileImage!)
                              : const AssetImage('assets/images/splash1.png')
                                  as ImageProvider),
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(height: 10 * scale),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.camera_alt, color: accentBlue),
                      label: Text(
                        'Đổi ảnh đại diện',
                        style: GoogleFonts.lato(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w500,
                          color: accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32 * scale),

              // 🧾 Họ và tên
              _label('Họ và tên', scale),
              _inputBox(
                controller: _nameController,
                hint: 'Nhập họ tên',
                scale: scale,
              ),
              SizedBox(height: 16 * scale),

              // ☎️ Số điện thoại
              _label('Số điện thoại', scale),
              _inputBox(
                controller: _phoneController,
                hint: 'Nhập số điện thoại',
                scale: scale,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16 * scale),

              // 🏠 Địa chỉ
              _label('Địa chỉ', scale),
              _inputBox(
                controller: _addressController,
                hint: 'Nhập địa chỉ',
                scale: scale,
                keyboardType: TextInputType.streetAddress,
              ),
              SizedBox(height: 40 * scale),

              // ✅ Nút lưu
              Center(
                child: SizedBox(
                  width: context.deviceSize.width * 0.6,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32 * scale),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Cập nhật',
                      style: GoogleFonts.lato(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40 * scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, double scale) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 6 * scale),
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 15.5 * scale,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );

  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required double scale,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.lato(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding:
            EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 8 * scale),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentBlue, width: 1.2),
        ),
      ),
      validator: (value) => (value == null || value.trim().isEmpty)
          ? 'Không được để trống'
          : null,
    );
  }

  Widget _infoBox(String text, double scale) => Container(
        width: double.infinity,
        padding:
            EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 4 * scale),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            height: 1.4,
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/utils/ui_helpers.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _avatarUrlCtrl = TextEditingController();
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      _nameCtrl.text = auth.user!.name;
      _avatarUrlCtrl.text = auth.user!.avatar ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: _avatarUrlCtrl.text.isNotEmpty
                              ? NetworkImage(_avatarUrlCtrl.text)
                              : null,
                          child: _avatarUrlCtrl.text.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: AppColors.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        if (_uploadingAvatar)
                          const CircularProgressIndicator(color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FamiButton(
                    text: 'Lưu thay đổi',
                    icon: Icons.save_rounded,
                    loading: auth.loading,
                    onPressed: () async {
                      if (_nameCtrl.text.trim().isEmpty) {
                        UIHelpers.showSnackBar(context, 'Vui lòng nhập tên');
                        return;
                      }

                      final success =
                          await context.read<AuthProvider>().updateProfile(
                                _nameCtrl.text.trim(),
                                _avatarUrlCtrl.text.trim(),
                              );

                      if (context.mounted) {
                        if (success) {
                          UIHelpers.showSnackBar(
                              context, 'Cập nhật thành công');
                          Navigator.pop(context);
                        } else {
                          UIHelpers.showSnackBar(
                              context, auth.error ?? 'Lỗi cập nhật',
                              isError: true);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    XFile? selectedImage;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () async {
                Navigator.pop(ctx);
                selectedImage = await picker.pickImage(
                    source: ImageSource.camera, imageQuality: 80);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(ctx);
                selectedImage = await picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 80);
              },
            ),
          ],
        ),
      ),
    );

    if (selectedImage != null) {
      if (!mounted) return;
      setState(() => _uploadingAvatar = true);
      final bytes = await selectedImage!.readAsBytes();
      final url = await context
          .read<AuthProvider>()
          .uploadAvatar(bytes, selectedImage!.name);
      if (!mounted) return;
      setState(() {
        _uploadingAvatar = false;
        if (url != null) {
          _avatarUrlCtrl.text = url;
          UIHelpers.showSnackBar(
              context, 'Tải ảnh lên thành công. Vui lòng bấm "Lưu thay đổi".');
        } else {
          UIHelpers.showSnackBar(context, 'Lỗi tải ảnh lên', isError: true);
        }
      });
    }
  }
}

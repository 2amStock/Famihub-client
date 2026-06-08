import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/utils/ui_helpers.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Bảo mật & Mật khẩu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
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
              const Icon(Icons.lock_person_rounded, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              TextField(
                controller: _currentPasswordCtrl,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FamiButton(
                text: 'Đổi mật khẩu',
                icon: Icons.save_rounded,
                loading: auth.loading,
                onPressed: () async {
                  if (_currentPasswordCtrl.text.isEmpty || _newPasswordCtrl.text.isEmpty || _confirmPasswordCtrl.text.isEmpty) {
                    UIHelpers.showSnackBar(context, 'Vui lòng điền đầy đủ thông tin');
                    return;
                  }
                  
                  if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
                    UIHelpers.showSnackBar(context, 'Mật khẩu xác nhận không khớp');
                    return;
                  }

                  if (_newPasswordCtrl.text.length < 6) {
                    UIHelpers.showSnackBar(context, 'Mật khẩu mới phải có ít nhất 6 ký tự');
                    return;
                  }

                  final success = await context.read<AuthProvider>().changePassword(
                        _currentPasswordCtrl.text,
                        _newPasswordCtrl.text,
                      );

                  if (context.mounted) {
                    if (success) {
                      UIHelpers.showSnackBar(context, 'Đổi mật khẩu thành công');
                      Navigator.pop(context);
                    } else {
                      UIHelpers.showSnackBar(context, auth.error ?? 'Lỗi đổi mật khẩu', isError: true);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

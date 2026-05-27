import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../child/child_home_screen.dart';
import 'otp_verification_screen.dart';
import '../../core/utils/ui_helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  String _role = 'Parent';
  bool _showPass = false;
  bool _showConfirmPass = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    
    String finalEmail = _email.text.trim();
    // Nếu là con cái và không nhập định dạng email, tự động thêm đuôi giả để thỏa mãn Backend
    if (_role == 'Child' && !finalEmail.contains('@')) {
      finalEmail = '$finalEmail@famihub.local';
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _name.text.trim(), finalEmail, _pass.text, _role);
    if (!mounted) return;
    if (ok) {
      if (_role == 'Parent') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: _email.text.trim())),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
          (_) => false,
        );
      }
    } else {
      UIHelpers.showMessageBox(context, 'Lỗi', auth.error ?? 'Đăng ký thất bại', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20)
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Tạo tài khoản',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text('Tham gia FamiHub cùng gia đình bạn! 🏠',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),

                  // Role selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8C5A5)),
                    ),
                    child: Row(
                      children: [
                        _RoleButton(
                          label: '👨‍👩‍👧 Phụ huynh',
                          selected: _role == 'Parent',
                          onTap: () => setState(() => _role = 'Parent'),
                        ),
                        _RoleButton(
                          label: '🧒 Con cái',
                          selected: _role == 'Child',
                          onTap: () => setState(() => _role = 'Child'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        FamiTextField(
                          controller: _name,
                          label: 'Tên của bạn',
                          prefixIcon: Icons.person_rounded,
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Vui lòng nhập tên' : null,
                        ),
                        const SizedBox(height: 16),
                        FamiTextField(
                          controller: _email,
                          label: _role == 'Parent' ? 'Email' : 'Tên đăng nhập',
                          keyboardType: _role == 'Parent' ? TextInputType.emailAddress : TextInputType.text,
                          prefixIcon: _role == 'Parent' ? Icons.email_rounded : Icons.person_outline_rounded,
                          validator: (v) => (v?.isEmpty ?? true)
                              ? (_role == 'Parent' ? 'Vui lòng nhập email' : 'Vui lòng nhập tên đăng nhập') : null,
                        ),
                        const SizedBox(height: 16),
                        FamiTextField(
                          controller: _pass,
                          label: 'Mật khẩu',
                          obscure: !_showPass,
                          prefixIcon: Icons.lock_rounded,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _showPass = !_showPass),
                            child: Icon(
                              _showPass ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textHint,
                            ),
                          ),
                          validator: (v) => (v?.length ?? 0) < 6
                              ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                        ),
                        const SizedBox(height: 16),
                        FamiTextField(
                          controller: _confirmPass,
                          label: 'Xác nhận mật khẩu',
                          obscure: !_showConfirmPass,
                          prefixIcon: Icons.lock_clock_rounded,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _showConfirmPass = !_showConfirmPass),
                            child: Icon(
                              _showConfirmPass ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textHint,
                            ),
                          ),
                          validator: (v) {
                            if ((v?.isEmpty ?? true)) return 'Vui lòng xác nhận mật khẩu';
                            if (v != _pass.text) return 'Mật khẩu không khớp';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => FamiButton(
                            text: 'Đăng ký',
                            loading: auth.loading,
                            onPressed: _register,
                            icon: Icons.how_to_reg_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? ',
                          style: Theme.of(context).textTheme.bodyMedium),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Đăng nhập',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

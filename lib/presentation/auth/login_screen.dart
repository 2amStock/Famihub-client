import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../parent/parent_home_screen.dart';
import '../child/child_home_screen.dart';
import 'register_screen.dart';
import 'otp_verification_screen.dart';
import '../../core/utils/ui_helpers.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;

    String finalEmail = _email.text.trim();
    // Nếu người dùng nhập tên đăng nhập (không chứa @), tự động thêm domain
    if (!finalEmail.contains('@')) {
      finalEmail = '$finalEmail@famihub.local';
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(finalEmail, _pass.text);
    if (!mounted) return;
    if (ok && auth.user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => auth.user!.isParent
              ? const ParentHomeScreen()
              : const ChildHomeScreen(),
        ),
      );
    } else {
      if (auth.error == 'UNVERIFIED_EMAIL') {
        _showUnverifiedDialog(_email.text.trim());
      } else {
        UIHelpers.showMessageBox(context, 'Lỗi', auth.error ?? 'Đăng nhập thất bại', isError: true);
      }
    }
  }

  void _showUnverifiedDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tài khoản chưa xác thực'),
        content: const Text('Bạn cần xác thực email trước khi đăng nhập. Bạn có muốn đi tới trang xác thực ngay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email)),
              );
            },
            child: const Text('Đi tới Xác thực'),
          ),
        ],
      ),
    );
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
                  Text('Đăng nhập',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text('Chào mừng bạn quay lại FamiHub! 👋',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 32),

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
                          controller: _email,
                          label: 'Email / Tên đăng nhập',
                          prefixIcon: Icons.account_circle_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v?.isEmpty ?? true) ? 'Vui lòng nhập thông tin' : null,
                        ),
                        const SizedBox(height: 16),
                        FamiTextField(
                          controller: _pass,
                          label: 'Mật khẩu',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscure: !_showPass,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _showPass = !_showPass),
                            child: Icon(
                              _showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppColors.textHint,
                            ),
                          ),
                          validator: (v) => (v?.isEmpty ?? true) ? 'Vui lòng nhập mật khẩu' : null,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => FamiButton(
                            text: 'Đăng nhập',
                            loading: auth.loading,
                            onPressed: _login,
                            icon: Icons.login_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

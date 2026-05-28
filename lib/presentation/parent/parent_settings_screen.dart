import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../auth/login_screen.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/utils/ui_helpers.dart';
import '../subscription/subscription_screen.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Phụ huynh',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Tài khoản Phụ huynh',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.textHint),
                    onPressed: () {
                      _showComingSoon(context);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subscription Upgrade Banner
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B48FF), Color(0xFF9D83FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B48FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nâng cấp Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text('Mở khóa tính năng AI & hơn thế nữa', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('CÀI ĐẶT CHUNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 1.2)),
            ),
            
            _buildSettingsGroup([
              _buildSettingsItem(context, icon: Icons.notifications_active_rounded, color: Colors.orange, title: 'Thông báo', onTap: () => _showComingSoon(context)),
              _buildSettingsItem(context, icon: Icons.lock_rounded, color: Colors.blue, title: 'Bảo mật & Mật khẩu', onTap: () => _showComingSoon(context)),
              _buildSettingsItem(context, icon: Icons.language_rounded, color: Colors.teal, title: 'Ngôn ngữ', trailing: const Text('Tiếng Việt', style: TextStyle(color: AppColors.textSecondary)), onTap: () => _showComingSoon(context)),
              _buildSettingsItem(context, icon: Icons.dark_mode_rounded, color: Colors.indigo, title: 'Giao diện', trailing: const Text('Sáng', style: TextStyle(color: AppColors.textSecondary)), onTap: () => _showComingSoon(context), showDivider: false),
            ]),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('HỖ TRỢ & THÔNG TIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textHint, letterSpacing: 1.2)),
            ),
            
            _buildSettingsGroup([
              _buildSettingsItem(context, icon: Icons.help_rounded, color: Colors.green, title: 'Trung tâm trợ giúp', onTap: () => _showComingSoon(context)),
              _buildSettingsItem(context, icon: Icons.star_rounded, color: Colors.amber, title: 'Đánh giá ứng dụng', onTap: () => _showComingSoon(context)),
              _buildSettingsItem(context, icon: Icons.privacy_tip_rounded, color: Colors.grey, title: 'Chính sách bảo mật', onTap: () => _showComingSoon(context), showDivider: false),
            ]),

            const SizedBox(height: 32),
            
            FamiButton(
              text: 'Đăng xuất',
              icon: Icons.logout_rounded,
              color: Colors.red[400],
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            
            const SizedBox(height: 24),
            const Center(
              child: Text('Phiên bản 1.0.0', style: TextStyle(color: AppColors.textHint, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required Color color, required String title, Widget? trailing, bool showDivider = true, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
                if (trailing != null) ...[
                  trailing,
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
              ],
            ),
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.only(left: 60),
              child: Divider(height: 1, color: Color(0xFFF2F2F7)),
            ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    UIHelpers.showMessageBox(
      context,
      'Thông báo',
      'Tính năng đang được phát triển!',
    );
  }
}

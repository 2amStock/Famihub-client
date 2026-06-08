import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool pushEnabled = true;
  bool emailEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Cài đặt thông báo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitchItem('Thông báo đẩy (Push)', pushEnabled, (val) => setState(() => pushEnabled = val)),
          const SizedBox(height: 16),
          _buildSwitchItem('Thông báo qua Email', emailEnabled, (val) => setState(() => emailEnabled = val)),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Ngôn ngữ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tiếng Việt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('English (Coming Soon)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textHint)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Giao diện', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.light_mode_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Giao diện Sáng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dark_mode_rounded, color: AppColors.textHint),
                    SizedBox(width: 12),
                    Text('Giao diện Tối (Coming Soon)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Trung tâm trợ giúp', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFaqItem('Làm sao để thêm thành viên vào gia đình?', 'Bạn có thể chia sẻ mã mời ở màn hình Gia đình cho các thành viên khác.'),
          _buildFaqItem('Điểm thưởng dùng để làm gì?', 'Điểm thưởng được dùng để đổi các phần quà trong Cửa hàng.'),
          _buildFaqItem('Làm sao để đổi mật khẩu?', 'Vào Cài đặt > Bảo mật & Mật khẩu để thực hiện đổi mật khẩu.'),
          const SizedBox(height: 32),
          FamiButton(
            text: 'Gửi yêu cầu hỗ trợ',
            icon: Icons.mail_rounded,
            onPressed: () {
              // TODO: Implement email intent
            },
          )
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Chính sách bảo mật', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Chính sách bảo mật của FamiHub\n\n'
            '1. Thu thập thông tin\n'
            'Chúng tôi thu thập thông tin bạn cung cấp trực tiếp cho chúng tôi khi tạo tài khoản.\n\n'
            '2. Sử dụng thông tin\n'
            'Chúng tôi sử dụng thông tin thu thập được để cung cấp, duy trì và cải thiện dịch vụ của mình.\n\n'
            '3. Chia sẻ thông tin\n'
            'Chúng tôi không chia sẻ thông tin cá nhân của bạn với bên thứ ba trừ khi có sự đồng ý của bạn hoặc theo yêu cầu của pháp luật.\n\n'
            '4. Bảo mật dữ liệu\n'
            'Chúng tôi áp dụng các biện pháp bảo mật hợp lý để bảo vệ thông tin của bạn khỏi mất mát, đánh cắp, lạm dụng và truy cập trái phép.\n\n'
            '5. Liên hệ\n'
            'Nếu bạn có bất kỳ câu hỏi nào về Chính sách bảo mật này, vui lòng liên hệ với chúng tôi.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

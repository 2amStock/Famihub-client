import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/api_service.dart';
import '../../data/providers/providers.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  Future<void> _checkout(int planId) async {
    setState(() => _isLoading = true);
    final api = context.read<ApiService>();
    try {
      final url = await api.createPaymentLink(planId);
      setState(() => _isLoading = false);

      if (url != null) {
        if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở trang thanh toán')));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi tạo link thanh toán')));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Loại bỏ chữ "Exception: " nếu có
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required int planId,
    required bool isPopular,
    required int currentPlanId,
  }) {
    final isCurrent = planId == currentPlanId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular || isCurrent ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isCurrent)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.approved.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.approved),
                ),
                child: const Text(
                  'GÓI HIỆN TẠI',
                  style: TextStyle(color: AppColors.approved, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else if (isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PHỔ BIẾN NHẤT',
                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.approved, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isCurrent ? null : () => _checkout(planId),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrent ? Colors.grey[300] : (isPopular ? AppColors.primary : Colors.grey[200]),
              foregroundColor: isCurrent ? Colors.grey[600] : (isPopular ? Colors.white : Colors.black87),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isCurrent ? 'Đang sử dụng' : 'Chọn gói $title'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final currentPlanId = user?.currentPlanId ?? 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nâng cấp FamiHub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Mở khóa toàn bộ tính năng và không giới hạn!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildPlanCard(
                  title: 'FREE',
                  price: '0đ / tháng',
                  features: ['Tối đa 3 thành viên', 'Tối đa 5 công việc/ngày', 'Chỉ có phần thưởng cố định'],
                  planId: 1,
                  isPopular: false,
                  currentPlanId: currentPlanId,
                ),
                _buildPlanCard(
                  title: 'STARTER',
                  price: '79.000đ / tháng',
                  features: ['Tối đa 5 thành viên', 'Không giới hạn công việc', 'Phần thưởng tùy biến', 'Báo cáo học tập'],
                  planId: 2,
                  isPopular: false,
                  currentPlanId: currentPlanId,
                ),
                _buildPlanCard(
                  title: 'FAMILY',
                  price: '119.000đ / tháng',
                  features: [
                    'Không giới hạn thành viên',
                    'Full tính năng (Thực đơn AI, Lịch, Mua sắm...)',
                    'Hệ thống Thành tựu',
                  ],
                  planId: 3,
                  isPopular: true,
                  currentPlanId: currentPlanId,
                ),
                _buildPlanCard(
                  title: 'YEARLY',
                  price: '1.199.000đ / năm',
                  features: [
                    'Đầy đủ tính năng gói FAMILY',
                    'Tiết kiệm 229.000đ so với gói tháng',
                    'Thanh toán tiện lợi 1 lần/năm',
                  ],
                  planId: 4,
                  isPopular: false,
                  currentPlanId: currentPlanId,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

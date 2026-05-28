import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:famihub_flutter/core/utils/ui_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscriptionData();
    });
  }

  Future<void> _checkout(int planId) async {
    setState(() => _isPaying = true);
    final provider = context.read<SubscriptionProvider>();
    try {
      final url = await provider.getPaymentLink(planId);
      setState(() => _isPaying = false);

      if (url != null) {
        if (!await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication)) {
          if (mounted) {
            UIHelpers.showMessageBox(
                context, 'Lỗi', 'Không thể mở trang thanh toán',
                isError: true);
          }
        }
      } else {
        if (mounted) {
          final error = provider.error ?? 'Lỗi tạo link thanh toán';
          UIHelpers.showMessageBox(context, 'Lỗi', error, isError: true);
        }
      }
    } catch (e) {
      setState(() => _isPaying = false);
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        UIHelpers.showMessageBox(context, 'Lỗi', msg, isError: true);
      }
    }
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isCurrent,
  }) {
    final isPopular = plan.name == 'FAMILY';

    // Tạo danh sách features từ các boolean của plan
    List<String> features = [
      plan.maxMembers > 100
          ? 'Không giới hạn thành viên'
          : 'Tối đa ${plan.maxMembers} thành viên',
      plan.maxTasksPerDay > 100
          ? 'Không giới hạn công việc'
          : 'Tối đa ${plan.maxTasksPerDay} công việc/ngày',
    ];
    if (plan.hasAI) features.add('Thực đơn AI thông minh');
    if (plan.hasCalendar) features.add('Đồng bộ Lịch gia đình');
    if (plan.hasShoppingList) features.add('Quản lý Shopping List');
    if (plan.hasStudyTracking) features.add('Báo cáo học tập của con');
    if (plan.hasAchievement) features.add('Hệ thống Thành tựu & Huy hiệu');
    if (plan.name == 'FREE') features.add('Chỉ có phần thưởng cố định');

    // Format giá tiền (VD: 119000 -> 119.000đ)
    final priceStr =
        '${plan.price.toInt()}đ / ${plan.durationType == 'MONTHLY' ? 'tháng' : 'năm'}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular || isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.approved.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.approved),
                ),
                child: const Text(
                  'GÓI HIỆN TẠI',
                  style: TextStyle(
                      color: AppColors.approved,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          else if (isPopular)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PHỔ BIẾN NHẤT',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Text(plan.name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(priceStr,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.approved, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(f, style: const TextStyle(height: 1.4))),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isCurrent ? null : () => _checkout(plan.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrent
                  ? Colors.grey[300]
                  : (isPopular ? AppColors.primary : Colors.grey[200]),
              foregroundColor: isCurrent
                  ? Colors.grey[600]
                  : (isPopular ? Colors.white : Colors.black87),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isCurrent ? 'Đang sử dụng' : 'Chọn gói ${plan.name}'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final isLoading = subProvider.loading || _isPaying;
    final currentPlanId = subProvider.currentSubscription?.plan.id ?? 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nâng cấp FamiHub',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (!subProvider.loading &&
              subProvider.plans.isEmpty &&
              subProvider.error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(subProvider.error!,
                      style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: () => subProvider.loadSubscriptionData(),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            )
          else if (!subProvider.loading)
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
                  ...subProvider.plans.map((plan) => _buildPlanCard(
                        plan: plan,
                        isCurrent: plan.id == currentPlanId,
                      )),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

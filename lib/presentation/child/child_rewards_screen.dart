import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../core/utils/ui_helpers.dart';

class ChildRewardsScreen extends StatefulWidget {
  const ChildRewardsScreen({super.key});

  @override
  State<ChildRewardsScreen> createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RewardProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRedeemConfirm(Reward reward, int currentPoints) {
    if (currentPoints < reward.requiredPoints) {
      UIHelpers.showMessageBox(context, 'Thông báo', 'Chưa đủ điểm để đổi phần thưởng này', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đổi thưởng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn đổi phần thưởng "${reward.title}" với ${reward.requiredPoints} điểm không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<RewardProvider>().redeemReward(reward.id);
                if (mounted) {
                  // Reload user to update points
                  await context.read<AuthProvider>().refreshUser();
                  UIHelpers.showMessageBox(context, 'Thành công', 'Đổi phần thưởng thành công! Đang chờ duyệt.');
                }
              } catch (e) {
                if (mounted) UIHelpers.showMessageBox(context, 'Lỗi', e.toString(), isError: true);
              }
            },
            child: const Text('Đổi ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Cửa hàng', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.pending.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppColors.pending, size: 18),
                const SizedBox(width: 4),
                Text('${user?.points ?? 0}', style: const TextStyle(color: AppColors.pending, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Khám phá'),
            Tab(text: 'Lịch sử đổi'),
          ],
        ),
      ),
      body: Consumer<RewardProvider>(
        builder: (context, provider, child) {
          if (provider.loading) return const Center(child: CircularProgressIndicator());
          return TabBarView(
            controller: _tabController,
            children: [
              _buildExploreTab(provider, user?.points ?? 0),
              _buildHistoryTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExploreTab(RewardProvider provider, int currentPoints) {
    if (provider.rewards.isEmpty) {
      return const Center(child: Text('Cửa hàng hiện chưa có phần thưởng nào.'));
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadRewards(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: provider.rewards.length,
        itemBuilder: (context, index) {
          final reward = provider.rewards[index];
          final canAfford = currentPoints >= reward.requiredPoints;

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showRedeemConfirm(reward, currentPoints),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, size: 40, color: canAfford ? AppColors.primary : Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      reward.title, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford ? AppColors.pending.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 14, color: canAfford ? AppColors.pending : Colors.grey),
                          const SizedBox(width: 4),
                          Text('${reward.requiredPoints}', 
                            style: TextStyle(color: canAfford ? AppColors.pending : Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(RewardProvider provider) {
    if (provider.redemptions.isEmpty) {
      return const Center(child: Text('Bạn chưa đổi phần thưởng nào.'));
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadRedemptions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.redemptions.length,
        itemBuilder: (context, index) {
          final req = provider.redemptions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                child: const Icon(Icons.redeem, color: AppColors.textHint),
              ),
              title: Text(req.rewardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('- ${req.requiredPoints} điểm', style: const TextStyle(color: AppColors.pending, fontWeight: FontWeight.w600)),
                  if (req.parentNote != null && req.parentNote!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Bố/Mẹ nhắn: ${req.parentNote}', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
              trailing: _buildStatusChip(req.status),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    if (status == 'Pending') {
      color = AppColors.pending;
      text = 'Chờ duyệt';
    } else if (status == 'Approved') {
      color = AppColors.approved;
      text = 'Đã duyệt';
    } else {
      color = AppColors.rejected;
      text = 'Từ chối';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

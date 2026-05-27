import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../subscription/subscription_screen.dart';
import '../../core/utils/ui_helpers.dart';

class ParentRewardsScreen extends StatefulWidget {
  const ParentRewardsScreen({super.key});

  @override
  State<ParentRewardsScreen> createState() => _ParentRewardsScreenState();
}

class _ParentRewardsScreenState extends State<ParentRewardsScreen> with SingleTickerProviderStateMixin {
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

  void _showCreateEditDialog({Reward? reward}) {
    final titleController = TextEditingController(text: reward?.title);
    final descController = TextEditingController(text: reward?.description);
    final pointsController = TextEditingController(text: reward?.requiredPoints.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reward == null ? 'Thêm Phần Thưởng' : 'Sửa Phần Thưởng',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tên phần thưởng', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả (tuỳ chọn)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Điểm yêu cầu', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final title = titleController.text.trim();
              final points = int.tryParse(pointsController.text.trim()) ?? 0;
              if (title.isEmpty || points <= 0) {
                UIHelpers.showMessageBox(context, 'Lỗi', 'Vui lòng nhập tên và điểm hợp lệ', isError: true);
                return;
              }

              final provider = context.read<RewardProvider>();
              try {
                if (reward == null) {
                  await provider.createReward(title: title, description: descController.text.trim(), requiredPoints: points);
                } else {
                  await provider.updateReward(reward.id, title: title, description: descController.text.trim(), requiredPoints: points);
                }
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);
                  _showUpgradeDialog(e.toString());
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cần Nâng Cấp', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.rejected)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Để sau')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
            },
            child: const Text('Nâng cấp ngay'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa phần thưởng này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rejected, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<RewardProvider>().deleteReward(id);
              } catch (e) {
                if (mounted) _showUpgradeDialog(e.toString());
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(RewardRedemption req) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xử lý yêu cầu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bé ${req.child?.name ?? "N/A"} muốn đổi ${req.rewardTitle}'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Ghi chú cho con', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RewardProvider>().approveRedemption(req.id, false, parentNote: noteController.text.trim());
            },
            child: const Text('Từ chối', style: TextStyle(color: AppColors.rejected)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.approved, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RewardProvider>().approveRedemption(req.id, true, parentNote: noteController.text.trim());
            },
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Phần Thưởng', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Danh sách'),
            Tab(text: 'Yêu cầu đổi'),
          ],
        ),
      ),
      body: Consumer<RewardProvider>(
        builder: (context, provider, child) {
          if (provider.loading) return const Center(child: CircularProgressIndicator());
          return TabBarView(
            controller: _tabController,
            children: [
              _buildRewardsTab(provider),
              _buildRedemptionsTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRewardsTab(RewardProvider provider) {
    if (provider.rewards.isEmpty) {
      return const Center(child: Text('Chưa có phần thưởng nào.'));
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadRewards(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.rewards.length,
        itemBuilder: (context, index) {
          final reward = provider.rewards[index];
          final isSystem = reward.createdBy == null;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.card_giftcard, color: AppColors.primary),
              ),
              title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (reward.description != null && reward.description!.isNotEmpty) ...[
                    Text(reward.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 16, color: AppColors.pending),
                      const SizedBox(width: 4),
                      Text('${reward.requiredPoints} điểm', style: const TextStyle(color: AppColors.pending, fontWeight: FontWeight.bold)),
                      if (isSystem) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Hệ thống', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        )
                      ]
                    ],
                  ),
                ],
              ),
              trailing: isSystem ? null : PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: AppColors.rejected))),
                ],
                onSelected: (val) {
                  if (val == 'edit') _showCreateEditDialog(reward: reward);
                  if (val == 'delete') _showDeleteConfirm(reward.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRedemptionsTab(RewardProvider provider) {
    if (provider.redemptions.isEmpty) {
      return const Center(child: Text('Chưa có yêu cầu nào.'));
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${req.child?.name ?? "Bé"} muốn đổi: ${req.rewardTitle}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      _buildStatusChip(req.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Chi phí: ${req.requiredPoints} điểm', style: const TextStyle(color: AppColors.pending, fontWeight: FontWeight.w600)),
                  if (req.parentNote != null && req.parentNote!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Ghi chú: ${req.parentNote}', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                  if (req.isPending) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          onPressed: () => _showApproveDialog(req),
                          child: const Text('Xử lý'),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import 'task_list_screen.dart';
import 'create_task_screen.dart';
import 'parent_rewards_screen.dart';

import '../shared/notification_screen.dart';
import '../../core/utils/ui_helpers.dart';
import '../shared/family_calendar_screen.dart';
import '../shared/shopping_list_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const ParentHomeScreen({super.key, this.onNavigate});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadFamily();
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final family = context.watch<FamilyProvider>();
    final tasks = context.watch<TaskProvider>();
    final rewards = context.watch<RewardProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.wait([
              tasks.loadTasks(),
              rewards.loadAll(),
              auth.refreshUser(),
              context.read<NotificationProvider>().loadNotifications(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Minimalist Header Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _ScaleOnTap(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FamilyCalendarScreen(isParent: true)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: const Icon(Icons.calendar_today_rounded, size: 22, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ScaleOnTap(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: Stack(
                            children: [
                              const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.textPrimary),
                              if (context.watch<NotificationProvider>().unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Strong Typographic Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Xin chào,',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Quản lý gia đình\ncủa bạn.',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          height: 1.1,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Flat Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Bạn cần tìm gì?',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Scroll Categories (Bento Row)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _CategoryItem(
                        icon: Icons.add_task_rounded,
                        label: 'Giao việc',
                        color: AppColors.secondary,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                          );
                          if (result == true) tasks.loadTasks();
                        },
                      ),
                      const SizedBox(width: 12),
                      _CategoryItem(
                        icon: Icons.rate_review_rounded,
                        label: 'Duyệt việc',
                        color: AppColors.primary,
                        onTap: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(1);
                          } else {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (_) => const TaskListScreen()));
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _CategoryItem(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Đổi thưởng',
                        color: AppColors.accent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ParentRewardsScreen()),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _CategoryItem(
                        icon: Icons.family_restroom_rounded,
                        label: 'Gia đình',
                        color: AppColors.inProgress,
                        onTap: () {
                          final familyProvider = context.read<FamilyProvider>();
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(20),
                              child: familyProvider.family == null
                                  ? const _FamilySetupCard(isInline: false)
                                  : _FamilyInfoCard(family: familyProvider),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _CategoryItem(
                        icon: Icons.shopping_cart_rounded,
                        label: 'Mua sắm',
                        color: AppColors.textPrimary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ShoppingListScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Featured Tasks Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nhiệm vụ',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(1);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TaskListScreen()),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (!family.loading && family.family == null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _FamilySetupCard(isInline: true),
                  ),
                ),

              if (tasks.loading)
                const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              else if (tasks.tasks.where((t) => t.dueDate == null || t.dueDate!.isAfter(DateTime.now())).isEmpty && family.family != null)
                // Clean Empty State
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_outline_rounded,
                                size: 40, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Đã hoàn thành',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chưa có nhiệm vụ mới nào. Hãy giao việc cho các bé nhé.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final unexpiredTasks = tasks.tasks.where((t) => t.dueDate == null || t.dueDate!.isAfter(DateTime.now())).toList();
                      final t = unexpiredTasks.take(5).toList()[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: _ScaleOnTap(
                          onTap: t.isSubmitted ? () => _showReviewDialog(context, t) : null,
                          child: _FeaturedTaskCard(task: t),
                        ),
                      );
                    },
                    childCount: tasks.tasks.where((t) => t.dueDate == null || t.dueDate!.isAfter(DateTime.now())).take(5).length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: family.family != null
          ? FamiButton(
              text: 'Giao việc mới',
              width: 180,
              icon: Icons.add_rounded,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
                );
                if (result == true) tasks.loadTasks();
              },
            )
          : null,
    );
  }

  void _showReviewDialog(BuildContext context, dynamic task) {
    // Moved from _FeaturedTaskCard to parent so it has access to context
    final noteController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.rate_review_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Duyệt nhiệm vụ',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Flat Proof Card
                  if (task.proof != null) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: task.proof!.photoUrls.isNotEmpty ? task.proof!.photoUrls.first : '',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 200,
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 200,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                        child: Icon(Icons.broken_image_rounded, color: AppColors.textHint)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.proof!.note != null && task.proof!.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.format_quote_rounded, size: 20, color: AppColors.textHint),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      task.proof!.note!,
                                      style: const TextStyle(
                                          fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  FamiTextField(
                    label: '',
                    hint: 'Lý do nếu cần làm lại...',
                    controller: noteController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  LoadingOverlay(
                    loading: isSubmitting,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: Colors.black.withOpacity(0.1)),
                            ),
                            onPressed: () async {
                              setState(() => isSubmitting = true);
                              final ok = await context
                                  .read<TaskProvider>()
                                  .approveTask(task.id, false, rejectionNote: noteController.text);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (ok && context.mounted) {
                                UIHelpers.showMessageBox(context, 'Thông báo', 'Đã yêu cầu làm lại.');
                              }
                            },
                            child: const Text('Từ chối'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => isSubmitting = true);
                              final ok = await context.read<TaskProvider>().approveTask(task.id, true);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (ok && context.mounted) {
                                UIHelpers.showMessageBox(context, 'Thành công', 'Đã duyệt nhiệm vụ.');
                              }
                            },
                            child: const Text('Duyệt ngay'),
                          ),
                        ),
                      ],
                    ),
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

class _FamilySetupCard extends StatefulWidget {
  final bool isInline;
  const _FamilySetupCard({this.isInline = false});

  @override
  State<_FamilySetupCard> createState() => _FamilySetupCardState();
}

class _FamilySetupCardState extends State<_FamilySetupCard> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_rounded, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tạo gia đình', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    Text('Bắt đầu giao việc cho các thành viên.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Tên gia đình...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_nameCtrl.text.trim().isEmpty) return;
                final ok = await context.read<FamilyProvider>().createFamily(_nameCtrl.text.trim());
                if (ok && context.mounted) {
                  UIHelpers.showMessageBox(context, 'Thành công', 'Đã tạo không gian gia đình.');
                }
              },
              child: const Text('Tạo ngay'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyInfoCard extends StatelessWidget {
  final FamilyProvider family;
  const _FamilyInfoCard({required this.family});

  @override
  Widget build(BuildContext context) {
    final f = family.family!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Thông tin chung', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: Row(
              children: [
                const Text('Mã mời:', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Text(f.inviteCode,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary, letterSpacing: 1)),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: f.inviteCode));
                    UIHelpers.showMessageBox(context, 'Thành công', 'Đã sao chép: ${f.inviteCode}');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: f.members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = f.members[index];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(member.role == 'Parent' ? 'Phụ huynh' : '${member.points} điểm',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _ScaleOnTap(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedTaskCard extends StatelessWidget {
  final dynamic task;
  const _FeaturedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final bool isActionRequired = task.isSubmitted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActionRequired ? AppColors.primary : Colors.black.withOpacity(0.04),
          width: isActionRequired ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActionRequired ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActionRequired ? Icons.rate_review_rounded : Icons.assignment_rounded,
              color: isActionRequired ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (task.assignedTo != null)
                      Text(task.assignedTo!.name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    if (task.assignedTo != null && task.dueDate != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('•', style: TextStyle(color: AppColors.textHint)),
                      ),
                    if (task.dueDate != null)
                      Text(DateFormat('HH:mm, dd/MM').format(task.dueDate!), style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
                  ],
                ),
              ],
            ),
          ),
          if (isActionRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Duyệt', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// Simple Scale Animation Wrapper for tactile feedback (Rule 4.5)
class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ScaleOnTap({required this.child, this.onTap});

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null ? (_) {
        _controller.reverse();
        widget.onTap!();
      } : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

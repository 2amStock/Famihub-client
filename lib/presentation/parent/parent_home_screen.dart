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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
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
                // Custom AppBar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const Icon(Icons.menu_rounded,
                        //     size: 28, color: AppColors.textPrimary),
                        Row(
                          children: [
                            Text(
                              'FAMI',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Text(
                              ' HUB',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.calendar_today_rounded,
                                  size: 26, color: AppColors.textPrimary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const FamilyCalendarScreen(isParent: true)),
                                );
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                                );
                              },
                              child: Stack(
                                children: [
                                  const Icon(Icons.notifications_none_rounded,
                                      size: 28, color: AppColors.textPrimary),
                                  if (context.watch<NotificationProvider>().unreadCount > 0)
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 12,
                                          minHeight: 12,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${context.watch<NotificationProvider>().unreadCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Greeting & House Image
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              'Xin chào, 👋',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Chào mừng bạn đến với\nFami Hub!',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                            // Space for house image
                          ],
                        ),
                        // Positioned(
                        //   right: -20,
                        //   bottom: 0,
                        //   child: Image.asset(
                        //     'assets/images/logo.png', // Temporary placeholder for 3D house
                        //     height: 160,
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Bạn cần tìm gì?',
                          hintStyle: const TextStyle(
                              color: AppColors.textHint, fontSize: 15),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.textHint),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 20,
                      children: [
                        _CategoryItem(
                          icon: Icons.add_task_rounded,
                          label: 'Giao việc',
                          color: AppColors.secondary,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CreateTaskScreen()),
                            );
                            if (result == true) tasks.loadTasks();
                          },
                        ),
                        _CategoryItem(
                          icon: Icons.rate_review_rounded,
                          label: 'Duyệt việc',
                          color: AppColors.pending,
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(1);
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const TaskListScreen()));
                            }
                          },
                        ),
                        _CategoryItem(
                          icon: Icons.card_giftcard_rounded,
                          label: 'Đổi thưởng',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ParentRewardsScreen()),
                            );
                          },
                        ),
                        _CategoryItem(
                          icon: Icons.family_restroom_rounded,
                          label: 'Gia đình',
                          color: AppColors.inProgress,
                          onTap: () {
                            final familyProvider =
                                context.read<FamilyProvider>();
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
                        _CategoryItem(
                          icon: Icons.shopping_cart_rounded,
                          label: 'Mua sắm',
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ShoppingListScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Featured/Recent Tasks Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nhiệm vụ nổi bật',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(1);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TaskListScreen()),
                              );
                            }
                          },
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Family setup info warning if no family
                if (!family.loading && family.family == null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: const _FamilySetupCard(isInline: true),
                    ),
                  ),

                // Tasks List
                if (tasks.loading)
                  const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()))
                else if (tasks.tasks.where((t) => t.dueDate == null || t.dueDate!.isAfter(DateTime.now())).isEmpty && family.family != null)
                  const SliverToBoxAdapter(
                      child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt,
                            size: 60, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Chưa có nhiệm vụ nào',
                            style: TextStyle(color: AppColors.textHint)),
                      ],
                    ),
                  ))
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final unexpiredTasks = tasks.tasks.where((t) => t.dueDate == null || t.dueDate!.isAfter(DateTime.now())).toList();
                        final t = unexpiredTasks.take(5).toList()[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: _FeaturedTaskCard(task: t),
                        );
                      },
                      childCount: tasks.tasks.where((t) => t.dueDate == null || t.dueDate!.isAfter(DateTime.now())).take(5).length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: family.family != null
          ? FamiButton(
              text: 'Giao việc',
              width: 160,
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
}

class _FamilySetupCard extends StatefulWidget {
  final bool isInline;
  const _FamilySetupCard({this.isInline = false});

  @override
  State<_FamilySetupCard> createState() => _FamilySetupCardState();
}

class _FamilySetupCardState extends State<_FamilySetupCard> {
  final _nameCtrl = TextEditingController();
  bool _isHidden = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isHidden) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        children: [
          const Icon(Icons.home_rounded,
              size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          const Text('Tạo gia đình của bạn',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Tạo gia đình để bắt đầu giao việc cho các con',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Tên gia đình',
              prefixIcon: Icon(Icons.family_restroom_rounded),
            ),
          ),
          const SizedBox(height: 12),
          FamiButton(
            text: 'Tạo gia đình',
            icon: Icons.add_home_rounded,
            onPressed: () async {
              if (_nameCtrl.text.trim().isEmpty) return;
              final ok = await context
                  .read<FamilyProvider>()
                  .createFamily(_nameCtrl.text.trim());
              if (ok && context.mounted) {
                UIHelpers.showMessageBox(
                    context, 'Thành công', 'Tạo gia đình thành công!');
              }
            },
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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.textPrimary)),
                    Text('${f.members.length} thành viên đang tham gia',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_rounded,
                    color: AppColors.textPrimary, size: 20),
                const SizedBox(width: 12),
                const Text('Mã mời: ',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                Text(f.inviteCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.primary,
                        letterSpacing: 2)),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: f.inviteCode));
                    UIHelpers.showMessageBox(context, 'Thành công',
                        'Đã sao chép mã mời: ${f.inviteCode}');
                  },
                  icon: const Icon(Icons.copy_rounded,
                      size: 20, color: AppColors.textPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Thành viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: f.members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = f.members[index];
                final isParent = member.role == 'Parent';
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isParent
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.white,
                    border:
                        Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            isParent ? AppColors.primary : AppColors.secondary,
                        child: Text(
                          member.name.isNotEmpty
                              ? member.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                            Text(
                              isParent
                                  ? 'Phụ huynh'
                                  : 'Con cái - ${member.points} điểm',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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

    return GestureDetector(
      onTap: isActionRequired ? () => _showReviewDialog(context) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActionRequired
                ? AppColors.secondary.withOpacity(0.5)
                : Colors.black.withOpacity(0.05),
            width: isActionRequired ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActionRequired
                  ? AppColors.secondary.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isActionRequired
                    ? AppColors.secondary.withOpacity(0.1)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActionRequired
                    ? Icons.rate_review_rounded
                    : Icons.assignment_rounded,
                color: isActionRequired
                    ? AppColors.secondary
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (task.assignedTo != null)
                        Expanded(
                          child: Text(
                            task.assignedTo!.name,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (task.assignedTo != null && task.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                                color: AppColors.textHint,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                      ],
                      if (task.dueDate != null)
                        Text(
                          DateFormat('HH:mm, dd/MM').format(task.dueDate!),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isActionRequired)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('DUYỆT NGAY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5)),
                  )
                else
                  StatusBadge(status: task.status),
                const SizedBox(height: 6),
                PointsBadge(points: task.points),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    final noteController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              gradient: AppColors.backgroundGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.rate_review_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Duyệt nhiệm vụ 🧐',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Proof Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.proof != null) ...[
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: task.proof!.photoUrls.isNotEmpty ? task.proof!.photoUrls.first : '',
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 240,
                                    color: const Color(0xFFF2F2F7),
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary)),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 200,
                                    color: const Color(0xFFF2F2F7),
                                    child: const Center(
                                        child: Icon(Icons.broken_image_rounded,
                                            size: 48,
                                            color: AppColors.textHint)),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person_pin_rounded,
                                            color: Colors.white, size: 14),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            'Từ: ${task.assignedTo?.name ?? "Con"} • ${DateFormat('HH:mm').format(task.proof!.submittedAt)}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.proof!.note != null &&
                              task.proof!.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.chat_bubble_rounded,
                                      size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '"${task.proof!.note}"',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textPrimary,
                                          height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('PHẢN HỒI (NẾU TỪ CHỐI)',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondary,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  FamiTextField(
                    label: '',
                    hint: 'Nhập lý do nếu cần làm lại...',
                    controller: noteController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  LoadingOverlay(
                    loading: isSubmitting,
                    child: Row(
                      children: [
                        Expanded(
                          child: FamiButton(
                            text: 'Từ chối',
                            outlined: true,
                            color: AppColors.rejected,
                            icon: Icons.close_rounded,
                            onPressed: () async {
                              setState(() => isSubmitting = true);
                              final ok = await context
                                  .read<TaskProvider>()
                                  .approveTask(task.id, false,
                                      rejectionNote: noteController.text);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (ok && context.mounted) {
                                UIHelpers.showMessageBox(context, 'Thông báo',
                                    'Đã yêu cầu bé làm lại ❌');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FamiButton(
                            text: 'Duyệt ✓',
                            color: AppColors.approved,
                            icon: Icons.check_rounded,
                            onPressed: () async {
                              setState(() => isSubmitting = true);
                              final ok = await context
                                  .read<TaskProvider>()
                                  .approveTask(task.id, true);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (ok && context.mounted) {
                                UIHelpers.showMessageBox(context, 'Tuyệt vời',
                                    'Đã duyệt và tặng điểm');
                              }
                            },
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

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

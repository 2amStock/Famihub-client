import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/login_screen.dart';
import 'task_list_screen.dart';
import 'create_task_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

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
    final user = auth.user!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await Future.wait([
                family.loadFamily(),
                tasks.loadTasks(),
                auth.refreshUser(),
              ]);
            },
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppColors.parentGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
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
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person_rounded,
                                    size: 28, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Chào ngày mới,',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Text(user.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Phụ huynh',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Family info or setup
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: family.loading
                        ? const Center(child: CircularProgressIndicator())
                        : family.family == null
                            ? _FamilySetupCard()
                            : _FamilyInfoCard(family: family),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.pending_actions_rounded,
                            label: 'Chờ làm',
                            count: tasks.pendingTasks.length,
                            color: AppColors.pending,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.rate_review_rounded,
                            label: 'Chờ duyệt',
                            count: tasks.submittedTasks.length,
                            color: AppColors.submitted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Recent tasks
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nhiệm vụ gần đây',
                            style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TaskListScreen())),
                          child: const Text('Xem tất cả →'),
                        ),
                      ],
                    ),
                  ),
                ),

                if (tasks.loading)
                  const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()))
                else if (tasks.tasks.isEmpty)
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
                        final t = tasks.tasks.take(5).toList()[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: _TaskPreviewCard(task: t),
                        );
                      },
                      childCount: tasks.tasks.take(5).length,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Column(
        children: [
          const Icon(Icons.home_rounded, size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          const Text('Tạo gia đình của bạn',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Tạo gia đình để bắt đầu giao việc cho các con',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tạo gia đình thành công! 🎉')));
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Đã sao chép mã mời: ${f.inviteCode}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ));
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
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.count,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text('$count',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TaskPreviewCard extends StatelessWidget {
  final dynamic task;
  const _TaskPreviewCard({required this.task});

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
                                  imageUrl: task.proof!.fullPhotoUrl,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Đã yêu cầu bé làm lại ❌')));
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Tuyệt vời! Đã duyệt và tặng điểm ✅')));
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

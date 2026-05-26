import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/login_screen.dart';
import 'my_tasks_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
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

    final myPending = tasks.tasks.where((t) =>
        t.isPending || t.isInProgress || t.isRejected).toList();
    final mySubmitted = tasks.tasks.where((t) => t.isSubmitted).toList();
    final myDone = tasks.tasks.where((t) => t.isApproved).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.accent,
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
                      gradient: AppColors.childGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
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
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.face_retouching_natural_rounded, size: 28, color: AppColors.secondary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Chào mừng trở lại,',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                                  Text(user.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5)),
                                  const SizedBox(height: 2),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('ĐIỂM TÍCH LŨY',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  Text('${auth.user?.points ?? 0}',
                                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1)),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Family join card
                if (family.family == null && !family.loading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _JoinFamilyCard(),
                    ),
                  ),

                // Family badge
                if (family.family != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_rounded,
                                color: AppColors.primary, size: 24),
                            const SizedBox(width: 10),
                            Text(family.family!.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                            const Spacer(),
                            Text('${family.family!.members.length} thành viên',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
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
                                icon: Icons.assignment_rounded,
                                label: 'Cần làm',
                                count: myPending.length,
                                color: AppColors.pending)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _StatCard(
                                icon: Icons.upload_rounded,
                                label: 'Chờ duyệt',
                                count: mySubmitted.length,
                                color: AppColors.submitted)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _StatCard(
                                icon: Icons.emoji_events_rounded,
                                label: 'Đã xong',
                                count: myDone.length,
                                color: AppColors.approved)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Quick actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nhiệm vụ của tôi',
                            style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const MyTasksScreen())),
                          child: const Text('Xem tất cả →'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Task list preview
                if (tasks.loading)
                  const SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                  color: AppColors.accent))))
                else if (tasks.tasks.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Text('🎉', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('Không có nhiệm vụ nào! Bạn rảnh rồi 😊',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final t = myPending.take(5).toList();
                        if (i >= t.length) return null;
                        final task = t[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          child: GestureDetector(
                            onTap: () => Navigator.push(ctx,
                                MaterialPageRoute(
                                    builder: (_) => MyTasksScreen(
                                        initialTask: task))),
                            child: _ChildTaskCard(task: task),
                          ),
                        );
                      },
                      childCount: myPending.take(5).length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FamiButton(
        text: 'Làm việc ngay',
        width: 200,
        icon: Icons.play_arrow_rounded,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MyTasksScreen())),
      ),
    );
  }
}

class _JoinFamilyCard extends StatefulWidget {
  @override
  State<_JoinFamilyCard> createState() => _JoinFamilyCardState();
}

class _JoinFamilyCardState extends State<_JoinFamilyCard> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.family_restroom_rounded,
              size: 40, color: AppColors.accent),
          const SizedBox(height: 8),
          const Text('Tham gia gia đình',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Nhập mã mời từ phụ huynh để bắt đầu',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Mã mời (8 ký tự)',
              prefixIcon: Icon(Icons.key_rounded),
            ),
          ),
          const SizedBox(height: 12),
          FamiButton(
            text: 'Tham gia gia đình',
            icon: Icons.login_rounded,
            color: AppColors.accent,
            onPressed: () async {
              if (_ctrl.text.trim().isEmpty) return;
              try {
                final ok = await context
                    .read<FamilyProvider>()
                    .joinFamily(_ctrl.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Tham gia gia đình thành công! 🎉'
                        : 'Mã mời không hợp lệ'),
                    backgroundColor:
                        ok ? AppColors.approved : AppColors.rejected,
                  ));
                }
              } catch (e) {
                if (context.mounted) {
                  if (e.toString().contains('LIMIT_EXCEEDED')) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Gia đình này đã đạt giới hạn thành viên miễn phí. Phụ huynh cần nâng cấp gói!'),
                      backgroundColor: AppColors.rejected,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: AppColors.rejected,
                    ));
                  }
                }
              }
            },
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text('$count',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

class _ChildTaskCard extends StatelessWidget {
  final dynamic task;
  const _ChildTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final bool isRejected = task.status == 'Rejected';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRejected ? AppColors.rejected.withOpacity(0.5) : Colors.black.withOpacity(0.05),
          width: isRejected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              task.status == 'Approved' 
                  ? Icons.check_circle_rounded 
                  : (isRejected ? Icons.error_outline_rounded : Icons.assignment_rounded),
              color: task.status == 'Approved' 
                  ? AppColors.approved 
                  : (isRejected ? AppColors.rejected : AppColors.secondary),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate != null 
                          ? DateFormat('HH:mm, dd/MM').format(task.dueDate!) 
                          : 'Không thời hạn',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(status: task.status),
              const SizedBox(height: 6),
              PointsBadge(points: task.points),
            ],
          ),
        ],
      ),
    );
  }
}

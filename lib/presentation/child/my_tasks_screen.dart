import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/utils/ui_helpers.dart';

class MyTasksScreen extends StatefulWidget {
  final FamilyTask? initialTask;
  const MyTasksScreen({super.key, this.initialTask});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ của tôi'),
        bottom: TabBar(
          controller: _tabController,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4, color: AppColors.secondary),
            insets: EdgeInsets.symmetric(horizontal: 48),
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Outfit'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Outfit'),
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textHint,
          tabs: const [
            Tab(text: 'Cần làm'),
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã xong'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: TabBarView(
          controller: _tabController,
          children: [
            _TaskList(tasks: taskProvider.pendingTasks),
            _TaskList(tasks: taskProvider.submittedTasks),
            _TaskList(tasks: taskProvider.completedTasks),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<FamilyTask> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Text('🏖️', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 24),
            const Text('Chưa có nhiệm vụ nào ở đây',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Nghỉ ngơi thôi nào! 😊',
                style: TextStyle(color: AppColors.textHint, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final canSubmit = task.isPending || task.isInProgress || task.isRejected;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: task.isRejected ? AppColors.rejected.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              width: task.isRejected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: task.isApproved ? AppColors.approved.withOpacity(0.1) : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        task.isApproved ? Icons.verified_rounded : Icons.assignment_rounded,
                        color: task.isApproved ? AppColors.approved : AppColors.secondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title, 
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(task.description ?? 'Nhiệm vụ không có mô tả cụ thể.',
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
                          if (task.dueDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('HH:mm, dd/MM/yyyy').format(task.dueDate!),
                                    style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          if (task.isRejected && task.rejectionNote != null)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.rejected.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.rejected.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.rejected),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Cần sửa: ${task.rejectionNote}',
                                      style: const TextStyle(fontSize: 13, color: AppColors.rejected, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    PointsBadge(points: task.points),
                    const Spacer(),
                    if (canSubmit)
                      FamiButton(
                        text: task.isRejected ? 'Nộp lại' : 'Nộp bài',
                        icon: Icons.camera_alt_rounded,
                        width: 160,
                        height: 44,
                        onPressed: () => _submitProof(context, task.id),
                      )
                    else if (task.isSubmitted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hourglass_bottom_rounded, size: 16, color: AppColors.secondary),
                            SizedBox(width: 8),
                            Text('Chờ duyệt...', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 13)),
                          ],
                        ),
                      )
                    else
                      StatusBadge(status: task.status),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitProof(BuildContext context, int taskId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);

    if (image != null) {
      if (!context.mounted) return;
      
      // Hiển thị loading
      UIHelpers.showMessageBox(context, 'Thông báo', 'Đang nộp minh chứng...');

      final bytes = await image.readAsBytes();
      final success = await context.read<TaskProvider>().submitTask(taskId, null, bytes, image.name);

      if (!context.mounted) return;
      if (success) {
        UIHelpers.showMessageBox(context, 'Thành công', 'Đã nộp minh chứng thành công!');
      } else {
        UIHelpers.showMessageBox(context, 'Lỗi', 'Có lỗi xảy ra khi nộp.', isError: true);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final List<String> _statuses = ['Tất cả', 'Chờ duyệt', 'Hoàn thành'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhiệm vụ'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: _statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => tasks.loadTasks(),
        child: TabBarView(
          controller: _tab,
          children: [
            _TaskTabView(items: tasks.tasks),
            _TaskTabView(items: tasks.submittedTasks),
            _TaskTabView(items: tasks.completedTasks),
          ],
        ),
      ),
    );
  }
}

class _TaskTabView extends StatelessWidget {
  final List<dynamic> items;
  const _TaskTabView({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('Không có nhiệm vụ',
                style: TextStyle(color: AppColors.textHint, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final task = items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(task.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      PointsBadge(points: task.points),
                    ],
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 6),
                    Text(task.description!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (task.assignedTo != null) ...[
                        const Icon(Icons.person_rounded,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            task.assignedTo!.name,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (task.dueDate != null) ...[
                        const Icon(Icons.calendar_today_rounded,
                            size: 12, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(task.dueDate!),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Spacer(),
                      StatusBadge(status: task.status),
                    ],
                  ),
                  if (task.isSubmitted) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.submitted.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.photo_camera_rounded,
                              size: 14, color: AppColors.submitted),
                          SizedBox(width: 6),
                          Text('Đã nộp ảnh bằng chứng – chờ phụ huynh duyệt',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.submitted,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
}

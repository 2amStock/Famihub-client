import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:famihub_flutter/core/utils/ui_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';

class TaskDetailScreen extends StatefulWidget {
  final FamilyTask task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late FamilyTask _task;
  bool _approving = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _approve(bool approved) async {
    String? note;
    if (!approved) {
      note = await _showNoteDialog();
      if (note == null) return;
    }

    setState(() => _approving = true);
    final tasks = context.read<TaskProvider>();
    final ok = await tasks.approveTask(_task.id, approved, rejectionNote: note);
    if (!mounted) return;
    setState(() => _approving = false);

    if (ok) {
      final updated = tasks.tasks.firstWhere((t) => t.id == _task.id,
          orElse: () => _task);
      setState(() => _task = updated);
      UIHelpers.showMessageBox(
        context,
        approved ? 'Thành công' : 'Thông báo',
        approved
            ? '✅ Đã duyệt nhiệm vụ! Con được cộng ${_task.points} điểm 🌟'
            : '❌ Đã từ chối nhiệm vụ.',
        isError: !approved,
      );
    }
  }

  Future<String?> _showNoteDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Lý do từ chối ✍️', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Con sẽ thấy lý do này để sửa bài nộp đấy.', 
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              FamiTextField(
                controller: ctrl,
                label: 'Lời nhắn cho con',
                hint: 'Ví dụ: Ảnh mờ quá, chụp lại giúp mẹ nhé...',
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('Hủy', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w700))),
            FamiButton(
              text: 'Gửi từ chối',
              width: 140, height: 44,
              color: AppColors.rejected,
              onPressed: () => Navigator.pop(ctx, ctrl.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết nhiệm vụ')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task card
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_task.title,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              StatusBadge(status: _task.status),
                            ],
                          ),
                        ),
                        PointsBadge(points: _task.points),
                      ],
                    ),
                    if (_task.description != null) ...[
                      const SizedBox(height: 20),
                      Text(_task.description!,
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5)),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(height: 1),
                    ),
                    if (_task.assignedTo != null) _InfoRow(
                      icon: Icons.person_rounded,
                      label: 'Người thực hiện',
                      value: _task.assignedTo!.name,
                    ),
                    if (_task.dueDate != null) _InfoRow(
                      icon: Icons.timer_rounded,
                      label: 'Hạn chót',
                      value: DateFormat('HH:mm, dd/MM/yyyy').format(_task.dueDate!),
                    ),
                    _InfoRow(
                      icon: Icons.history_rounded,
                      label: 'Ngày giao',
                      value: DateFormat('dd/MM/yyyy').format(_task.createdAt),
                    ),
                    if (_task.rejectionNote != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.rejected.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.rejected.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.rejected, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Lý do từ chối trước đó:', 
                                    style: TextStyle(color: AppColors.rejected, fontSize: 11, fontWeight: FontWeight.w900)),
                                  Text(_task.rejectionNote!,
                                      style: const TextStyle(color: AppColors.rejected, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Proof photo
              if (_task.proof != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text('BẰNG CHỨNG CỦA CON',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: _task.proof!.fullPhotoUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              placeholder: (_, __) => Container(
                                height: 300,
                                color: const Color(0xFFF2F2F7),
                                child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 200,
                                color: const Color(0xFFF2F2F7),
                                child: const Center(
                                    child: Icon(Icons.broken_image_rounded,
                                        size: 48, color: AppColors.textHint)),
                              ),
                            ),
                            Positioned(
                              bottom: 12, left: 12, right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_pin_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Nộp bởi ${_task.proof!.child?.name ?? "Con"} • ${DateFormat('HH:mm').format(_task.proof!.submittedAt)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_task.proof!.note != null && _task.proof!.note!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_rounded, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('"${_task.proof!.note!}"',
                                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Approve / Reject buttons
                if (_task.isSubmitted) ...[
                  const SizedBox(height: 24),
                  LoadingOverlay(
                    loading: _approving,
                    child: Row(
                      children: [
                        Expanded(
                          child: FamiButton(
                            text: 'Từ chối',
                            outlined: true,
                            color: AppColors.rejected,
                            icon: Icons.close_rounded,
                            onPressed: () => _approve(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FamiButton(
                            text: 'Duyệt ✓',
                            color: AppColors.approved,
                            icon: Icons.check_rounded,
                            onPressed: () => _approve(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

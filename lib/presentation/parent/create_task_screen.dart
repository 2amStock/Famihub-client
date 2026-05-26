import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../subscription/subscription_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  int? _selectedChild;
  DateTime? _dueDate;
  int _points = 10;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        ),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final task = await context.read<TaskProvider>().createTask(
            title: _title.text.trim(),
            description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            assignedToUserId: _selectedChild,
            dueDate: _dueDate,
            points: _points,
          );
      if (!mounted) return;
      setState(() => _saving = false);
      if (task != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Đã tạo nhiệm vụ thành công!'),
          backgroundColor: AppColors.approved,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể tạo nhiệm vụ. Vui lòng thử lại.'),
          backgroundColor: AppColors.rejected,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      if (e.toString().contains('LIMIT_EXCEEDED')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.rejected,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final family = context.watch<FamilyProvider>();
    final children = family.children;

    return Scaffold(
      appBar: AppBar(title: const Text('Giao nhiệm vụ mới 📋')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task info card
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
                          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text('THÔNG TIN NHIỆM VỤ',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FamiTextField(
                        controller: _title,
                        label: 'Tên nhiệm vụ',
                        hint: 'Ví dụ: Dọn dẹp phòng khách...',
                        prefixIcon: Icons.edit_note_rounded,
                        suffix: IconButton(
                          icon: const Icon(Icons.content_paste_rounded, color: AppColors.primary, size: 20),
                          tooltip: 'Dán từ ghi nhớ tạm',
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null) {
                              final text = _title.text + data!.text!;
                              _title.text = text;
                              _title.selection = TextSelection.collapsed(offset: text.length);
                            }
                          },
                        ),
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Vui lòng nhập tên nhiệm vụ' : null,
                      ),
                      const SizedBox(height: 24),
                      FamiTextField(
                        controller: _desc,
                        label: 'Mô tả chi tiết',
                        hint: 'Hướng dẫn cụ thể cho bé...',
                        prefixIcon: Icons.description_rounded,
                        suffix: IconButton(
                          icon: const Icon(Icons.content_paste_rounded, color: AppColors.primary, size: 20),
                          tooltip: 'Dán từ ghi nhớ tạm',
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null) {
                              final text = _desc.text + data!.text!;
                              _desc.text = text;
                              _desc.selection = TextSelection.collapsed(offset: text.length);
                            }
                          },
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Assign & settings
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
                          const Icon(Icons.settings_outlined, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 10),
                          Text('CÀI ĐẶT & THƯỞNG',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Assign to child
                      DropdownButtonFormField<int?>(
                        value: _selectedChild,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Giao cho ai?',
                          prefixIcon: const Icon(Icons.child_care_rounded,
                              color: AppColors.secondary),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('Tất cả các con 👨‍👩‍👧‍👦')),
                          ...children.map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _selectedChild = v),
                      ),
                      const SizedBox(height: 20),

                      // Due date
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: AppColors.secondary, size: 20),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  _dueDate == null
                                      ? 'Hạn nộp bài'
                                      : DateFormat('HH:mm - dd/MM/yyyy').format(_dueDate!),
                                  style: TextStyle(
                                      color: _dueDate == null
                                          ? AppColors.textHint
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textHint),
                                  onPressed: () => setState(() => _dueDate = null),
                                )
                              else
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Points
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Điểm thưởng', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('$_points ⭐',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _points.toDouble(),
                          min: 5,
                          max: 100,
                          divisions: 19,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.1),
                          onChanged: (v) => setState(() => _points = v.toInt()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                LoadingOverlay(
                  loading: _saving,
                  child: FamiButton(
                    text: 'Giao nhiệm vụ',
                    icon: Icons.send_rounded,
                    loading: _saving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

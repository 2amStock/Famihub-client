import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../subscription/subscription_screen.dart';
import 'meal_session_detail_screen.dart';

class MealSuggestionScreen extends StatefulWidget {
  const MealSuggestionScreen({super.key});

  @override
  State<MealSuggestionScreen> createState() => _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends State<MealSuggestionScreen> {
  bool _showFavorites = false;
  String? _selectedMealType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealSuggestionProvider>().loadHistory();
    });
  }

  void _showSuggestionDialog() {
    String mealType = 'Dinner';
    int servingSize = 4;
    int numberOfDishes = 3;
    final ingredientsCtrl = TextEditingController();
    final cuisineCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gợi ý thực đơn AI',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bữa ăn', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: mealType,
                            decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                            items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => setState(() => mealType = val!),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Khẩu phần (người)', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: '4',
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                                      onChanged: (val) => servingSize = int.tryParse(val) ?? 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Số món ăn', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      initialValue: '3',
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                                      onChanged: (val) => numberOfDishes = int.tryParse(val) ?? 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('Nguyên liệu có sẵn', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: ingredientsCtrl,
                            decoration: const InputDecoration(
                                hintText: 'VD: thịt heo, cà chua, trứng...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                          ),
                          const SizedBox(height: 16),
                          const Text('Loại ẩm thực', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: cuisineCtrl,
                            decoration: const InputDecoration(
                                hintText: 'VD: Món Việt, Món Âu...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FamiButton(
                    text: 'Tạo thực đơn',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () async {
                      Navigator.pop(context);
                      await _generateMeals(
                        mealType: mealType,
                        servingSize: servingSize,
                        numberOfDishes: numberOfDishes,
                        availableIngredients: ingredientsCtrl.text,
                        cuisinePreference: cuisineCtrl.text,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _generateMeals({
    required String mealType,
    required int servingSize,
    required int numberOfDishes,
    String? availableIngredients,
    String? cuisinePreference,
  }) async {
    final provider = context.read<MealSuggestionProvider>();
    final result = await provider.suggestMeals(
      mealType: mealType,
      servingSize: servingSize,
      numberOfDishes: numberOfDishes,
      availableIngredients: availableIngredients,
      cuisinePreference: cuisinePreference,
    );

    if (result == null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nâng cấp gói cước', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(provider.error ?? 'Đã xảy ra lỗi, vui lòng thử lại sau.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng', style: TextStyle(color: AppColors.textHint)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
              child: const Text('Nâng cấp ngay'),
            ),
          ],
        ),
      );
    } else if (result != null && result.isNotEmpty && mounted) {
      final firstId = result.first.id;
      final group = provider.history.firstWhere(
        (g) => g.dishes.any((d) => d.id == firstId),
        orElse: () => MealSuggestionGroup(date: DateTime.now().toIso8601String(), mealType: mealType, dishes: result),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealSessionDetailScreen(session: group)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealSuggestionProvider>();
    final history = provider.history;
    var displayList = history;
    if (_selectedDate != null) {
      displayList = displayList.where((g) {
        final d = DateTime.tryParse(g.date)?.toLocal();
        if (d == null) return false;
        return d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day;
      }).toList();
    }
    if (_selectedMealType != null) {
      displayList = displayList.where((g) => g.mealType.toLowerCase().contains(_selectedMealType!.toLowerCase())).toList();
    }
    if (_showFavorites) {
      displayList = displayList
          .map((g) => MealSuggestionGroup(
                date: g.date,
                mealType: g.mealType,
                dishes: g.dishes.where((d) => d.isFavorite).toList(),
              ))
          .where((g) => g.dishes.isNotEmpty)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn AI', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: _selectedDate != null ? AppColors.primary : AppColors.textPrimary),
            onPressed: () async {
              if (_selectedDate != null) {
                // If already selected, allow clearing by tapping again, or let them pick.
                // It's better to show picker but add a clear button in the body
              }
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String?>(
              value: _selectedMealType,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả bữa', style: TextStyle(fontSize: 14))),
                DropdownMenuItem(value: 'breakfast', child: Text('Bữa sáng', style: TextStyle(fontSize: 14))),
                DropdownMenuItem(value: 'lunch', child: Text('Bữa trưa', style: TextStyle(fontSize: 14))),
                DropdownMenuItem(value: 'dinner', child: Text('Bữa tối', style: TextStyle(fontSize: 14))),
              ],
              onChanged: (val) {
                setState(() => _selectedMealType = val);
              },
            ),
          ),
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _showFavorites ? AppColors.secondary : AppColors.textPrimary),
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
          )
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Chip(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                label: Text('Ngày: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                deleteIconColor: AppColors.primary,
                onDeleted: () => setState(() => _selectedDate = null),
              ),
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, size: 80, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(_showFavorites ? 'Chưa có món yêu thích' : 'Chưa có lịch sử gợi ý',
                            style: const TextStyle(color: AppColors.textHint)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final group = displayList[index];
                      return _SessionCard(session: group);
                    },
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSuggestionDialog,
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Gợi ý món ăn', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final MealSuggestionGroup session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    IconData mealIcon = Icons.restaurant;
    String mealName = session.mealType;
    if (mealName.toLowerCase().contains('breakfast')) {
      mealIcon = Icons.free_breakfast_rounded;
      mealName = 'Bữa sáng';
    } else if (mealName.toLowerCase().contains('lunch')) {
      mealIcon = Icons.lunch_dining_rounded;
      mealName = 'Bữa trưa';
    } else if (mealName.toLowerCase().contains('dinner')) {
      mealIcon = Icons.dinner_dining_rounded;
      mealName = 'Bữa tối';
    } else if (mealName.toLowerCase().contains('snack')) {
      mealIcon = Icons.tapas_rounded;
      mealName = 'Ăn vặt';
    }

    DateTime? dt = DateTime.tryParse(session.date)?.toLocal();
    String formattedDate = dt != null 
        ? 'Lúc ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day}/${dt.month}/${dt.year}'
        : session.date;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MealSessionDetailScreen(session: session),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(mealIcon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gợi ý $mealName', 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(formattedDate, 
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Danh sách món:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              ...session.dishes.asMap().entries.map((entry) {
                int index = entry.key + 1;
                MealSuggestion dish = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text('$index.', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(dish.dishName, 
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ),
                      if (dish.isFavorite)
                        const Icon(Icons.favorite_rounded, size: 16, color: AppColors.secondary),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

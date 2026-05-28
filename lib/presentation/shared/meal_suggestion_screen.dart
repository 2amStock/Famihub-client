import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../subscription/subscription_screen.dart';

class MealSuggestionScreen extends StatefulWidget {
  const MealSuggestionScreen({super.key});

  @override
  State<MealSuggestionScreen> createState() => _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends State<MealSuggestionScreen> {
  bool _showFavorites = false;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealSuggestionProvider>();
    final history = provider.history;
    final displayList = _showFavorites ? history.where((e) => e.isFavorite).toList() : history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thực đơn AI', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _showFavorites ? AppColors.secondary : AppColors.textPrimary),
            onPressed: () => setState(() => _showFavorites = !_showFavorites),
          )
        ],
      ),
      body: Container(
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
                      final meal = displayList[index];
                      return _MealCard(meal: meal);
                    },
                  ),
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

class _MealCard extends StatelessWidget {
  final MealSuggestion meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(meal.dishName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ),
                IconButton(
                  icon: Icon(meal.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: meal.isFavorite ? AppColors.secondary : AppColors.textHint),
                  onPressed: () {
                    context.read<MealSuggestionProvider>().toggleFavorite(meal.id);
                  },
                ),
              ],
            ),
            if (meal.description != null) ...[
              const SizedBox(height: 4),
              Text(meal.description!, style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(Icons.timer_outlined, '${meal.estimatedTime} phút'),
                if (meal.difficultyLevel != null) _buildChip(Icons.speed_rounded, meal.difficultyLevel!),
                if (meal.cuisineType != null) _buildChip(Icons.public_rounded, meal.cuisineType!),
              ],
            ),
            const Divider(height: 24),
            const Text('Nguyên liệu:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...meal.ingredients.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${i.name} - ${i.amount} ${i.unit}', style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            const Text('Hướng dẫn:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...meal.instructions.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(i, style: const TextStyle(fontSize: 14)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

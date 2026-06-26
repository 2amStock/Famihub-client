import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../../data/services/shopping_service.dart';
import '../../core/utils/ui_helpers.dart';

class MealSessionDetailScreen extends StatelessWidget {
  final MealSuggestionGroup session;

  const MealSessionDetailScreen({super.key, required this.session});

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
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} • ${dt.day}/${dt.month}/${dt.year}'
        : session.date;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gợi ý $mealName', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(mealIcon, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(formattedDate, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: session.dishes.length,
                itemBuilder: (context, index) {
                  return _MealCardDetail(meal: session.dishes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCardDetail extends StatelessWidget {
  final MealSuggestion meal;
  const _MealCardDetail({required this.meal});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<MealSuggestionProvider>().history;
    MealSuggestion currentMeal = meal;
    for (var group in history) {
      for (var d in group.dishes) {
        if (d.id == meal.id) currentMeal = d;
      }
    }

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
                  child: Text(currentMeal.dishName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ),
                IconButton(
                  icon: Icon(currentMeal.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: currentMeal.isFavorite ? AppColors.secondary : AppColors.textHint),
                  onPressed: () {
                    context.read<MealSuggestionProvider>().toggleFavorite(currentMeal.id);
                  },
                ),
              ],
            ),
            if (currentMeal.description != null) ...[
              const SizedBox(height: 4),
              Text(currentMeal.description!, style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(Icons.timer_outlined, '${currentMeal.estimatedTime} phút'),
                if (currentMeal.difficultyLevel != null) _buildChip(Icons.speed_rounded, currentMeal.difficultyLevel!),
                if (currentMeal.cuisineType != null) _buildChip(Icons.public_rounded, currentMeal.cuisineType!),
              ],
            ),
            const Divider(height: 24),
            const Text('Nguyên liệu:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...currentMeal.ingredients.map((i) => Padding(
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
            ...currentMeal.instructions.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(i, style: const TextStyle(fontSize: 14)),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FamiButton(
                text: 'Thêm vào danh sách mua sắm',
                icon: Icons.add_shopping_cart_rounded,
                onPressed: () async {
                  try {
                    await context.read<ShoppingService>().addMealToShoppingList(currentMeal.id);
                    if (context.mounted) {
                      UIHelpers.showMessageBox(context, 'Thành công', 'Đã thêm nguyên liệu vào danh sách mua sắm!');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      UIHelpers.showMessageBox(context, 'Lỗi', 'Cần nâng cấp gói cước để sử dụng tính năng này', isError: true);
                    }
                  }
                },
              ),
            ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:famihub_flutter/core/utils/ui_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';

class FoodPreferenceScreen extends StatefulWidget {
  const FoodPreferenceScreen({super.key});

  @override
  State<FoodPreferenceScreen> createState() => _FoodPreferenceScreenState();
}

class _FoodPreferenceScreenState extends State<FoodPreferenceScreen> {
  final _favoriteController = TextEditingController();
  final _dislikedController = TextEditingController();
  final _dietaryController = TextEditingController();
  final _cuisineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<FoodPreferenceProvider>();
    await provider.loadPreference();
    if (provider.preference != null) {
      _favoriteController.text = provider.preference!.favoriteDishes.join(', ');
      _dislikedController.text = provider.preference!.dislikedIngredients.join(', ');
      _dietaryController.text = provider.preference!.dietaryRestrictions.join(', ');
      _cuisineController.text = provider.preference!.cuisinePreferences.join(', ');
    }
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    _dislikedController.dispose();
    _dietaryController.dispose();
    _cuisineController.dispose();
    super.dispose();
  }

  Future<void> _savePreference() async {
    final provider = context.read<FoodPreferenceProvider>();
    
    final newPref = FoodPreference(
      userId: 0, // Sẽ được gán lại ở server
      userName: '',
      favoriteDishes: _favoriteController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      dislikedIngredients: _dislikedController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      dietaryRestrictions: _dietaryController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      cuisinePreferences: _cuisineController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );

    final success = await provider.updatePreference(newPref);
    if (success && mounted) {
      UIHelpers.showMessageBox(context, 'Thành công', 'Đã lưu sở thích ăn uống');
      Navigator.pop(context);
    } else if (mounted) {
      UIHelpers.showMessageBox(context, 'Lỗi', provider.error ?? 'Không thể lưu', isError: true);
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FoodPreferenceProvider>().loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sở thích ăn uống'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Cài đặt này giúp AI Gợi ý Món Ăn có thể đưa ra thực đơn phù hợp nhất với khẩu vị của bạn.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildTextField('Món yêu thích', 'Ví dụ: Phở, Bún chả...', _favoriteController),
                _buildTextField('Nguyên liệu không thích', 'Ví dụ: Hành, Mùi tàu...', _dislikedController),
                _buildTextField('Chế độ ăn kiêng', 'Ví dụ: Ăn chay, Keto, Không gluten...', _dietaryController),
                _buildTextField('Phong cách ẩm thực', 'Ví dụ: Việt Nam, Hàn Quốc, Âu...', _cuisineController),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _savePreference,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu Thay Đổi', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

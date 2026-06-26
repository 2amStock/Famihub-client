import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/shopping_service.dart';
import '../../data/models/shopping_model.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/utils/ui_helpers.dart';
import 'shopping_history_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: "1");
  String _selectedUnit = '';
  String _filter = 'all'; // 'all', 'toBuy', 'bought'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = Provider.of<ShoppingService>(context, listen: false);
      service.loadActiveList();
      service.initSignalR();
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemController.text.trim().isEmpty) return;
    final service = Provider.of<ShoppingService>(context, listen: false);
    final qty = double.tryParse(_quantityController.text) ?? 1.0;
    service.addItem(_itemController.text.trim(), qty, _selectedUnit.isEmpty ? null : _selectedUnit);
    _itemController.clear();
    _quantityController.text = "1";
    setState(() => _selectedUnit = '');
    FocusScope.of(context).unfocus();
  }

  void _confirmArchive() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chốt danh sách?',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        content: const Text('Danh sách hiện tại sẽ được lưu vào lịch sử và tạo danh sách mới.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.approved,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final service = Provider.of<ShoppingService>(context, listen: false);
              await service.archiveList();
              if (mounted) {
                if (service.error != null) {
                  UIHelpers.showMessageBox(context, 'Lỗi', service.error!, isError: true);
                } else {
                  UIHelpers.showMessageBox(context, 'Thành công', 'Đã chốt danh sách!');
                }
              }
            },
            child: const Text('Chốt'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách mua sắm',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.secondary),
            tooltip: 'Lịch sử',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingHistoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.approved),
            tooltip: 'Chốt danh sách',
            onPressed: _confirmArchive,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Consumer<ShoppingService>(
          builder: (context, service, child) {
            if (service.isLoading && service.activeList == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (service.error != null && service.error!.contains('Gói cước')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.pending.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded, size: 48, color: AppColors.pending),
                      ),
                      const SizedBox(height: 20),
                      const Text('Tính năng Premium',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(service.error!, textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      FamiButton(
                        text: 'Nâng cấp gói',
                        icon: Icons.diamond_rounded,
                        onPressed: () {
                          // Navigate to upgrade screen
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            final list = service.activeList;
            if (list == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    const Text('Không có dữ liệu',
                        style: TextStyle(color: AppColors.textHint, fontSize: 16)),
                  ],
                ),
              );
            }

            final toBuy = list.items.where((i) => !i.isBought).toList();
            final bought = list.items.where((i) => i.isBought).toList();

            return Column(
              children: [
                // Add Item Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _itemController,
                                decoration: const InputDecoration(
                                  hintText: 'Thêm món cần mua...',
                                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 15),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                onSubmitted: (_) => _addItem(),
                              ),
                            ),
                            GestureDetector(
                              onTap: _addItem,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                          child: Row(
                            children: [
                              // Quantity field
                              Container(
                                width: 64,
                                height: 36,
                                child: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'SL',
                                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF2F2F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onSubmitted: (_) => _addItem(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Unit chips
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: ['', 'g', 'kg', 'ml', 'lít', 'quả', 'gói', 'hộp', 'chai', 'bó'].map((unit) {
                                      final isSelected = _selectedUnit == unit;
                                      final label = unit.isEmpty ? 'Không' : unit;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: GestureDetector(
                                          onTap: () => setState(() => _selectedUnit = unit),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.secondary : const Color(0xFFF2F2F7),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SummaryChip(
                          icon: Icons.list_alt_rounded,
                          label: 'Tất cả (${list.items.length})',
                          color: AppColors.primary,
                          isSelected: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all'),
                        ),
                        const SizedBox(width: 12),
                        _SummaryChip(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Cần mua (${toBuy.length})',
                          color: AppColors.secondary,
                          isSelected: _filter == 'toBuy',
                          onTap: () => setState(() => _filter = 'toBuy'),
                        ),
                        const SizedBox(width: 12),
                        _SummaryChip(
                          icon: Icons.check_circle_outline,
                          label: 'Đã mua (${bought.length})',
                          color: AppColors.approved,
                          isSelected: _filter == 'bought',
                          onTap: () => setState(() => _filter = 'bought'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Items list
                Expanded(
                  child: list.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_shopping_cart_rounded,
                                  size: 64, color: AppColors.textHint.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text('Danh sách trống',
                                  style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Text('Thêm món cần mua ở trên nhé!',
                                  style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                          children: [
                            if (toBuy.isNotEmpty && (_filter == 'all' || _filter == 'toBuy')) ...[
                              _SectionHeader(
                                title: 'Cần mua',
                                count: toBuy.length,
                                color: AppColors.secondary,
                                icon: Icons.shopping_cart_rounded,
                              ),
                              const SizedBox(height: 8),
                              ...toBuy.map((item) => _ShoppingItemCard(
                                    item: item,
                                    service: service,
                                  )),
                            ],
                            if (bought.isNotEmpty && (_filter == 'all' || _filter == 'bought')) ...[
                              const SizedBox(height: 20),
                              _SectionHeader(
                                title: 'Đã mua',
                                count: bought.length,
                                color: AppColors.approved,
                                icon: Icons.check_circle_rounded,
                              ),
                              const SizedBox(height: 8),
                              ...bought.map((item) => _ShoppingItemCard(
                                    item: item,
                                    service: service,
                                  )),
                            ],
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final ShoppingService service;

  const _ShoppingItemCard({required this.item, required this.service});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: item.isBought ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isBought ? Colors.white.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isBought
                ? AppColors.approved.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: item.isBought
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => service.toggleItemBought(item.id, !item.isBought),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Custom checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: item.isBought ? AppColors.approved : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.isBought ? AppColors.approved : AppColors.textHint,
                        width: 2,
                      ),
                    ),
                    child: item.isBought
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Item info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: item.isBought ? AppColors.textHint : AppColors.textPrimary,
                            decoration: item.isBought ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Số lượng: ${item.quantity}${item.unit != null && item.unit!.isNotEmpty ? ' ${item.unit}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: item.isBought
                                ? AppColors.textHint.withOpacity(0.6)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: () {
                      service.deleteItem(item.id);
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.rejected.withOpacity(0.7),
                      size: 22,
                    ),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/shopping_service.dart';
import 'package:intl/intl.dart';

class ShoppingHistoryScreen extends StatefulWidget {
  const ShoppingHistoryScreen({super.key});

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingService>(context, listen: false).loadArchivedLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử mua sắm',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Consumer<ShoppingService>(
          builder: (context, service, child) {
            if (service.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (service.archivedLists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: AppColors.textHint.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text('Chưa có lịch sử mua sắm',
                        style: TextStyle(color: AppColors.textHint, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: service.archivedLists.length,
              itemBuilder: (context, index) {
                final list = service.archivedLists[index];
                final dateStr = DateFormat('dd/MM/yyyy • HH:mm').format(list.createdAt);
                final totalItems = list.items.length;
                final boughtItems = list.items.where((i) => i.isBought).length;
                final progress = totalItems > 0 ? boughtItems / totalItems : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: progress == 1.0
                              ? AppColors.approved.withOpacity(0.1)
                              : AppColors.pending.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          progress == 1.0 ? Icons.check_circle_rounded : Icons.shopping_bag_rounded,
                          color: progress == 1.0 ? AppColors.approved : AppColors.pending,
                          size: 22,
                        ),
                      ),
                      title: Text(dateStr,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$boughtItems/$totalItems món đã mua',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFFF2F2F7),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress == 1.0 ? AppColors.approved : AppColors.secondary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      children: list.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                item.isBought
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: item.isBought ? AppColors.approved : AppColors.textHint,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${item.name} (${item.quantity})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: item.isBought ? AppColors.textHint : AppColors.textPrimary,
                                    decoration: item.isBought ? TextDecoration.lineThrough : null,
                                    decorationColor: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

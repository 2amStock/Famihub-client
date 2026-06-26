import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        title: Text('Lịch sử mua sắm'),
      ),
      body: Consumer<ShoppingService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (service.archivedLists.isEmpty) {
            return Center(child: Text("Chưa có lịch sử mua sắm."));
          }

          return ListView.builder(
            itemCount: service.archivedLists.length,
            itemBuilder: (context, index) {
              final list = service.archivedLists[index];
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(list.createdAt);
              final totalItems = list.items.length;
              final boughtItems = list.items.where((i) => i.isBought).length;

              return ExpansionTile(
                title: Text("Danh sách ngày $dateStr"),
                subtitle: Text("Hoàn thành $boughtItems/$totalItems món"),
                children: list.items.map((item) {
                  return ListTile(
                    leading: Icon(
                      item.isBought ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: item.isBought ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      "${item.name} (${item.quantity})",
                      style: TextStyle(
                        decoration: item.isBought ? TextDecoration.lineThrough : null,
                        color: item.isBought ? Colors.grey : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

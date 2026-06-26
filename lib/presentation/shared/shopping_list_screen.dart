import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/shopping_service.dart';
import '../../data/models/shopping_model.dart';
import 'shopping_history_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: "1");

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
    service.addItem(_itemController.text.trim(), qty, "");
    _itemController.clear();
    _quantityController.text = "1";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách mua sắm'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ShoppingHistoryScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.check_circle_outline),
            tooltip: "Chốt danh sách",
            onPressed: () async {
               final service = Provider.of<ShoppingService>(context, listen: false);
               await service.archiveList();
               if (service.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(service.error!)));
               } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã chốt danh sách!")));
               }
            },
          )
        ],
      ),
      body: Consumer<ShoppingService>(
        builder: (context, service, child) {
          if (service.isLoading && service.activeList == null) {
            return Center(child: CircularProgressIndicator());
          }
          if (service.error != null && service.error!.contains('Gói cước')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(service.error!, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to upgrade screen
                    },
                    child: Text('Nâng cấp gói'),
                  )
                ],
              ),
            );
          }

          final list = service.activeList;
          if (list == null) return Center(child: Text("Không có dữ liệu"));

          final toBuy = list.items.where((i) => !i.isBought).toList();
          final bought = list.items.where((i) => i.isBought).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _itemController,
                        decoration: InputDecoration(
                          hintText: 'Tên món đồ (vd: Sữa)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'SL',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 36),
                      onPressed: _addItem,
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    if (toBuy.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Cần mua (\${toBuy.length})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ...toBuy.map((item) => _buildItemTile(item, service)).toList(),
                    ],
                    if (bought.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Đã mua (\${bought.length})", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                      ),
                      ...bought.map((item) => _buildItemTile(item, service)).toList(),
                    ]
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemTile(ShoppingItem item, ShoppingService service) {
    return AnimatedOpacity(
      opacity: item.isBought ? 0.5 : 1.0,
      duration: Duration(milliseconds: 300),
      child: ListTile(
        leading: Checkbox(
          value: item.isBought,
          onChanged: (val) {
            if (val != null) {
              service.toggleItemBought(item.id, val);
            }
          },
        ),
        title: Text(
          "\${item.name} (\${item.quantity})",
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            service.deleteItem(item.id);
          },
        ),
      ),
    );
  }
}

class ShoppingItem {
  final int id;
  final int listId;
  final String name;
  final double quantity;
  final String? unit;
  final bool isBought;
  final int? buyerId;
  final int createdByUserId;
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    required this.quantity,
    this.unit,
    required this.isBought,
    this.buyerId,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] ?? 0,
      listId: json['listId'] ?? 0,
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      unit: json['unit'],
      isBought: json['isBought'] ?? false,
      buyerId: json['buyerId'],
      createdByUserId: json['createdByUserId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ShoppingList {
  final int id;
  final int familyId;
  final String name;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.familyId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<ShoppingItem> items = itemsList.map((i) => ShoppingItem.fromJson(i)).toList();

    return ShoppingList(
      id: json['id'] ?? 0,
      familyId: json['familyId'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      items: items,
    );
  }
}

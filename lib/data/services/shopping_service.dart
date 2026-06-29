import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shopping_model.dart';
import 'api_service.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter/foundation.dart';

class ShoppingService extends ChangeNotifier {
  final ApiService apiService;
  HubConnection? _hubConnection;

  ShoppingList? activeList;
  List<ShoppingList> archivedLists = [];
  bool isLoading = false;
  String? error;

  ShoppingService({required this.apiService});

  String get _baseUrl => apiService.baseUrl;

  Future<void> initSignalR() async {
    final token = await apiService.getToken(); // Giả định
    if (token == null) return;

    final baseUrlObj = Uri.parse(_baseUrl);
    final hubUrl =
        "${baseUrlObj.scheme}://${baseUrlObj.host}:${baseUrlObj.port}/shoppingHub";

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
            ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on('ShoppingItemAdded', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final item =
            ShoppingItem.fromJson(arguments[0] as Map<String, dynamic>);
        if (activeList != null) {
          final exists = activeList!.items.any((i) => i.id == item.id);
          if (!exists) {
            activeList!.items.add(item);
            notifyListeners();
          }
        }
      }
    });

    _hubConnection?.on('ShoppingItemUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final updatedItem =
            ShoppingItem.fromJson(arguments[0] as Map<String, dynamic>);
        if (activeList != null) {
          final index =
              activeList!.items.indexWhere((i) => i.id == updatedItem.id);
          if (index != -1) {
            activeList!.items[index] = updatedItem;
            notifyListeners();
          }
        }
      }
    });

    _hubConnection?.on('ShoppingItemDeleted', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final id = arguments[0] as int;
        if (activeList != null) {
          activeList!.items.removeWhere((i) => i.id == id);
          notifyListeners();
        }
      }
    });

    _hubConnection?.on('ShoppingListArchived', (arguments) {
      loadActiveList();
    });

    await _hubConnection?.start();
  }

  void disposeSignalR() {
    _hubConnection?.stop();
  }

  Future<void> loadActiveList() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final headers = await apiService.getAuthHeaders();
      final response = await http
          .get(Uri.parse('$_baseUrl/shoppinglists/active'), headers: headers);
      if (response.statusCode == 200) {
        activeList = ShoppingList.fromJson(json.decode(response.body));
      } else if (response.statusCode == 403) {
        error = "Gói cước của bạn không hỗ trợ tính năng này.";
      } else {
        error = "Có lỗi xảy ra: ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArchivedLists() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final headers = await apiService.getAuthHeaders();
      final response = await http.get(
          Uri.parse('$_baseUrl/shoppinglists/archived'),
          headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        archivedLists =
            data.map((json) => ShoppingList.fromJson(json)).toList();
      } else {
        error = "Có lỗi xảy ra: ${response.statusCode}";
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(String name, double quantity, String? unit) async {
    try {
      final headers = await apiService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/shoppinglists/items'),
        headers: headers,
        body: json.encode({
          'name': name,
          'quantity': quantity,
          'unit': unit,
        }),
      );
      if (response.statusCode == 200) {
        final newItem = ShoppingItem.fromJson(json.decode(response.body));
        if (activeList != null && !activeList!.items.any((i) => i.id == newItem.id)) {
          activeList!.items.add(newItem);
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  Future<void> toggleItemBought(int id, bool isBought) async {
    // Optimistic update
    final index = activeList?.items.indexWhere((i) => i.id == id) ?? -1;
    if (index != -1) {
      final oldItem = activeList!.items[index];
      activeList!.items[index] = ShoppingItem(
        id: oldItem.id,
        listId: oldItem.listId,
        name: oldItem.name,
        quantity: oldItem.quantity,
        unit: oldItem.unit,
        isBought: isBought,
        buyerId: oldItem.buyerId,
        createdByUserId: oldItem.createdByUserId,
        createdAt: oldItem.createdAt,
      );
      notifyListeners();
    }
    try {
      final headers = await apiService.getAuthHeaders();
      await http.put(
        Uri.parse('$_baseUrl/shoppinglists/items/$id'),
        headers: headers,
        body: json.encode({'isBought': isBought}),
      );
    } catch (e) {
      // Rollback on error
      if (index != -1) {
        final rollbackItem = activeList!.items[index];
        activeList!.items[index] = ShoppingItem(
          id: rollbackItem.id,
          listId: rollbackItem.listId,
          name: rollbackItem.name,
          quantity: rollbackItem.quantity,
          unit: rollbackItem.unit,
          isBought: !isBought,
          buyerId: rollbackItem.buyerId,
          createdByUserId: rollbackItem.createdByUserId,
          createdAt: rollbackItem.createdAt,
        );
        notifyListeners();
      }
      print("Error updating item: $e");
    }
  }

  Future<void> deleteItem(int id) async {
    // Optimistic delete
    ShoppingItem? removedItem;
    int removedIndex = -1;
    if (activeList != null) {
      removedIndex = activeList!.items.indexWhere((i) => i.id == id);
      if (removedIndex != -1) {
        removedItem = activeList!.items.removeAt(removedIndex);
        notifyListeners();
      }
    }
    try {
      final headers = await apiService.getAuthHeaders();
      await http.delete(
        Uri.parse('$_baseUrl/shoppinglists/items/$id'),
        headers: headers,
      );
    } catch (e) {
      // Rollback on error
      if (removedItem != null && removedIndex != -1 && activeList != null) {
        activeList!.items.insert(removedIndex, removedItem);
        notifyListeners();
      }
      print("Error deleting item: $e");
    }
  }

  Future<void> archiveList() async {
    try {
      final headers = await apiService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/shoppinglists/archive'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        await loadActiveList();
      } else {
        error = "Bạn không có quyền chốt danh sách.";
        notifyListeners();
      }
    } catch (e) {
      print("Error archiving list: $e");
    }
  }

  Future<void> addMealToShoppingList(int mealId) async {
    try {
      final headers = await apiService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/meals/$mealId/add-to-shopping-list'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Success
      } else {
        throw Exception("Failed to add meal");
      }
    } catch (e) {
      print("Error: \$e");
      throw e;
    }
  }
}

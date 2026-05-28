import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api;
  List<AppNotification> _notifications = [];
  bool _loading = false;
  String? _error;

  NotificationProvider(this._api);

  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _api.getNotifications();
    } catch (e) {
      _error = 'Không thể tải thông báo';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    try {
      await _api.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = AppNotification(
          id: old.id,
          userId: old.userId,
          title: old.title,
          message: old.message,
          type: old.type,
          relatedId: old.relatedId,
          isRead: true,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.markAllAsRead();
      _notifications = _notifications.map((n) {
        return AppNotification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          relatedId: n.relatedId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;

  AuthProvider(this._api);

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> tryAutoLogin() async {
    final token = await _api.getToken();
    if (token == null) return false;
    try {
      _user = await _api.getMe();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _api.login(email, password);
      _user = AppUser.fromJson(data['user']);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    _setLoading(true);
    try {
      final data = await _api.register(name, email, password, role);
      _user = AppUser.fromJson(data['user']);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _api.getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> verifyOtp(String email, String otpCode) async {
    _setLoading(true);
    try {
      await _api.verifyOtp(email, otpCode);
      return true;
    } catch (e) {
      _error = 'Mã xác thực không hợp lệ hoặc đã hết hạn.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resendOtp(String email) async {
    _setLoading(true);
    try {
      await _api.resendOtp(email);
      return true;
    } catch (e) {
      _error = 'Không thể gửi lại mã xác thực.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e.toString().contains('UNVERIFIED_EMAIL')) return 'UNVERIFIED_EMAIL';
    if (e.toString().contains('401')) return 'Email hoặc mật khẩu không đúng';
    if (e.toString().contains('403')) return 'Không có quyền truy cập';
    if (e.toString().contains('409')) return 'Email đã được sử dụng';
    if (e.toString().contains('SocketException')) return 'Không thể kết nối tới máy chủ';
    return 'Có lỗi xảy ra, vui lòng thử lại';
  }
}

class TaskProvider extends ChangeNotifier {
  final ApiService _api;

  TaskProvider(this._api);

  List<FamilyTask> _tasks = [];
  bool _loading = false;
  String? _error;

  List<FamilyTask> get tasks => _tasks;
  bool get loading => _loading;
  String? get error => _error;

  List<FamilyTask> get pendingTasks =>
      _tasks.where((t) => t.isPending || t.isInProgress || t.isRejected).toList();
  List<FamilyTask> get submittedTasks =>
      _tasks.where((t) => t.isSubmitted).toList();
  List<FamilyTask> get completedTasks =>
      _tasks.where((t) => t.isApproved).toList();

  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _api.getTasks();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách nhiệm vụ';
    } finally {
      _setLoading(false);
    }
  }

  Future<FamilyTask?> createTask({
    required String title,
    String? description,
    int? assignedToUserId,
    DateTime? dueDate,
    required int points,
  }) async {
    try {
      final task = await _api.createTask(
        title: title,
        description: description,
        assignedToUserId: assignedToUserId,
        dueDate: dueDate,
        points: points,
      );
      _tasks.insert(0, task);
      notifyListeners();
      return task;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403 && e.response?.data != null) {
        if (e.response?.data.toString().contains('LIMIT_EXCEEDED') == true) {
          throw Exception('LIMIT_EXCEEDED');
        }
      }
      return null;
    }
  }

  Future<bool> submitTask(int taskId, String? note, Uint8List bytes, String fileName) async {
    try {
      // 1. Upload to Cloud first (using bytes for Web support)
      final photoUrl = await _api.uploadFile(bytes, fileName);

      // 2. Submit Task with the cloud URL
      final updated = await _api.submitTask(taskId, note, photoUrl);

      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) _tasks[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SubmitTask Error: $e');
      return false;
    }
  }

  Future<bool> approveTask(int taskId, bool approved, {String? rejectionNote}) async {
    try {
      final updated = await _api.approveTask(taskId, approved, rejectionNote: rejectionNote);
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) _tasks[idx] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      await _api.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

class FamilyProvider extends ChangeNotifier {
  final ApiService _api;

  FamilyProvider(this._api);

  Family? _family;
  bool _loading = false;

  Family? get family => _family;
  bool get loading => _loading;

  Future<void> loadFamily() async {
    _loading = true;
    notifyListeners();
    try {
      _family = await _api.getMyFamily();
    } catch (_) {
      _family = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createFamily(String name) async {
    try {
      _family = await _api.createFamily(name);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> joinFamily(String code) async {
    try {
      await _api.joinFamily(code);
      await loadFamily();
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403 && e.response?.data != null) {
        if (e.response?.data.toString().contains('LIMIT_EXCEEDED') == true) {
          throw Exception('LIMIT_EXCEEDED');
        }
      }
      return false;
    }
  }

  List<AppUser> get children =>
      _family?.members.where((m) => m.isChild).toList() ?? [];
  List<AppUser> get parents =>
      _family?.members.where((m) => m.isParent).toList() ?? [];
}

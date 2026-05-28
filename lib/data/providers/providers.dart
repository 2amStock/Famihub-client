import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/models.dart';
import '../services/api_service.dart';
export 'notification_provider.dart';

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

  Future<bool> register(
      String name, String email, String password, String role) async {
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
    if (e.toString().contains('SocketException'))
      return 'Không thể kết nối tới máy chủ';
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

  List<FamilyTask> get pendingTasks => _tasks
      .where((t) => t.isPending || t.isInProgress || t.isRejected)
      .toList();
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
      if (e is DioException &&
          e.response?.statusCode == 403 &&
          e.response?.data != null) {
        if (e.response?.data.toString().contains('LIMIT_EXCEEDED') == true) {
          throw Exception('LIMIT_EXCEEDED');
        }
      }
      return null;
    }
  }

  Future<bool> submitTask(
      int taskId, String? note, Uint8List bytes, String fileName) async {
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

  Future<bool> approveTask(int taskId, bool approved,
      {String? rejectionNote}) async {
    try {
      final updated = await _api.approveTask(taskId, approved,
          rejectionNote: rejectionNote);
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
      if (e is DioException &&
          e.response?.statusCode == 403 &&
          e.response?.data != null) {
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

class RewardProvider extends ChangeNotifier {
  final ApiService _api;

  RewardProvider(this._api);

  List<Reward> _rewards = [];
  List<RewardRedemption> _redemptions = [];
  bool _loading = false;
  String? _error;

  List<Reward> get rewards => _rewards;
  List<RewardRedemption> get redemptions => _redemptions;
  bool get loading => _loading;
  String? get error => _error;

  List<RewardRedemption> get pendingRedemptions =>
      _redemptions.where((r) => r.isPending).toList();
  List<RewardRedemption> get historyRedemptions =>
      _redemptions.where((r) => !r.isPending).toList();

  Future<void> loadRewards() async {
    _setLoading(true);
    try {
      _rewards = await _api.getRewards();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách phần thưởng';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRedemptions() async {
    _setLoading(true);
    try {
      _redemptions = await _api.getRedemptions();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải lịch sử đổi thưởng';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      final futures = await Future.wait([
        _api.getRewards(),
        _api.getRedemptions(),
      ]);
      _rewards = futures[0] as List<Reward>;
      _redemptions = futures[1] as List<RewardRedemption>;
      _error = null;
    } catch (e) {
      _error = 'Không thể tải dữ liệu phần thưởng';
    } finally {
      _setLoading(false);
    }
  }

  Future<Reward?> createReward({
    required String title,
    String? description,
    required int requiredPoints,
  }) async {
    try {
      final reward = await _api.createReward(
        title: title,
        description: description,
        requiredPoints: requiredPoints,
      );
      _rewards.insert(0, reward);
      notifyListeners();
      return reward;
    } catch (e) {
      if (e is DioException &&
          e.response?.statusCode == 400 &&
          e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi tạo phần thưởng');
      }
      throw Exception(e.toString());
    }
  }

  Future<bool> updateReward(
    int id, {
    String? title,
    String? description,
    int? requiredPoints,
  }) async {
    try {
      final updated = await _api.updateReward(
        id,
        title: title,
        description: description,
        requiredPoints: requiredPoints,
      );
      final idx = _rewards.indexWhere((r) => r.id == id);
      if (idx != -1) _rewards[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is DioException &&
          e.response?.statusCode == 400 &&
          e.response?.data != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Lỗi cập nhật phần thưởng');
      }
      throw Exception(e.toString());
    }
  }

  Future<bool> deleteReward(int id) async {
    try {
      await _api.deleteReward(id);
      _rewards.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      if (e is DioException &&
          e.response?.statusCode == 400 &&
          e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi xóa phần thưởng');
      }
      throw Exception(e.toString());
    }
  }

  Future<RewardRedemption?> redeemReward(int rewardId) async {
    try {
      final redemption = await _api.redeemReward(rewardId);
      _redemptions.insert(0, redemption);
      notifyListeners();
      return redemption;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> approveRedemption(int redemptionId, bool approved,
      {String? parentNote}) async {
    try {
      final updated = await _api.approveRedemption(redemptionId, approved,
          parentNote: parentNote);
      final idx = _redemptions.indexWhere((r) => r.id == redemptionId);
      if (idx != -1) _redemptions[idx] = updated;
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

class FamilyEventProvider extends ChangeNotifier {
  final ApiService _api;

  FamilyEventProvider(this._api);

  List<FamilyEvent> _events = [];
  bool _loading = false;
  String? _error;

  List<FamilyEvent> get events => _events;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadEvents() async {
    _setLoading(true);
    try {
      _events = await _api.getFamilyEvents();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải sự kiện gia đình';
    } finally {
      _setLoading(false);
    }
  }

  Future<FamilyEvent?> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final event = await _api.createFamilyEvent(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      _events.add(event);
      notifyListeners();
      return event;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteEvent(int id) async {
    try {
      await _api.deleteFamilyEvent(id);
      _events.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

class FoodPreferenceProvider extends ChangeNotifier {
  final ApiService _api;

  FoodPreferenceProvider(this._api);

  FoodPreference? _preference;
  bool _loading = false;
  String? _error;

  FoodPreference? get preference => _preference;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPreference() async {
    _setLoading(true);
    try {
      _preference = await _api.getFoodPreference();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải sở thích ăn uống';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePreference(FoodPreference newPref) async {
    _setLoading(true);
    try {
      _preference = await _api.updateFoodPreference(newPref);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Không thể cập nhật sở thích ăn uống';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

class SubscriptionProvider extends ChangeNotifier {
  final ApiService _api;

  SubscriptionProvider(this._api);

  List<SubscriptionPlan> _plans = [];
  UserSubscription? _currentSubscription;
  bool _loading = false;
  String? _error;

  List<SubscriptionPlan> get plans => _plans;
  UserSubscription? get currentSubscription => _currentSubscription;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadSubscriptionData() async {
    _setLoading(true);
    try {
      final futures = await Future.wait([
        _api.getSubscriptionPlans(),
        _api.getCurrentSubscription(),
      ]);
      _plans = futures[0] as List<SubscriptionPlan>;
      _currentSubscription = futures[1] as UserSubscription;
      _error = null;
    } catch (e) {
      _error = 'Không thể tải dữ liệu gói dịch vụ';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getPaymentLink(int planId) async {
    try {
      return await _api.createPaymentLink(planId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

class MealSuggestionProvider extends ChangeNotifier {
  final ApiService _api;
  MealSuggestionProvider(this._api);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<MealSuggestion> _history = [];
  List<MealSuggestion> get history => _history;

  Future<List<MealSuggestion>?> suggestMeals({
    required String mealType,
    required int servingSize,
    required int numberOfDishes,
    String? availableIngredients,
    String? cuisinePreference,
    String? additionalNotes,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final request = {
        'mealType': mealType,
        'servingSize': servingSize,
        'numberOfDishes': numberOfDishes,
        'availableIngredients': availableIngredients ?? '',
        'cuisinePreference': cuisinePreference ?? '',
        'additionalNotes': additionalNotes ?? '',
      };
      final suggestions = await _api.suggestMeals(request);
      
      // Add to beginning of history
      _history.insertAll(0, suggestions);
      
      return suggestions;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHistory() async {
    _setLoading(true);
    _error = null;
    try {
      _history = await _api.getMealHistory(1, 50);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final updated = await _api.toggleFavoriteMeal(id);
      final index = _history.indexWhere((m) => m.id == id);
      if (index != -1) {
        _history[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> deleteSuggestion(int id) async {
    try {
      await _api.deleteMealSuggestion(id);
      _history.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}

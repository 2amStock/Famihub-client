import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onError: (error, handler) {
        print(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        print('Error Data: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final res = await _dio.post('/Auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    if (res.data['token'] != null && res.data['token'].toString().isNotEmpty) {
      await _storage.write(key: 'token', value: res.data['token']);
    }
    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/Auth/login', data: {
        'email': email,
        'password': password,
      });
      await _storage.write(key: 'token', value: res.data['token']);
      return res.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['errorCode'] == 'UNVERIFIED_EMAIL') {
        throw Exception('UNVERIFIED_EMAIL');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otpCode) async {
    final res = await _dio.post('/Auth/verify-otp', data: {
      'email': email,
      'otpCode': otpCode,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    final res = await _dio.post('/Auth/resend-otp', data: {
      'email': email,
    });
    return res.data;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<String?> getToken() => _storage.read(key: 'token');

  Future<AppUser> getMe() async {
    final res = await _dio.get('/Auth/me');
    return AppUser.fromJson(res.data);
  }

  Future<List<AppUser>> getLeaderboard() async {
    final res = await _dio.get('/User/leaderboard');
    return (res.data as List).map((u) => AppUser.fromJson(u)).toList();
  }

  Future<AppUser> updateProfile(String? name, String? avatar) async {
    final res = await _dio.put('/User/profile', data: {
      'name': name,
      'avatar': avatar,
    });
    return AppUser.fromJson(res.data);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.put('/User/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      rethrow;
    }
  }

  // ── Families ─────────────────────────────────────────────────────────────

  Future<Family> createFamily(String name) async {
    final res = await _dio.post('/Families', data: {'name': name});
    return Family.fromJson(res.data);
  }

  Future<Map<String, dynamic>> joinFamily(String inviteCode) async {
    final res =
        await _dio.post('/Families/join', data: {'inviteCode': inviteCode});
    return res.data;
  }

  Future<Family> getMyFamily() async {
    final res = await _dio.get('/Families/my');
    return Family.fromJson(res.data);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  Future<List<FamilyTask>> getTasks() async {
    final res = await _dio.get('/Tasks');
    return (res.data as List).map((t) => FamilyTask.fromJson(t)).toList();
  }

  Future<FamilyTask> getTask(int id) async {
    final res = await _dio.get('/Tasks/$id');
    return FamilyTask.fromJson(res.data);
  }

  Future<FamilyTask> createTask({
    required String title,
    String? description,
    int? assignedToUserId,
    DateTime? dueDate,
    required int points,
  }) async {
    final res = await _dio.post('/Tasks', data: {
      'title': title,
      'description': description,
      'assignedToUserId': assignedToUserId,
      'dueDate': dueDate?.toIso8601String(),
      'points': points,
    });
    return FamilyTask.fromJson(res.data);
  }

  Future<String> uploadFile(Uint8List bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final res = await _dio.post(
      '/File/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return res.data['url'] as String;
  }

  Future<FamilyTask> submitTask(
      int taskId, String? note, String photoUrl) async {
    final res = await _dio.post(
      '/Tasks/$taskId/submit',
      data: {
        'note': note ?? '',
        'photoUrl': photoUrl,
      },
    );
    return FamilyTask.fromJson(res.data);
  }

  Future<FamilyTask> approveTask(int taskId, bool approved,
      {String? rejectionNote}) async {
    final res = await _dio.post('/Tasks/$taskId/approve', data: {
      'approved': approved,
      'rejectionNote': rejectionNote,
    });
    return FamilyTask.fromJson(res.data);
  }

  // --- Payment ---
  Future<String?> createPaymentLink(int planId) async {
    try {
      // Truyền baseUrl để Backend biết đường dẫn Ngrok hiện tại
      final baseUrl = _dio.options.baseUrl.replaceAll('/api', '');
      final res = await _dio.post('/Payment/create-link', data: {
        'planId': planId,
        'returnUrl': '$baseUrl/api/Payment/redirect-app'
      });
      return res.data['checkoutUrl'];
    } on DioException catch (e) {
      if (e.response != null &&
          e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Lỗi kết nối PayOS');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    await _dio.delete('/Tasks/$taskId');
  }

  // ── Rewards ──────────────────────────────────────────────────────────────

  Future<List<Reward>> getRewards() async {
    final res = await _dio.get('/Rewards');
    return (res.data as List).map((r) => Reward.fromJson(r)).toList();
  }

  Future<Reward> createReward(
      {required String title,
      String? description,
      required int requiredPoints}) async {
    final res = await _dio.post('/Rewards', data: {
      'title': title,
      'description': description,
      'requiredPoints': requiredPoints,
    });
    return Reward.fromJson(res.data);
  }

  Future<Reward> updateReward(int id,
      {String? title, String? description, int? requiredPoints}) async {
    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (requiredPoints != null) body['requiredPoints'] = requiredPoints;
    final res = await _dio.put('/Rewards/$id', data: body);
    return Reward.fromJson(res.data);
  }

  Future<void> deleteReward(int id) async {
    await _dio.delete('/Rewards/$id');
  }

  Future<List<RewardRedemption>> getRedemptions() async {
    final res = await _dio.get('/Rewards/redemptions');
    return (res.data as List)
        .map((rr) => RewardRedemption.fromJson(rr))
        .toList();
  }

  Future<RewardRedemption> redeemReward(int rewardId) async {
    try {
      final res = await _dio.post('/Rewards/$rewardId/redeem');
      return RewardRedemption.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      rethrow;
    }
  }

  Future<RewardRedemption> approveRedemption(int redemptionId, bool approved,
      {String? parentNote}) async {
    final res =
        await _dio.post('/Rewards/redemptions/$redemptionId/approve', data: {
      'approved': approved,
      'parentNote': parentNote,
    });
    return RewardRedemption.fromJson(res.data);
  }

  // ── Family Events ────────────────────────────────────────────────────────

  Future<List<FamilyEvent>> getFamilyEvents() async {
    final res = await _dio.get('/family-events');
    return (res.data as List).map((e) => FamilyEvent.fromJson(e)).toList();
  }

  Future<FamilyEvent> createFamilyEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final res = await _dio.post('/family-events', data: {
      'title': title,
      'description': description ?? '',
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
    });
    return FamilyEvent.fromJson(res.data);
  }

  Future<void> deleteFamilyEvent(int id) async {
    await _dio.delete('/family-events/$id');
  }

  // ── Food Preferences ──────────────────────────────────────────────────────

  // ── Food Preferences ──────────────────────────────────────────────────────

  Future<FoodPreference> getFoodPreference() async {
    final res = await _dio.get('/FoodPreferences');
    return FoodPreference.fromJson(res.data);
  }

  Future<FoodPreference> updateFoodPreference(FoodPreference preference) async {
    final res = await _dio.put('/FoodPreferences', data: preference.toJson());
    return FoodPreference.fromJson(res.data);
  }

  // --- Meal Suggestions ---
  Future<List<MealSuggestion>> suggestMeals(Map<String, dynamic> request) async {
    try {
      final res = await _dio.post('/meals/suggest', data: request);
      final List data = res.data['dishes'];
      return data.map((e) => MealSuggestion.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Lỗi khi gọi AI gợi ý món ăn');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<List<MealSuggestionGroup>> getMealHistory(int page, int pageSize) async {
    try {
      final res = await _dio.get('/meals/history?page=$page&pageSize=$pageSize');
      final List data = res.data;
      
      final flatList = data.map((e) => MealSuggestion.fromJson(e)).toList();
      final Map<String, MealSuggestionGroup> groups = {};
      
      for (var dish in flatList) {
        String dateKey = '${dish.createdAt.year}-${dish.createdAt.month.toString().padLeft(2, '0')}-${dish.createdAt.day.toString().padLeft(2, '0')} ${dish.createdAt.hour.toString().padLeft(2, '0')}:${dish.createdAt.minute.toString().padLeft(2, '0')}';
        String fullKey = '${dateKey}_${dish.mealType}';
        
        if (!groups.containsKey(fullKey)) {
          groups[fullKey] = MealSuggestionGroup(date: dateKey, mealType: dish.mealType, dishes: []);
        }
        groups[fullKey]!.dishes.add(dish);
      }
      
      return groups.values.toList();
    } catch (e) {
      throw Exception('Lỗi tải lịch sử gợi ý món ăn: $e');
    }
  }

  Future<List<MealSuggestion>> getFavoriteMeals() async {
    try {
      final res = await _dio.get('/meals/favorites');
      final List data = res.data;
      return data.map((e) => MealSuggestion.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Lỗi tải danh sách món yêu thích');
    }
  }

  Future<MealSuggestion> toggleFavoriteMeal(int id) async {
    try {
      final res = await _dio.put('/meals/$id/favorite');
      return MealSuggestion.fromJson(res.data['dish']);
    } catch (e) {
      throw Exception('Lỗi cập nhật món yêu thích');
    }
  }

  Future<void> deleteMealSuggestion(int id) async {
    try {
      await _dio.delete('/meals/$id');
    } catch (e) {
      throw Exception('Lỗi xóa món ăn');
    }
  } 

  // ── Subscriptions ─────────────────────────────────────────────────────────

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final res = await _dio.get('/Subscriptions/plans');
    return (res.data as List).map((p) => SubscriptionPlan.fromJson(p)).toList();
  }

  Future<UserSubscription> getCurrentSubscription() async {
    final res = await _dio.get('/Subscriptions/current');
    return UserSubscription.fromJson(res.data);
  }
  // ── Notifications ──────────────────────────────────────────────────────────

  Future<List<AppNotification>> getNotifications() async {
    final res = await _dio.get('/Notifications');
    return (res.data as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markAsRead(int id) async {
    await _dio.put('/Notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.put('/Notifications/read-all');
  }
}

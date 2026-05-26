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
        print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
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
      if (e.response?.statusCode == 403 && e.response?.data['errorCode'] == 'UNVERIFIED_EMAIL') {
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

  // ── Families ─────────────────────────────────────────────────────────────

  Future<Family> createFamily(String name) async {
    final res = await _dio.post('/Families', data: {'name': name});
    return Family.fromJson(res.data);
  }

  Future<Map<String, dynamic>> joinFamily(String inviteCode) async {
    final res = await _dio.post('/Families/join', data: {'inviteCode': inviteCode});
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

  Future<FamilyTask> submitTask(int taskId, String? note, String photoUrl) async {
    final res = await _dio.post(
      '/Tasks/$taskId/submit',
      data: {
        'note': note ?? '',
        'photoUrl': photoUrl,
      },
    );
    return FamilyTask.fromJson(res.data);
  }

  Future<FamilyTask> approveTask(int taskId, bool approved, {String? rejectionNote}) async {
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
      if (e.response != null && e.response?.data != null && e.response?.data['message'] != null) {
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
}

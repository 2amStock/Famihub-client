class ApiConstants {
  // Change this to your server IP when testing on physical device
  // For Android emulator: http://10.0.2.2:5000
  // For iOS simulator: http://localhost:5000
  // For physical device: https://famihub-api-dev-production.up.railway.app
  static const String baseUrl = 'https://famihub-be-prod.up.railway.app';
  static const String apiUrl = '$baseUrl/api';

  static const String auth = '$apiUrl/Auth';
  static const String families = '$apiUrl/Families';
  static const String tasks = '$apiUrl/Tasks';
}

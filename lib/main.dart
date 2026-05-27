import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/providers.dart';
import 'data/services/api_service.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/parent/parent_main_screen.dart';
import 'presentation/child/child_main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiService = ApiService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => FamilyProvider(apiService)),
        ChangeNotifierProvider(create: (_) => TaskProvider(apiService)),
        ChangeNotifierProvider(create: (_) => RewardProvider(apiService)),
      ],
      child: const FamiHubApp(),
    ),
  );
}

class FamiHubApp extends StatelessWidget {
  const FamiHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamiHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    if (auth.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }
    
    return auth.user!.isParent 
        ? const ParentMainScreen() 
        : const ChildMainScreen();
  }
}

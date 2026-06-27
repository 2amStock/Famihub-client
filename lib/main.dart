import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/providers.dart';
import 'data/services/api_service.dart';
import 'presentation/auth/onboarding_screen.dart';
import 'presentation/parent/parent_main_screen.dart';
import 'presentation/child/child_main_screen.dart';
import 'data/services/fcm_service.dart' as data_services;
import 'data/services/shopping_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  
  final apiService = ApiService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ProxyProvider<ApiService, data_services.FcmService>(
          update: (_, api, __) => data_services.FcmService(api),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => FamilyProvider(apiService)),
        ChangeNotifierProvider(create: (_) => TaskProvider(apiService)),
        ChangeNotifierProvider(create: (_) => RewardProvider(apiService)),
        ChangeNotifierProvider(create: (_) => FamilyEventProvider(apiService)),

        ChangeNotifierProvider(create: (_) => SubscriptionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => MealSuggestionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(apiService)),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ShoppingService(apiService: apiService)),
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
      builder: (context, child) {
        // Ensure responsive UI across different screen sizes by clamping text scaling
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.1);
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: child!,
        );
      },
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
    data_services.FcmService.onRefreshRequired = () {
      if (mounted) {
        context.read<TaskProvider>().loadTasks();
        context.read<RewardProvider>().loadAll();
        context.read<NotificationProvider>().loadNotifications();
        context.read<FamilyProvider>().loadFamily();
      }
    };
    _checkAuth();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (!Platform.isAndroid) return;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      debugPrint("In-app update error: $e");
    }
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (auth.isLoggedIn && mounted) {
      context.read<data_services.FcmService>().initialize();
    }
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
      return const OnboardingScreen();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<data_services.FcmService>().initialize();
      }
    });

    return auth.user!.isParent 
        ? const ParentMainScreen() 
        : const ChildMainScreen();
  }
}

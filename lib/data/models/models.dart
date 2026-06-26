import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
export 'family_event_model.dart';
export 'notification_model.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? familyId;
  final String? familyName;
  final int points;
  final String? avatar;
  final int currentPlanId;
  final DateTime? subscriptionExpiryTime;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.familyId,
    this.familyName,
    required this.points,
    this.avatar,
    this.currentPlanId = 1,
    this.subscriptionExpiryTime,
  });

  bool get isParent => role == 'Parent';
  bool get isChild => role == 'Child';

  String? get fullAvatarUrl {
    if (avatar == null) return null;
    String url = avatar!;
    if (!url.startsWith('http')) {
      url = '${ApiConstants.baseUrl}$url';
    }
    
    // Fix for Android Emulator if using localhost backend
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && 
        (url.contains('localhost') || url.contains('127.0.0.1'))) {
      url = url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        familyId: json['familyId'],
        familyName: json['familyName'],
        points: json['points'] ?? 0,
        avatar: json['avatar'],
        currentPlanId: json['currentPlanId'] ?? 1,
        subscriptionExpiryTime: json['subscriptionExpiryTime'] != null 
            ? DateTime.parse(json['subscriptionExpiryTime']).toLocal() 
            : null,
      );
}

class Family {
  final int id;
  final String name;
  final String inviteCode;
  final List<AppUser> members;

  Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.members,
  });

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json['id'],
        name: json['name'],
        inviteCode: json['inviteCode'],
        members: (json['members'] as List? ?? [])
            .map((m) => AppUser.fromJson(m))
            .toList(),
      );
}

class TaskProof {
  final int id;
  final String photoUrl;
  final String? note;
  final DateTime submittedAt;
  final AppUser? child;

  TaskProof({
    required this.id,
    required this.photoUrl,
    this.note,
    required this.submittedAt,
    this.child,
  });

  String get fullPhotoUrl {
    String url = photoUrl;
    if (!url.startsWith('http')) {
      url = '${ApiConstants.baseUrl}$url';
    }

    // Fix for Android Emulator if using localhost backend
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && 
        (url.contains('localhost') || url.contains('127.0.0.1'))) {
      url = url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  List<String> get photoUrls {
    if (photoUrl.isEmpty) return [];
    return photoUrl.split(',').map((url) {
      String fullUrl = url.trim();
      if (fullUrl.isEmpty) return '';
      if (!fullUrl.startsWith('http')) {
        fullUrl = '${ApiConstants.baseUrl}$fullUrl';
      }
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && 
          (fullUrl.contains('localhost') || fullUrl.contains('127.0.0.1'))) {
        fullUrl = fullUrl.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
      }
      return fullUrl;
    }).where((u) => u.isNotEmpty).toList();
  }

  factory TaskProof.fromJson(Map<String, dynamic> json) => TaskProof(
        id: json['id'],
        photoUrl: json['photoUrl'],
        note: json['note'],
        submittedAt: DateTime.parse(json['submittedAt']).toLocal(),
        child: json['child'] != null ? AppUser.fromJson(json['child']) : null,
      );
}

class FamilyTask {
  final int id;
  final String title;
  final String? description;
  final int points;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final AppUser? assignedTo;
  final AppUser? createdBy;
  final TaskProof? proof;
  final String? rejectionNote;

  FamilyTask({
    required this.id,
    required this.title,
    this.description,
    required this.points,
    required this.status,
    this.dueDate,
    required this.createdAt,
    this.assignedTo,
    this.createdBy,
    this.proof,
    this.rejectionNote,
  });

  bool get isPending => status == 'Pending';
  bool get isInProgress => status == 'InProgress';
  bool get isSubmitted => status == 'Submitted';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';

  factory FamilyTask.fromJson(Map<String, dynamic> json) => FamilyTask(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        points: json['points'],
        status: json['status'],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']).toLocal() : null,
        createdAt: DateTime.parse(json['createdAt']).toLocal(),
        assignedTo: json['assignedTo'] != null ? AppUser.fromJson(json['assignedTo']) : null,
        createdBy: json['createdBy'] != null ? AppUser.fromJson(json['createdBy']) : null,
        proof: json['proof'] != null ? TaskProof.fromJson(json['proof']) : null,
        rejectionNote: json['rejectionNote'],
      );
}

class Reward {
  final int id;
  final String title;
  final String? description;
  final int requiredPoints;
  final bool isSuggested;
  final DateTime createdAt;
  final AppUser? createdBy;

  Reward({
    required this.id,
    required this.title,
    this.description,
    required this.requiredPoints,
    this.isSuggested = false,
    required this.createdAt,
    this.createdBy,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        requiredPoints: json['requiredPoints'],
        isSuggested: json['isSuggested'] ?? false,
        createdAt: DateTime.parse(json['createdAt']).toLocal(),
        createdBy: json['createdBy'] != null ? AppUser.fromJson(json['createdBy']) : null,
      );
}

class RewardRedemption {
  final int id;
  final int rewardId;
  final String rewardTitle;
  final String? rewardDescription;
  final int requiredPoints;
  final String status;
  final String? parentNote;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final AppUser? child;

  RewardRedemption({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    this.rewardDescription,
    required this.requiredPoints,
    required this.status,
    this.parentNote,
    required this.createdAt,
    this.updatedAt,
    this.child,
  });

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';

  factory RewardRedemption.fromJson(Map<String, dynamic> json) => RewardRedemption(
        id: json['id'],
        rewardId: json['rewardId'],
        rewardTitle: json['rewardTitle'] ?? '',
        rewardDescription: json['rewardDescription'],
        requiredPoints: json['requiredPoints'] ?? 0,
        status: json['status'],
        parentNote: json['parentNote'],
        createdAt: DateTime.parse(json['createdAt']).toLocal(),
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']).toLocal() : null,
        child: json['child'] != null ? AppUser.fromJson(json['child']) : null,
      );
}

class FoodPreference {
  final int userId;
  final String userName;
  final List<String> favoriteDishes;
  final List<String> dislikedIngredients;
  final List<String> dietaryRestrictions;
  final List<String> cuisinePreferences;

  FoodPreference({
    required this.userId,
    required this.userName,
    this.favoriteDishes = const [],
    this.dislikedIngredients = const [],
    this.dietaryRestrictions = const [],
    this.cuisinePreferences = const [],
  });

  factory FoodPreference.fromJson(Map<String, dynamic> json) => FoodPreference(
        userId: json['userId'] ?? 0,
        userName: json['userName'] ?? '',
        favoriteDishes: List<String>.from(json['favoriteDishes'] ?? []),
        dislikedIngredients: List<String>.from(json['dislikedIngredients'] ?? []),
        dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
        cuisinePreferences: List<String>.from(json['cuisinePreferences'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'favoriteDishes': favoriteDishes,
        'dislikedIngredients': dislikedIngredients,
        'dietaryRestrictions': dietaryRestrictions,
        'cuisinePreferences': cuisinePreferences,
      };
}

class SubscriptionPlan {
  final int id;
  final String name;
  final double price;
  final String durationType;
  final int maxMembers;
  final int maxTasksPerDay;
  final bool hasAI;
  final bool hasCalendar;
  final bool hasShoppingList;
  final bool hasStudyTracking;
  final bool hasAchievement;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationType,
    required this.maxMembers,
    required this.maxTasksPerDay,
    required this.hasAI,
    required this.hasCalendar,
    required this.hasShoppingList,
    required this.hasStudyTracking,
    required this.hasAchievement,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        durationType: json['durationType'],
        maxMembers: json['maxMembers'],
        maxTasksPerDay: json['maxTasksPerDay'],
        hasAI: json['hasAI'],
        hasCalendar: json['hasCalendar'],
        hasShoppingList: json['hasShoppingList'],
        hasStudyTracking: json['hasStudyTracking'],
        hasAchievement: json['hasAchievement'],
      );
}

class UserSubscription {
  final int userId;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  UserSubscription({
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) => UserSubscription(
        userId: json['userId'],
        plan: SubscriptionPlan.fromJson(json['plan']),
        startDate: DateTime.parse(json['startDate']).toLocal(),
        endDate: DateTime.parse(json['endDate']).toLocal(),
        status: json['status'],
      );
}

class Ingredient {
  final String name;
  final String amount;
  final String unit;
  final String? note;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.note,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] ?? '',
        amount: json['amount'] ?? '',
        unit: json['unit'] ?? '',
        note: json['note'],
      );
}

class NutritionInfo {
  final String calories;
  final String protein;
  final String carbs;
  final String fat;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
        calories: json['calories'] ?? '',
        protein: json['protein'] ?? '',
        carbs: json['carbs'] ?? '',
        fat: json['fat'] ?? '',
      );
}

class MealSuggestion {
  final int id;
  final String mealType;
  final String dishName;
  final String? description;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final int servingSize;
  final int estimatedTime;
  final String? difficultyLevel;
  final String? cuisineType;
  final NutritionInfo? nutritionInfo;
  final bool isFavorite;
  final DateTime createdAt;
  final String? requestedByName;

  MealSuggestion({
    required this.id,
    required this.mealType,
    required this.dishName,
    this.description,
    this.ingredients = const [],
    this.instructions = const [],
    required this.servingSize,
    required this.estimatedTime,
    this.difficultyLevel,
    this.cuisineType,
    this.nutritionInfo,
    this.isFavorite = false,
    required this.createdAt,
    this.requestedByName,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) => MealSuggestion(
        id: json['id'] ?? 0,
        mealType: json['mealType'] ?? '',
        dishName: json['dishName'] ?? '',
        description: json['description'],
        ingredients: (json['ingredients'] as List?)?.map((i) => Ingredient.fromJson(i)).toList() ?? [],
        instructions: (json['instructions'] as List?)?.map((i) => i.toString()).toList() ?? [],
        servingSize: json['servingSize'] ?? 1,
        estimatedTime: json['estimatedTime'] ?? 0,
        difficultyLevel: json['difficultyLevel'],
        cuisineType: json['cuisineType'],
        nutritionInfo: json['nutritionInfo'] != null ? NutritionInfo.fromJson(json['nutritionInfo']) : null,
        isFavorite: json['isFavorite'] ?? false,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']).toLocal() : DateTime.now(),
        requestedByName: json['requestedByName'],
      );
}

class MealSuggestionGroup {
  final String date;
  final String mealType;
  final List<MealSuggestion> dishes;

  MealSuggestionGroup({
    required this.date,
    required this.mealType,
    required this.dishes,
  });

  factory MealSuggestionGroup.fromJson(Map<String, dynamic> json) => MealSuggestionGroup(
        date: json['date'] ?? '',
        mealType: json['mealType'] ?? '',
        dishes: (json['dishes'] as List?)?.map((i) => MealSuggestion.fromJson(i)).toList() ?? [],
      );
}

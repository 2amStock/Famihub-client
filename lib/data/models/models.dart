            import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

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
            ? DateTime.parse(json['subscriptionExpiryTime']) 
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

  factory TaskProof.fromJson(Map<String, dynamic> json) => TaskProof(
        id: json['id'],
        photoUrl: json['photoUrl'],
        note: json['note'],
        submittedAt: DateTime.parse(json['submittedAt']),
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
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        assignedTo: json['assignedTo'] != null ? AppUser.fromJson(json['assignedTo']) : null,
        createdBy: json['createdBy'] != null ? AppUser.fromJson(json['createdBy']) : null,
        proof: json['proof'] != null ? TaskProof.fromJson(json['proof']) : null,
        rejectionNote: json['rejectionNote'],
      );
}

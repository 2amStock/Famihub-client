class FamilyEvent {
  final int id;
  final int familyId;
  final int createdByUserId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  FamilyEvent({
    required this.id,
    required this.familyId,
    required this.createdByUserId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  factory FamilyEvent.fromJson(Map<String, dynamic> json) {
    return FamilyEvent(
      id: json['id'],
      familyId: json['familyId'],
      createdByUserId: json['createdByUserId'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']).toLocal(),
      endTime: DateTime.parse(json['endTime']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
    };
  }
}

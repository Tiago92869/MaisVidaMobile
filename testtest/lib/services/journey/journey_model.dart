import 'dart:convert';

class Journey {
  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? completionImage;
  final List<JourneyResource> journeyResources;

  Journey({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.completionImage,
    required this.journeyResources,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      completionImage: json['completionImage'],
      journeyResources: (json['journeyResources'] as List)
          .map((resource) => JourneyResource.fromJson(resource))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completionImage': completionImage,
      'journeyResources': journeyResources.map((e) => e.toJson()).toList(),
    };
  }
}

class JourneyResource {
  final String id;
  final String resourceId;
  final int order;
  final String? unlockImageId;

  JourneyResource({
    required this.id,
    required this.resourceId,
    required this.order,
    this.unlockImageId,
  });

  factory JourneyResource.fromJson(Map<String, dynamic> json) {
    return JourneyResource(
      id: json['id'],
      resourceId: json['resourceId'],
      order: json['order'],
      unlockImageId: json['unlockImageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'order': order,
      'unlockImageId': unlockImageId,
    };
  }
}

class UserJourneyProgress {
  final String id;
  final String userId;
  final String journeyId;
  final int currentStep;
  final List<UserJourneyResourceProgress> resourceProgressList;

  UserJourneyProgress({
    required this.id,
    required this.userId,
    required this.journeyId,
    required this.currentStep,
    required this.resourceProgressList,
  });

  factory UserJourneyProgress.fromJson(Map<String, dynamic> json) {
    return UserJourneyProgress(
      id: json['id'],
      userId: json['userId'],
      journeyId: json['journeyId'],
      currentStep: json['currentStep'],
      resourceProgressList: (json['resourceProgressList'] as List)
          .map((progress) => UserJourneyResourceProgress.fromJson(progress))
          .toList(),
    );
  }
}

class UserJourneyResourceProgress {
  final String id;
  final int order;
  final bool completed;
  final bool unlocked;

  UserJourneyResourceProgress({
    required this.id,
    required this.order,
    required this.completed,
    required this.unlocked,
  });

  factory UserJourneyResourceProgress.fromJson(Map<String, dynamic> json) {
    return UserJourneyResourceProgress(
      id: json['id'],
      order: json['order'],
      completed: json['completed'],
      unlocked: json['unlocked'],
    );
  }
}

DateTime? parseDate(String? date) => date != null ? DateTime.parse(date) : null;
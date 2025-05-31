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
    print('Parsing Journey JSON: $json');
    return Journey(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Journey',
      description: json['description'] ?? 'No description available.',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      completionImage: json['completionImage'],
      journeyResources: (json['journeyResources'] as List?)
              ?.map((resource) => JourneyResource.fromJson(resource))
              .toList() ??
          [],
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
    print('Parsing JourneyResource JSON: $json');
    return JourneyResource(
      id: json['id'] ?? '',
      resourceId: json['resourceId'] ?? '',
      order: json['order'] ?? 0,
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

class JourneySimpleUser {
  final String id;
  final String title;
  final String description;
  final bool started;
  final String? rewardImage;
  final DateTime? createdAt;
  final int resourceQuantity;
  final int completedQuantity;

  JourneySimpleUser({
    required this.id,
    required this.title,
    required this.description,
    required this.started,
    this.rewardImage,
    this.createdAt,
    required this.resourceQuantity,
    required this.completedQuantity,
  });

  factory JourneySimpleUser.fromJson(Map<String, dynamic> json) {
    return JourneySimpleUser(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Journey',
      description: json['description'] ?? 'No description available.',
      started: json['started'] ?? false,
      rewardImage: json['rewardImage'],
      createdAt: parseDate(json['createdAt']),
      resourceQuantity: json['resourceQuantity'] ?? 0,
      completedQuantity: json['completedQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'started': started,
      'rewardImage': rewardImage,
      'createdAt': createdAt?.toIso8601String(),
      'resourceQuantity': resourceQuantity,
      'completedQuantity': completedQuantity,
    };
  }
}

class UserJourneyProgress {
  final String id;
  final JourneySimpleUser journey;
  final int currentStep;
  final List<UserJourneyResourceProgress> resourceProgressList;

  UserJourneyProgress({
    required this.id,
    required this.journey,
    required this.currentStep,
    required this.resourceProgressList,
  });

  factory UserJourneyProgress.fromJson(Map<String, dynamic> json) {
    return UserJourneyProgress(
      id: json['id'] ?? '',
      journey: JourneySimpleUser.fromJson(json['journey']),
      currentStep: json['currentStep'] ?? 0,
      resourceProgressList: (json['resourceProgressList'] as List?)
              ?.map((progress) => UserJourneyResourceProgress.fromJson(progress))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journey': journey.toJson(),
      'currentStep': currentStep,
      'resourceProgressList': resourceProgressList.map((e) => e.toJson()).toList(),
    };
  }
}

class UserJourneyResourceProgress {
  final String id;
  final int order;
  final bool completed;
  final bool unlocked;
  final String? feeling;

  UserJourneyResourceProgress({
    required this.id,
    required this.order,
    required this.completed,
    required this.unlocked,
    this.feeling,
  });

  factory UserJourneyResourceProgress.fromJson(Map<String, dynamic> json) {
    return UserJourneyResourceProgress(
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      completed: json['completed'] ?? false,
      unlocked: json['unlocked'] ?? false,
      feeling: json['feeling'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'completed': completed,
      'unlocked': unlocked,
      'feeling': feeling,
    };
  }
}

final mockJourney = UserJourneyProgress(
  id: "mock-journey-id",
  journey: JourneySimpleUser(
    id: "mock-journey-id",
    title: "Mock Journey",
    description: "This is a mock journey",
    started: true,
    rewardImage: null,
    createdAt: DateTime.now(),
    resourceQuantity: 28,
    completedQuantity: 10,
  ),
  currentStep: 5,
  resourceProgressList: List.generate(
    28,
    (index) => UserJourneyResourceProgress(
      id: "resource-${index + 1}",
      order: index + 1,
      completed: true, // First 10 resources are completed
      unlocked: true, // First 20 resources are unlocked
      feeling: null,
    ),
  ),
);

DateTime? parseDate(String? date) => date != null ? DateTime.parse(date) : null;
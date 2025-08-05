import 'package:maisvida/services/favorite/favorite_model.dart';
import 'package:maisvida/services/resource/resource_model.dart';

class ActivityPage {
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final int number;
  final List<Activity> content;

  ActivityPage({
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.number,
    required this.content,
  });

  factory ActivityPage.fromJson(Map<String, dynamic> json) {
    var contentJson = json['content'] as List;
    List<Activity> contentList =
        contentJson.map((i) => Activity.fromJsonPage(i)).toList();

    return ActivityPage(
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      first: json['first'],
      last: json['last'],
      size: json['size'],
      number: json['number'],
      content: contentList,
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Resource>? resources;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.resources,
  });

  factory Activity.fromSimple(ActivitySimple simple) {
    return Activity(
      id: simple.id,
      title: simple.title,
      description: '',
      createdAt: null,
      updatedAt: null,
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    var resourcesJson = json['resources'] as List?;

    List<Resource> resourcesList =
        resourcesJson != null
            ? resourcesJson.map((i) => Resource.fromJson(i)).toList()
            : [];

    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt:
          json.containsKey('createdAt')
              ? DateTime.parse(json['createdAt'])
              : null,
      updatedAt:
          json.containsKey('updatedAt')
              ? DateTime.parse(json['updatedAt'])
              : null,
      resources: resourcesList,
    );
  }

  factory Activity.fromJsonPage(Map<String, dynamic> json) {
    var resourcesJson = json['resources'] as List?;

    List<Resource> resourcesList =
        resourcesJson != null
            ? resourcesJson.map((i) => Resource.fromJson(i)).toList()
            : [];

    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'], // Parse the description
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      resources: resourcesList, // Parse the resources
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resources': resources?.map((r) => r.toJson()).toList(),
    };
  }
}

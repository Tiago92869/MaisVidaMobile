
class Favorite {
  final String id;
  final List<ResourceSimple> resources;
  final List<ActivitySimple> activities;

  Favorite({
    required this.id,
    required this.resources,
    required this.activities,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    var resourcesJson = json['resources'] as List?;
    var activitiesJson = json['activities'] as List?;

    List<ResourceSimple> resourcesList = resourcesJson != null
        ? resourcesJson
            .map((i) => ResourceSimple.fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    List<ActivitySimple> activitiesList = activitiesJson != null
        ? activitiesJson
            .map((i) => ActivitySimple.fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    return Favorite(
      id: json['id'] as String,
      resources: resourcesList,
      activities: activitiesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resources': resources.map((e) => e.toJson()).toList(),
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }
}

class FavoriteInput {
  final List<String> activities;
  final List<String> resources;

  FavoriteInput({
    required this.activities,
    required this.resources,
  });

  Map<String, dynamic> toJson() {
    return {
      'activities': activities,
      'resources': resources,
    };
  }
}

class ResourceSimple {
  final String id;
  final String title;
  final String type;

  ResourceSimple({
    required this.id,
    required this.title,
    required this.type,
  });

  factory ResourceSimple.fromJson(Map<String, dynamic> json) {
    return ResourceSimple(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
    };
  }
}

class ActivitySimple {
  final String id;
  final String title;

  ActivitySimple({
    required this.id,
    required this.title,
  });

  factory ActivitySimple.fromJson(Map<String, dynamic> json) {
    return ActivitySimple(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

import 'package:maisvida/services/favorite/favorite_model.dart';

enum ResourceType {
  ARTICLE,
  VIDEO,
  PODCAST,
  PHRASE,
  CARE,
  EXERCISE,
  RECIPE,
  MUSIC,
  SOS,
  OTHER,
  TIVA,
}

extension ResourceTypeExtension on ResourceType {
  static ResourceType fromString(String type) {
    switch (type.toUpperCase()) { // Convert to uppercase for case-insensitive comparison
      case 'ARTICLE':
        return ResourceType.ARTICLE;
      case 'VIDEO':
        return ResourceType.VIDEO;
      case 'PODCAST':
        return ResourceType.PODCAST;
      case 'PHRASE':
        return ResourceType.PHRASE;
      case 'CARE':
        return ResourceType.CARE;
      case 'EXERCISE':
        return ResourceType.EXERCISE;
      case 'RECIPE':
        return ResourceType.RECIPE;
      case 'MUSIC':
        return ResourceType.MUSIC;
      case 'SOS':
        return ResourceType.SOS;
      case 'OTHER':
        return ResourceType.OTHER;
      case 'TIVA': // Ensure TIVA is handled
        return ResourceType.TIVA;
      default:
        throw ArgumentError('Unknown ResourceType: $type');
    }
  }

  static List<ResourceType> getFilterableTypes() {
    return ResourceType.values.where((type) => type != ResourceType.TIVA).toList();
  }
}

class Content {
  final String id;
  final String? contentValue; // Made nullable
  final String? contentId; // Made nullable
  final String type;
  final int order;
  final List<String>? multipleValue;
  final String? answerYes; // Already nullable
  final String? answerNo; // Already nullable

  const Content({
    required this.id,
    this.contentValue, // Made nullable
    this.contentId, // Made nullable
    required this.type,
    required this.order,
    this.multipleValue,
    this.answerYes,
    this.answerNo,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      contentValue: json['contentValue'], // Nullable
      contentId: json['contentId'], // Nullable
      type: json['type'],
      order: json['order'],
      multipleValue: (json['multipleValue'] as List<dynamic>?)?.cast<String>(),
      answerYes: json['answerYes'],
      answerNo: json['answerNo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentValue': contentValue, // Nullable
      'contentId': contentId, // Nullable
      'type': type,
      'order': order,
      'multipleValue': multipleValue,
      'answerYes': answerYes,
      'answerNo': answerNo,
    };
  }
}

class Resource {
  final String id;
  final String title;
  final String description;
  final ResourceType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Content> contents;

  const Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.createdAt,
    this.updatedAt,
    required this.contents,
  });

  factory Resource.fromJsonGetAll(Map<String, dynamic> json) {
    var contentsJson = json['contents'] as List?; // Handle null case
    List<Content> contentsList = contentsJson != null
        ? contentsJson.map((i) => Content.fromJson(i)).toList()
        : []; // Default to an empty list if null

    return Resource(
      id: json['id'],
      title: json['title'],
      description: json['description'], // Parse the description from JSON
      type: ResourceTypeExtension.fromString(json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      contents: contentsList,
    );
  }

  factory Resource.fromSimple(ResourceSimple simple) {
    return Resource(
      id: simple.id,
      title: simple.title,
      description: '',
      type: ResourceTypeExtension.fromString(simple.type),
      createdAt: null,
      updatedAt: null,
      contents: [],
    );
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    var contentsJson = json['contents'] as List?; // Handle null case
    List<Content> contentsList = contentsJson != null
        ? contentsJson.map((i) => Content.fromJson(i)).toList()
        : []; // Default to an empty list if null

    return Resource(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ResourceTypeExtension.fromString(json['type']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      contents: contentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last.toUpperCase(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'contents': contents.map((content) => content.toJson()).toList(),
    };
  }
}

class ResourcePage {
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final int number;
  final List<Resource> content;

  ResourcePage({
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.number,
    required this.content,
  });

  factory ResourcePage.fromJson(Map<String, dynamic> json) {
    var contentJson = json['content'] as List;
    List<Resource> contentList =
        contentJson.map((i) => Resource.fromJsonGetAll(i)).toList();

    return ResourcePage(
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

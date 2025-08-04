
enum DiaryType {
  Love,
  Fantastic,
  Happy,
  Neutral,
  Disappointed,
  Sad,
  Angry,
  Sick,
}

extension DiaryEmotionExtension on DiaryType {
  static DiaryType fromString(String type) {
    switch (type) {
      case 'LOVE':
        return DiaryType.Love;
      case 'FANTASTIC':
        return DiaryType.Fantastic;
      case 'HAPPY':
        return DiaryType.Happy;
      case 'NEUTRAL':
        return DiaryType.Neutral;
      case 'DISAPPOINTED':
        return DiaryType.Disappointed;
      case 'SAD':
        return DiaryType.Sad;
      case 'ANGRY':
        return DiaryType.Angry;
      case 'SICK':
        return DiaryType.Sick;
      default:
        throw ArgumentError('Unknown DiaryEmotion: $type');
    }
  }
}

class Diary {
  final String id;
  final String title;
  final String description;
  final DateTime recordedAt;
  final DiaryType emotion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Diary({
    required this.id,
    required this.title,
    required this.description,
    required this.recordedAt,
    required this.emotion,
    this.createdAt,
    this.updatedAt,
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      emotion: DiaryEmotionExtension.fromString(json['emotion'] as String),
      createdAt: parseDate(json['createdAt'] as String?),
      updatedAt: parseDate(json['updatedAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'recordedAt': recordedAt.toIso8601String(),
      'emotion': emotion.toString().split('.').last.toUpperCase(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class DiaryDay {
  final DateTime day;
  final List<Diary> diaries;

  DiaryDay({
    required this.day,
    required this.diaries,
  });

  factory DiaryDay.fromJson(Map<String, dynamic> json) {
    var diariesJson = json['diaries'] as List;
    List<Diary> diariesList =
        diariesJson.map((i) => Diary.fromJson(i)).toList();

    return DiaryDay(
      day: DateTime.parse(json['day'] as String),
      diaries: diariesList,
    );
  }
}

DateTime? parseDate(String? date) => date != null ? DateTime.parse(date) : null;

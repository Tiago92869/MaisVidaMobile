enum UsefulnessRating {
  USEFUL,
  INDIFFERENT,
  NOT_USEFUL,
}

class Feedback {
  final String id;
  final String userId;
  final String resourceId;
  final UsefulnessRating usefulnessRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Feedback({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.usefulnessRating,
    this.createdAt,
    this.updatedAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      userId: json['userId'],
      resourceId: json['resourceId'],
      usefulnessRating: UsefulnessRating.values
          .firstWhere((e) => e.toString().split('.').last == json['usefulnessRating']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'resourceId': resourceId,
      'usefulnessRating': usefulnessRating.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class FeedbackPage {
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final int number;
  final List<Feedback> content;

  FeedbackPage({
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.number,
    required this.content,
  });

  factory FeedbackPage.fromJson(Map<String, dynamic> json) {
    var contentJson = json['content'] as List;
    List<Feedback> contentList =
        contentJson.map((i) => Feedback.fromJson(i)).toList();

    return FeedbackPage(
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

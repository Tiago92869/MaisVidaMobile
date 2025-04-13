enum GoalSubject { Personal, Work, Studies, Family }

extension GoalSubjectExtension on GoalSubject {
  static GoalSubject fromString(String subject) {
    switch (subject) {
      case 'PERSONAL':
        return GoalSubject.Personal;
      case 'WORK':
        return GoalSubject.Work;
      case 'STUDIES':
        return GoalSubject.Studies;
      case 'FAMILY':
        return GoalSubject.Family;
      default:
        throw ArgumentError('Unknown GoalSubject: $subject');
    }
  }
}

class GoalInfoCard {
  final String id;
  final String title;
  final String description;
  final DateTime goalDate;
  final DateTime? completedDate;
  final bool completed;
  final bool? hasNotifications;
  final GoalSubject subject;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GoalInfoCard({
    required this.id,
    required this.title,
    required this.description,
    required this.goalDate,
    this.completedDate,
    required this.completed,
    this.hasNotifications,
    required this.subject,
    this.createdAt,
    this.updatedAt,
  });

  factory GoalInfoCard.fromJson(Map<String, dynamic> json) {
    return GoalInfoCard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      goalDate: DateTime.parse(json['goalDate']),
      completedDate: parseDate(json['completedDate']),
      completed: json['completed'],
      hasNotifications: json['hasNotifications'],
      subject: GoalSubjectExtension.fromString(json['subject']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'goalDate': goalDate.toIso8601String(),
      'completed': completed,
      'hasNotifications': hasNotifications,
      'subject': subject.toString().split('.').last.toUpperCase(),
    };
  }
}

class GoalDay {
  final DateTime day;
  final List<GoalInfoCard> goals;

  GoalDay({required this.day, required this.goals});

  factory GoalDay.fromJson(Map<String, dynamic> json) {
    var goalsJson = json['goals'] as List;
    List<GoalInfoCard> goalsList =
        goalsJson.map((i) => GoalInfoCard.fromJson(i)).toList();

    return GoalDay(day: DateTime.parse(json['day']), goals: goalsList);
  }
}

class PagezGoalsDTO {
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final int numberOfElements;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;
  final List<GoalInfoCard> goals;

  PagezGoalsDTO({
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.numberOfElements,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
    required this.goals,
  });

  factory PagezGoalsDTO.fromJson(Map<String, dynamic> json) {
    var contentJson = json['content'] as List;
    List<GoalInfoCard> goalsList =
        contentJson.map((goal) => GoalInfoCard.fromJson(goal)).toList();

    return PagezGoalsDTO(
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      pageNumber: json['number'],
      pageSize: json['size'],
      numberOfElements: json['numberOfElements'],
      isFirst: json['first'],
      isLast: json['last'],
      isEmpty: json['empty'],
      goals: goalsList,
    );
  }
}

DateTime? parseDate(String? date) => date != null ? DateTime.parse(date) : null;

enum GoalSubject {
  Personal,
  Work,
  Studies,
  Family,
}

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

  GoalDay({
    required this.day,
    required this.goals,
  });

  factory GoalDay.fromJson(Map<String, dynamic> json) {
    print('STATUS CODE1');
    var goalsJson = json['goals'] as List;
    print('STATUS CODE2');
    List<GoalInfoCard> goalsList =
        goalsJson.map((i) => GoalInfoCard.fromJson(i)).toList();
    print('STATUS CODE3');

    return GoalDay(
      day: DateTime.parse(json['day']),
      goals: goalsList,
    );
  }
}

DateTime? parseDate(String? date) => date != null ? DateTime.parse(date) : null;

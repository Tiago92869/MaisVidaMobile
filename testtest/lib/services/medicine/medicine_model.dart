import 'package:flutter/material.dart';

class MedicinePage {
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final int number;
  final List<Medicine> content;

  MedicinePage({
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.number,
    required this.content,
  });

  factory MedicinePage.fromJson(Map<String, dynamic> json) {
    var contentJson = json['content'] as List;
    List<Medicine> contentList =
        contentJson.map((i) => Medicine.fromJson(i)).toList();

    return MedicinePage(
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

enum WeekDay {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}

extension WeekDayExtension on WeekDay {
  static WeekDay fromString(String day) {
    switch (day) {
      case 'MONDAY':
        return WeekDay.MONDAY;
      case 'TUESDAY':
        return WeekDay.TUESDAY;
      case 'WEDNESDAY':
        return WeekDay.WEDNESDAY;
      case 'THURSDAY':
        return WeekDay.THURSDAY;
      case 'FRIDAY':
        return WeekDay.FRIDAY;
      case 'SATURDAY':
        return WeekDay.SATURDAY;
      case 'SUNDAY':
        return WeekDay.SUNDAY;
      default:
        throw ArgumentError('Unknown WeekDay: $day');
    }
  }
}

class Dosage {
  final String id;
  final TimeOfDay time;
  final double dosage;

  Dosage({
    required this.id,
    required this.time,
    required this.dosage,
  });

  factory Dosage.fromJson(Map<String, dynamic> json) {
    String timeString = json['time'];
    List<String> parts = timeString.split(':');
    TimeOfDay timeOfDay = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    return Dosage(
      id: json['id'],
      time: timeOfDay,
      dosage: json['dosage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      'dosage': dosage,
    };
  }
}

class Plan {
  final String id;
  final WeekDay weekDay;
  final List<Dosage> dosages;

  Plan({
    required this.id,
    required this.weekDay,
    required this.dosages,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    var dosagesJson = json['dosages'] as List;
    List<Dosage> dosageList =
        dosagesJson.map((i) => Dosage.fromJson(i)).toList();

    return Plan(
      id: json['id'],
      weekDay: WeekDayExtension.fromString(json['weekDay']),
      dosages: dosageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekDay': weekDay.toString().split('.').last,
      'dosages': dosages.map((d) => d.toJson()).toList(),
    };
  }
}

class Medicine {
  final String id;
  final String name;
  final String description;
  final bool archived;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool hasNotifications;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Plan> plans;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.archived,
    required this.startedAt,
    required this.endedAt,
    required this.hasNotifications,
    this.createdAt,
    this.updatedAt,
    required this.plans,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    var plansJson = json['plans'] as List;
    List<Plan> plansList = plansJson.map((i) => Plan.fromJson(i)).toList();

    return Medicine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      archived: json['archived'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: DateTime.parse(json['endedAt']),
      hasNotifications: json['hasNotifications'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      plans: plansList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'archived': archived,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'hasNotifications': hasNotifications,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'plans': plans.map((p) => p.toJson()).toList(),
    };
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';

class MedicinePage {
  final int totalPages;
  final int totalElements;
  final List<Medicine> content;
  final int number;

  MedicinePage({
    required this.totalPages,
    required this.totalElements,
    required this.content,
    required this.number,
  });

  factory MedicinePage.fromJson(Map<String, dynamic> json) {
    return MedicinePage(
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      content:
          (json['content'] as List)
              .map((item) => Medicine.fromJson(item))
              .toList(),
      number: json['number'],
    );
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Plan> plans;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.archived,
    required this.startedAt,
    required this.endedAt,
    required this.hasNotifications,
    required this.createdAt,
    required this.updatedAt,
    required this.plans,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
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
      plans:
          (json['plans'] as List).map((item) => Plan.fromJson(item)).toList(),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'plans': plans.map((plan) => plan.toJson()).toList(),
    };
  }
}

class Plan {
  final String id;
  final String weekDay;
  final List<Dosage> dosages;

  Plan({required this.id, required this.weekDay, required this.dosages});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      weekDay: json['weekDay'],
      dosages:
          (json['dosages'] as List)
              .map((item) => Dosage.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekDay': weekDay,
      'dosages': dosages.map((dosage) => dosage.toJson()).toList(),
    };
  }
}

class Dosage {
  final String id;
  final DateTime time;
  final int dosage;

  Dosage({required this.id, required this.time, required this.dosage});

  factory Dosage.fromJson(Map<String, dynamic> json) {
    return Dosage(
      id: json['id'],
      time: DateTime.parse(json['time']),
      dosage: json['dosage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'time': time.toIso8601String(), 'dosage': dosage};
  }
}

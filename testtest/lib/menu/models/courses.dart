import 'package:flutter/material.dart';
import 'package:mentara/menu/assets.dart' as app_assets;
import 'package:mentara/services/resource/resource_model.dart';

class CourseModel {
  CourseModel({
    this.id,
    this.title = "",
    this.subtitle = "",
    this.caption = "",
    this.color = Colors.white,
    this.image = "",
    this.category = ResourceType.OTHER, // Default category
  });

  UniqueKey? id = UniqueKey();
  String title, caption, image;
  String? subtitle;
  Color color;
  ResourceType category; // New key for resource category

  static List<CourseModel> courses = [
    CourseModel(
      title: "Animations in SwiftUI",
      subtitle: "Build and animate an iOS app from scratch",
      caption: "20 sections - 3 hours",
      color: const Color(0xFF7850F0),
      image: app_assets.topic_1,
    ),
    CourseModel(
      title: "Build Quick Apps with SwiftUI",
      subtitle:
          "Apply your Swift and SwiftUI knowledge by building real, quick and various applications from scratch",
      caption: "47 sections - 11 hours",
      color: const Color(0xFF6792FF),
      image: app_assets.topic_2,
    ),
    CourseModel(
      title: "Build a SwiftUI app for iOS 15",
      subtitle:
          "Design and code a SwiftUI 3 app with custom layouts, animations and gestures using Xcode 13, SF Symbols 3, Canvas, Concurrency, Searchable and a whole lot more",
      caption: "21 sections - 4 hours",
      color: const Color(0xFF005FE7),
      image: app_assets.topic_1,
    ),
  ];

  static List<CourseModel> courseSections = [
    CourseModel(
      title: "State Machine",
      caption: "Watch video - 15 mins",
      color: const Color(0xFF9CC5FF),
      category: ResourceType.ARTICLE, // Random category
    ),
    CourseModel(
      title: "Animated Menu",
      caption: "Watch video - 10 mins",
      color: const Color(0xFF6E6AE8),
      category: ResourceType.CARE, // Random category
    ),
    CourseModel(
      title: "Tab Bar",
      caption: "Watch video - 8 mins",
      color: const Color(0xFF005FE7),
      category: ResourceType.EXERCISE, // Random category
    ),
    CourseModel(
      title: "Button",
      caption: "Watch video - 9 mins",
      color: const Color(0xFFBBA6FF),
      category: ResourceType.MUSIC, // Random category
    ),
    CourseModel(
      title: "State Machine",
      caption: "Watch video - 15 mins",
      color: const Color(0xFF9CC5FF),
      category: ResourceType.OTHER, // Random category
    ),
    CourseModel(
      title: "Animated Menu",
      caption: "Watch video - 10 mins",
      color: const Color(0xFF6E6AE8),
      category: ResourceType.PHRASE, // Random category
    ),
    CourseModel(
      title: "Tab Bar",
      caption: "Watch video - 8 mins",
      color: const Color(0xFF005FE7),
      category: ResourceType.PODCAST, // Random category
    ),
    CourseModel(
      title: "Button",
      caption: "Watch video - 9 mins",
      color: const Color(0xFFBBA6FF),
      category: ResourceType.RECIPE, // Random category
    ),
    CourseModel(
      title: "State Machine",
      caption: "Watch video - 15 mins",
      color: const Color(0xFF9CC5FF),
      category: ResourceType.SOS, // Random category
    ),
    CourseModel(
      title: "Animated Menu",
      caption: "Watch video - 10 mins",
      color: const Color(0xFF6E6AE8),
      category: ResourceType.VIDEO, // Random category
    ),
  ];

  // Function to map ResourceType to image paths
  static String getImageForResourceType(ResourceType type) {
    switch (type) {
      case ResourceType.ARTICLE:
        return 'assets/images/resources/newspaper.png';
      case ResourceType.VIDEO:
        return 'assets/images/resources/video.png';
      case ResourceType.PODCAST:
        return 'assets/images/resources/recording.png';
      case ResourceType.PHRASE:
        return 'assets/images/resources/training-phrase.png';
      case ResourceType.CARE:
        return 'assets/images/resources/healthcare.png';
      case ResourceType.EXERCISE:
        return 'assets/images/resources/physical-wellbeing.png';
      case ResourceType.RECIPE:
        return 'assets/images/resources/recipe.png';
      case ResourceType.MUSIC:
        return 'assets/images/resources/headphones.png';
      case ResourceType.SOS:
        return 'assets/images/resources/sos.png';
      case ResourceType.OTHER:
        return 'assets/images/resources/other.png';
      default:
        return 'assets/samples/ui/rive_app/images/topics/topic_1.png';
    }
  }

  // Function to assign images to all courses
  static void assignImagesToCourses() {
    for (var course in courses) {
      course.image = getImageForResourceType(course.category);
    }
    for (var course in courseSections) {
      course.image = getImageForResourceType(course.category);
    }
  }
}

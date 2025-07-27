import 'package:mentara/services/activity/activity_service.dart';
import 'package:mentara/services/activity/activity_model.dart';

class ActivityRepository {
  final ActivityService _activityService = ActivityService();

  Future<ActivityPage> getActivitiesByUserId(
    int page,
    int size,
    String searchQuery,
  ) async {
    try {
      final activityPage = await _activityService.fetchActivities(
        page: page,
        size: size,
        searchQuery: searchQuery,
      );
      return activityPage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Activity> getActivityById(String id) async {
    try {
      final activity = await _activityService.fetchActivityById(id);
      return activity;
    } catch (e) {
      rethrow;
    }
  }
}

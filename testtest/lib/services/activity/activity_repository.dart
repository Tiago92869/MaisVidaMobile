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
      print('Fetching activities by user ID...');
      final activityPage = await _activityService.fetchActivities(
        page: page,
        size: size,
        searchQuery: searchQuery,
      );
      print('Fetched ${activityPage.content.length} activities on page $page.');
      return activityPage;
    } catch (e) {
      print('Error fetching activities by user ID: $e');
      rethrow;
    }
  }

  Future<Activity> getActivityById(String id) async {
    try {
      print('Fetching activity with ID: $id...');
      final activity = await _activityService.fetchActivityById(id);
      print('Fetched activity: ${activity.toString()}');
      return activity;
    } catch (e) {
      print('Error fetching activity with ID $id: $e');
      rethrow;
    }
  }
}

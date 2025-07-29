import 'package:mentara/services/journey/journey_service.dart';
import 'package:mentara/services/journey/journey_model.dart';

class JourneyRepository {
  final JourneyService _journeyService = JourneyService();

  // Fetch all journeys for the current user
  Future<List<JourneySimpleUser>> getAllJourneys() {
    return _journeyService.getAllJourneys();
  }

  // Fetch detailed progress for a specific journey
  Future<UserJourneyProgress> getJourneyDetails(String journeyId) {
    return _journeyService.getJourneyDetails(journeyId);
  }

  // Update user journey progress
  Future<UserJourneyProgress> editUserJourneyProgress(
      String userJourneyResourceProgressId,
      UpdateUserJourneyResourceProgress progress) {
    return _journeyService.editUserJourneyProgress(
        userJourneyResourceProgressId, progress);
  }

  // Start a journey for the current user
  Future<UserJourneyProgress> startJourneyForUser(String journeyId) {
    return _journeyService.startJourneyForUser(journeyId);
  }
}
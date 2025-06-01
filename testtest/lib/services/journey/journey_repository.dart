import 'package:testtest/services/journey/journey_service.dart';
import 'package:testtest/services/journey/journey_model.dart';

class JourneyRepository {
  final JourneyService _journeyService = JourneyService();

  // Fetch all journeys for the current user
  Future<List<JourneySimpleUser>> getAllJourneys() {
    print('JourneyRepository: Fetching all journeys');
    return _journeyService.getAllJourneys();
  }

  // Fetch detailed progress for a specific journey
  Future<UserJourneyProgress> getJourneyDetails(String journeyId) {
    print('JourneyRepository: Fetching details for journey $journeyId');
    return _journeyService.getJourneyDetails(journeyId);
  }

  // Update user journey progress
  Future<UserJourneyProgress> editUserJourneyProgress(
      String userJourneyResourceProgressId,
      UserJourneyResourceProgress progress) {
    print(
        'JourneyRepository: Updating progress for resource $userJourneyResourceProgressId');
    return _journeyService.editUserJourneyProgress(
        userJourneyResourceProgressId, progress);
  }

  // Start a journey for the current user
  Future<UserJourneyProgress> startJourneyForUser(String journeyId) {
    print('JourneyRepository: Starting journey for user with ID $journeyId');
    return _journeyService.startJourneyForUser(journeyId);
  }
}
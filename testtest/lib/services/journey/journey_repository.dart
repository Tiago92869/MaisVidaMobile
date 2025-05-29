import 'package:testtest/services/journey/journey_service.dart';
import 'package:testtest/services/journey/journey_model.dart';

class JourneyRepository {
  final JourneyService _journeyService = JourneyService();

  Future<Journey> getJourneyById(String id) {
    return _journeyService.getJourneyById(id);
  }

  Future<List<Journey>> getAllJourneys(int page, int size) {
    return _journeyService.getAllJourneys(page, size);
  }

  Future<Journey> createJourney(Journey journey) {
    return _journeyService.createJourney(journey);
  }

  Future<void> deleteJourney(String id) {
    return _journeyService.deleteJourney(id);
  }
}
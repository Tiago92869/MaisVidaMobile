import 'package:testtest/services/feedback/feedback_model.dart';
import 'package:testtest/services/feedback/feedback_service.dart';

class FeedbackRepository {
  final FeedbackService _feedbackService = FeedbackService();

  Future<Feedback> createFeedback(Feedback feedback) async {
    try {
      return await _feedbackService.createFeedback(feedback);
    } catch (e) {
      rethrow;
    }
  }

  Future<Feedback> updateFeedback(Feedback feedback) async {
    try {
      return await _feedbackService.updateFeedback(feedback);
    } catch (e) {
      rethrow;
    }
  }

  Future<Feedback> getFeedbackByResource(String resourceId) async {
    try {
      return await _feedbackService.getFeedbackByResource(resourceId);
    } catch (e) {
      rethrow;
    }
  }
}

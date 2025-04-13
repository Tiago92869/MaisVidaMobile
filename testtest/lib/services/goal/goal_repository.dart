import 'package:testtest/services/goal/goal_service.dart';
import 'package:testtest/services/goal/goal_model.dart';

class GoalRepository {
  final GoalService _goalService = GoalService();

  Future<List<GoalDay>> getGoals(
    bool isCompleted,
    DateTime startDate,
    DateTime endDate,
    List<GoalSubject> goalSubjects,
    int page,
    int size,
  ) {
    return _goalService.fetchGoals(
      isCompleted,
      startDate,
      endDate,
      goalSubjects,
    );
  }

  Future<GoalInfoCard> addGoal(GoalInfoCard goal) {
    return _goalService.createGoal(goal);
  }

  Future<GoalInfoCard> modifyGoal(String id, GoalInfoCard goal) {
    return _goalService.updateGoal(id, goal);
  }

  Future<void> removeGoal(String id) {
    return _goalService.deleteGoal(id);
  }
}

import 'package:testtest/services/goal/goal_service.dart';
import 'package:testtest/services/goal/goal_model.dart';

class GoalRepository {
  final GoalService _goalService = GoalService();

  Future<PagezGoalsDTO> getGoals(
    bool? isCompleted,
    DateTime startDate,
    DateTime endDate,
    List<GoalSubject> goalSubjects, {
    int page = 0,
    int size = 10,
  }) {
    return _goalService.fetchGoals(
      isCompleted,
      startDate,
      endDate,
      goalSubjects,
      page: page,
      size: size,
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

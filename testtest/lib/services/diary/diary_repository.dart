import 'package:testtest/services/diary/diary_service.dart';

import 'diary_model.dart';

class DiaryRepository {
  final DiaryService _diaryService = DiaryService();

  Future<List<DiaryDay>> fetchDiaries(
      List<DiaryType> emotions, DateTime startDate, DateTime endDate) {
    print('DiaryRepository: Fetching diaries');
    return _diaryService.fetchDiaries(emotions, startDate, endDate);
  }

  Future<Diary> createDiary(Diary diary) {
    print('DiaryRepository: Creating diary with data: ${diary.toJson()}');
    return _diaryService.createDiary(diary);
  }

  Future<Diary> updateDiary(String id, Diary diary) {
    print(
        'DiaryRepository: Updating diary with id: $id and data: ${diary.toJson()}');
    return _diaryService.updateDiary(id, diary);
  }

  Future<void> deleteDiary(String id) {
    print('DiaryRepository: Deleting diary with id: $id');
    return _diaryService.deleteDiary(id);
  }
}

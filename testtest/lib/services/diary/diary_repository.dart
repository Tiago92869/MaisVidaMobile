import 'package:mentara/services/diary/diary_service.dart';

import 'diary_model.dart';

class DiaryRepository {
  final DiaryService _diaryService = DiaryService();

  Future<List<DiaryDay>> fetchDiaries(
      List<DiaryType> emotions, DateTime startDate, DateTime endDate) {
    return _diaryService.fetchDiaries(emotions, startDate, endDate);
  }

  Future<Diary> createDiary(Diary diary) {
    return _diaryService.createDiary(diary);
  }

  Future<Diary> updateDiary(String id, Diary diary) {
    return _diaryService.updateDiary(id, diary);
  }

  Future<void> deleteDiary(String id) {
    return _diaryService.deleteDiary(id);
  }
}


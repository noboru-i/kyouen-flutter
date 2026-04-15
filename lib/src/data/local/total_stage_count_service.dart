import 'package:shared_preferences/shared_preferences.dart';

class TotalStageCountService {
  static const _keyTotalStageCount = 'total_stage_count';

  Future<int?> getCachedTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalStageCount);
  }

  Future<void> saveTotalCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalStageCount, count);
  }
}

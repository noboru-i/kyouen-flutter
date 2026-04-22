import 'package:shared_preferences/shared_preferences.dart';

class ClearedStageCountService {
  static const _key = 'cleared_stage_count';

  Future<int?> getRawCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key);
  }

  Future<void> saveCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, count);
  }

  Future<void> increment() async {
    final current = await getRawCount() ?? 0;
    await saveCount(current + 1);
  }
}

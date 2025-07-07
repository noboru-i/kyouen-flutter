import 'package:shared_preferences/shared_preferences.dart';

class LastStageService {
  static const _keyLastStageNo = 'last_stage_no';

  Future<int?> getLastStageNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastStageNo);
  }

  Future<void> saveLastStageNo(int stageNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastStageNo, stageNo);
  }
}

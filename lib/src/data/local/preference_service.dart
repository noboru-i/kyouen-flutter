import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage local preferences using SharedPreferences
class PreferenceService {
  const PreferenceService(this._prefs);

  final SharedPreferences _prefs;

  // Key constants - matching Android implementation
  static const String _keyLastStageNo = 'last_stage_no';

  /// Get the last opened stage number, defaults to 1 if not set
  int getLastStageNo() {
    return _prefs.getInt(_keyLastStageNo) ?? 1;
  }

  /// Save the last opened stage number
  Future<void> setLastStageNo(int stageNo) async {
    await _prefs.setInt(_keyLastStageNo, stageNo);
  }
}

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for PreferenceService
final preferenceServiceProvider = FutureProvider<PreferenceService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return PreferenceService(prefs);
});
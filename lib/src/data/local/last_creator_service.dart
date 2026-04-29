import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'last_creator_service.g.dart';

class LastCreatorService {
  static const _key = 'last_creator';

  Future<String?> getLastCreator() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> saveLastCreator(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value);
  }
}

@riverpod
LastCreatorService lastCreatorService(Ref ref) => LastCreatorService();

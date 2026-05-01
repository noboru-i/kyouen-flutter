import 'package:web/web.dart' as web;

void updateStageUrl(int stageNo) {
  web.window.history.replaceState(null, '', '/stage?stage=$stageNo');
}

import 'package:web/web.dart' as web;

String? getConsentStorage(String key) => web.window.localStorage.getItem(key);
void setConsentStorage(String key, String value) =>
    web.window.localStorage.setItem(key, value);

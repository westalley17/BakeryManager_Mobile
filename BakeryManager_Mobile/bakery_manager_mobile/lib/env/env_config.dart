import 'dart:io';

import 'mobile_env.dart' as android_env;
import 'web_env.dart' as web_env;
import 'windows_env.dart' as windows_env;

String get baseURL {
  if (Platform.isAndroid || Platform.isIOS) {
    return android_env.baseUrl;
  } else if (Platform.isWindows) {
    return windows_env.baseUrl;
  }
  // You can add other platform checks if needed
  return web_env.baseUrl;
}

import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/config.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Config config = Config();
  static Future<AppState> init() async {
    String apppath = "";
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      apppath = dirname(Platform.script.toFilePath());
    } else {
      var dir = await getApplicationSupportDirectory();
      apppath = dir.path;
    }
    print(apppath);
    var state = AppState();
    return state;
  }
}

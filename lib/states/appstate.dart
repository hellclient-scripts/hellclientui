import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/config.dart';
import '../models/server.dart';
import '../models/rendersettings.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Config config = Config();
  String settingsPath = "";
  RenderSettings renderSettings = RenderSettings();
  int currentPage = 0;
  Server? currentServer;
  static Future<AppState> init() async {
    var state = AppState();
    String apppath = "";
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      apppath = dirname(Platform.script.toFilePath());
    } else {
      var dir = await getApplicationSupportDirectory();
      apppath = join(dir.path, "hellclientui");
    }
    state.settingsPath = join(apppath, "settings.json");
    print(join(apppath, "settings.json"));
    final file = File(state.settingsPath);
    if (await file.exists()) {
      final Map<String, dynamic> config =
          json.decode(await file.readAsString());
      state.config = Config.fromJson(config);
    } else {
      await state.save();
    }
    return state;
  }

  Future save() async {
    var data = jsonEncode(config);
    final file = File(settingsPath);
    file.writeAsStringSync(data);
  }

  Future<bool> addServer(Server server) {
    config.servers.add(server);
    save();
    notifyListeners();
    return Future<bool>.value(true);
  }
}

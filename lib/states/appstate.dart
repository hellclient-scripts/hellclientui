import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/config.dart';
import '../models/connecting.dart';
import '../models/server.dart';
import '../models/rendersettings.dart';
import 'package:flutter/material.dart';

late AppState currentAppState;

class AppState extends ChangeNotifier {
  Config config = Config();
  String settingsPath = "";
  String colorConfigPath = "";
  final connecting = Connecting();
  late double devicePixelRatio;
  RenderSettings renderSettings = RenderSettings();
  RenderConfig renderConfig = RenderConfig();
  int currentPage = 0;
  bool showMore = true;
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
    final file = File(state.settingsPath);
    if (await file.exists()) {
      final Map<String, dynamic> config =
          json.decode(await file.readAsString());
      state.config = Config.fromJson(config);
    } else {
      await state.save();
    }
    state.colorConfigPath = join(apppath, "colors.json");

    final colorfile = File(state.colorConfigPath);

    if (await colorfile.exists()) {
      final Map<String, dynamic> config =
          json.decode(await colorfile.readAsString());
      state.renderConfig = RenderConfig.fromJson(config);
    } else {
      await state.saveColors();
    }
    state.renderSettings = state.renderConfig.getSettings();
    return state;
  }

  Future save() async {
    var data = jsonEncode(config);
    final file = File(settingsPath);
    final folder = dirname(settingsPath);
    await Directory(folder).create(recursive: true);
    file.writeAsStringSync(data);
  }

  Future saveColors() async {
    var data = jsonEncode(renderConfig);
    final file = File(colorConfigPath);
    file.writeAsStringSync(data);
  }

  Future<bool> addServer(Server server) {
    config.servers.add(server);
    save();
    notifyListeners();
    return Future<bool>.value(true);
  }

  Future<bool> removeServer(Server server) {
    if (config.servers.remove(server)) {
      save();
      notifyListeners();
      return Future<bool>.value(true);
    }
    return Future<bool>.value(false);
  }

  void updated() {
    notifyListeners();
  }
}
